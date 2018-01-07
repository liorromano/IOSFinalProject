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
        Model.instance.getAllPostsAndObserve(type: "all")
    }
    
    deinit{
        if (observerId != nil){
            ModelNotification.removeObserver(observer: observerId!)
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
        //cell.dateLabel.text = self.postList[indexPath.row].lastUpdate
        cell.descriptionLabel.text = self.postList[indexPath.row].description
        Model.instance.getImagePost(urlStr: self.postList[indexPath.row].imageUrl, callback: { (image) in
            cell.picturePost.image = image
        })

        return cell
}
}
