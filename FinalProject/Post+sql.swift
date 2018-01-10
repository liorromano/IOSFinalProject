//
//  Student+sql.swift
//  TestFb
//
//  Created by Eliav Menachi on 21/12/2016.
//  Copyright © 2016 menachi. All rights reserved.
//

import Foundation


extension Post{
    static let POST_TABLE = "POSTS"
    static let POST_ID = "POST_ID"
    static let POST_USER_NAME = "POST_USER_NAME"
    static let POST_IMAGE_URL = "POST_IMAGE_URL"
    static let POST_LAST_UPDATE = "POST_LAST_UPDATE"
    static let POST_USER_ID = "POST_USER_ID"
    static let POST_DESCRIPTION = "POST_DESCRIPTION"
    static let POST_LAT = "POST_LAT"
    static let POST_LANG = "POST_LANG"

    
    
    static func createTable(database:OpaquePointer?)->Bool{
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + POST_TABLE + " ( " + POST_ID  + " TEXT PRIMARY KEY, "
            + POST_USER_ID + " TEXT SECONDARY KEY, "
            + POST_USER_NAME + " TEXT, " + POST_IMAGE_URL + " TEXT, " + POST_DESCRIPTION + " TEXT, " + POST_LAT + " TEXT, " + POST_LANG + " TEXT, "
            + POST_LAST_UPDATE + " DOUBLE)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return false
        }

        return true
    }
    
    func addPostToLocalDb(database:OpaquePointer?){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + Post.POST_TABLE
            + "(" + Post.POST_ID + ","
            + Post.POST_USER_ID + ","
            + Post.POST_USER_NAME + "," + Post.POST_IMAGE_URL + "," + Post.POST_DESCRIPTION + "," + Post.POST_LAT + "," + Post.POST_LANG + ","
            + Post.POST_LAST_UPDATE + ") VALUES (?,?,?,?,?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            let sql = "INSERT OR REPLACE INTO " + Post.POST_TABLE
                + "(" + Post.POST_USER_ID + ","
                + Post.POST_ID + ","
                + Post.POST_USER_NAME + "," + Post.POST_IMAGE_URL + "," + Post.POST_DESCRIPTION + "," + Post.POST_LAT + "," + Post.POST_LANG + ","
                + Post.POST_LAST_UPDATE + ") VALUES (?,?,?,?,?,?,?,?);"
            print("insert post to db - \(sql)")
            let userId = self.uID.cString(using: .utf8)
            let postId = self.postID?.cString(using: .utf8)
            let userName = self.userName.cString(using: .utf8)
            var imageUrl = "".cString(using: .utf8)
            if self.imageUrl != nil  {
                imageUrl = self.imageUrl.cString(using: .utf8)
            }
            var description = "".cString(using: .utf8)
            if self.description != nil {
                description = self.description?.cString(using: .utf8)
            }
            var lat = "".cString(using: .utf8)
            if self.lat != nil {
                lat = self.lat?.cString(using: .utf8)
            }
            var lang = "".cString(using: .utf8)
            if self.lang != nil {
                lang = self.lang?.cString(using: .utf8)
            }
            
            sqlite3_bind_text(sqlite3_stmt, 2, userId,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 1, postId,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, userName,-1,nil);
            if(imageUrl != nil)
            {
                sqlite3_bind_text(sqlite3_stmt, 4, imageUrl,-1,nil);
            }
            if(description != nil)
            {
                sqlite3_bind_text(sqlite3_stmt, 5, description,-1,nil);
            }
            if(lat != nil)
            {
                sqlite3_bind_text(sqlite3_stmt, 6, lat,-1,nil);
            }
            if(lang != nil)
            {
                sqlite3_bind_text(sqlite3_stmt, 7, lang,-1,nil);
            }
            
            
            if (lastUpdate == nil){
                lastUpdate = Date()
            }
            sqlite3_bind_double(sqlite3_stmt, 8, lastUpdate!.toFirebase());
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func getAllPostsFromLocalDb(database:OpaquePointer?)->[Post]{
        var posts = [Post]()
        var sqlite3_stmt: OpaquePointer? = nil
        var sql = ""
        sql = "SELECT * from POSTS ORDER BY POST_LAST_UPDATE DESC;"
        if (sqlite3_prepare_v2(database,sql,-1,&sqlite3_stmt,nil) == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let userId =  String(validatingUTF8: sqlite3_column_text(sqlite3_stmt,1))
                let postId =  String(validatingUTF8: sqlite3_column_text(sqlite3_stmt,0))
                let userName =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,2))
                let update =  Double(sqlite3_column_double(sqlite3_stmt,7))
                var imageUrl = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,3))
                var description = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,4))
                var lat = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,5))
                var lang = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,6))
                //print("read from filter st: \(stId) \(name) \(imageUrl)")
                if (imageUrl != nil && imageUrl == ""){
                    imageUrl = nil
                }
                if (description != nil && description == ""){
                    description = nil
                }
                if (lat != nil && lat == ""){
                    lat = nil
                }
                if (lang != nil && lang == ""){
                    lang = nil
                }
                let post = Post(userName: userName!, imageUrl: imageUrl!, uID: userId!, lat: lat, lang: lang, description: description, postID: postId)
                post.lastUpdate = Date.fromFirebase(update)
                posts.append(post)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return posts
    }

}
