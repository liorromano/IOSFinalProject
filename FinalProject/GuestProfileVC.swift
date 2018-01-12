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
    var followFlag:Bool = false
    
    //refresher variable
    var refresher: UIRefreshControl!
    
    var followers = [Follow]()
    var following = [Follow]()
    var postList = [Post]()
    var post: Post?
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
        
        ModelNotification.FollowList.observe{(list) in
            if(list != nil)
            {
                self.followers.removeAll()
                self.following.removeAll()
                let follows = list! as [Follow]
                    for follow in follows
                    {
                        if((follow.followerUID == self.userID) && (follow.deleted == "false"))
                        {
                            self.followers.append(follow)
                        }
                        else if((follow.followingUID == self.userID)  && (follow.deleted == "false"))
                        {
                            self.following.append(follow)
                        }
                        Model.instance.loggedinUser(callback: { (uid) in
                            let s = String(self.userID.appending(uid!) )
                            if((follow.followID == s)  && (follow.deleted == "false"))
                            {
                                self.followFlag = true
                            }
                        })
                        
                    }
                    
                    self.spinner?.stopAnimating()
                    self.collectionView?.reloadData()
                
            }
        }
        

        spinner?.startAnimating()
        Model.instance.getAllPostsAndObserve()
        Model.instance.getAllFollowsAndObserve()
        
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
            let followers = String(self.followers.count)
            headerView.followers.text = followers
            let following = String(self.following.count)
            headerView.following.text = following
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
            
        if self.followFlag == false{
        headerView.button.setTitle("Follow", for: UIControlState.normal)
        }
        else{
       headerView.button.setTitle("UnFollow", for: UIControlState.normal)
        }
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "GuestFollowingSegue"
        {
            let vc = segue.destination as? FollowersVC
            vc?.followList = following
            vc?.type = "following"
        }
        if segue.identifier == "GuestFollowersSegue"
        {
            let vc = segue.destination as? FollowersVC
            vc?.followList = followers
            vc?.type = "followers"
        }
        if segue.identifier == "GuestPostLarge"
        {
            let vc = segue.destination as? OnePostVC
            vc?.post = post
        }
    }

    
    @IBAction func FOLLOWBtnClick(_ sender: Any) {
     
        print(self.followFlag)
        if self.followFlag == false{
            self.followFlag = true
            Model.instance.loggedinUser { (loginUserID) in
                        Model.instance.follow(follower: self.userID, following: loginUserID!)
                    }
                refresh()
            }
        
        else if (self.followFlag == true) {
            self.followFlag = false
            Model.instance.loggedinUser { (loginUserID) in
                        Model.instance.unfollow(follower: self.userID, following: loginUserID!)
                        
                    }
    refresh()
            }
        }
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        post = self.postList[indexPath.row]
        self.performSegue(withIdentifier: "GuestPostLarge", sender: nil)
    }


}




