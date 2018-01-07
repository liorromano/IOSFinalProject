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
    

   static func checkIfUserExistByUserName(userName:String, callback:@escaping (String?)->Void)
    {
        getUserById(id: userName, callback: {(user) in
            if (user != nil)
            {
                print("got into user.userName == userName")
                callback("userName exist")
                
            }
            else{
                print("UserName avail")
                callback("userName avail")
                
            }
        })
    }
    
   static func checkIfUserExistByUserEmail(email:String, callback:@escaping (String?)->Void)
    {
        Auth.auth().fetchProviders(forEmail: email) { (string, error) in
            if (string != nil) {
                print ("email not avail")
                callback("Email exist")
                
            } else {
                print ("email avail")
                callback("Email avail")
                
            }

        }
    }
    
    static func sendResetPassword(email: String)
    {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
          
        }
        
    }
    
    static public func authentication(email: String, password: String, callback:@escaping (Bool?)->Void)
    {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if(user != nil)
            {
                print("user autenticated")
                callback(true)
            }
            else{
             print ("there was an error")
                callback (false)
            }
        }
        
    }
    
    static public func logOut(callback:@escaping (Bool?)->Void)
    {
        try! Auth.auth().signOut()
        callback(true)
        
    }
    
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
    
   static func loggedinUser(callback:@escaping (String?)->Void){
        callback(Auth.auth().currentUser?.uid)
            
    }
    
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
 


}
