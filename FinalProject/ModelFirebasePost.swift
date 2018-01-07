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
    FirebaseApp.configure()
    dataBase=Database.database().reference()
}

func addNewPost(post: Post,callback:@escaping (Bool)->Void){
  
        let myRef = self.dataBase?.child("Posts").child(post.uID).child("postID")
        myRef?.setValue(post.toJson())
        callback(true)
    
}


lazy var storageRef = Storage.storage().reference(forURL:
    "gs://finalproject-53f16.appspot.com/posts/")

    func saveImageToFirebase(image:UIImage, userID: String ,postID: String, callback:@escaping (String?)->Void){
    let filesRef = storageRef.child(userID).child(postID)
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
    dataBase?.child("Posts").child(userID).child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
        // Get post value
        let value = snapshot.value as? NSDictionary
        let post = Post(json: value as! Dictionary<String,Any> )
        callback(post)
    }) { (error) in
        print(error.localizedDescription)
    }
}



}
