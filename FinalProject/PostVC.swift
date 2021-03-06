//
//  PostVC.swift
//  FinalProject
//
//  Created by admin on 21/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit

class PostVC: UITableViewController {
    var observerId:Any?
    var postList = [Post]()
    var spinner: UIActivityIndicatorView?
    var userID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //spinner configuration
        spinner = UIActivityIndicatorView()
        spinner?.center = (self.tableView.center)
        spinner?.hidesWhenStopped = true
        spinner?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        tableView.addSubview(spinner!)
        
        ModelNotification.PostList.observe{(list) in
            if(list != nil)
            {
                self.postList = list!
                self.spinner?.stopAnimating()
                self.tableView?.reloadData()
                
            }
        }
        spinner?.startAnimating()
        Model.instance.getAllPostsAndObserve()
    }
    
    deinit{
        if (observerId != nil){
            ModelNotification.removeObserver(observer: observerId!)
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "GuestSegue"
        {
            let vc = segue.destination as? GuestProfileVC
            vc?.userID = userID
        }
    }
    
    
    
    func postListDidUpdate(notification:NSNotification){
        self.postList = notification.userInfo?["posts"] as! [Post]
        self.tableView!.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        cell.TimeLabel.text = self.postList[indexPath.row].lastUpdate?.stringValue
        cell.Description.text = self.postList[indexPath.row].description
        Model.instance.getUserById(id: self.postList[indexPath.row].uID) { (user) in
            cell.Username.text = user?.userName
            if(user?.imageUrl != nil)
            {
                Model.instance.getImage(urlStr: (user?.imageUrl)!, callback: { (image) in
                    cell.ProfilePicture.image = image
                })
            }
        }
        Model.instance.getImagePost(urlStr: self.postList[indexPath.row].imageUrl, callback: { (image) in
            cell.PostImage.image = image
        })
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        userID = self.postList[indexPath.row].uID
        Model.instance.loggedinUser { (uID) in
            if(uID == self.userID)
            {
                self.performSegue(withIdentifier: "ProfileSegue", sender: nil)
            }
            else
            {
                
                self.performSegue(withIdentifier: "GuestSegue", sender: nil)
            }
        }
    }
    

}
