//
//  OnePostCell.swift
//  FinalProject
//
//  Created by Romano on 11/01/2018.
//  Copyright © 2018 Romano. All rights reserved.
//

import UIKit

class OnePostCell: UITableViewCell {
    //header objects
    @IBOutlet weak var PostImage: UIImageView!
    
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var Description: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //round ava
        ProfilePicture.layer.cornerRadius = ProfilePicture.frame.size.width / 2
        ProfilePicture.clipsToBounds = true
    }
    
}
