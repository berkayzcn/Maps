//
//  ViewController.swift
//  MAPS.try
//
//  Created by Berkay Ozcan on 25/03/2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
   
    @IBOutlet weak var notTextField: UITextField!
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationMananger = CLLocationManager()
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    
    //veri aktarma ic.tabledan tiklaninca segue yapmak icin degisken olusturuyoruz
    var secilenIsim = ""
    var secilenId : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationMananger.delegate = self
         
        locationMananger.desiredAccuracy = kCLLocationAccuracyBest
        locationMananger.requestWhenInUseAuthorization()
        locationMananger.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumsec(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        //VERI AKTARMA tabledan tiklaninca veri ayrintilarini gostermek icin
        if secilenIsim != "" {  //SECILENISIM BOSDEGILSE YANI TABLE DAN BIR ROW A TIKLAYARAK GELINDIYSE
             
            if let uuidString = secilenId?.uuidString { //uuid yi string olarak gostermek ve veriyi cekmek
                //FILTRELEYEREK VERI CEKIYORUZ
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString) //id ye gore filtreleme islemi id si uuidString e esit olanlari getir
                fetchRequest.returnsObjectsAsFaults = false
            
                do{
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject]{
                            
                            if let isim = sonuc.value(forKey: "isim") as? String {
                                annotationTitle = isim
                                if let not = sonuc.value(forKey: "not") as? String {
                                    annotationSubtitle = not
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double {
                                        annotationLatitude = latitude
                                        if let longitude = sonuc.value(forKey: "longitude") as? Double {
                                            annotationLongitude = longitude
                                            
                                            //koordinatlarla annotion olusturuyoruz
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = coordinate
                                            
                                            mapView.addAnnotation(annotation)
                                            isimTextField.text = annotationTitle
                                            notTextField.text = annotationSubtitle
                                            
                                            //anootionun yani koordinatin oldugu yeri gostermesi icin kendi bulundugumuz konumu iptal ediyoruz
                                            locationMananger.stopUpdatingLocation() //GUNCELLMEYI BIRAK DIYORUZ
                                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }catch{
                }
            }
        }else{ //bos ise yeni veri eklemeye geldi demektir yani + ya tiklanmistir
            
        }
        
    }
    
   /* func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        <#code#>
    }*/
        
        @objc func konumsec(gestureRecognizer : UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let dokunulanNokta = gestureRecognizer.location(in: mapView)
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
      
            //koordinatlari dataya set etmek icin degiskene atioruz
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            
            //dokunulan noktayi koordinat a cevirip noktayayla eslioyurz
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat
            annotation.title = isimTextField.text
            annotation.subtitle = notTextField.text
            mapView.addAnnotation(annotation)
        }
         
    }
    //kendi konumumuz guncellenince ne olacagi
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       //print(locations[0].coordinate.latitude)
       //print(locations[0].coordinate.longitude)
        if secilenIsim == "" { //   YANI TABLE DAN BIR KONUM GOSTER DEMEDIYSEK KENDI KONUMUMUZU GORELIM
            let locationOlustur = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: locationOlustur, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //nsentity ile taninlicaz giricez sonrada context ile save
    @IBAction func kaydetTiklandi(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let kayityericontext = appDelegate.persistentContainer.viewContext
        
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: kayityericontext)//context icine kaydediyoruz
        
        yeniYer.setValue(isimTextField.text, forKey: "isim")
        yeniYer.setValue(notTextField.text, forKey: "not")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        do{
            try kayityericontext.save()
            print("kayit edildi")
        }catch{
            print("hata")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("konumGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}

