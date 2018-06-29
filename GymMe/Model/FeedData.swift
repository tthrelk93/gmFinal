//
//  FeedData.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 6/19/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import Foundation

class FeedData: NSObject {
    
    var posterUID: String?
    var posterName: String?
    var posterPicURL: String?
    var datePosted: String?
    var postText: String?
    var postPic: String?
    var likes: Int?
    var comments: [String:Any]?
    
}
