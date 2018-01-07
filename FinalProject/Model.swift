//
//  Model.swift
//  FinalProject
//
//  Created by Romano on 18/12/2017.
//  Copyright © 2017 Romano. All rights reserved.
//

import Foundation
import UIKit

//let notifyStudentListUpdate = "com.menachi.NotifyStudentListUpdate"

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
    
   // lazy private var modelSql:ModelSql? = ModelSql()
    lazy private var modelFirebaseUsers:ModelFirebaseUsers? = ModelFirebaseUsers()
    lazy private var modelFirebasePost:ModelFirebasePost? = ModelFirebasePost()
    
    private init(){
        
    }
    
    func addUser(user:User, password: String, email: String ){
        modelFirebaseUsers?.addNewUser(user: user, password: password, email: email ){(error) in
            //st.addStudentToLocalDb(database: self.modelSql?.database)
        }
    }
    
    func getUserById(id:String, callback:@escaping (User?)->Void){
        
        modelFirebaseUsers?.getUserById(id: id, callback:{ (user) in
            if(user != nil)
            {
                callback(user)
            }
        })
    }
    
     /* func getAllUsers(callback:@escaping ([User])->Void){
        // get last update date from SQL
        let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: modelSql?.database, table: User.USER_TABLE)
        
        // get all updated records from firebase
        modelFirebase?.getAllUsers(lastUpdateDate, callback: { (users) in
            //update the local db
            print("got \(users.count) new records from FB")
            var lastUpdate:Date?
            for user in users{
                user.addUserToLocalDb(database: self.modelSql?.database)
                if lastUpdate == nil{
                    lastUpdate = user.lastUpdate
                }else{
                    if lastUpdate!.compare(user.lastUpdate!) == ComparisonResult.orderedAscending{
                        lastUpdate = user.lastUpdate
                    }
                }
            }
            
            //upadte the last update table
            if (lastUpdate != nil){
                LastUpdateTable.setLastUpdate(database: self.modelSql!.database, table: User.USER_TABLE, lastUpdate: lastUpdate!)
            }
            
            //get the complete list from local DB
            let totalList = User.getAllUsersFromLocalDb(database: self.modelSql?.database)
            
            //return the list to the caller
            callback(totalList)
        })
    }
    
  func getAllStudentsAndObserve(){
        // get last update date from SQL
        let lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: modelSql?.database, table: User.USER_TABLE)
        
        // get all updated records from firebase
        modelFirebase?.getAllStudentsAndObserve(lastUpdateDate, callback: { (students) in
            //update the local db
            print("got \(students.count) new records from FB")
            var lastUpdate:Date?
            for st in students{
                st.addStudentToLocalDb(database: self.modelSql?.database)
                if lastUpdate == nil{
                    lastUpdate = st.lastUpdate
                }else{
                    if lastUpdate!.compare(st.lastUpdate!) == ComparisonResult.orderedAscending{
                        lastUpdate = st.lastUpdate
                    }
                }
            }
            
            //upadte the last update table
            if (lastUpdate != nil){
                LastUpdateTable.setLastUpdate(database: self.modelSql!.database, table: Student.ST_TABLE, lastUpdate: lastUpdate!)
            }
            
            //get the complete list from local DB
            let totalList = Student.getAllStudentsFromLocalDb(database: self.modelSql?.database)
            
            //return the list to the observers using notification center
            NotificationCenter.default.post(name: Notification.Name(rawValue:
                notifyStudentListUpdate), object:nil , userInfo:["students":totalList])
        })
    }*/
    
    func saveImage(image:UIImage, name:String, callback:@escaping (String?)->Void){
        //1. save image to Firebase
        modelFirebaseUsers?.saveImageToFirebase(image: image, name: name, callback: {(url) in
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
            modelFirebaseUsers?.getImageFromFirebase(url: urlStr, callback: { (image) in
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
        
        modelFirebaseUsers?.checkIfUserExistByUserEmail(email: email, callback: { (answer) in
            userEmailCheck = answer!
            print("userEmailCheck= "+userEmailCheck!)
            self.modelFirebaseUsers?.checkIfUserExistByUserName(userName: userName, callback: { (answer) in
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
        modelFirebaseUsers?.checkIfUserExistByUserEmail(email: email, callback: { (answer) in
            userEmailCheck = answer!
            if(userEmailCheck?.compare("Email exist") == ComparisonResult.orderedSame)
            {
                self.modelFirebaseUsers?.sendResetPassword(email: email)
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
        modelFirebaseUsers?.authentication(email: email, password: password, callback: { (answer) in
            callback(answer)
        })
    }
    
    func loggedinUser(callback:@escaping (String?)->Void){
        modelFirebaseUsers?.loggedinUser(callback: { (ans) in
            callback(ans)
        })
        
    }
    
    
    
    
    func updateUser(user: User, callback:@escaping (Bool)->Void)
    {
        modelFirebaseUsers?.updateUser(user: user, callback: { (answer) in
            callback (answer)
        })
    
    }
    

    
    func addNewPost(post: Post,callback:@escaping (Bool?)->Void){
        
        modelFirebasePost?.addNewPost(post: post, callback: { (answer) in
            callback(answer)
            
            
        })
        
    }
    
    
    
    
    
    
    
    func getPostById(postID:String , userID:String , callback:@escaping (Post)->Void){
        
    }
    
    func savePostImage(image:UIImage, userName:String, userID:String,postID:Int, callback:@escaping (String?)->Void){
        //1. save image to Firebase
        modelFirebasePost?.saveImageToFirebase(image: image, userID: userID, postID: postID, callback: { (url) in
            if (url != nil){
                //2. save image localy
                self.saveImageToFile(image: image, name: userName)
            }
            //3. notify the user on complete
            callback(url)
        })
        
    }
    
    func loadPostsToUserProfile(callback:@escaping ([Post]?)->Void){
        modelFirebasePost?.loadPostsToUserProfile(callback: { (posts) in
            if(posts!.count != 0){
                callback(posts)
            }
            else{
                callback(nil)
            }
        })
    }
    
    func fromPostArraytoPicArray(posts: [Post], callback:@escaping ([UIImage]?)->Void){
        modelFirebasePost?.fromPostArraytoPicArray(posts: posts, callback: { (picArray) in
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
                modelFirebasePost?.getImageFromFirebase(url: urlStr, callback: { (image) in
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
    
}





