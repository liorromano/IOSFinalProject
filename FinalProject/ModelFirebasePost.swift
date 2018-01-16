//
//  ModelFirebasePost.swift
//  FinalProject
//
//  Created by Romano on 26/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ModelFirebasePost{
    
    static func addNewPost(post: Post,callback:@escaping (Bool)->Void){
        print("add new post- model firebase post")
        let postNumber = String(describing: post.postID)
        let ref = Database.database().reference().child("posts").child(postNumber)
        ref.setValue(post.toJson())
        ref.setValue(post.toJson()){(error, dbref) in
            if (error != nil)
            {
                callback(false)
            }
            else
            {
                callback(true)
            }
        }
   
        
    }
    
    static func saveImageToFirebase(image:UIImage, userID: String ,postID: Int, callback:@escaping (String?)->Void){
        let postNumber = String(postID)
        let filesRef = Storage.storage().reference(forURL:
            "gs://finalproject-53f16.appspot.com/posts/").child(userID).child(userID.appending(postNumber))
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            filesRef.putData(data, metadata: nil) { metadata, error in
                if (error != nil) {
                    callback(nil)
                } else {
                    let downloadURL = metadata!.downloadURL()
                    callback(downloadURL?.absoluteString)
                }
            }
        }
    }
    
    
    
    
    
   static func getImageFromFirebase(url:String, callback:@escaping (UIImage?)->Void){
        let ref = Storage.storage().reference(forURL: url)
        
        ref.getData(maxSize: 10000000, completion: {(data, error) in
            if ( data != nil){
                let image = UIImage(data: data!)
                callback(image)
                print("get image from firebase")
            }else{
                callback(nil)
            }
        })
    }
    
   static func getPostById(postID:String , userID:String , callback:@escaping (Post)->Void){
        Database.database().reference().child("posts").child(userID).child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get post value
            let value = snapshot.value as? NSDictionary
            let post = Post(json: value as! Dictionary<String,Any> )
            callback(post)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    static func clearObservers(){
        let ref = Database.database().reference().child("posts")
        ref.removeAllObservers()
    }
    
    static func getAllPostsAndObserve(_ lastUpdateDate:Date?, callback:@escaping ([Post])->Void){
        print("FB: getAllPostsAndObserve")
        let handler = {(snapshot:DataSnapshot) in
            var posts = [Post]()
            for child in snapshot.children.allObjects{
                if let childData = child as? DataSnapshot{
                    if let json = childData.value as? Dictionary<String,Any>{
                        let post = Post(json: json)
                        posts.append(post)
                    }
                }
            }
            callback(posts)
        }
        let ref = Database.database().reference().child("posts")
        if (lastUpdateDate != nil){
            print("q starting at:\(lastUpdateDate!) \(lastUpdateDate!.toFirebase())")
            let fbQuery = ref.queryOrdered(byChild:"lastUpdate").queryStarting(atValue:lastUpdateDate!.toFirebase())
            fbQuery.observe(DataEventType.value, with: handler)
        }else{
            ref.observe(DataEventType.value, with: handler)
        }
    }

    
    
    
}
