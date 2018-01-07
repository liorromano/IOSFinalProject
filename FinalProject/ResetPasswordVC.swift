//
//  ResetPasswordVC.swift
//  FinalProject
//
//  Created by Romano on 07/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit

class ResetPasswordVC: UIViewController {

    // reset password txt
    @IBOutlet weak var ResetPasswordEmailTxt: UITextField!
    
    //buttons
    @IBOutlet weak var ResetPasswordResetBtn: UIButton!

    @IBOutlet weak var ResetPasswordCancelBtn: UIButton!
    
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }

    
    //reset password clicked
    @IBAction func resetPassword_click(_ sender: Any) {
        
        //hide keyboard
        self.view.endEditing(true)
        
        //email txt field is empty
        if ResetPasswordEmailTxt.text!.isEmpty
        {
            //show alert massage
            let alert = UIAlertController(title: "Email Field", message: "is empty", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            Model.instance.checkEmail(email: ResetPasswordEmailTxt.text!, callback: { (answer) in
                if(answer == true)
                {
                    //show alert massage
                    let alert = UIAlertController(title: "Done", message: "Reset Password email sent", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(ok)
                    self.ResetPasswordEmailTxt.text = nil
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else
                {
        
                    //show alert massage
                    let alert = UIAlertController(title: "Error", message: "wrong email", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        
        
    }
    
    // cacnel clicked
    @IBAction func cancelResetPassword_click(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
