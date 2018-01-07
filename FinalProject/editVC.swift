//
//  editVC.swift
//  FinalProject
//
//  Created by admin on 19/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit

class editVC: UIViewController ,UIPickerViewDelegate,UIPickerViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    //UI objects
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var fullNameTxt: UITextField!
    @IBOutlet weak var aboutMeTxt: UITextView!
    @IBOutlet weak var titleLbl:UILabel!
    @IBOutlet weak var telTxt: UITextField!
    @IBOutlet weak var genderTxt: UITextField!
    
    //pickerView & pickerData
    var genderPicker: UIPickerView!
    let genders = ["male","female"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create picker
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        //tap to choose image
        let avaTap = UITapGestureRecognizer(target: self, action: Selector(("loadImg:")))
        avaTap.numberOfTapsRequired = 1
        imageProfile.isUserInteractionEnabled = true
        imageProfile.addGestureRecognizer(avaTap)
        
        
        
    }
    
    //func to call UIImagePickerController
    func loadImg(recognizer: UITapGestureRecognizer){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    //method to finilize our actions with UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageProfile.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true,completion: nil)
    }
    
    //validate for email textfield
    func validateEmail(email: String) -> Bool{
        let regex = "[A-Z0-9a-z._+-]{4}+@[A-Za-z0-9.-]{2}+\\.[A-Za-z]{2}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true:false
        return result

    }
    
    //alert message function
    func alert(error: String, message: String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true, completion: nil)
    }
    

    //clicked save button
    @IBAction func save_clicked(_ sender: Any) {
            print("save clicked")
    }
    //clicked cancel button
    @IBAction func cancel_clicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    //picker view methods
    //picker comp numb
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //picker text numb
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    //picker text config
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    //picker did selected the some value from it
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        self.view.endEditing(true)
    }
    
}
