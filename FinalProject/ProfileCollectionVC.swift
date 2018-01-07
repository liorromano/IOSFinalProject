//
//  ProfileCollectionVC.swift
//  FinalProject
//
//  Created by Romano on 13/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit


class ProfileCollectionVC: UICollectionViewController {
    //refresher variable
    var refresher: UIRefreshControl!
    
    var postList = [Post]()
    var observerId:Any?
    
    var spinner: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ModelNotification.PostList.observe{(list) in
            if(list != nil)
            {
                self.postList = list!
                self.collectionView?.reloadData()
            }
        }
        Model.instance.getAllPostsAndObserveForProfile()
        

       /* //pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ProfileCollectionVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        
        //spinner configuration
        spinner = UIActivityIndicatorView()
        spinner?.center = self.view.center
        spinner?.hidesWhenStopped = true
        spinner?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(spinner!)*/
        
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
    
    /*override func viewWillAppear(_ animated: Bool) {
               self.collectionView?.reloadData()
        
    }*/

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        print("second")
   
            //define haeder
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ProfileHeader", for: indexPath) as! ProfileHeaderVC
            spinner?.startAnimating()
            //get the user data with connection to firebase
            Model.instance.loggedinUser(callback: { (uID) in
                Model.instance.getUserById(id:uID! ) { (user) in
                    headerView.HeaderFullNameLbl.text = user?.fullName
                    //title at the top of the profile page
                    self.navigationItem.title=user?.userName
                    if (user?.imageUrl != nil)
                    {
                    Model.instance.getImage(urlStr: (user?.imageUrl)!, callback: { (image) in
                        headerView.HeaderAvaImg.image = image
                        self.spinner?.stopAnimating()
                        
                    })
                }
                }
                self.spinner?.stopAnimating()
            })
            headerView.button.setTitle("edit profile", for: UIControlState.normal)
            return headerView
        }
    
    //refreshing func
   /* func refresh(){
        collectionView?.reloadData()
        
    }*/
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print ("self.postList.count")
        print(self.postList.count)
        return self.postList.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { 
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! PictureCell
            Model.instance.getImage(urlStr: self.postList[indexPath.row].imageUrl, callback: { (image) in
                cell.picturePost.image = image
            })
            return cell
        }
    }



