//
//  User.swift
//  FinalProject
//
//  Created by Romano on 18/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import Foundation
import FirebaseDatabase
class User{
    
    var userName:String
    var fullName:String
    var imageUrl:String?
    var lastUpdate:Date?
    
    init(userName:String, fullName:String, imageUrl:String? = nil){
        self.userName=userName
        self.fullName=fullName
        self.imageUrl = imageUrl
    }
    
    
    init(json:Dictionary<String,Any>){
        userName = json["userName"] as! String
        fullName = json["fullName"] as! String
        if let im = json["imageUrl"] as? String{
            imageUrl = im
        }
        if let user = json["lastUpdate"] as? Double{
            self.lastUpdate = Date.fromFirebase(user)
        }
    }
    
    func toJson() -> Dictionary<String,Any> {
        var json = Dictionary<String,Any>()
        json["userName"] = userName
        json["fullName"] = fullName
        if (imageUrl != nil){
            json["imageUrl"] = imageUrl!
        }
        json["lastUpdate"] = ServerValue.timestamp()
        return json
    }
    
    
}
