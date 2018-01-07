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
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var fullNameTxt: UITextField!
    @IBOutlet weak var aboutMeTxt: UITextView!
    @IBOutlet weak var titleLbl:UILabel!
    @IBOutlet weak var telTxt: UITextField!
    @IBOutlet weak var genderTxt: UITextField!
    
    //button

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var EditScrollView: UIScrollView!
    @IBOutlet weak var EditContentView: UIView!
    
    //pickerView & pickerData
    var genderPicker: UIPickerView!
    var imageUrl:String?
    var selectedImage:UIImage?
    let genders = ["male","female"]
    
 
    override func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()
        
        //round ava
        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2
        self.imageProfile.clipsToBounds = true
        
        //declare select image tap
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.loadImg))
        avaTap.numberOfTapsRequired = 1
        self.imageProfile.isUserInteractionEnabled = true
        self.imageProfile.addGestureRecognizer(avaTap)
        
        //background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.EditContentView.addSubview(bg)
        
        //create picker
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        initiliaze()
        
    }
    
    
    public func initiliaze()
    {   print("initiliaze")
        Model.instance.loggedinUser { (uID) in
            if(uID != nil)
            {   print("uid ok")
                Model.instance.getUserById(id: uID!, callback: { (user) in
                    
                    if(!(user?.imageUrl?.isEmpty)!)
                    {
                        Model.instance.getImage(urlStr: (user?.imageUrl)!, callback: { (image) in
                            
                            
                            self.imageProfile.image = image
                            self.fullNameTxt.text?.append((user?.fullName)!)
                            if(user?.gender != nil)
                            {
                                self.genderTxt.text = user?.gender
                            }
                            if(user?.phone != nil)
                            {
                                self.telTxt.text?.append((user?.phone)!)
                            }
                            super.viewDidLoad()
                        })
                    }
                    else
                    {
                        
                        
                        self.fullNameTxt.text = user?.fullName
                        if(user?.gender != nil)
                        {
                            self.genderTxt.text = user?.gender
                        }
                        if(user?.phone != nil)
                        {
                            self.telTxt.text = user?.phone
                        }
                        super.viewDidLoad()
                        
                    }
                })
            }
        }
        
    }
    
    
    //call picker to select image
    public func loadImg(recognizer: UITapGestureRecognizer)
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        //let image = info["UIImagePickerControllerEditedImage"] as? UIImage
        selectedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        self.imageProfile.image = selectedImage
        self.dismiss(animated: true, completion: nil);
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
