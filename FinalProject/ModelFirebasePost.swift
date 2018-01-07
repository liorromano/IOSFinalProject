//
//  File.swift
//  FinalProject
//
//  Created by Koral Shmueli on 26/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ModelFirebasePost{
    
    var dataBase: DatabaseReference?
    
    init(){
        //FirebaseApp.configure()
        dataBase=Database.database().reference()
    }
    
    func addNewPost(post: Post,callback:@escaping (Bool)->Void){
        print("add new post- model firebase post")
        let postNumber = String(post.postID)
        let myRef = self.dataBase?.child("posts").child(post.uID).child(postNumber)
        myRef?.setValue(post.toJson())
        callback(true)
        
    }
    
    
    lazy var storageRef = Storage.storage().reference(forURL:
        "gs://finalproject-53f16.appspot.com/posts/")
    
    func saveImageToFirebase(image:UIImage, userID: String ,postID: Int, callback:@escaping (String?)->Void){
        let postNumber = String(postID)
        let filesRef = storageRef.child(userID).child(postNumber)
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
    
    
    
    
    
    func getImageFromFirebase(url:String, callback:@escaping (UIImage?)->Void){
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
    
    func getPostById(postID:String , userID:String , callback:@escaping (Post)->Void){
        dataBase?.child("posts").child(userID).child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get post value
            let value = snapshot.value as? NSDictionary
            let post = Post(json: value as! Dictionary<String,Any> )
            callback(post)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loadPostsToUserProfile(callback:@escaping ([Post]?)->Void){
        var postArray = [Post]()
        Model.instance.loggedinUser { (logginUser) in
            self.dataBase?.child("posts").child(logginUser!).observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children{
                    // Get post value
                    let snap = child as! DataSnapshot
                    let value = snap.value as? NSDictionary
                    let post = Post(json: value as! Dictionary<String,Any> )
                    postArray.append(post)
                }
                if(postArray.count != 0){
                    callback(postArray)
                }
                else{
                    callback(nil)
                }
            })
            
        }
        
        
    }
    
    func fromPostArraytoPicArray(posts: [Post], callback:@escaping ([UIImage]?)->Void)
    {
        
    }
    
    
    
    
    
    
}
