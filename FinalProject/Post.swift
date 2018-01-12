//
//  Post.swift
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
    var lat:String?
    var lang:String?
    var description:String?
    
    
    init(userName:String, imageUrl:String, uID:String, lat:String? = nil, lang:String? = nil, description:String? = nil ,postID:String? = nil){
        self.userName = userName
        self.imageUrl = imageUrl
        self.uID = uID
        self.lat = lat
        self.lang = lang
        self.description = description
        self.postID = postID!
        
    }
    
    
    init(json:Dictionary<String,Any>){
        userName = json["userName"] as! String
        uID = json["uID"] as! String
        lat = json["lat"] as? String
        lang = json["lang"] as? String
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
        json["lat"] = lat
        json["lang"] = lang
        json["description"] = description
        json["postID"] = postID
        json["imageUrl"] = imageUrl
        json["lastUpdate"] = ServerValue.timestamp()
        return json
    }
    
    
}
