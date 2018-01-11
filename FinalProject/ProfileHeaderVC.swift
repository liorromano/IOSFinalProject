//
//  ProfileHeaderVC.swift
//  FinalProject
//
//  Created by Romano on 13/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit

class ProfileHeaderVC: UICollectionReusableView {
    
    //Image
    @IBOutlet weak var HeaderAvaImg: UIImageView!
    
    //labels
    @IBOutlet weak var HeaderFullNameLbl: UILabel!
    
    //numbers labels
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    
    //titles
    @IBOutlet weak var postsTitle: UILabel!
    @IBOutlet weak var followingBtn: UIButton!
    
    @IBOutlet weak var followersBtn: UIButton!
    
    //edit profile/following button
    @IBOutlet weak var button: UIButton!
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //round ava
        HeaderAvaImg.layer.cornerRadius = HeaderAvaImg.frame.size.width / 2
        HeaderAvaImg.clipsToBounds = true
    }
}
