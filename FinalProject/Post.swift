//
//  File.swift
//  FinalProject
//
//  Created by Koral Shmueli on 26/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Post{
    
    var userName:String
    var imageUrl:String
    var lastUpdate:Date?
    var uID:String
    var postID:String?
    var location:String?
    var description:String?
    
    
    init(userName:String, imageUrl:String, uID:String, location:String? = nil, description:String? = nil ,postID:String? = nil){
        self.userName = userName
        self.imageUrl = imageUrl
        self.uID = uID
        self.location = location
        self.description = description
        self.postID = postID!
        
    }
    
    
    init(json:Dictionary<String,Any>){
        userName = json["userName"] as! String
        uID = json["uID"] as! String
        location = json["location"] as? String
        description = json["description"] as? String
        postID = json["postID"] as? String
        imageUrl=json["imageUrl"] as! String
        if let user = json["lastUpdate"] as? Double{
            self.lastUpdate = Date.fromFirebase(user)
        }
    }
    
    func toJson() -> Dictionary<String,Any> {
        var json = Dictionary<String,Any>()
        json["userName"] = userName
        json["uID"] = uID
        json["location"] = location
        json["description"] = description
        json["postID"] = postID
        json["imageUrl"] = imageUrl
        json["lastUpdate"] = ServerValue.timestamp()
        return json
    }
    
    
}
