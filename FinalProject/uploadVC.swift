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
    var imageUrl:String?
    
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
        
        //declare select image tap
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.loadImg))
        avaTap.numberOfTapsRequired = 1
        picImage.isUserInteractionEnabled = true
        picImage.addGestureRecognizer(avaTap)
        
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
    
    
    //zooming in or out function
    func zoomImage(){
        //define frame of zoomed image
        let zoomed = CGRect(x: 0, y: self.view.center.y-self.view.center.x , width: self.view.frame.size.width ,height: self.view.frame.size.width )
        //frame of unzoomed (small image)
        let unzoomed = CGRect(x: 15, y: self.navigationController!.navigationBar.frame.size.height+35 , width: self.view.frame.size.width/4.5 ,height: self.view.frame.size.width/4.5)
        
        //if picture unzommed, zoom it
        if(picImage.frame == unzoomed){
            //with animation
            UIView.animate(withDuration: 0.3, animations: {()->Void in
                //resize image frame
                self.picImage.frame == zoomed
                
                //hide object of background
                self.view.backgroundColor = .black
                self.titleText.alpha = 0
                self.publishButton.alpha = 0
                
            })
        }
            //to unzoom
        else{
            //with animation
            UIView.animate(withDuration: 0.3, animations: {()->Void in
                //resize image frame
                self.picImage.frame = unzoomed
                
                //unhide object from background
                self.view.backgroundColor = .white
                self.titleText.alpha = 1
                self.publishButton.alpha = 1
            })
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
    //clicked publish button
    @IBAction func publishButton(_ sender: Any) {
        //dissmiss keyboard
        self.view.endEditing(true)
        
        if let image = self.selectedImage{
            
            //save the post to firebase
            Model.instance.loggedinUser(callback: { (userID) in
                Model.instance.getUserById(id: userID!, callback: { (user) in
                    Model.instance.savePostImage(image: image, userName: (user?.userName)!, userID: userID!, postID: (user?.numberOfPosts)!+1, callback: { (url) in
                        self.imageUrl = url
                        let post = Post(userName:(user?.userName)!, imageUrl:self.imageUrl!, uID:userID!, description:self.titleText.text ,postID:(user?.numberOfPosts)!+1)
                        Model.instance.addNewPost(post: post, callback: { (ans) in
                        })
                    })
                })
                
                
            })
            
            
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
}
