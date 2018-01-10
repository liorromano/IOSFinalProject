//
//  Student+sql.swift
//  TestFb
//
//  Created by Eliav Menachi on 21/12/2016.
//  Copyright © 2016 menachi. All rights reserved.
//

import Foundation


extension Follow{
    static let FOLLOW_TABLE = "FOLLOW"
    static let FOLLOWER_ID = "FOLLOWER_ID"
    static let FOLLOWING_ID = "FOLLOWING_ID"
    static let FOLLOW_ID = "FOLLOW_ID"
    static let FOLLOW_DELETED = "FOLLOW_DELETED"
    static let FOLLOW_LAST_UPDATE = "FOLLOW_LAST_UPDATE"

    
    
    static func createTable(database:OpaquePointer?)->Bool{
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + FOLLOW_TABLE + " ( " + FOLLOW_ID  + " TEXT PRIMARY KEY, "
            + FOLLOWER_ID + " TEXT, "
            + FOLLOWING_ID + " TEXT, " + FOLLOW_DELETED + " TEXT, "
            + FOLLOW_LAST_UPDATE + " DOUBLE)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return false
        }
        
        return true
    }
    
    func addFollowToLocalDb(database:OpaquePointer?){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + Follow.FOLLOW_TABLE
            + "(" + Follow.FOLLOW_ID + ","
            + Follow.FOLLOWER_ID + ","
            + Follow.FOLLOWING_ID + "," + Follow.FOLLOW_DELETED + ","
            + Follow.FOLLOW_LAST_UPDATE + ") VALUES (?,?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            let sql = "INSERT OR REPLACE INTO " + Follow.FOLLOW_TABLE
                + "(" + Follow.FOLLOW_ID + ","
                + Follow.FOLLOWER_ID + ","
                + Follow.FOLLOWING_ID + "," + Follow.FOLLOW_DELETED + ","
                + Follow.FOLLOW_LAST_UPDATE + ") VALUES (?,?,?,?,?);"
            print("insert post to db - \(sql)")
            let followerId = self.followerUID.cString(using: .utf8)
            let followingId = self.followingUID.cString(using: .utf8)
            let followId = self.followID.cString(using: .utf8)
            let deleted = self.deleted?.cString(using: .utf8)

            sqlite3_bind_text(sqlite3_stmt, 1, followId,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, followerId,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, followingId,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 4, deleted,-1,nil);
            if (lastUpdate == nil){
                lastUpdate = Date()
            }
            sqlite3_bind_double(sqlite3_stmt, 5, lastUpdate!.toFirebase());
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func getAllFollowFromLocalDb(database:OpaquePointer?)->[Follow]{
        var follows = [Follow]()
        var sqlite3_stmt: OpaquePointer? = nil
        var sql = ""
        sql = "SELECT * from FOLLOW;"
        if (sqlite3_prepare_v2(database,sql,-1,&sqlite3_stmt,nil) == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let followId =  String(validatingUTF8: sqlite3_column_text(sqlite3_stmt,0))
                let followingId =  String(validatingUTF8: sqlite3_column_text(sqlite3_stmt,2))
                let followerId =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,1))
                let deleted =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,3))
                let update =  Double(sqlite3_column_double(sqlite3_stmt,4))
                let follow = Follow(followerUID: followerId!, followingUID: followingId!, followID: followId!, deleted: deleted)
                follow.lastUpdate = Date.fromFirebase(update)
                follows.append(follow)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return follows
    }
    
}
