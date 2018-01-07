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
    //size of page
    var page:Int = 9
    
    var uuIDArray = [String]()
    var picArray = [UIImage]()
    
    var spinner: UIActivityIndicatorView?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ProfileCollectionVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        
        //spinner configuration
        spinner = UIActivityIndicatorView()
        spinner?.center = self.view.center
        spinner?.hidesWhenStopped = true
        spinner?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(spinner!)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
               self.collectionView?.reloadData()
        
    }

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
                    self.user = user
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
    func refresh(){
        collectionView?.reloadData()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("first")
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("picture cell")
        //define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! PictureCell
        
        Model.instance.loadPostsToUserProfile { (posts) in
           // print("collection view cell")
            //print(posts?.count)
           /* if(posts != nil){
                for post in posts!
                {
                    Model.instance.getImagePost(urlStr: post.imageUrl, callback: { (image) in
                        self.picArray.append(image!)
                    })
                
                    
                }
                for image in self.picArray
                {
                    cell.picturePost.image = image
                }*/
                
               Model.instance.fromPostArraytoPicArray(posts: posts!, callback: { (images) in
                    self.picArray=images!
                    let image = self.picArray[indexPath.row]
                    cell.picturePost.image = image
                    
                })
            }
        return cell

        }
    
    
}
    



    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    

