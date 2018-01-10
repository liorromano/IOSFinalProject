//
//  ProfileCollectionVC.swift
//  FinalProject
//
//  Created by Romano on 13/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit


class GuestProfileVC: UICollectionViewController {
    
    @IBOutlet weak var backBtn: UIBarButtonItem!

    var userID:String = ""
    
    
    //refresher variable
    var refresher: UIRefreshControl!
    
    var postList = [Post]()
    var observerId:Any?
    
    var spinner: UIActivityIndicatorView?
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //spinner configuration
        spinner = UIActivityIndicatorView()
        spinner?.center = (self.collectionView?.center)!
        spinner?.hidesWhenStopped = true
        spinner?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        collectionView?.addSubview(spinner!)
        
        
        ModelNotification.PostList.observe{(list) in
            if(list != nil)
            {
                self.postList.removeAll()
                let posts = list! as [Post]
             
                    for post in posts
                    {
                        if(post.uID == self.userID)
                        {
                            self.postList.append(post)
                        }
                    }
                    self.spinner?.stopAnimating()
                    self.collectionView?.reloadData()
                
                
                
            }
        }
        spinner?.startAnimating()
        Model.instance.getAllPostsAndObserve()
        
        
        //pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(GuestProfileVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        
        
        
    }
    
    
    deinit{
        if (observerId != nil){
            ModelNotification.removeObserver(observer: observerId!)
        }
    }
    
    
    func postsListDidUpdate(notification:NSNotification){
        self.postList = notification.userInfo?["posts"] as! [Post]
        self.collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView?.reloadData()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        print("second")
        
        //define haeder
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "GuestProfileHeaderVC", for: indexPath) as! GuestProfileHeaderVC
        //get the user data with connection to firebase

        Model.instance.getUserById(id:userID) { (user) in
                headerView.HeaderFullNameLbl.text = user?.fullName
                headerView.posts.text = String (self.postList.count)
                //title at the top of the profile page
                self.navigationItem.title=user?.userName
                if (user?.imageUrl != nil)
                {
                    Model.instance.getImage(urlStr: (user?.imageUrl)!, callback: { (image) in
                        headerView.HeaderAvaImg.image = image
                    })
                }
            }
            
        
        headerView.button.setTitle("FOLLOW", for: UIControlState.normal)
        return headerView
    }
    
    //refreshing func
    func refresh(){
        collectionView?.reloadData()
        
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print ("self.postList.count")
        print(self.postList.count)
        return self.postList.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuestCell", for: indexPath as IndexPath) as! PictureCell
        Model.instance.getImage(urlStr: self.postList[indexPath.row].imageUrl, callback: { (image) in
            cell.picturePost.image = image
        })
        return cell
    }
    

    
}




