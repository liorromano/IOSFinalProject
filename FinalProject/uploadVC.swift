//
//  uploadVC.swift
//  FinalProject
//
//  Created by Koral Shmueli on 26/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit
import CoreLocation

class uploadVC: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var contentStack: UIStackView!
    
      var spinner: UIActivityIndicatorView?
    
    @IBOutlet weak var picImage: UIImageView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var publishButton: UIButton!
    var imageUrl:String?
    
    var selectedImage:UIImage?
    
    let locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingLocation()
        
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
        
      
        //spinner configuration
        spinner = UIActivityIndicatorView()
        spinner?.center = self.picImage.center
        spinner?.hidesWhenStopped = true
        spinner?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        picImage.addSubview(spinner!)
        
        
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

    func getGPSLocation(completion: (_ lat: String, _ lng: String) -> Void) {
        var currentLocation: CLLocation!
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            
            currentLocation = locManager.location
            
            let latitude = String(format: "%.7f", currentLocation.coordinate.latitude)
            let longitude = String(format: "%.7f", currentLocation.coordinate.longitude)
            //let location = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            
            debugPrint("Latitude:", latitude)
            debugPrint("Longitude:", longitude)
            
            completion(latitude, longitude)  // your block of code you passed to this function will run in this way
            
            
        }
    }

    
    //clicked publish button
    @IBAction func publishButton(_ sender: Any) {
        spinner?.startAnimating()
        //dissmiss keyboard
        self.view.endEditing(true)
        
        if let image = self.selectedImage{
            
            //save the post to firebase
            Model.instance.loggedinUser(callback: { (userID) in
                Model.instance.getUserById(id: userID!, callback: { (user) in
                    var postId = String((user?.numberOfPosts)!+1)
                    postId = (user?.uID?.appending(postId))!
                        self.getGPSLocation(completion: { (lat, lang) in
                        print(lat)
                        print(lang)
                        Model.instance.savePostImage(image: image, userName: (user?.userName)!, userID: userID!, postID: (user?.numberOfPosts)!+1, callback: { (url) in
                            self.imageUrl = url
                            let post = Post(userName:(user?.userName)!, imageUrl:self.imageUrl!, uID:userID!, lat: lat ,lang: lang, description:self.titleText.text, postID: postId)
                            Model.instance.addNewPost(post: post, callback: { (ans) in
                                if (ans == true)
                                {
                                    user?.numberOfPosts = (user?.numberOfPosts)!+1
                                    Model.instance.updateUser(user: user!, callback: { (ans) in
                                        if(ans == true)
                                        {
                                            print("true")
                                            self.picImage.image = UIImage(named: "UserPicture")
                                            self.titleText.text = nil
                                            self.spinner?.stopAnimating()
                                            self.tabBarController!.selectedIndex = 0
                                        }
                                        else
                                        {
                                            self.spinner?.stopAnimating()
                                            let alert = UIAlertController(title: "Error", message: "can not upload post", preferredStyle: UIAlertControllerStyle.alert)
                                            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                                            alert.addAction(ok)
                                            self.present(alert, animated: true, completion: nil)
                                            
                                        }
                                    })
                                }
                                
                            })
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
