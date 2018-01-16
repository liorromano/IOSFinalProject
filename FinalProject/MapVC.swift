//
//  MapVC.swift
//  FinalProject
//
//  Created by Romano on 08/01/2018.
//  Copyright © 2018 Romano. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


class MapVC: UIViewController , CLLocationManagerDelegate {
    var observerId:Any?
    var postList = [Post]()
    
  

     
    override func viewDidLoad() {
        super.viewDidLoad()
        ModelNotification.PostList.observe{(list) in
            if(list != nil)
            {
                self.postList = list!

                
            }
        }
        Model.instance.getAllPostsAndObserve()

        // Do any additional setup after loading the view.
    }
    deinit{
        if (observerId != nil){
            ModelNotification.removeObserver(observer: observerId!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        //image.draw(in: CGRectMake(0, 0, newSize.width, newSize.height))
        image.draw(in: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: newSize.width, height: newSize.height))  )
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.reloadInputViews()
        
    }
    
   override func viewDidAppear(_ animated: Bool) {
        let camera = GMSCameraPosition.camera(withLatitude: 31.975856, longitude: 34.771984, zoom: 11.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        view = mapView
        
        
        
        //load posts locations on the map
        for post in postList{
            if((post.lang != nil) && (post.lat != nil))
            {
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            
            
            let lat = Double(post.lat!)
            let long = Double(post.lang!)
            
            marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            marker.title = post.userName
            Model.instance.getImagePost(urlStr: post.imageUrl, callback: { (image) in
               marker.icon = self.imageWithImage(image: image!, scaledToSize: CGSize(width: 30.0, height: 30.0))
                
            })
            marker.snippet = post.description
            marker.map = mapView
            }

    }

    
 
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


