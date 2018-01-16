//
//  SignUpVC.swift
//  FinalProject
//
//  Created by Romano on 07/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    var spinner: UIActivityIndicatorView?
    var imageUrl:String?
    var selectedImage:UIImage?
    var checkIfExist:String?
    //profile image
    @IBOutlet weak var SignUpAvaImg: UIImageView!
    
    //text fields
    @IBOutlet weak var SignUpPasswordTxt: UITextField!
    @IBOutlet weak var SignUpRepeatPasswordTxt: UITextField!
    @IBOutlet weak var SignUpFullnameTxt: UITextField!
    @IBOutlet weak var SignUpEmailTxt: UITextField!
    @IBOutlet weak var SignUpUserNameTxt: UITextField!
   
    
    //buttons
    @IBOutlet weak var SignUpSignUpBtn: UIButton!
    @IBOutlet weak var SignUpCancelBtn: UIButton!

    //scroll view
    @IBOutlet weak var SignUpScrollView: UIScrollView!
    @IBOutlet weak var SignUpContentView: UIView!
    
    //reset default size
    var SignUpScrollViewHeight : CGFloat = 0
    
    //keyboard frame size
    var keyboard = CGRect()
    

    //default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //spinner configuration
        spinner = UIActivityIndicatorView()
        spinner?.center = self.view.center
        spinner?.hidesWhenStopped = true
        spinner?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(spinner!)
        
        
        //round ava
        SignUpAvaImg.layer.cornerRadius = SignUpAvaImg.frame.size.width / 2
        SignUpAvaImg.clipsToBounds = true
        
        //declare select image tap
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.loadImg))
        avaTap.numberOfTapsRequired = 1
        SignUpAvaImg.isUserInteractionEnabled = true
        SignUpAvaImg.addGestureRecognizer(avaTap)
        
        //background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
          bg.layer.zPosition = -1
        self.SignUpContentView.addSubview(bg)
        
       
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
        self.SignUpAvaImg.image = selectedImage
        self.dismiss(animated: true, completion: nil);
    }

    @IBAction func SignUpBtn_click(_ sender: Any) {
        if (SignUpEmailTxt.text!.isEmpty || SignUpPasswordTxt.text!.isEmpty || SignUpUserNameTxt.text!.isEmpty || SignUpRepeatPasswordTxt.text!.isEmpty || SignUpFullnameTxt.text!.isEmpty) {
            //show alert massage
            alerts(writeTitle: "Please", writeMessage: "fill in fields")
        }
        else if ((SignUpRepeatPasswordTxt.text!.characters.count) < 6)
        {
            alerts(writeTitle: "Error", writeMessage: "please insert 6 characters password")
        }

        else if(!isValidEmail(testStr: SignUpEmailTxt.text!))
        {
            alerts(writeTitle: "Error", writeMessage: "please insert valid email")
        }
        else if(SignUpPasswordTxt.text != SignUpRepeatPasswordTxt.text)
        {
        //show alert massage
            alerts(writeTitle: "Error", writeMessage: "passwords are not the same")
        }
        else
        {
            self.spinner?.startAnimating()
            Model.instance.checkIfUserExist(userName: SignUpUserNameTxt.text!, email: SignUpEmailTxt.text!, callback: { (answer) in
                self.checkIfExist = answer
                if (self.checkIfExist?.compare("both avail") == ComparisonResult.orderedSame) {
                    if let image = self.selectedImage{
                        Model.instance.saveImage(image: image, name: self.SignUpUserNameTxt.text!){(url) in
                            self.imageUrl = url
                            let user = User(userName: self.SignUpUserNameTxt.text!, fullName: self.SignUpFullnameTxt.text!, imageUrl: self.imageUrl)
                            Model.instance.addUser(user: user, password: self.SignUpPasswordTxt.text!, email: self.SignUpEmailTxt.text!)
                            self.spinner?.stopAnimating()
                            self.resetForm()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
             
                else{
                        let user = User(userName: self.SignUpUserNameTxt.text!, fullName: self.SignUpFullnameTxt.text!)
                        Model.instance.addUser(user: user, password: self.SignUpPasswordTxt.text!, email: self.SignUpEmailTxt.text!)
                        self.spinner?.stopAnimating()
                        self.resetForm()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else if(self.checkIfExist?.compare("both exist") == ComparisonResult.orderedSame){
                    self.spinner?.stopAnimating()
                    self.alerts(writeTitle: "Error", writeMessage: "username and email already taken")
                }
                else if(self.checkIfExist?.compare("username") == ComparisonResult.orderedSame){
                    self.spinner?.stopAnimating()
                    self.alerts(writeTitle: "Error", writeMessage: "username already taken")
                }
                else if(self.checkIfExist?.compare("email") == ComparisonResult.orderedSame){
                    self.spinner?.stopAnimating()
                    self.alerts(writeTitle: "Error", writeMessage: "email already taken")
                }
            })
        
        }
    }

    @IBAction func SignUpCancel_click(_ sender: Any) {
        print("cancel clicked")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func alerts(writeTitle: String, writeMessage: String)
    {
        let alert = UIAlertController(title: writeTitle, message: writeMessage, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetForm()
    {
        self.SignUpAvaImg.image = UIImage(named: "UserPicture")
        self.SignUpEmailTxt.text = nil
        self.SignUpUserNameTxt.text = nil
        self.SignUpPasswordTxt.text = nil
        self.SignUpRepeatPasswordTxt.text = nil
        self.SignUpFullnameTxt.text = nil
    
    }
    
   /* func getUsernameFromEmail(testStr: String) -> String
    {
        var token = testStr.components(separatedBy: "@")
        return (token[0])
    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
