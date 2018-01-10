//
//  ProfileCollectionVC.swift
//  FinalProject
//
//  Created by Romano on 13/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit


class ProfileCollectionVC: UICollectionViewController {
    
    
    @IBOutlet weak var LogoutBtn: UIBarButtonItem!
    
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
                Model.instance.loggedinUser(callback: { (uID) in
                    for post in posts
                    {
                        if(post.uID == uID)
                        {
                           self.postList.append(post)
                        }
                    }
                    self.spinner?.stopAnimating()
                    self.collectionView?.reloadData()
                })
                
                
            }
        }
        spinner?.startAnimating()
        Model.instance.getAllPostsAndObserve()
        

        //pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ProfileCollectionVC.refresh), for: UIControlEvents.valueChanged)
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
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ProfileHeader", for: indexPath) as! ProfileHeaderVC
            //get the user data with connection to firebase
            Model.instance.loggedinUser(callback: { (uID) in
                Model.instance.getUserById(id:uID! ) { (user) in
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
               
            })
            headerView.button.setTitle("edit profile", for: UIControlState.normal)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! PictureCell
            Model.instance.getImage(urlStr: self.postList[indexPath.row].imageUrl, callback: { (image) in
                cell.picturePost.image = image
            })
            return cell
        }
    
    @IBAction func logOutBtn_clicked(_ sender: Any) {
                spinner?.startAnimating()
               Model.instance.logOut { (ans) in
                if(ans == true)
                {
                    print ("logged out")
                    self.spinner?.stopAnimating()
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoginVC")
                    self.present(newViewController, animated: true, completion: nil)
                }
                else{
                    print("not logged out")
                    self.spinner?.stopAnimating()
                    let alert = UIAlertController(title: "Error", message: "Can not logout", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    
}




