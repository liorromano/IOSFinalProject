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
    
    var dataBase: DatabaseReference?
    
    init(){
        FirebaseApp.configure()
        dataBase=Database.database().reference()
    }
    
    func addNewUser(user: User, password: String, email: String, completionBlock:@escaping (Error?)->Void){
        let myRef = dataBase?.child("Users").child(user.userName)
         myRef?.setValue(user.toJson())
         myRef?.setValue(user.toJson()){(error, dbref) in
            completionBlock(error)
        }
        Auth.auth().createUser(withEmail: email, password: password) {
            (user, error) in
            //??????????????
        }
    }
    
    lazy var storageRef = Storage.storage().reference(forURL:
        "gs://finalproject-53f16.appspot.com")
    
    func saveImageToFirebase(image:UIImage, name:(String), callback:@escaping (String?)->Void){
        let filesRef = storageRef.child(name)
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
    
    func getStudentById(id:String, callback:@escaping (User)->Void){
        dataBase?.child("Users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["userName"] as? String ?? ""
            print(username)
            let fullName = value?["fullName"] as? String ?? ""
            let imageUrl = value?["imageUrl"] as? String ?? ""
            let user = User(userName: username, fullName: fullName, imageUrl: imageUrl)
            callback(user)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func checkIfUserExistByUserName(userName:String, callback:@escaping (String?)->Void)
    {
        getStudentById(id: userName, callback: {(user) in
            if (userName.compare(user.userName) == ComparisonResult.orderedSame)
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
    
    func checkIfUserExistByUserEmail(email:String, callback:@escaping (String?)->Void)
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
    

}
