//
//  ViewController.swift
//  Maps
//
//  Created by Berkay Ozcan on 12/08/2022.

import UIKit
import MapKit
import CoreLocation
import CoreData

class mapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var isimText: UITextField!
    @IBOutlet weak var notText: UITextField!
    
    var locationManager = CLLocationManager()
    
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    
    var secilmisIsim = ""
    var secilmisID : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRC:)))
        gestureRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if secilmisIsim != ""{
            if let uuidString = secilmisID?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                
                do{
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject]{
                            
                            if let isim = sonuc.value(forKey: "isim") as? String{
                                annotationTitle = isim
                                if let not = sonuc.value(forKey: "not") as? String{
                                    annotationSubtitle = not
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double{
                                        annotationLatitude = latitude
                                        if let longitude = sonuc.value(forKey: "longitude") as? Double{
                                            annotationLongitude = longitude
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = coordinate
                                            
                                            mapView.addAnnotation(annotation)
                                            isimText.text = annotationTitle
                                            notText.text = annotationSubtitle
                                            
                                            locationManager.stopUpdatingLocation()
                                            
                                            let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                                            //let secilenKoordinat = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }catch{
                    print("Hata")
                }
            }
        }else{
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let resueId = "benimAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: resueId)
       
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: resueId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }else{
            pinView?.annotation = annotation
        }
            return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if secilmisIsim != "" {
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placeMarkDizisi, hata in
                if let placemarks = placeMarkDizisi{
                    if placemarks.count > 0 {
                        let yeniPlacemark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: yeniPlacemark)
                        item.name = self.annotationTitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if secilmisIsim == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 0.6)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @objc func konumSec(gestureRC : UILongPressGestureRecognizer){
        if gestureRC.state == .began {
            let dokunulanNokta = gestureRC.location(in: mapView)
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat
            annotation.title = isimText.text
            annotation.subtitle = notText.text
            mapView.addAnnotation(annotation)
            
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
        }
    }
    
    
    @IBAction func kaydetTiklandi(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        
        yeniYer.setValue(isimText.text, forKey: "isim")
        yeniYer.setValue(notText.text, forKey: "not")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("kayit edildi")
        }catch{
            print("hata")
        }

        NotificationCenter.default.post(name: NSNotification.Name("konumGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

