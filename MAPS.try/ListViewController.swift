//
//  ViewController.swift
//  MAPS.try
//
//  Created by Berkay Ozcan on 26/03/2022.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    
    //table da row at tiklandginda veri aktarimi icin segue icin
    var secilenYerIsmi = ""
    var secilenYerId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(artiButonuTiklandi))
        
        veriAl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(veriAl), name: NSNotification.Name(rawValue: "konumGirildi"), object: nil)
    }
    
    
    @objc func veriAl() {
        //listeye her veri eklendiginde oncekilerle beraber iki kez gostermesin diye siliyoruz
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
    
        let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        
        do{
           let sonuclar = try context.fetch(fetchrequest)
            
            //sonuckar dizi halinde any olarak geliyor nsmanagedobject seklinde istedigimiz icin ceviriyoruz
            if sonuclar.count > 0 {
                
                isimDizisi.removeAll(keepingCapacity: false)
                idDizisi.removeAll(keepingCapacity: false)
                
                for sonuc in sonuclar as! [NSManagedObject] {
                   // sonuc.value(forKey: "isim")
                   //string yapmak icin
                    if let isim = sonuc.value(forKey: "isim") as? String{ //sonra stringe e cevriyoruz ve bir isim dizisine kaydediyoruz
                        isimDizisi.append(isim)
                    }
                    //TABLEVIEW DE GOSTEREBILMEK ICIN ALDIGIMIZ VERILERIZ DIZILERE APPENDE EDIYORUZ
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
                }
                tableView.reloadData() //tableview i yeniliyor her yeni dizi geldiginde
            }
        
        
        }catch{
            print("hata")
        }
        
        
    
    }
    
    @objc func artiButonuTiklandi(){
        secilenYerIsmi = "" //+ ya basip segue yapildiginda bos oldugu belli olsunki else ye girip veri ekleme oldgu belli olsun
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        return cell
    }
    
    //table da bir row a tiklandiginda
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenYerIsmi = isimDizisi[indexPath.row]
        secilenYerId = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinaitonVC = segue.destination as! MapsViewController
            destinaitonVC.secilenIsim = secilenYerIsmi
            destinaitonVC.secilenId = secilenYerId
        }
    }
}
