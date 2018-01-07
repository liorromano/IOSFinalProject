//
//  PostCell.swift
//  FinalProject
//
//  Created by admin on 21/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    //header objects
    @IBOutlet weak var PostImage: UIImageView!

    @IBOutlet weak var UsernameBtn: UIButton!
    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var LikeBtn: UIButton!
    @IBOutlet weak var CommentBtn: UIButton!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var LikesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
