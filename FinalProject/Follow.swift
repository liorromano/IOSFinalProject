//
//  Follow.swift
//  FinalProject
//
//  Created by Romano on 09/01/2018.
//  Copyright © 2018 Romano. All rights reserved.
//


import Foundation
import FirebaseDatabase

class Follow{
    
    var followerUID:String
    var followingUID:String
    var followID:String
    var lastUpdate:Date?
    var deleted: String?
    
    init(followerUID:String, followingUID:String,followID:String, deleted:String? = "false" )
    {
        self.followerUID = followerUID
        self.followingUID = followingUID
        self.followID = followID
        self.deleted = deleted
    }
    
    
    init(json:Dictionary<String,Any>){
        followerUID = json["follower"] as! String
        followingUID = json["following"] as! String
        followID = json["followID"] as! String
        deleted = json["deleted"] as? String
        if let user = json["lastUpdate"] as? Double{
            self.lastUpdate = Date.fromFirebase(user)
        }
    }
    
    func toJson() -> Dictionary<String,Any> {
        var json = Dictionary<String,Any>()
        json["follower"] = followerUID
        json["following"] = followingUID
        json["followID"] = followID
        json["deleted"] = deleted
        json["lastUpdate"] = ServerValue.timestamp()
        return json
    }
    
    
}
