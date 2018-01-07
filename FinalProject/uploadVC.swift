//
//  uploadVC.swift
//  FinalProject
//
//  Created by Koral Shmueli on 26/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit

class uploadVC: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var picImage: UIImageView!
    @IBOutlet weak var titleText: UITextView!
    @IBOutlet weak var publishButton: UIButton!
    
    var selectedImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disable publish button
        publishButton.isEnabled = false
        publishButton.backgroundColor = .lightGray
        
        //hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self , action: "hideKeyboardTap")
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //select image tap
        let picTap = UITapGestureRecognizer(target: self , action : "selectImage")
        picTap.numberOfTapsRequired = 1
        picImage.isUserInteractionEnabled = true
        picImage.addGestureRecognizer(picTap)

    }
    
    //hide keyboard function
    func hideKeyboardTap() {
        self.view.endEditing(true)
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
        self.picImage.image = selectedImage
        self.dismiss(animated: true, completion: nil);
        
        //enable publish button
        publishButton.isEnabled = true
        publishButton.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        //implement second tap for zooming image
        let zoomTap = UITapGestureRecognizer(target : self , action : "zoomImage")
        zoomTap.numberOfTapsRequired = 1
        picImage.isUserInteractionEnabled = true
        picImage.addGestureRecognizer(zoomTap)
        
    }
    
    /*//////////////////////sirton 45 daka 13:42
     //zooming in or out function
    func zoomImage(){
        let zoomed = CGRect
    }
*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
