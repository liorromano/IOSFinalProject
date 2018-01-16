//
//  ModelFirebaseUsers.swift
//  FinalProject
//
//  Created by Romano on 18/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ModelFirebaseUsers{

    //function that add the new user to firebase
    static func addNewUser(user: User, password: String, email: String, completionBlock:@escaping (Error?)->Void){
        Auth.auth().createUser(withEmail: email, password: password) {
            (uID, error) in
            user.uID = uID?.uid
            let myRef = Database.database().reference().child("Users").child(user.uID!)
            myRef.setValue(user.toJson())
            myRef.setValue(user.toJson()){(error, dbref) in
                completionBlock(error)
            }

        }
    }
    //save image to firebase
   static func saveImageToFirebase(image:UIImage, name:(String), callback:@escaping (String?)->Void){
    let filesRef = Storage.storage().reference(forURL:
        "gs://finalproject-53f16.appspot.com/profile/").child(name)
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
    
    //check if user exist by username
   static func checkIfUserExistByUserName(userName:String, callback:@escaping (String?)->Void)
    {
        getUserById(id: userName, callback: {(user) in
            if (user != nil)
            {
                callback("userName exist")
                
            }
            else{
                callback("userName avail")
                
            }
        })
    }
    //check if user exist by email in authntication
   static func checkIfUserExistByUserEmail(email:String, callback:@escaping (String?)->Void)
    {
        Auth.auth().fetchProviders(forEmail: email) { (string, error) in
            if (string != nil) {
                callback("Email exist")
                
            } else {
                callback("Email avail")
                
            }

        }
    }
    //reset function email from firebase
    static func sendResetPassword(email: String)
    {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
          
        }
        
    }
    //check if user email and password is ok for log in
    static public func authentication(email: String, password: String, callback:@escaping (Bool?)->Void)
    {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if(user != nil)
            {
                callback(true)
            }
            else{
                callback (false)
            }
        }
        
    }
    //log out
    static public func logOut(callback:@escaping (Bool?)->Void)
    {
        try! Auth.auth().signOut()
        callback(true)
        
    }
    
    //get the profile image from firebase
   static func getImageFromFirebase(url:String, callback:@escaping (UIImage?)->Void){
        let ref = Storage.storage().reference(forURL: url)
        
        ref.getData(maxSize: 10000000, completion: {(data, error) in
            if ( data != nil){
                let image = UIImage(data: data!)
                callback(image)
            }else{
                callback(nil)
            }
        })
    }
    //get the user from firebase by uId
   static func getUserById(id:String, callback:@escaping (User?)->Void){
        Database.database().reference().child("Users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get user value
            if let value = snapshot.value as? NSDictionary{
              let user = User(json: value as! Dictionary<String, Any>)
                callback(user)
            }
            else
            {
                callback(nil)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    

    //current user that logged in to this app
   static func loggedinUser(callback:@escaping (String?)->Void){
        callback(Auth.auth().currentUser?.uid)
            
    }
    //function that update the user in firebase
   static func updateUser(user: User, callback:@escaping (Bool)->Void)
    {
        Database.database().reference().child("Users").child(user.uID!).updateChildValues(user.toJson(), withCompletionBlock: { (error, DatabaseReference) in
            if((error) != nil)
            {
                callback(false)
            }
            else
            {
                callback(true)
            }
        })
    
    }
    //save follow to follow in firebase
    static func follow(follower: String, following: String , completionBlock:@escaping (Error?)->Void)
    {
        let myRef = Database.database().reference().child("follow").child(follower.appending(following))
        let follow = Follow(followerUID: follower, followingUID: following, followID: follower.appending(following))
        myRef.setValue(follow.toJson())
        myRef.setValue(follow.toJson()){(error, dbref) in
            completionBlock(error)
        }
        
    }
    //update follow to unfollow in firebase
    static func unfollow(follower: String, following: String)
    {
        let myRef = Database.database().reference().child("follow").child(follower.appending(following))
        myRef.updateChildValues(["deleted": "true"])
    }
    //function that gets all the follow list from firebase
    static func getAllFollowsAndObserve(_ lastUpdateDate:Date?, callback:@escaping ([Follow])->Void){
        print("FB: getAllFollowsAndObserve")
        let handler = {(snapshot:DataSnapshot) in
            var follows = [Follow]()
            for child in snapshot.children.allObjects{
                if let childData = child as? DataSnapshot{
                    if let json = childData.value as? Dictionary<String,Any>{
                        let follow = Follow(json: json)
                        follows.append(follow)
                    }
                }
            }
            callback(follows)
        }
        let ref = Database.database().reference().child("follow")
        if (lastUpdateDate != nil){
            print("q starting at:\(lastUpdateDate!) \(lastUpdateDate!.toFirebase())")
            let fbQuery = ref.queryOrdered(byChild:"lastUpdate").queryStarting(atValue:lastUpdateDate!.toFirebase())
            fbQuery.observe(DataEventType.value, with: handler)
        }else{
            ref.observe(DataEventType.value, with: handler)
        }
    }
 


}
