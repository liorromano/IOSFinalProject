//
//  GuestProfileHeaderVC.swift
//  FinalProject
//
//  Created by Koral Shmueli on 09/01/2018.
//  Copyright © 2018 Romano. All rights reserved.
//

import UIKit

class GuestProfileHeaderVC: UICollectionReusableView {

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
    
}
