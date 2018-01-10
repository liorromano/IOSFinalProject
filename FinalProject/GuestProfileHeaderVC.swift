//
//  ProfileHeaderVC.swift
//  FinalProject
//
//  Created by Romano on 13/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit

class GuestProfileHeaderVC: UICollectionReusableView {
    
    //Image
    @IBOutlet weak var HeaderAvaImg: UIImageView!
    
    //labels
    @IBOutlet weak var HeaderFullNameLbl: UILabel!
    @IBOutlet weak var HeaderBioLbl: UILabel!
    
    //numbers labels
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    
    //titles
    @IBOutlet weak var postsTitle: UILabel!
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var followingTitle: UILabel!
    
    //edit profile/following button
    @IBOutlet weak var button: UIButton!
    
    
    
}
