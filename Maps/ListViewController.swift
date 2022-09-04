//
//  ListViewController.swift
//  Maps
//
//  Created by Berkay Ozcan on 31/08/2022.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableVC: UITableView!
    
    var isimdizisi = [String]()
    var idDizisi = [UUID]()
    
    var secilenYer = ""
    var secilenID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableVC.delegate = self
        tableVC.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(artiButonuTiklandi))
        
        veriAl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(veriAl), name: NSNotification.Name("konumGirildi"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimdizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimdizisi[indexPath.row]
        return cell
    }
    
    
    @objc func artiButonuTiklandi(){
        secilenYer = ""
        performSegue(withIdentifier: "toMap", sender: nil)
    }
    
    @objc func veriAl(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
            
        isimdizisi.removeAll(keepingCapacity: false)
        idDizisi.removeAll(keepingCapacity: false)
        
        do{
            let sonuclar = try context.fetch(fetchRequest)
            if sonuclar.count > 0 {
                for sonuc in sonuclar as! [NSManagedObject]{
                    if let isim = sonuc.value(forKey: "isim") as? String{
                        isimdizisi.append(isim)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID{
                        idDizisi.append(id)
                    }
                }
                tableVC.reloadData()
            }
        }catch{
            print("Hata")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenYer = isimdizisi[indexPath.row]
        secilenID = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toMap", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap"{
            let destinationVC = segue.destination as! mapsViewController
            destinationVC.secilmisIsim = secilenYer
            destinationVC.secilmisID = secilenID
        }
    }

}
