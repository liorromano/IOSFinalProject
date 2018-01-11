//
//  PostVC.swift
//  FinalProject
//
//  Created by admin on 21/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit

class FollowersVC: UITableViewController {
    
    var followList = [Follow]()
    var type: String?
    var userId: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return self.followList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowersCell
        if(type == "followers")
        {
            Model.instance.getUserById(id: self.followList[indexPath.row].followingUID, callback: { (user) in
                cell.usernameLabel.text = user?.userName
                if(!(user?.imageUrl?.isEmpty)!)
                {
                    Model.instance.getImage(urlStr: (user?.imageUrl)!, callback: { (image) in
                        cell.userImage.image = image
                    })
                
                }
            })
        
        }
        else if (type == "following")
        {
            Model.instance.getUserById(id: self.followList[indexPath.row].followerUID, callback: { (user) in
                cell.usernameLabel.text = user?.userName
                if(!(user?.imageUrl?.isEmpty)!)
                {
                    Model.instance.getImage(urlStr: (user?.imageUrl)!, callback: { (image) in
                        cell.userImage.image = image
                    })
                    
                }
            })
        
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "FollowGuestSegue"
        {
            let vc = segue.destination as? GuestProfileVC
            vc?.userID = userId!
        }
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if(type == "followers")
        {
            userId = self.followList[indexPath.row].followingUID
        }
        if (type == "following")
        {
            userId = self.followList[indexPath.row].followerUID
        }
        Model.instance.loggedinUser { (uID) in
            if(uID == self.userId)
            {
                self.performSegue(withIdentifier: "FollowProfileSegue", sender: nil)
            }
            else
            {
                
                self.performSegue(withIdentifier: "FollowGuestSegue", sender: nil)
            }
        }
    }
    
    
}
