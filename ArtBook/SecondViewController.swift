//
//  SecondViewController.swift
//  ArtBook
//
//  Created by Can Kanbur on 30.03.2023.
//

import CoreData
import UIKit

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var yearTextField: UITextField!
    @IBOutlet var artistTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    var chosenPainting = ""
    var chosenPaintingID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context  = appDelegate.persistentContainer.viewContext
            let idString = chosenPaintingID?.uuidString
            
            let fetxhRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetxhRequest.predicate = NSPredicate(format: "id = %@ ", idString!)
            fetxhRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetxhRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameTextField.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistTextField.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearTextField.text = "\(year)"
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
                
            }catch{
                
            }
            
            
            
            
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameTextField.text = ""
            artistTextField.text = ""
            yearTextField.text = ""
            
        }
        

        let tabGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tabGesture)

        imageView.isUserInteractionEnabled = true
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGesture)
    }

    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)

        newPainting.setValue(nameTextField.text!, forKey: "name")
        newPainting.setValue(artistTextField.text!, forKey: "artist")

        if let year = Int(yearTextField.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
        }catch{
            print("error")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }

    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
