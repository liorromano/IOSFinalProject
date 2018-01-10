//
//  Model.swift
//  FinalProject
//
//  Created by Romano on 18/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ModelNotificationBase<T>{
    var name:String?
    
    init(name:String){
        self.name = name
    }
    
    func observe(callback:@escaping (T?)->Void)->Any{
        return NotificationCenter.default.addObserver(forName: NSNotification.Name(name!), object: nil, queue: nil) { (data) in
            if let data = data.userInfo?["data"] as? T {
                callback(data)
            }
        }
    }
    
    func follow(data:T){
        NotificationCenter.default.post(name: NSNotification.Name(name!), object: self, userInfo: ["data":data])
    }
    
    func post(data:T){
        NotificationCenter.default.post(name: NSNotification.Name(name!), object: self, userInfo: ["data":data])
    }
}

class ModelNotification{
    static let PostList = ModelNotificationBase<[Post]>(name: "PostListNotificatio")
    
    static let FollowList = ModelNotificationBase<[Follow]>(name: "FollowListNotificatio")
    
    static func removeObserver(observer:Any){
        NotificationCenter.default.removeObserver(observer)
    }
}


extension Date {
    
    func toFirebase()->Double{
        return self.timeIntervalSince1970 * 1000
    }
    
    static func fromFirebase(_ interval:String)->Date{
        return Date(timeIntervalSince1970: Double(interval)!)
    }
    
    static func fromFirebase(_ interval:Double)->Date{
        if (interval>9999999999){
            return Date(timeIntervalSince1970: interval/1000)
        }else{
            return Date(timeIntervalSince1970: interval)
        }
    }
    
    var stringValue: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
    
}


class Model{
    static let instance = Model()
    
    lazy private var modelSql:ModelSql? = ModelSql()
    
    private init(){
        
    }
    
    func clear(){
        print("Model.clear")
        ModelFirebasePost.clearObservers()
    }

    
    func addUser(user:User, password: String, email: String ){
        ModelFirebaseUsers.addNewUser(user: user, password: password, email: email ){(error) in
        }
    }
    
    func getUserById(id:String, callback:@escaping (User?)->Void){
        
        ModelFirebaseUsers.getUserById(id: id, callback:{ (user) in
            if(user != nil)
            {
                callback(user)
            }
        })
    }

    
    func getAllPostsAndObserve(){
        print("Model.getAllStudentsAndObserve")
        // get last update date from SQL
        let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: modelSql?.database, table: Post.POST_TABLE)
        
