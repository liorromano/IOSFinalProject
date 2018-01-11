//
//  PostVC.swift
//  FinalProject
//
//  Created by admin on 21/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit

class OnePostVC: UITableViewController {
    var observerId:Any?
    var post: Post?
    var spinner: UIActivityIndicatorView?
    var userID:String = ""
    
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OnePostCell", for: indexPath) as! OnePostCell
        cell.TimeLabel.text = self.post?.lastUpdate?.stringValue
        cell.Description.text = self.post?.description
        Model.instance.getUserById(id: (self.post?.uID)!) { (user) in
            cell.Username.text = user?.userName
            if(user?.imageUrl != nil)
            {
                Model.instance.getImage(urlStr: (user?.imageUrl)!, callback: { (image) in
                    cell.ProfilePicture.image = image
                })
            }
        }
        Model.instance.getImagePost(urlStr: (self.post?.imageUrl)!, callback: { (image) in
            cell.PostImage.image = image
        })
        
        return cell
    }
    
    
    
}
