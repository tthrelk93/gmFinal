//
//  ForumCollectionViewCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 2/10/19.
//  Copyright © 2019 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

protocol ForumDelegate {
    
    func performSegueToPosterProfile(uid: String, name: String)
    //func showLikedByViewTextCell(sentBy: String, cell: NewsFeedCellCollectionViewCell)
    //func showLikedByViewPicCell(sentBy: String, cell: NewsFeedPicCollectionViewCell)
    //func locationButtonTextCellPressed(sentBy: String, cell: NewsFeedCellCollectionViewCell)
    //func locationButtonPicCellPressed(sentBy: String, cell: NewsFeedPicCollectionViewCell)
    func reloadDataAfterLike(newData: [[String:Any]], indexPathRow: Int, likeType: String)
    //func showHashTag(tagType: String, payload:String, postID: String, name: String)
    
    
    
    
}

class ForumCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var posterNameButton: UIButton!
    @IBAction func posterNameButtonPressed(_ sender: Any) {
        delegate?.performSegueToPosterProfile(uid: (self.forumData["posterID"] as! String), name: (self.posterNameLabel.text)!)
    }
    @IBAction func likesCountButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var likesCountButton: UIButton!
    @IBOutlet weak var posterPicImageView: UIImageView!
    @IBOutlet weak var timeStampLabel: UILabel!
    var forumData = [String:Any]()
    var forumID = String()
    var myPic = String()
    var myUName = String()
    var myRealName = String()
    var favoritedTopics: [String]?
    var likedTopics: [String]?
    
    @IBAction func actualLikeTopicPressed(_ sender: Any) {
        print("likePressed")
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let valDict = snapshot.value as! [String:Any]
            self.myPic = valDict["profPic"] as! String
            self.myUName = valDict["username"] as! String
            self.myRealName = valDict["realName"] as! String
            self.likedTopics = valDict["likedTopics"] as? [String]
        })
        if self.actualLikeTopic.imageView?.image == UIImage(named: "like.png"){
            self.actualLikeTopic.setImage(UIImage(named:"likeSelected.png"), for: .normal)
            Database.database().reference().child("forum").child(self.forumID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                var likesArray = valDict["actualLikes"] as! [[String:Any]]
                if likesArray.count == 1 && (likesArray.first! as! [String:String]) == ["x": "x"]{
                    likesArray.remove(at: 0)
                }
                var likesVal = likesArray.count
                likesVal = likesVal + 1
                //if self.myPicString == nil{
                //   self.myPicString = "profile-placeholder"
                //}
                likesArray.append(["uName": self.myUName, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": self.myPic])
                
                if self.likedTopics == nil {
                    self.likedTopics = [self.forumID]
                } else {
                    self.likedTopics!.append(self.forumID)
                }
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("likedTopics").setValue(self.likedTopics!)
                Database.database().reference().child("forum").child(self.forumID).child("actualLikes").setValue(likesArray)
                Database.database().reference().child("users").child((self.forumData["posterID"] as! String)).child("forumPosts").child(self.forumID).child("actualLikes").setValue(likesArray)
                
                Database.database().reference().child("users").child((self.forumData["posterID"] as! String)).observeSingleEvent(of: .value, with: { snapshot in
                    var uploadDict = [String:Any]()
                    var snapDict = snapshot.value as! [String:Any]
                    var noteArray = [[String:Any]]()
                    if snapDict["notifications"] != nil{
                        noteArray = snapDict["notifications"] as! [[String:Any]]
                        let sendString = self.myUName + " liked your forum post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName, "postID": self.forumID, "actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": self.myPic, "postText": self.topicLabel.text as! String, "isForumPost":true] as! [String:Any]
                        noteArray.append(tempDict)
                        Database.database().reference().child("users").child((self.forumData["posterID"] as! String)).updateChildValues(["notifications": noteArray])
                    } else {
                        let sendString = self.myUName + " liked your forum post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName , "postID": self.forumID, "actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": self.myPic, "postText": self.topicLabel.text, "isForumPost":true] as [String : Any]
                        Database.database().reference().child("users").child((self.forumData["posterID"] as! String)).updateChildValues(["notifications":[tempDict]])
                    }
                    
                })
                
                
                
                var likesString = String()
                if likesArray.count == 1 {
                    if(likesArray.first! as! [String:String]) == ["x": "x"]{
                        likesString = "0 likes"
                    } else {
                        likesString = "\(likesArray.count) like"
                    }
                } else {
                    likesString = "\(likesArray.count) likes"
                }
                self.likesCountButton.setTitle(likesString, for: .normal)
                self.delegate?.reloadDataAfterLike(newData: likesArray, indexPathRow: self.indexPath.row, likeType: "actualLike")
                
                //reload collect in delegate
                
            })
            
            //update Database for post with new like count
            
        } else {
            self.actualLikeTopic.setImage(UIImage(named:"like.png"), for: .normal)
            
            Database.database().reference().child("forum").child(self.forumID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                var likesVal = Int()
                var likesArray = valDict["actualLikes"] as! [[String: Any]]
                if likesArray.count == 1 {
                    likesArray.remove(at: 0)
                    likesArray.append(["x": "x"])
                    likesVal = 0
                    
                } else {
                    likesArray.remove(at: 0)
                    likesVal = likesArray.count
                    
                }
                var likesString = String()
                if likesArray.count == 1 {
                    if(likesArray.first! as! [String:String]) == ["x": "x"]{
                        likesString = "0 likes"
                    } else {
                        likesString = "\(likesArray.count) like"
                    }
                } else {
                    likesString = "\(likesArray.count) likes"
                }
                self.likesCountButton.setTitle(likesString, for: .normal)
                
                self.likedTopics!.remove(at: self.likedTopics!.firstIndex(of: self.forumID)!)
                
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("likedTopics").setValue(self.likedTopics!)
                
                Database.database().reference().child("forum").child(self.forumID).child("actualLikes").setValue(likesArray)
                
                
                Database.database().reference().child("users").child((self.forumData["posterID"] as! String)).child("forumPosts").child(self.forumID).child("actualLikes").setValue(likesArray)
                
                self.delegate?.reloadDataAfterLike(newData: likesArray, indexPathRow: self.indexPath.row, likeType: "actualLike")
            })
            
        }
        
    }
    var indexPath = IndexPath()
    @IBOutlet weak var actualLikeTopic: UIButton!
    @IBAction func likeTopicPressed(_ sender: Any) {
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let valDict = snapshot.value as! [String:Any]
            self.myPic = valDict["profPic"] as! String
            self.myUName = valDict["username"] as! String
            self.myRealName = valDict["realName"] as! String
            self.favoritedTopics = valDict["favoritedTopics"] as? [String]
         })
        if self.likeTopicButton.imageView?.image == UIImage(named: "favoritesUnfilled.png"){
            self.likeTopicButton.setImage(UIImage(named:"favoritesFilled.png"), for: .normal)
            
            Database.database().reference().child("forum").child(self.forumID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                var likesArray = valDict["likes"] as! [[String:Any]]
                if likesArray.count == 1 && (likesArray.first! as! [String:String]) == ["x": "x"]{
                    likesArray.remove(at: 0)
                }
                var likesVal = likesArray.count
                likesVal = likesVal + 1
                //if self.myPicString == nil{
                //   self.myPicString = "profile-placeholder"
                //}
                likesArray.append(["uName": self.myUName, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": self.myPic])
                
                if self.favoritedTopics == nil {
                    self.favoritedTopics = [self.forumID]
                } else {
                    self.favoritedTopics!.append(self.forumID)
                }
               Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favoritedTopics").setValue(self.favoritedTopics!)
                Database.database().reference().child("forum").child(self.forumID).child("likes").setValue(likesArray)
                Database.database().reference().child("users").child((self.forumData["posterID"] as! String)).child("forumPosts").child(self.forumID).child("likes").setValue(likesArray)
                Database.database().reference().child("users").child((self.forumData["posterID"] as! String)).observeSingleEvent(of: .value, with: { snapshot in
                    var uploadDict = [String:Any]()
                    var snapDict = snapshot.value as! [String:Any]
                    var noteArray = [[String:Any]]()
                    if snapDict["notifications"] != nil{
                        noteArray = snapDict["notifications"] as! [[String:Any]]
                        let sendString = self.myUName + " liked your forum post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName, "postID": self.forumID, "actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": self.myPic, "postText": self.topicLabel.text as! String, "isForumPost":true] as! [String:Any]
                        noteArray.append(tempDict)
                        Database.database().reference().child("users").child((self.forumData["posterID"] as! String)).updateChildValues(["notifications": noteArray])
                    } else {
                        let sendString = self.myUName + " liked your forum post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName , "postID": self.forumID, "actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": self.myPic, "postText": self.topicLabel.text, "isForumPost":true] as [String : Any]
                        Database.database().reference().child("users").child((self.forumData["posterID"] as! String)).updateChildValues(["notifications":[tempDict]])
                    }
                    
                })
                
                
                
                var likesString = String()
                if likesArray.count == 1 {
                    if(likesArray.first! as! [String:String]) == ["x": "x"]{
                        likesString = "0 likes"
                    } else {
                        likesString = "\(likesArray.count) like"
                    }
                } else {
                    likesString = "\(likesArray.count) likes"
                }
                self.delegate?.reloadDataAfterLike(newData: likesArray, indexPathRow: self.indexPath.row, likeType: "fav")
               
                
            })
            
            //update Database for post with new like count
            
        } else {
            self.likeTopicButton.setImage(UIImage(named:"favoritesUnfilled.png"), for: .normal)
            
            Database.database().reference().child("forum").child(self.forumID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                var likesVal = Int()
                var likesArray = valDict["likes"] as! [[String: Any]]
                if likesArray.count == 1 {
                    likesArray.remove(at: 0)
                    likesArray.append(["x": "x"])
                    likesVal = 0
                    
                } else {
                    likesArray.remove(at: 0)
                    likesVal = likesArray.count
                    
                }
                var likesString = String()
                if likesArray.count == 1 {
                    if(likesArray.first! as! [String:String]) == ["x": "x"]{
                        likesString = "0 likes"
                    } else {
                        likesString = "\(likesArray.count) like"
                    }
                } else {
                    likesString = "\(likesArray.count) likes"
                }
                //self.likesCountButton.setTitle(likesString, for: .normal)
                if((self.favoritedTopics?.contains(self.forumID))!){
                self.favoritedTopics!.remove(at: self.favoritedTopics!.firstIndex(of: self.forumID)!)
                } else {
                    print("aready removed")
                }
                
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favoritedTopics").setValue(self.favoritedTopics!)
                
                Database.database().reference().child("forum").child(self.forumID).child("likes").setValue(likesArray)
                
                
                Database.database().reference().child("users").child((self.forumData["posterID"] as! String)).child("forumPosts").child(self.forumID).child("likes").setValue(likesArray)
                
                self.delegate?.reloadDataAfterLike(newData: likesArray, indexPathRow: self.indexPath.row, likeType: "fav")
            })
            
        }
        
        
        
    }
    var delegate: ForumDelegate!
    @IBOutlet weak var likeTopicButton: UIButton!
    @IBAction func replyCountButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var replyCountButton: UIButton!
    
    @IBOutlet weak var posterNameLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBAction func posterPicButtonPressed(_ sender: Any) {
        //go to profile
        delegate?.performSegueToPosterProfile(uid: (self.forumData["posterID"] as! String), name: (self.posterNameLabel.text)!)
    }
    @IBOutlet weak var posterPicButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        posterPicImageView.frame = CGRect(x: posterPicImageView.frame.origin.x, y: posterPicImageView.frame.origin.y, width: 60, height: 60)
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        self.likeTopicButton.setImage(UIImage(named: "favoritesUnfilled"), for: .normal)
    }

}