        // get all updated records from firebase
        ModelFirebasePost.getAllPostsAndObserve(lastUpdateDate, callback: { (posts) in
            //update the local db
            print("got \(posts.count) new records from FB")
            var lastUpdate:Date?
            for post in posts{
                post.addPostToLocalDb(database: self.modelSql?.database)
                if lastUpdate == nil{
                    lastUpdate = post.lastUpdate
                }else{
                    if lastUpdate!.compare(post.lastUpdate!) == ComparisonResult.orderedAscending{
                        lastUpdate = post.lastUpdate
                    }
                }
            }
            
            //upadte the last update table
            if (lastUpdate != nil){
                LastUpdateTable.setLastUpdate(database: self.modelSql!.database, table: Post.POST_TABLE, lastUpdate: lastUpdate!)
            }
            
            //get the complete list from local DB
 
                let totalList = Post.getAllPostsFromLocalDb(database: self.modelSql?.database)
                print("\(totalList)")
                
                ModelNotification.PostList.post(data: totalList)
            
          
        })
    }
    
    
    func saveImage(image:UIImage, name:String, callback:@escaping (String?)->Void){
        //1. save image to Firebase
        ModelFirebaseUsers.saveImageToFirebase(image: image, name: name, callback: {(url) in
            if (url != nil){
                //2. save image localy
                self.saveImageToFile(image: image, name: name)
            }
            //3. notify the user on complete
            callback(url)
        })
    }
    
    func getImage(urlStr:String, callback:@escaping (UIImage?)->Void){
        //1. try to get the image from local store
        let url = URL(string: urlStr)
        if(url != nil){
        let localImageName = url!.lastPathComponent
        if let image = self.getImageFromFile(name: localImageName){
            callback(image)
        }else{
            //2. get the image from Firebase
            ModelFirebaseUsers.getImageFromFirebase(url: urlStr, callback: { (image) in
                if (image != nil){
                    //3. save the image localy
                    self.saveImageToFile(image: image!, name: localImageName)
                }
                //4. return the image to the user
                callback(image)
            })
        }
        }
    }
    
    
    private func saveImageToFile(image:UIImage, name:String){
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent(name)
            try? data.write(to: filename)
        }
    }
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func getImageFromFile(name:String)->UIImage?{
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        return UIImage(contentsOfFile:filename.path)
    }
    
    public func checkIfUserExist(userName:String,email: String, callback:@escaping (String?)->Void)
    {
        var userEmailCheck: String?
        var userNameCheck: String?
        
        ModelFirebaseUsers.checkIfUserExistByUserEmail(email: email, callback: { (answer) in
            userEmailCheck = answer!
            print("userEmailCheck= "+userEmailCheck!)
            ModelFirebaseUsers.checkIfUserExistByUserName(userName: userName, callback: { (answer) in
                userNameCheck = answer!
                print("userNameCheck= "+userNameCheck!)
                if((userEmailCheck?.compare("Email exist") == ComparisonResult.orderedSame)&&(userNameCheck?.compare("userName exist") == ComparisonResult.orderedSame)){
                    print("both exist")
                    callback("both exist")
                    
                }
                else if(userEmailCheck?.compare("Email exist") == ComparisonResult.orderedSame)
                {
                    print("email")
                    callback("email")
                }
                else if(userNameCheck?.compare("userName exist") == ComparisonResult.orderedSame)
                {
                    print("username")
                    callback("username")
                }
                else
                {
                    print("both avail")
                    callback("both avail")
                }

            })
        })
        
       
    }
    
    public func checkEmail(email: String, callback:@escaping (Bool?)->Void)
    {
        var userEmailCheck: String?
        ModelFirebaseUsers.checkIfUserExistByUserEmail(email: email, callback: { (answer) in
            userEmailCheck = answer!
            if(userEmailCheck?.compare("Email exist") == ComparisonResult.orderedSame)
            {
                ModelFirebaseUsers.sendResetPassword(email: email)
                callback(true)
            }
            else
            {
                callback(false)
            }
        })
    }
    
    public func login (email: String, password: String, callback:@escaping (Bool?)->Void)
    {
        ModelFirebaseUsers.authentication(email: email, password: password, callback: { (answer) in
            callback(answer)
        })
    }
    
    func loggedinUser(callback:@escaping (String?)->Void){
        ModelFirebaseUsers.loggedinUser(callback: { (ans) in
            callback(ans)
        })
        
    }
    
    public func logOut(callback:@escaping (Bool?)->Void)
    {
        ModelFirebaseUsers.logOut(callback: { (answer) in
            callback(answer)
        })
    }
    
    
    func updateUser(user: User, callback:@escaping (Bool)->Void)
    {
        ModelFirebaseUsers.updateUser(user: user, callback: { (answer) in
            callback (answer)
        })
    
    }
    

    
    func addNewPost(post: Post,callback:@escaping (Bool?)->Void){
        
        ModelFirebasePost.addNewPost(post: post, callback: { (answer) in
            callback(answer)
        })
        
    }
    
    
    func savePostImage(image:UIImage, userName:String, userID:String,postID:Int, callback:@escaping (String?)->Void){
        //1. save image to Firebase
        ModelFirebasePost.saveImageToFirebase(image: image, userID: userID, postID: postID, callback: { (url) in
            if (url != nil){
                //2. save image localy
                self.saveImageToFile(image: image, name: userID.appending(String(postID)) )
            }
            //3. notify the user on complete
            callback(url)
        })
        
    }
    
    func loadPostsToUserProfile(callback:@escaping ([Post]?)->Void){
        ModelFirebasePost.loadPostsToUserProfile(callback: { (posts) in
            if(posts!.count != 0){
                callback(posts)
            }
            else{
                callback(nil)
            }
        })
    }
    
    func fromPostArraytoPicArray(posts: [Post], callback:@escaping ([UIImage]?)->Void){
        ModelFirebasePost.fromPostArraytoPicArray(posts: posts, callback: { (picArray) in
            if(picArray != nil){
                callback(picArray)
            }
            else{
                callback(nil)
            }
        })
    }
    
    func getImagePost(urlStr:String, callback:@escaping (UIImage?)->Void){
        //1. try to get the image from local store
        let url = URL(string: urlStr)
        if(url != nil){
            let localImageName = url!.lastPathComponent
            if let image = self.getImageFromFile(name: localImageName){
                callback(image)
            }else{
                //2. get the image from Firebase
                ModelFirebasePost.getImageFromFirebase(url: urlStr, callback: { (image) in
                    if (image != nil){
                        //3. save the image localy
                        self.saveImageToFile(image: image!, name: localImageName)
                    }
                    //4. return the image to the user
                    callback(image)
                })
            }
        }
    }
    
    func follow( follower: String, following: String ){
        ModelFirebaseUsers.follow(follower: follower, following: following) { (error) in
            
        }
    }
    
    func unfollow(follower: String, following: String ){
        ModelFirebaseUsers.unfollow(follower: follower, following: following)
    }
    
    func getAllFollowsAndObserve(){
        print("Model.getAllFollowsAndObserve")
        // get last update date from SQL
        let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: modelSql?.database, table: Follow.FOLLOW_TABLE)
        
        // get all updated records from firebase
        ModelFirebaseUsers.getAllFollowsAndObserve(lastUpdateDate, callback: { (follows) in
            //update the local db
            print("got \(follows.count) new records from FB")
            var lastUpdate:Date?
            for follow in follows{
                follow.addFollowToLocalDb(database: self.modelSql?.database)
                if lastUpdate == nil{
                    lastUpdate = follow.lastUpdate
                }else{
                    if lastUpdate!.compare(follow.lastUpdate!) == ComparisonResult.orderedAscending{
                        lastUpdate = follow.lastUpdate
                    }
                }
            }
            
            //upadte the last update table
            if (lastUpdate != nil){
                LastUpdateTable.setLastUpdate(database: self.modelSql!.database, table: Follow.FOLLOW_TABLE, lastUpdate: lastUpdate!)
            }
            
            //get the complete list from local DB
            
            let totalList = Follow.getAllFollowFromLocalDb(database: self.modelSql?.database)
            print("\(totalList)")
            
            ModelNotification.FollowList.follow(data: totalList)
            
            
        })
    }

    
   }





