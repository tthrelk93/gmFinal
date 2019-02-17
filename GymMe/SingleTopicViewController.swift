//
//  SingleTopicViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 2/17/19.
//  Copyright © 2019 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class SingleTopicViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, CommentLike {
    func likeComment() {
        
    }
    
    var collectType = "comments"
    var commentData = [[String:Any]]()
    var likeData = [[String:Any]]()
    var topicData = [String:Any]()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectType == "comments"{
            return commentData.count
        } else {
            return likeData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (collectType == "likedBy"){
            let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
            DispatchQueue.main.async{
                cell.contentView.layer.cornerRadius = 2.0
                cell.contentView.layer.borderWidth = 1.0
                cell.contentView.layer.borderColor = UIColor.clear.cgColor
                cell.contentView.layer.masksToBounds = true
                
                // cell.layer.shadowColor = UIColor.gray.cgColor
                //cell.layer.shadowOffset = CGSize(width: 0, height: 2.0);
                //cell.layer.shadowRadius = 2.0;
                //cell.layer.shadowOpacity = 1.0;
                cell.layer.masksToBounds = false
                //cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
                
                if (self.following.contains(self.likeData[indexPath.row]["uid"] as! String)){
                    cell.likedByFollowButton.setTitle("Unfollow", for: .normal)
                }
                cell.likedByName.isHidden = false
                cell.likedByUName.isHidden = false
                cell.likedByFollowButton.isHidden = false
                cell.commentName.isHidden = true
                cell.commentTextView.isHidden = true
                cell.commentTimestamp.isHidden = true
                cell.likedByUName.text = self.likeData[indexPath.row]["uName"] as! String
                
                cell.likedByUID = self.likeData[indexPath.row]["uid"] as! String
                
                cell.likedByName.text = self.likeData[indexPath.row]["realName"] as! String
                if self.likeData[indexPath.row]["pic"] as! String == "profile-placeholder"{
                    DispatchQueue.main.async{
                        cell.likedByImage.image = UIImage(named: "profile-placeholder")
                    }
                } else {
                    if let messageImageUrl = URL(string: self.likeData[indexPath.row]["pic"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            DispatchQueue.main.async{
                                cell.likedByImage.image = UIImage(data: imageData as Data)
                            }
                            
                        }
                        
                        //}
                    }
                }
            }
            return cell
        } else {
            //commentTF.becomeFirstResponder()
            let cell : CommentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCollectionViewCell", for: indexPath) as! CommentCollectionViewCell
            //DispatchQueue.main.async{
            cell.myRealName = self.myName
            cell.posterUID = self.topicData["posterID"] as! String
            
            //cell.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
            cell.postID = self.topicData["postID"] as! String
            cell.commentDelegate = self
            cell.indexPath = indexPath
            cell.contentView.layer.cornerRadius = 2.0
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.masksToBounds = true
            
            
            cell.commentorPic.frame.size = CGSize(width: 35, height: 35)
            
            cell.commentorPic.layer.cornerRadius = cell.commentorPic.frame.width/2
            cell.commentorPic.layer.masksToBounds = true
            
            if self.commentData[indexPath.row]["likes"] as? [[String:Any]] == nil{
                
            } else {
                var tempLikes = self.commentData[indexPath.row]["likes"] as? [[String:Any]]
                
                if tempLikes!.count == 1 {
                    cell.likesCountLabel.text = "1 like"
                } else {
                    cell.likesCountLabel.text = "\(tempLikes!.count) likes"
                }
                cell.likesCount = tempLikes!.count
                
                for dict in tempLikes!{
                    var tempDict = dict as! [String:Any]
                    if (tempDict["uid"] as! String) == Auth.auth().currentUser!.uid{
                        cell.likeButton.setImage(UIImage(named: "likeSelected.png"), for: .normal)
                    }
                    
                }
            }
            
            let nameAndComment = (self.commentData[indexPath.row]["commentorName"] as! String) + " " +  (self.commentData[indexPath.row]["commentText"] as! String)
            print("name&Comment: \(nameAndComment)")
            let boldNameAndComment = self.attributedText(withString: nameAndComment, boldString: (self.commentData[indexPath.row]["commentorName"] as! String), font: cell.commentTextView.font!)
            print("boldName&Comment: \(boldNameAndComment)")
            cell.commentTextView.attributedText = boldNameAndComment
            let tStampDateString = self.commentData[indexPath.row]["commentDate"] as! String
            cell.commentTextView.resolveHashTags()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            let date = dateFormatter.date(from: tStampDateString)
            
            let now = Date()
            //print("tStampDateString: \(tStampDateString), date: \(date!), now: \(now)")
            var hoursBetween = Int(now.days(from: date!))
            print("hrs Between: \(hoursBetween)")
            if hoursBetween < 1{
                hoursBetween = Int(now.hours(from: date!))!
                if hoursBetween < 1 {
                    hoursBetween = Int(now.minutes(from: date!))
                    if hoursBetween == 1{
                        cell.commentTimeStamp.text = "\(hoursBetween) minute ago"
                    } else {
                        cell.commentTimeStamp.text = "\(hoursBetween) minutes ago"
                    }
                } else {
                    if hoursBetween == 1 {
                        cell.commentTimeStamp.text = "\(hoursBetween) hour ago"
                    } else {
                        cell.commentTimeStamp.text = "\(hoursBetween) hours ago"
                    }
                }
            } else {
                if hoursBetween == 1 {
                    cell.commentTimeStamp.text = "\(hoursBetween) day ago"
                } else {
                    cell.commentTimeStamp.text = "\(hoursBetween) days ago"
                }
            }
            
            if self.commentData[indexPath.row]["commentorPic"] as! String == "profile-placeholder"{
                cell.commentorPic.setImage(UIImage(named: "profile-placeholder"), for: .normal)
            } else {
                if let messageImageUrl = URL(string: self.commentData[indexPath.row]["commentorPic"] as! String) {
                    
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        cell.commentorPic.setImage(UIImage(data: imageData as Data), for: .normal)
                    }
                }
            }
            
            return cell
        }
    }
    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedStringKey.font: font])
        let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "TopicToForum", sender: self)
    }
    @IBOutlet weak var topicTopLine1: UIView!
    
    @IBOutlet weak var topicTopLabel: UILabel!
    @IBOutlet weak var topicTopLine2: UIView!
    
    @IBOutlet weak var replyCountButton: UIButton!
    
    @IBAction func replyCountPressed(_ sender: Any) {
    }
    @IBAction func likesCountButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var likesCountButton: UIButton!
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var timeStampLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction func likeButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var topicTitleLabel: UILabel!
    
    @IBOutlet weak var posterPicButton: UIButton!
    
    @IBAction func posterPicButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var topicDescriptionLabel: UILabel!
    
    @IBOutlet weak var likeReplyCollect: UICollectionView!
    
    @IBOutlet weak var commentView: UIView!
    
    @IBOutlet weak var typeCommentTF: UITextField!
    
    @IBOutlet weak var postCommentButton: UIButton!
    
    var myPicString = String()
    var myUName = String()
    var myName = String()
    
    @IBAction func postCommentButtonPressed(_ sender: Any) {
        var textField = typeCommentTF
        
        if textField!.text == "" || textField?.hasText == false {
            
        } else {
            var cellTypeTemp = topicData["postID"] as! String
            var posterID = topicData["posterID"] as! String
           
            Database.database().reference().child("forum").child(cellTypeTemp).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                var commentsArray = valDict["replies"] as! [[String:Any]]
                if commentsArray.count == 1 {
                    if (commentsArray.first! as! [String:Any])["x"] != nil{
                        commentsArray.remove(at: 0)
                    }
                }
                var commentsVal = commentsArray.count
                commentsVal = commentsVal + 1
                if self.myPicString == nil{
                    self.myPicString = "profile-placeholder"
                }
                //add current users id and uName to comment object and upload to database
                var now = Date()
                //var dateFormatter = DateFormatter()
                //var dateString = dateFormatter.string(from: now)
                commentsArray.append(["commentorName": self.myUName, "commentorID": Auth.auth().currentUser!.uid, "commentorPic": self.myPicString, "commentText": self.typeCommentTF.text, "commentDate": now.description])
                Database.database().reference().child("forum").child(cellTypeTemp).child("replies").setValue(commentsArray)
                Database.database().reference().child("users").child(posterID).child("forumPosts").child(cellTypeTemp).child("replies").setValue(commentsArray)
                
                Database.database().reference().child("users").child(posterID).observeSingleEvent(of: .value, with: { (snapshot) in
                    let valDict = snapshot.value as! [String:Any]
                    if valDict["notifications"] as? [[String:Any]] == nil {
                        var tempString = "\(self.myUName) replied to your forum topic."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        var tempDict = (["actionByUID": Auth.auth().currentUser!.uid,"postID": self.topicData["postID"] as! String, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as! [String : Any])
                        
                        print("commentNote: \(tempDict)")
                        Database.database().reference().child("users").child(posterID).updateChildValues((["notifications": [tempDict]] as! [String:Any]))
                        
                    } else {
                        
                        var tempString = "\(self.myUName) replied to your forum topic" as! String
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        var tempDict = (["actionByUID": Auth.auth().currentUser!.uid, "postID": self.topicData["postID"] as! String, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as! [String : Any])
                        
                        //Database.database().reference().child("users").child(uid).updateChildValues((["notifications": [tempDict]] as! [String:Any]))
                        
                        var tempNotifs = valDict["notifications"] as! [[String:Any]]
                        tempNotifs.append(tempDict)
                        print("acommentNote \(posterID)")
                        Database.database().reference().child("users").child(posterID).updateChildValues((["notifications": tempNotifs] as! [String:Any]))
                        
                        
                    }
                    
                    
                    
                    
                    
                    
                    self.typeCommentTF.text = nil
                    
                   
                        
                        let commStringNum = String(commentsArray.count)
                        var commString = String()
                        if commStringNum == "1"{
                            commString = "View \(commStringNum) comment"
                        } else {
                            commString = "View \(commStringNum) comments"
                        }
                        self.replyCountButton.setTitle(commString, for: .normal)
                        
                    
                    
                    //reload collect in delegate
                    self.commentData = commentsArray
                    if commentsArray.count == 1{
                        DispatchQueue.main.async{
                            self.likeReplyCollect.delegate = self
                            self.likeReplyCollect.dataSource = self
                            self.likeReplyCollect.reloadData()
                            /*self.likedByCollect.performBatchUpdates(nil, completion: {
                             (result) in
                             //self.likedByCollect.reloadData()
                             })*/
                        }
                        
                    } else {
                        Database.database().reference().child("forum").child(cellTypeTemp).observeSingleEvent(of: .value, with: { snapshot in
                            let valDict = snapshot.value as! [String:Any]
                            self.commentData = valDict["replies"] as! [[String:Any]]
                            DispatchQueue.main.async{
                                self.likeReplyCollect.reloadData()
                            }
                            
                        })
                      
                        }
                        
                        
                        
                        /*self.likedByCollect.performBatchUpdates(nil, completion: {
                         (result) in
                         
                         })*/
                        //DispatchQueue.main.async{
                        //self.likedByCollect.reloadData()
                        //self.likedByCollect.reloadItems(at: [(self.curCommentCell?.cellIndexPath)!])
                        //}
                    
                })
            })
        }
        self.view.endEditing(true)
       /* if typeCommentTF.hasText == false{
            //alert
        } else {
            //let key = Database.database().reference().child("forum").child((topicData["postID"] as! String)).child(replies).childByAutoId().key
            var newComment = [String:Any]()
            newComment["replyPosterID"] = Auth.auth().currentUser!.uid
            newComment["replyPic"] = self.myPicString
            newComment["replyName"] = self.myName
            newComment["myUName"] = self.myUName
            newComment["replyText"] = typeCommentTF.text!
            newComment["likes"] = [["x":"x"]]
            newComment["timestamp"] = Date().description
            self.commentData.append(newComment)
            Database.database().reference().child("forum").child((topicData["postID"] as! String)).updateChildValues(["replies": commentData])
            Database.database().reference().child("users").child(topicData["posterID"] as! String).child("forumPosts").child(topicData["postID"] as! String).updateChildValues(["replies": commentData])
        }*/
    }
    @IBOutlet weak var commentLineView: UIView!
    
    @IBOutlet weak var commentorPic: UIImageView!
    var following = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.likeReplyCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        
        self.likeReplyCollect.register(UINib(nibName: "CommentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CommentCollectionViewCell")
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            
            let valDict = snapshot.value as! [String:Any]
            self.myName = valDict["realName"] as! String
            self.myUName = valDict["username"] as! String
            self.myPicString = valDict["profPic"] as! String
            self.following = valDict["following"] as! [String]
            self.topicTitleLabel.text = self.topicData["topicTitle"] as! String
            self.topicDescriptionLabel.text = (self.topicData["posterRealName"] as! String)
            self.likeData = self.topicData["likes"] as! [[String:Any]]
            if (self.topicData["replies"] as? [[String:Any]]) == nil{
            
        } else {
            self.commentData = self.topicData["replies"] as! [[String:Any]]
            
        }
            if let messageImageUrl = URL(string: self.topicData["posterPic"] as! String) {
                
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    
                    self.posterImageView.image = UIImage(data: imageData as Data)
                    
                }
            }
            if let messageImageUrl = URL(string: self.myPicString as! String) {
                
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    
                    self.myPic = UIImage(data: imageData as Data)!
                    self.commentorPic.image = UIImage(data: imageData as Data)
                    
                }
            }
            self.likeReplyCollect.delegate = self
            self.likeReplyCollect.dataSource = self
            
        })
        
        
        // Do any additional setup after loading the view.
    }
    var myPic = UIImage()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
