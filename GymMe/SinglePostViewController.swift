//
//  SinglePostViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 11/2/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class SinglePostViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UITextViewDelegate, HashDelegate {
    func goToHash(tagType: String, payload: String) {
        showHashTagAlert(tagType: "hash", payload: payload)
    }
    
    func goToMention(tagType: String, payload: String) {
        showHashTagAlert(tagType: "mention", payload: payload)
    }
    
    var prevScreen = String()
    var senderScreen = String()
    var hashtag = String()
    
    @IBOutlet weak var topLine: UIView!
    @IBAction func backPressed(_ sender: Any) {
        if senderScreen == "notification"{
            performSegue(withIdentifier: "backToNote", sender: self)
        } else if prevScreen == "advancedSearch"{
            performSegue(withIdentifier: "SinglePostToAdvancedSearch", sender: self)
        } else if prevScreen == "messages"{
            performSegue(withIdentifier: "SinglePostToMessages", sender: self)
        } else if prevScreen == "Favorites"{
            performSegue(withIdentifier: "SinglePostToFav", sender: self)
        } else if prevScreen == "hash"{
            performSegue(withIdentifier: "SinglePostToHash", sender: self)
        }else {
            performSegue(withIdentifier: "backToProfile", sender: self)
        }
    }
    @IBAction func sharePressed(_ sender: Any) {
        activityViewController = UIActivityViewController(
            activityItems: ["Download GymMe today!"],
            applicationActivities: nil)
        
        present(activityViewController!, animated: true, completion: nil)
    }
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        print("here000")
       // print("df: \(self.favoritesButton.currentImage)")
        if self.favoritesButton.imageView?.image == UIImage(named: "favoritesUnfilled.png"){
            self.favoritesButton.setImage(UIImage(named:"favoritesFilled.png"), for: .normal)
            print("here111")
            Database.database().reference().child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                var favoritesArray = valDict["favorites"] as! [[String:Any]]
                if favoritesArray.count == 1 && (favoritesArray.first! as! [String:String]) == ["x": "x"]{
                    favoritesArray.remove(at: 0)
                }
                var favesVal = favoritesArray.count
                favesVal = favesVal + 1
                if self.myPicString == nil{
                    self.myPicString = "profile-placeholder"
                }
                favoritesArray.append(["uName": self.myUName, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": self.myPicString])
                
                Database.database().reference().child("posts").child(self.postID).child("favorites").setValue(favoritesArray)
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("favorites").setValue(favoritesArray)
               
                var tempDict = self.thisPostData
                if tempDict["posterPicURLString"] != nil{
                tempDict["posterPicURL"] = tempDict["posterPicURLString"]
                
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").updateChildValues([self.postID: tempDict])
                } else {
                    Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").updateChildValues([self.postID: self.thisPostData])
                }
                // self.favoritesCountButton.setTitle(String(favoritesArray.count), for: .normal)
                Database.database().reference().child("users").child(self.posterUID).observeSingleEvent(of: .value, with: { snapshot in
                    var uploadDict = [String:Any]()
                    var snapDict = snapshot.value as! [String:Any]
                    var noteArray = [[String:Any]]()
                    if snapDict["notifications"] != nil{
                        noteArray = snapDict["notifications"] as! [[String:Any]]
                        let sendString = self.myUName + " favorited your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName , "postID": self.postID,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": self.myPicString, "postText": self.postText.text as! String] as! [String:Any]
                        noteArray.append(tempDict)
                        Database.database().reference().child("users").child(self.posterUID).updateChildValues(["notifications": noteArray] as [AnyHashable:Any]){ err, ref in
                            print("done")
                        }
                    } else {
                        let sendString = self.myUName + " favorited your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName ,"postID": self.postID,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": self.myPicString, "postText": self.postText.text] as [String : Any]
                        Database.database().reference().child("users").child(self.posterUID).updateChildValues(["notifications":[tempDict]])
                    }
                    
                })
                
                //reload collect in delegate
                
            })
        } else {
            self.favoritesButton.setImage(UIImage(named:"favoritesUnfilled.png"), for: .normal)
            
            
            Database.database().reference().child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                var favesVal = Int()
                var favesArray = valDict["favorites"] as! [[String: Any]]
                if favesArray.count == 1 {
                    favesArray.remove(at: 0)
                    favesArray.append(["x": "x"])
                    favesVal = 0
                    //self.favoritesCountButton.setTitle("0", for: .normal)
                } else {
                    favesArray.remove(at: 0)
                    favesVal = favesArray.count
                    //self.favoritesCountButton.setTitle(String(favesArray.count), for: .normal)
                }
                Database.database().reference().child("posts").child(self.postID).child("favorites").setValue(favesArray)
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("favorites").setValue(favesArray)
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").child(self.postID).removeValue()
                
            })
        }
    }
    @IBOutlet weak var favoritesButton: UIButton!
    @IBAction func commentButtonPressed(_ sender: Any) {
        commentView.isHidden = false
        commentView.isHidden = false
        commentsCollect.isHidden = false
        likesCollect.isHidden = true
        print("commentsArray: \(commentsArray)")
        commentsCollect.delegate = self
        commentsCollect.dataSource = self
        commentTF.isHidden = false
        postCommentPic.isHidden = false
        postCommentButton.isHidden = false
        commentLine.isHidden = false
    }
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var postText: UITextView!
    @IBAction func commentsCountPressed(_ sender: Any) {
        commentView.isHidden = false
        commentView.isHidden = false
        commentsCollect.isHidden = false
        likesCollect.isHidden = true
        print("commentsArray: \(commentsArray)")
        commentsCollect.delegate = self
        commentsCollect.dataSource = self
        commentTF.isHidden = false
        postCommentPic.isHidden = false
        postCommentButton.isHidden = false
        commentLine.isHidden = false
    }
    @IBOutlet weak var commentsCountButton: UIButton!
    @IBOutlet weak var likesCountButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBAction func likesCountButtonPressed(_ sender: Any) {
        commentView.isHidden = false
        commentsCollect.isHidden = true
        likesCollect.isHidden = false
    }
    @IBAction func likeButtonPressed(_ sender: Any) {
        var myPic = String()
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let valDict = snapshot.value as! [String:Any]
            myPic = valDict["profPic"] as! String
            
        })
        
        if self.likeButton.imageView?.image == UIImage(named: "like.png"){
            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
            // let curLikes = Int((self.likesCountButton.titleLabel?.text)!)
            //self.likesCountButton.setTitle(String(curLikes! + 1), for: .normal)
            Database.database().reference().child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                var likesArray = valDict["likes"] as! [[String:Any]]
                if likesArray.count == 1 && (likesArray.first! as! [String:String]) == ["x": "x"]{
                    likesArray.remove(at: 0)
                }
                var likesVal = likesArray.count
                likesVal = likesVal + 1
                // if self.myPicString == nil{
                // self.myPicString = "profile-placeholder"
                //}
                likesArray.append(["uName": self.myUName, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": myPic])
                
                
                Database.database().reference().child("posts").child(self.postID).child("likes").setValue(likesArray)
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("likes").setValue(likesArray)
                
                
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
                
                // self.delegate?.reloadDataAfterLike()
                Database.database().reference().child("users").child(self.posterUID).observeSingleEvent(of: .value, with: { snapshot in
                    var uploadDict = [String:Any]()
                    var snapDict = snapshot.value as! [String:Any]
                    var noteArray = [[String:Any]]()
                    if snapDict["notifications"] != nil{
                        noteArray = snapDict["notifications"] as! [[String:Any]]
                        let sendString = self.myUName + " liked your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName ,"postID": self.postID,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": myPic, "postText": self.postText.text!] as! [String:Any]
                        noteArray.append(tempDict)
                        Database.database().reference().child("users").child(self.posterUID).updateChildValues(["notifications": noteArray])
                    } else {
                        let sendString = self.myUName + " liked your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName ,"postID": self.postID,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": myPic, "postText": self.postText.text] as [String : Any]
                        Database.database().reference().child("users").child(self.posterUID).updateChildValues(["notifications":[tempDict]])
                    }
                    
                })
                
            })
            
            //update Database for post with new like count
            
        } else {
            self.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
            
            Database.database().reference().child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                var likesVal = Int()
                var likesArray = valDict["likes"] as! [[String: Any]]
                var likesString = String()
                if likesArray.count == 1 {
                    likesArray.remove(at: 0)
                    likesArray.append(["x":"x"])
                    likesVal = 0
                    
                } else {
                    likesArray.remove(at: 0)
                    likesVal = likesArray.count
                    //likesString = "\(likesArray.count) likes"
                    
                }
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
                 Database.database().reference().child("posts").child(self.postID).child("likes").setValue(likesArray)
                
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("likes").setValue(likesArray)
                
            })
        }
        DispatchQueue.main.async {
            //self.reloadDataAfterLike()
        }
    }
    @IBOutlet weak var postPic: UIImageView!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var commentsCollect: UICollectionView!
    @IBAction func closeCommentsButtonPressed(_ sender: Any) {
        commentView.isHidden = true
    }
    @IBOutlet weak var commentView: UIView!
    
    @IBAction func posterPicButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var posterNameButton: UIButton!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var posterPicButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tpPostCommentSep: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var likesCollect: UICollectionView!
    @IBOutlet weak var tpLikeButton: UIButton!
    @IBAction func tpLikeButtonPressed(_ sender: Any) {
        var myPic = String()
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let valDict = snapshot.value as! [String:Any]
            myPic = valDict["profPic"] as! String
            
        })
        
        if self.tpLikeButton.imageView?.image == UIImage(named: "like.png"){
            self.tpLikeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
            
            Database.database().reference().child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                var likesArray = valDict["likes"] as! [[String:Any]]
                if likesArray.count == 1 && (likesArray.first! as! [String:String]) == ["x": "x"]{
                    likesArray.remove(at: 0)
                }
                var likesVal = likesArray.count
                likesVal = likesVal + 1
                // if self.myPicString == nil{
                // self.myPicString = "profile-placeholder"
                //}
                likesArray.append(["uName": self.myUName, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": myPic])
                
                
                Database.database().reference().child("posts").child(self.postID).child("likes").setValue(likesArray)
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("likes").setValue(likesArray)
                
                
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
                self.tpLikesCount.setTitle(likesString, for: .normal)
                
                // self.delegate?.reloadDataAfterLike()
                Database.database().reference().child("users").child(self.posterUID).observeSingleEvent(of: .value, with: { snapshot in
                    var uploadDict = [String:Any]()
                    var snapDict = snapshot.value as! [String:Any]
                    var noteArray = [[String:Any]]()
                    if snapDict["notifications"] != nil{
                        noteArray = snapDict["notifications"] as! [[String:Any]]
                        let sendString = self.myUName + " liked your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName ,"postID": self.postID,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": myPic, "postText": self.postText.text!] as! [String:Any]
                        noteArray.append(tempDict)
                        Database.database().reference().child("users").child(self.posterUID).updateChildValues(["notifications": noteArray])
                    } else {
                        let sendString = self.myUName + " liked your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName ,"postID": self.postID,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": myPic, "postText": self.postText.text] as [String : Any]
                        Database.database().reference().child("users").child(self.posterUID).updateChildValues(["notifications":[tempDict]])
                    }
                    
                })
                
            })
            
            //update Database for post with new like count
            
        } else {
            self.tpLikeButton.setImage(UIImage(named:"like.png"), for: .normal)
            
            Database.database().reference().child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                var likesVal = Int()
                var likesArray = valDict["likes"] as! [[String: Any]]
                var likesString = String()
                if likesArray.count == 1 {
                    likesArray.remove(at: 0)
                    likesArray.append(["x":"x"])
                    likesVal = 0
                    
                } else {
                    likesArray.remove(at: 0)
                    likesVal = likesArray.count
                    //likesString = "\(likesArray.count) likes"
                    
                }
                if likesArray.count == 1 {
                    if(likesArray.first! as! [String:String]) == ["x": "x"]{
                        likesString = "0 likes"
                    } else {
                        likesString = "\(likesArray.count) like"
                    }
                } else {
                    likesString = "\(likesArray.count) likes"
                }
                
                self.tpLikesCount.setTitle(likesString, for: .normal)

                Database.database().reference().child("posts").child(self.postID).child("likes").setValue(likesArray)
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("likes").setValue(likesArray)
        
            })
        }
        
    }
    @IBOutlet weak var tpFaveButton: UIButton!
    @IBAction func tpFaveButtonPressed(_ sender: Any) {
        print("here000")
        //print("df: \(self.favoritesButton.currentBackgroundImage)")
        
        if self.tpFaveButton.imageView?.image == UIImage(named: "favoritesUnfilled.png"){
            self.tpFaveButton.setImage(UIImage(named:"favoritesFilled.png"), for: .normal)
            print("here111")
            Database.database().reference().child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                var favoritesArray = valDict["favorites"] as! [[String:Any]]
                if favoritesArray.count == 1 && (favoritesArray.first! as! [String:String]) == ["x": "x"]{
                    favoritesArray.remove(at: 0)
                }
                var favesVal = favoritesArray.count
                favesVal = favesVal + 1
                if self.myPicString == nil{
                    self.myPicString = "profile-placeholder"
                }
                favoritesArray.append(["uName": self.myUName, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": self.myPicString])
                
                Database.database().reference().child("posts").child(self.postID).child("favorites").setValue(favoritesArray)
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("favorites").setValue(favoritesArray)
                
                var tempDict = self.thisPostData
                if tempDict["posterPicURLString"] != nil{
                    tempDict["posterPicURL"] = tempDict["posterPicURLString"]
                    
                    Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").updateChildValues([self.postID: tempDict])
                } else {
                    Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").updateChildValues([self.postID: self.thisPostData])
                }
                
                // self.favoritesCountButton.setTitle(String(favoritesArray.count), for: .normal)
                Database.database().reference().child("users").child(self.posterUID).observeSingleEvent(of: .value, with: { snapshot in
                    var uploadDict = [String:Any]()
                    var snapDict = snapshot.value as! [String:Any]
                    var noteArray = [[String:Any]]()
                    if snapDict["notifications"] != nil{
                        noteArray = snapDict["notifications"] as! [[String:Any]]
                        let sendString = self.myUName + " favorited your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName , "postID": self.postID,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": self.myPicString, "postText": self.postText.text as! String] as! [String:Any]
                        noteArray.append(tempDict)
                        Database.database().reference().child("users").child(self.posterUID).updateChildValues(["notifications": noteArray] as [AnyHashable:Any]){ err, ref in
                            print("done")
                        }
                    } else {
                        let sendString = self.myUName + " favorited your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName ,"postID": self.postID,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": self.myPicString, "postText": self.postText.text] as [String : Any]
                        Database.database().reference().child("users").child(self.posterUID).updateChildValues(["notifications":[tempDict]])
                    }
                    
                })
            })
        } else {
            self.tpFaveButton.setImage(UIImage(named:"favoritesUnfilled.png"), for: .normal)
            
            
            Database.database().reference().child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                var favesVal = Int()
                var favesArray = valDict["favorites"] as! [[String: Any]]
                if favesArray.count == 1 {
                    favesArray.remove(at: 0)
                    favesArray.append(["x": "x"])
                    favesVal = 0
                    //self.favoritesCountButton.setTitle("0", for: .normal)
                } else {
                    favesArray.remove(at: 0)
                    favesVal = favesArray.count
                    //self.favoritesCountButton.setTitle(String(favesArray.count), for: .normal)
                }
                Database.database().reference().child("posts").child(self.postID).child("favorites").setValue(favesArray)
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("favorites").setValue(favesArray)
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").child(self.postID).removeValue()
                
            })
            
        }
        
    }
    @IBOutlet weak var tpCommentButton: UIButton!
    @IBAction func tpCommentButtonPressed(_ sender: Any) { }
    @IBOutlet weak var tpShareButton: UIButton!
    @IBAction func tpShareButtonPressed(_ sender: Any) { }
    @IBAction func tpCommentEditingDidBegin(_ sender: Any) {}
    @IBAction func tpCommentEditingDidEnd(_ sender: Any) {}
    @IBOutlet weak var tpView: UIView!
    @IBOutlet weak var tpLikesCount: UIButton!
    @IBAction func tpLikesCountButtonPressed(_ sender: Any) {}
    @IBAction func tpPostCommentButtonPressed(_ sender: Any) {
        var textField = tpCommentTF
        if textField!.text == "" || textField?.hasText == false {
            
        } else {
            var cellTypeTemp = String()
            var posterID = String()
            var postID = thisPostData["postID"] as! String
            cellTypeTemp = thisPostData["postID"] as! String
            posterID = self.posterUID
            
            Database.database().reference().child("posts").child(cellTypeTemp).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                var commentsArray = valDict["comments"] as! [[String:Any]]
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
                var now = Date()
                
                commentsArray.append(["commentorName": self.myUName, "commentorID": Auth.auth().currentUser!.uid, "commentorPic": self.myPicString, "commentText": self.tpCommentTF.text, "commentDate": now.description])
                Database.database().reference().child("posts").child(cellTypeTemp).child("comments").setValue(commentsArray)
                Database.database().reference().child("users").child(posterID).child("posts").child(cellTypeTemp).child("comments").setValue(commentsArray)
                
                Database.database().reference().child("users").child(posterID).observeSingleEvent(of: .value, with: { (snapshot) in
                    let valDict = snapshot.value as! [String:Any]
                    if valDict["notifications"] as? [[String:Any]] == nil {
                        var tempString = "\(self.myUName) commented on your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        var tempDict = (["actionByUID": Auth.auth().currentUser!.uid,"postID": postID, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as! [String : Any])
                        
                        print("commentNote: \(tempDict)")
                        Database.database().reference().child("users").child(posterID).updateChildValues((["notifications": [tempDict]] as! [String:Any]))
                        
                    } else {
                        
                        var tempString = "\(self.myUName) commented on your post." as! String
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        var tempDict = (["actionByUID": Auth.auth().currentUser!.uid, "postID": postID, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as! [String : Any])
                        
                        
                        
                        var tempNotifs = valDict["notifications"] as! [[String:Any]]
                        tempNotifs.append(tempDict)
                        print("acommentNote \(posterID)")
                        Database.database().reference().child("users").child(posterID).updateChildValues((["notifications": tempNotifs] as! [String:Any]))
 
                    }

                    self.tpCommentTF.text = nil
                    
                    if self.thisPostData["postPic"] as? String != nil{
                        
                        let commStringNum = String(commentsArray.count)
                        var commString = String()
                        if commStringNum == "1"{
                            commString = "View \(commStringNum) comment"
                        } else {
                            commString = "View \(commStringNum) comments"
                        }
                    } else {
                        let commStringNum = String(commentsArray.count)
                        var commString = String()
                        if commStringNum == "1"{
                            commString = "View \(commStringNum) comment"
                        } else {
                            commString = "View \(commStringNum) comments"
                        }
                    }
                    self.commentsArray = commentsArray
                    if commentsArray.count == 1{
                        DispatchQueue.main.async{
                            self.tpCommentCollect.delegate = self
                            self.tpCommentCollect.dataSource = self
                            self.tpCommentCollect.reloadData()
                        }
                    } else {
                        Database.database().reference().child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
                            var tempDict = snapshot.value as! [String:Any]
                            if tempDict["postPic"] == nil && tempDict["postVid"] == nil{
                                //text
                                if (tempDict["posterPicURL"] as! String) == "profile-placeholder"{
                                    
                                    var tempImage = UIImage(named: "profile-placeholder")
                                    tempDict["posterPicURL"] = tempImage
                                    
                                } else {
                                    if let messageImageUrl = URL(string: (tempDict["posterPicURL"] as! String)) {
                                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                            
                                            var tempImage = UIImage(data: imageData as Data)
                                            tempDict["posterPicURL"] = tempImage
                                            
                                        }
                                    }
                                }
                            } else {
                                if (tempDict["posterPicURL"] as! String) == "profile-placeholder"{
                                    
                                    var tempImage = UIImage(named: "profile-placeholder")
                                    tempDict["posterPicURL"] = tempImage
                                    
                                } else {
                                    if let messageImageUrl = URL(string: (tempDict["posterPicURL"] as! String)) {
                                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                            
                                            var tempImage = UIImage(data: imageData as Data)
                                            tempDict["posterPicURL"] = tempImage
                                            
                                        }
                                    }
                                }
                                if tempDict["postPic"] != nil{
                                    var picString = tempDict["postPic"] as! String
                                    
                                    if let messageImageUrl = URL(string: picString) {
                                        
                                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                            var pic = UIImage(data: imageData as Data)
                                            tempDict["postPic"] = pic as! UIImage
                                        }
                                    }
                                } else {
                                    //vid
                                    
                                    tempDict["postVid"] = URL(string: tempDict["postVid"] as! String)!
                                    
                                }
                            }
                            self.thisPostData = tempDict
                            self.commentsArray = ((self.thisPostData["comments"] as? [[String: Any]])!)
                            if(self.commentsArray.count == 1 && self.commentsArray[0]["x"] != nil){
                                self.commentsArray.removeAll()
                            }
                            DispatchQueue.main.async{
                                
                                self.tpCommentCollect.reloadData()
                            }
                            
                        })
                        
                    }
                    
                })
            })
        }
        self.view.endEditing(true)
    }
    @IBOutlet weak var tpCommentTopLine: UIView!
    @IBOutlet weak var tpPostCommentButton: UIButton!
    @IBOutlet weak var tpCommentorPic: UIImageView!
    @IBOutlet weak var tpCommentTF: UITextField!
    @IBOutlet weak var tpCommentView: UIView!
    @IBOutlet weak var tpCommentCollect: UICollectionView!
    @IBOutlet weak var commentLine: UIView!
    @IBOutlet weak var postCommentPic: UIImageView!
    @IBOutlet weak var postCommentButton: UIButton!
    @IBAction func postCommentButtonPressed(_ sender: Any) {
        var textField = commentTF
        
        if textField!.text == "" || textField?.hasText == false {
            
        } else {
            var cellTypeTemp = String()
            var posterID = String()
            var postID = thisPostData["postID"] as! String
            cellTypeTemp = thisPostData["postID"] as! String
            posterID = self.posterUID
            
            Database.database().reference().child("posts").child(cellTypeTemp).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                var commentsArray = valDict["comments"] as! [[String:Any]]
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
                var now = Date()
                
                commentsArray.append(["commentorName": self.myUName, "commentorID": Auth.auth().currentUser!.uid, "commentorPic": self.myPicString, "commentText": self.commentTF.text, "commentDate": now.description])
                Database.database().reference().child("posts").child(cellTypeTemp).child("comments").setValue(commentsArray)
                Database.database().reference().child("users").child(posterID).child("posts").child(cellTypeTemp).child("comments").setValue(commentsArray)
                
                Database.database().reference().child("users").child(posterID).observeSingleEvent(of: .value, with: { (snapshot) in
                    let valDict = snapshot.value as! [String:Any]
                    if valDict["notifications"] as? [[String:Any]] == nil {
                        var tempString = "\(self.myUName) commented on your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        var tempDict = (["actionByUID": Auth.auth().currentUser!.uid,"postID": postID, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as! [String : Any])
                        
                        print("commentNote: \(tempDict)")
                        Database.database().reference().child("users").child(posterID).updateChildValues((["notifications": [tempDict]] as! [String:Any]))
                        
                    } else {
                        
                        var tempString = "\(self.myUName) commented on your post." as! String
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        var tempDict = (["actionByUID": Auth.auth().currentUser!.uid, "postID": postID, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as! [String : Any])
                        
                        
                        
                        var tempNotifs = valDict["notifications"] as! [[String:Any]]
                        tempNotifs.append(tempDict)
                        print("acommentNote \(posterID)")
                        Database.database().reference().child("users").child(posterID).updateChildValues((["notifications": tempNotifs] as! [String:Any]))
                        
                    }
                    self.commentTF.text = nil
                    
                    if self.thisPostData["postPic"] as? String != nil{
                        
                        let commStringNum = String(commentsArray.count)
                        var commString = String()
                        if commStringNum == "1"{
                            commString = "View \(commStringNum) comment"
                        } else {
                            commString = "View \(commStringNum) comments"
                        }
                        self.commentsCountButton.setTitle(commString, for: .normal)
                        
                    } else {
                        
                        
                        let commStringNum = String(commentsArray.count)
                        var commString = String()
                        if commStringNum == "1"{
                            commString = "View \(commStringNum) comment"
                        } else {
                            commString = "View \(commStringNum) comments"
                        }
                        self.commentsCountButton.setTitle(commString, for: .normal)
                        
                    }
                    self.commentsArray = commentsArray
                    if(self.commentsArray.count == 1 && self.commentsArray[0]["x"] != nil){
                        self.commentsArray.removeAll()
                    }
                    if commentsArray.count == 1{
                        DispatchQueue.main.async{
                            self.commentsCollect.delegate = self
                            self.commentsCollect.dataSource = self
                            self.commentsCollect.reloadData()
                            
                        }
                        
                    } else {
                        
                        print("reloading here")
                        
                        Database.database().reference().child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
                            var tempDict = snapshot.value as! [String:Any]
                            if tempDict["postPic"] == nil && tempDict["postVid"] == nil{
                                //text
                                if (tempDict["posterPicURL"] as! String) == "profile-placeholder"{
                                    
                                    var tempImage = UIImage(named: "profile-placeholder")
                                    tempDict["posterPicURL"] = tempImage
                                    
                                } else {
                                    if let messageImageUrl = URL(string: (tempDict["posterPicURL"] as! String)) {
                                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                            
                                            var tempImage = UIImage(data: imageData as Data)
                                            tempDict["posterPicURL"] = tempImage
                                            
                                        }
                                    }
                                }
                            } else {
                                if (tempDict["posterPicURL"] as! String) == "profile-placeholder"{
                                    
                                    var tempImage = UIImage(named: "profile-placeholder")
                                    tempDict["posterPicURL"] = tempImage
                                    
                                } else {
                                    if let messageImageUrl = URL(string: (tempDict["posterPicURL"] as! String)) {
                                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                            
                                            var tempImage = UIImage(data: imageData as Data)
                                            tempDict["posterPicURL"] = tempImage
                                            
                                        }
                                    }
                                }
                                if tempDict["postPic"] != nil{
                                    var picString = tempDict["postPic"] as! String
                                    
                                    if let messageImageUrl = URL(string: picString) {
                                        
                                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                            var pic = UIImage(data: imageData as Data)
                                            tempDict["postPic"] = pic as! UIImage
                                            
                                            
                                        }
                                    }
                                } else {
                                    //vid
                                    
                                    tempDict["postVid"] = URL(string: tempDict["postVid"] as! String)!
                                    
                                }
                            }
                            self.thisPostData = tempDict
                            self.commentsArray = ((self.thisPostData["comments"] as? [[String: Any]])!)
                            if(self.commentsArray.count == 1 && self.commentsArray[0]["x"] != nil){
                                self.commentsArray.removeAll()
                            }
                            DispatchQueue.main.async{
                                
                                self.commentsCollect.reloadData()
                            }
                            
                        })
                        
                    }
                    
                })
            })
        }
        self.view.endEditing(true)
    }
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var commentTopLine: UIView!
    @IBOutlet weak var commentTopLabel: UILabel!
    @IBOutlet weak var backFromComments: UIButton!
    @objc func playOrPause(){
        if self.player?.playbackState == PlaybackState.paused || self.player?.playbackState == PlaybackState.stopped{
            if self.player?.playbackState == PlaybackState.paused{
                player?.playFromCurrentTime()
            } else {
                player?.playFromBeginning()
            }
        } else {
            player?.stop()
        }
    }
    var thisPostData = [String:Any]()
    var activityViewController:UIActivityViewController?
    var myPicString = String()
    var postID = String()
    var posterUID = String()
    var player: Player?
    var myUName = String()
    var commentsArray = [[String:Any]]()
    var likesArray = [[String:Any]]()
    var advancedData = [String:Any]()
    var myRealName = String()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
         scrollView.contentSize = CGSize(width: self.view.frame.width,height: self.view.frame.height+200)
        commentTF.frame.size = CGSize(width: commentTF.frame.width, height: 29)
        tpCommentTF.frame.size = CGSize(width: commentTF.frame.width, height: 29)
        postCommentPic.frame.size = CGSize(width: 25, height: 25)
        
        postCommentPic.layer.cornerRadius = postCommentPic.frame.width/2
        postCommentPic.layer.masksToBounds = true
        
        
        tpCommentorPic.frame.size = CGSize(width: 25, height: 25)
        tpCommentorPic.layer.cornerRadius = tpCommentorPic.frame.width/2
        tpCommentorPic.layer.masksToBounds = true
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: {(snapshot) in
            var curUser = snapshot.value as! [String:Any]
            self.myUName = curUser["username"] as! String
            self.myRealName = curUser["realName"] as! String
            if let messageImageUrl = URL(string: (curUser["profPic"] as! String)) {
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    self.postCommentPic.image = UIImage(data: imageData as Data)
                    self.tpCommentorPic.image = UIImage(data: imageData as Data)
                    
                }
            }
        self.tpPostCommentSep.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
            self.topLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
            self.commentTopLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
            self.tpCommentTopLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        
            self.posterPicButton.frame.size = CGSize(width: 40, height: 40)
            self.posterPicButton.layer.cornerRadius = self.posterPicButton.frame.width/2
            self.posterPicButton.layer.masksToBounds = true
       
            self.postTextView.delegate = self
            self.postText.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
        Database.database().reference().child("posts").child(self.thisPostData["postID"] as! String).observeSingleEvent(of: .value, with: {(snapshot) in
            if self.prevScreen == "advancedSearch"{
            
                self.thisPostData = snapshot.value as! [String:Any]
                
            
        }
            self.posterPicButton.frame = CGRect(x: self.posterPicButton.frame.origin.x, y: self.posterPicButton.frame.origin.y, width: 40.0, height: 40.0)
            self.postID = self.thisPostData["postID"] as! String
            self.posterUID = self.thisPostData["posterUID"] as! String
        //posterPicButton.layer.cornerRadius = posterPicButton.frame.width/2
        //posterPicButton.layer.masksToBounds = true
        
            self.commentsCollect.register(UINib(nibName: "CommentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CommentCollectionViewCell")
            self.tpCommentCollect.register(UINib(nibName: "CommentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CommentCollectionViewCell")
        
            self.likesCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        

            self.commentTF.delegate = self
            self.tpCommentTF.delegate = self
        
            if self.thisPostData["postVid"] == nil && self.thisPostData["postPic"] == nil{
            //textPost
                self.posterNameButton.setTitle((self.thisPostData["posterName"] as! String), for: .normal)
                if self.prevScreen == "Favorites"{
                    self.posterPicButton.setImage(self.thisPostData["posterPicURL"] as! UIImage, for: .normal)
                } else {
            if let messageImageUrl = URL(string: (self.thisPostData["posterPicURL"] as! String)) {
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    
                    self.posterPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                    
                    
                }
            }
                }
           
                if self.thisPostData["postText"] == nil{
                print("nilText")
            } else {
                    print("textPostSizingTime")
                    self.commentsCountButton.frame = CGRect(x: self.commentsCountButton.frame.origin.x, y: self.postText.frame.origin.y + 8, width: self.commentsCountButton.frame.width, height: self.commentsCountButton.frame.height)
                    self.postTextView.isHidden = false
                    self.tpView.isHidden = false
                    self.likesCountButton.isHidden = true
                    self.likeButton.isHidden = true
                    self.favoritesButton.isHidden = true
                    self.commentButton.isHidden = true
                    self.shareButton.isHidden = true
                    //self.postTextView.text = (self.thisPostData["postText"] as! String)
                    let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]
                    let attributedString = NSMutableAttributedString(string:(self.thisPostData["postText"] as! String), attributes:attrs)
                    
                    self.postTextView.attributedText = attributedString
                    let fixedWidth = self.postTextView.frame.size.width
                    
                    let newSize = self.postTextView.sizeThatFits(CGSize(width: fixedWidth, height: self.estimateFrameForText(text: self.postTextView.text as! String).height))
                    print("sizeForText:\(newSize), \(self.postTextView.isHidden)")
                    self.postTextView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                    
                    self.postTextView.isScrollEnabled = false
                    self.commentsCountButton.frame.origin = CGPoint(x: self.commentsCountButton.frame.origin.x, y: self.postTextView.frame.origin.y + self.postTextView.frame.height)
                    var x = self.tpView.frame.origin.x
                    var w = self.tpView.frame.width
                    var y = self.postTextView.frame.origin.y + self.postTextView.frame.height + self.posterNameButton.frame.origin.y + 60
                    var h = abs(y - UIScreen.main.bounds.maxY)
                    // Figure out proper dynamic sizing since view all comments will be hidden.
                    self.commentsCountButton.isHidden = true
                    self.tpView.frame = CGRect(x: x, y: y, width: w, height: h)
                    self.tpCommentorPic.frame.size = CGSize(width: self.tpCommentTF.frame.height, height: self.tpCommentTF.frame.height)
                    
                    self.scrollView.isScrollEnabled = false
                   
            }
                self.postTextView.resolveHashTags()
                
                if self.thisPostData["city"] != nil{
                    self.cityButton.setTitle((self.thisPostData["city"] as! String), for: .normal)
            }
            
            var commentsPost: [String:Any]?
            for item in (self.thisPostData["comments"] as? [[String: Any]])!{
                
                commentsPost = item as! [String: Any]
                
            }
            
            var tempPost: [String:Any]?
            self.likesArray = ((self.thisPostData["likes"] as? [[String: Any]])!)
            
                self.likesCollect.delegate = self
                self.likesCollect.dataSource = self
                var likedBySelf = false
            for item in (self.thisPostData["likes"] as? [[String: Any]])!{
                
                tempPost = item as! [String: Any]
                if tempPost!.count == 1 && tempPost!["x"] != nil{
                    
                } else {
                    if (tempPost!["uName"] as! String) == self.myUName{
                        likedBySelf = true
                    }
                }
                
            }
            if tempPost!["x"] != nil {
                
            } else {
                
                
                let countStringNum = String((self.thisPostData["likes"] as? [[String: Any]])!.count)
                
                var fullString1 = String()
                if countStringNum == "1"{
                    fullString1 = "\(countStringNum) like"
                } else {
                    fullString1 = "\(countStringNum) likes"
                }
               
                
               self.tpLikesCount.setTitle(fullString1, for: .normal)
                self.likesCountButton.setTitle(fullString1, for: .normal)
                
                if (likedBySelf == true){
                   
                   self.tpLikeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                    self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                    let countStringNum = String((self.thisPostData["likes"] as? [[String: Any]])!.count)
                    var fullString = String()
                    if countStringNum == "1"{
                        fullString = "\(countStringNum) like"
                    } else {
                        fullString = "\(countStringNum) likes"
                    }
                    self.likesCountButton.setTitle(fullString, for: .normal)
                    self.tpLikesCount.setTitle(fullString, for: .normal)
                    
                }
            }
            var favedBySelf = false
            var favesPost: [String:Any]?
                var thisFaves = (self.thisPostData["favorites"] as? [[String: Any]])!
                for item in (self.thisPostData["favorites"] as? [[String: Any]])!{
                
                favesPost = item as! [String: Any]
                    if favesPost!.count == 1 && favesPost!["x"] != nil{
                        
                    } else {
                        if (favesPost!["uName"] as! String) == self.myUName{
                            favedBySelf = true
                        }
                    }
                
            }
            if favesPost!["x"] != nil {
                
            } else {
                
                
                if (favedBySelf == true){
                   
                    self.tpFaveButton.setImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                    
                    self.favoritesButton.setImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                    //cell.favoritesCountButton.setTitle((self.feedDataArray[indexPath.row]["favorites"] as! [[String:Any]]).count.description, for: .normal)
                }
            }
            
            //set comments count
            self.commentsArray = ((self.thisPostData["comments"] as? [[String: Any]])!)
                if(self.commentsArray.count == 1 && self.commentsArray[0]["x"] != nil){
                    self.commentsArray.removeAll()
                }
            
            if commentsPost!["x"] != nil {
                
            } else {
                let commStringNum = String((self.thisPostData["comments"] as? [[String: Any]])!.count)
                var commString = String()
                if commStringNum == "1"{
                    commString = "View \(commStringNum) comment"
                } else {
                    commString = "View \(commStringNum) comments"
                }
                self.commentsCountButton.setTitle(commString, for: .normal)
                
            }
                self.tpCommentCollect.delegate = self
                self.tpCommentCollect.dataSource = self
            
            
            
        } else {
                if self.thisPostData["postVid"] == nil{
                //pic post
                    self.posterNameButton.setTitle((self.thisPostData["posterName"] as! String), for: .normal)
                
                if let messageImageUrl = URL(string: (self.thisPostData["posterPicURL"] as! String)) {
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                       
                        self.posterPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                        
                    }
                }
                    if self.prevScreen == "hash"{
                        self.postPic.image = self.thisPostData["postPic"] as! UIImage
                    } else {
                if let messageImageUrl = URL(string: (self.thisPostData["postPic"] as! String)) {
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        
                        self.postPic.image = UIImage(data: imageData as Data)
                        
                    }
                }
                    }
                    if self.thisPostData["postText"] == nil{
                    
                } else {
                        let boldText  = (self.thisPostData["posterName"] as! String) + " "
                        let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)]
                        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
                        
                        let normalText = self.thisPostData["postText"] as! String
                        let attrs2 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15, weight: .regular)]
                        let normalString = NSMutableAttributedString(string:normalText, attributes: attrs2)
                        
                        
                        attributedString.append(normalString)
                        
                        self.postText.attributedText = attributedString
                        
                        
                        self.postText.resolveHashTags()
                        
                        
                        let fixedWidth = self.postText.frame.size.width
                        let newSize = self.postText.sizeThatFits(CGSize(width: fixedWidth, height: self.estimateFrameForText(text: self.postText.text as! String).height))
                        
                        self.postText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                        self.postText.isScrollEnabled = false
                        self.commentsCountButton.frame.origin = CGPoint(x: self.commentsCountButton.frame.origin.x, y: self.postText.frame.origin.y + self.postText.frame.height + 2)
                        //self.tpFaveButton.frame = CGRect(x: self.tpFaveButton.frame.origin.x, y: self.tpLikeButton.frame.origin.y, width: self.tpLikeButton.frame.width, height: self.tpLikeButton.frame.height)
                        //self.tpShareButton.frame = CGRect(x: self.tpShareButton.frame.origin.x, y: self.tpLikeButton.frame.origin.y, width: self.tpLikeButton.frame.width, height: self.tpLikeButton.frame.height)
                        
                }
                    self.postText.resolveHashTags()
                    if self.thisPostData["city"] != nil{
                        self.cityButton.setTitle((self.thisPostData["city"] as! String), for: .normal)
                }
                
                var commentsPost: [String:Any]?
                for item in (self.thisPostData["comments"] as? [[String: Any]])!{
                    
                    commentsPost = item as! [String: Any]
                    
                }
                
                var tempPost: [String:Any]?
                    var likedBySelf = false
                self.likesArray = ((self.thisPostData["likes"] as? [[String: Any]])!)
                
                    self.likesCollect.delegate = self
                    self.likesCollect.dataSource = self
                    
                for item in (self.thisPostData["likes"] as? [[String: Any]])!{
                    
                    tempPost = item as! [String: Any]
                    if tempPost!.count == 1 && tempPost!["x"] != nil{
                        
                    } else {
                        if (tempPost!["uName"] as! String) == self.myUName{
                            likedBySelf = true
                        }
                    }
                    
                }
                if tempPost!["x"] != nil {
                    
                } else {
                    
                    
                    let countStringNum = String((self.thisPostData["likes"] as? [[String: Any]])!.count)
                    
                    var fullString1 = String()
                    if countStringNum == "1"{
                        fullString1 = "\(countStringNum) like"
                    } else {
                        fullString1 = "\(countStringNum) likes"
                    }
                    self.likesCountButton.setTitle(fullString1, for: .normal)
                    
                    if (likedBySelf == true){
                        self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                        let countStringNum = String((self.thisPostData["likes"] as? [[String: Any]])!.count)
                        var fullString = String()
                        if countStringNum == "1"{
                            fullString = "\(countStringNum) like"
                        } else {
                            fullString = "\(countStringNum) likes"
                        }
                        self.likesCountButton.setTitle(fullString, for: .normal)
                       
                    }
                }
                var favedBySelf = false
                var favesPost: [String:Any]?
                    for item in (self.thisPostData["favorites"] as? [[String: Any]])!{
                    
                    favesPost = item as! [String: Any]
                        if favesPost!.count == 1 && favesPost!["x"] != nil{
                            
                        } else {
                        if (favesPost!["uName"] as! String) == self.myUName{
                            favedBySelf = true
                        }
                        }
                    
                }
                if favesPost!["x"] != nil {
                    
                } else {
                    
                    
                    if favedBySelf == true{
                        self.favoritesButton.setImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                        
                    }
                }
                
                //set comments count
                 self.commentsArray = ((self.thisPostData["comments"] as? [[String: Any]])!)
                    if(self.commentsArray.count == 1 && self.commentsArray[0]["x"] != nil){
                        self.commentsArray.removeAll()
                    }
                
                if commentsPost!["x"] != nil {
                    
                } else {
                    let commStringNum = String((self.thisPostData["comments"] as? [[String: Any]])!.count)
                    var commString = String()
                    if commStringNum == "1"{
                        commString = "View \(commStringNum) comment"
                    } else {
                        commString = "View \(commStringNum) comments"
                    }
                    self.commentsCountButton.setTitle(commString, for: .normal)
                    
                }
                
                
            } else {
                //vidPost
                    self.posterNameButton.setTitle((self.thisPostData["posterName"] as! String), for: .normal)
                    
                    if let messageImageUrl = URL(string: (self.thisPostData["posterPicURL"] as! String)) {
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            
                            self.posterPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                            
                        }
                    }
                    
                    if self.thisPostData["postText"] == nil{
                        
                    } else {
                        let boldText  = (self.thisPostData["posterName"] as! String) + " "
                        let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)]
                        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
                        
                        let normalText = self.thisPostData["postText"] as! String
                        let attrs2 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15, weight: .regular)]
                        let normalString = NSMutableAttributedString(string:normalText, attributes: attrs2)
                        
                        
                        attributedString.append(normalString)
                        
                        self.postText.attributedText = attributedString
                        let fixedWidth = self.postText.frame.size.width
                        let newSize = self.postText.sizeThatFits(CGSize(width: fixedWidth, height: self.estimateFrameForText(text: self.postText.text as! String).height))
                        
                        self.postText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                        self.postText.isScrollEnabled = false
                        self.commentsCountButton.frame.origin = CGPoint(x: self.commentsCountButton.frame.origin.x, y: self.postText.frame.origin.y + self.postText.frame.height + 2)
                        
                        
                        //self.tpFaveButton.frame = CGRect(x: self.tpFaveButton.frame.origin.x, y: self.tpLikeButton.frame.origin.y, width: self.tpLikeButton.frame.width, height: self.tpLikeButton.frame.height)
                         //self.tpShareButton.frame = CGRect(x: self.tpShareButton.frame.origin.x, y: self.tpLikeButton.frame.origin.y, width: self.tpLikeButton.frame.width, height: self.tpLikeButton.frame.height)
                        
                    }
                    if self.thisPostData["city"] != nil{
                        self.cityButton.setTitle((self.thisPostData["city"] as! String), for: .normal)
                    }
                    
                    var commentsPost: [String:Any]?
                    for item in (self.thisPostData["comments"] as? [[String: Any]])!{
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    
                    var tempPost: [String:Any]?
                    self.likesArray = ((self.thisPostData["likes"] as? [[String: Any]])!)
                    
                    self.likesCollect.delegate = self
                    self.likesCollect.dataSource = self
                    var likedBySelf = false
                    for item in (self.thisPostData["likes"] as? [[String: Any]])!{
                        
                        tempPost = item as! [String: Any]
                        if tempPost!.count == 1 && tempPost!["x"] != nil{
                            
                        } else {
                            if (tempPost!["uName"] as! String) == self.myUName{
                                likedBySelf = true
                            }
                        }
                        
                    }
                    if tempPost!["x"] != nil {
                        print("liikedBySelfVidfalse")
                    } else {
                        
                        
                        let countStringNum = String((self.thisPostData["likes"] as? [[String: Any]])!.count)
                        
                        var fullString1 = String()
                        if countStringNum == "1"{
                            fullString1 = "\(countStringNum) like"
                        } else {
                            fullString1 = "\(countStringNum) likes"
                        }
                        self.likesCountButton.setTitle(fullString1, for: .normal)
                        
                        if (likedBySelf == true){
                           
                           print("liikedBySelfVidTrue")
                            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                            let countStringNum = String((self.thisPostData["likes"] as? [[String: Any]])!.count)
                            var fullString = String()
                            if countStringNum == "1"{
                                fullString = "\(countStringNum) like"
                            } else {
                                fullString = "\(countStringNum) likes"
                            }
                            self.likesCountButton.setTitle(fullString, for: .normal)
                            
                        }
                    }
                    
                    var favesPost: [String:Any]?
                    var favedBySelf2 = false
                    for item in (self.thisPostData["favorites"] as? [[String: Any]])!{
                        
                        favesPost = item as! [String: Any]
                        if favesPost!.count == 1 && favesPost!["x"] != nil{
                            
                        } else {
                        if (favesPost!["uName"] as! String) == self.myUName{
                            favedBySelf2 = true
                        }
                        }
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        
                        
                        if favedBySelf2 == true{
                            self.favoritesButton.setImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            
                        }
                    }
                    
                    //set comments count
                    self.commentsArray = ((self.thisPostData["comments"] as? [[String: Any]])!)
                    
                    if(self.commentsArray.count == 1 && self.commentsArray[0]["x"] != nil){
                        self.commentsArray.removeAll()
                    }
                        
                    
                    if commentsPost!["x"] != nil {
                        
                    } else {
                        let commStringNum = String((self.thisPostData["comments"] as? [[String: Any]])!.count)
                        var commString = String()
                        if commStringNum == "1"{
                            commString = "View \(commStringNum) comment"
                        } else {
                            commString = "View \(commStringNum) comments"
                        }
                        self.commentsCountButton.setTitle(commString, for: .normal)
                        
                    }
                    self.player = Player()
                    //textPostTV.isHidden = true
                    self.player?.url = URL(string:self.thisPostData["postVid"] as! String)
                    let playTap = UITapGestureRecognizer()
                    playTap.numberOfTapsRequired = 1
                    playTap.addTarget(self, action: #selector(SinglePostViewController.playOrPause))
                    self.player?.view.addGestureRecognizer(playTap)
                    
                    let vidFrame = self.postPic.frame
                    self.player?.view.frame = vidFrame
                    self.view.addSubview((self.player?.view)!)
                    self.player?.didMove(toParentViewController: self)
                    self.view.sendSubview(toBack: (self.player?.view)!)
            }
        }
            print("thisData: \(self.thisPostData)")
        })
        })
        
        // Do any additional setup after loading the view.
    }
    var curCollect = String()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == commentsCollect || collectionView == tpCommentCollect{
            return commentsArray.count
        } else {
            return likesArray.count
        }
    }
    private func estimateFrameForText(text: String) -> CGRect {
        //we make the height arbitrarily large so we don't undershoot height in calculation
        let height: CGFloat = 1000
        
        let size = CGSize(width: postTextView.frame.width, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)]
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
    
    var following = [String]()
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == likesCollect{
        let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
            if (self.likesArray.count == 1 && (self.likesArray[indexPath.row])["x"] != nil){
                
                return cell
                
            } else {
        DispatchQueue.main.async{
            
            if (self.following.contains(self.likesArray[indexPath.row]["uid"] as! String)){
                cell.likedByFollowButton.setTitle("Unfollow", for: .normal)
            }
            cell.likedByName.isHidden = false
            cell.likedByUName.isHidden = false
            cell.likedByFollowButton.isHidden = false
            cell.commentName.isHidden = true
            cell.commentTextView.isHidden = true
            cell.commentTimestamp.isHidden = true
            cell.likedByUName.text = self.likesArray[indexPath.row]["uName"] as! String
            
            cell.likedByUID = self.likesArray[indexPath.row]["uid"] as! String
            
            cell.likedByName.text = self.likesArray[indexPath.row]["realName"] as! String
            if self.likesArray[indexPath.row]["pic"] as! String == "profile-placeholder"{
                DispatchQueue.main.async{
                    cell.likedByImage.image = UIImage(named: "profile-placeholder")
                }
            } else {
                if let messageImageUrl = URL(string: self.likesArray[indexPath.row]["pic"] as! String) {
                    
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
            }
    } else {
    //commentTF.becomeFirstResponder()
    let cell : CommentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCollectionViewCell", for: indexPath) as! CommentCollectionViewCell
            cell.postID = self.postID
    DispatchQueue.main.async{
        cell.hashDelegate = self
    cell.commentorPic.layer.cornerRadius = cell.commentorPic.frame.width/2
    cell.commentorPic.layer.masksToBounds = true
        //cell.commentDelegate = self
        //cell.indexPath = indexPath
        cell.indexPath = indexPath
        cell.myRealName = self.myUName
        cell.posterUID = self.posterUID
    let nameAndComment = (self.commentsArray[indexPath.row]["commentorName"] as! String) + " " +  (self.commentsArray[indexPath.row]["commentText"] as! String)
        
    print("name&Comment: \(nameAndComment)")
        
        
        let boldNameAndComment = self.attributedText(withString: nameAndComment, boldString: (self.commentsArray[indexPath.row]["commentorName"] as! String), font: (cell.commentTextView.font!))
        
    print("boldName&Comment: \(boldNameAndComment)")
    cell.commentTextView.attributedText = boldNameAndComment
        
    let tStampDateString = self.commentsArray[indexPath.row]["commentDate"] as! String
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    let date = dateFormatter.date(from: tStampDateString)
    
    let now = Date()
    //print("tStampDateString: \(tStampDateString), date: \(date!), now: \(now)")
    let hoursBetween = now.hours(from: date!)
    //let tString = dateFormatter.string(from: tDate!)
    cell.commentTimeStamp.text = "\(hoursBetween) hours ago"
    cell.commentTextView.resolveHashTags()
    
    if self.commentsArray[indexPath.row]["commentorPic"] as! String == "profile-placeholder"{
    cell.commentorPic.setImage(UIImage(named: "profile-placeholder"), for: .normal)
    } else {
    if let messageImageUrl = URL(string: self.commentsArray[indexPath.row]["commentorPic"] as! String) {
    
    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
    cell.commentorPic.setImage(UIImage(data: imageData as Data), for: .normal)
    }
    }
        }
            }
    return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //select
    }
    

    var curName = String()
    var favData = [[String:Any]]()
    // MARK: - Navigation
    
    

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SinglePostToProfile"{
            if let vc = segue.destination as? ProfileViewController{
                if toMention == true{
                    vc.curUID = self.mentionID
                } else {
                    vc.curUID = Auth.auth().currentUser!.uid
                }
                vc.prevScreen = "singlePost"
                
                if selectedCurAuthProfile == true{
                    vc.viewerIsCurAuth = true
                    
                } else {
                    vc.viewerIsCurAuth = false
                }
                vc.curName = self.curName
            }
        }
        if segue.identifier == "SinglePostToFav"{
            if let vc = segue.destination as? FavoritesViewController{
                vc.favData = self.favData
            }
        }
        if segue.identifier == "SinglePostToHash"{
            if let vc = segue.destination as? HashTagViewController{
                vc.hashtag = self.selectedHash
            }
            
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
       
    }
    
    
    
    
    
    
    
 
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedStringKey.font: font])
        let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            print("keyHeight: \(keyboardHeight)")
            if tpView.isHidden == true{
            commentTopLabel.frame = CGRect(x: commentTopLabel.frame.origin.x, y: commentTopLabel.frame.origin.y - keyboardHeight, width: commentTopLabel.frame.width, height: commentTopLabel.frame.height)
            
            backFromComments.isHidden = false
            
            commentTopLine.frame = CGRect(x: commentTopLine.frame.origin.x, y: commentTopLine.frame.origin.y - keyboardHeight, width: commentTopLine.frame.width, height: commentTopLine.frame.height)
            
            
            commentsCollect.frame = CGRect(x: commentsCollect.frame.origin.x, y: commentsCollect.frame.origin.y - keyboardHeight, width: commentsCollect.frame.width, height: commentsCollect.frame.height)
            } else {
                
                scrollView.frame = CGRect(x: scrollView.frame.origin.x, y: scrollView.frame.origin.y - keyboardHeight, width: scrollView.frame.width, height: scrollView.frame.height)
                tpView.frame = CGRect(x: tpView.frame.origin.x, y: tpView.frame.origin.y - keyboardHeight, width: tpView.frame.width, height: tpView.frame.height)
                 tpCommentView.frame = CGRect(x: tpCommentView.frame.origin.x, y: tpCommentView.frame.origin.y + keyboardHeight, width: tpCommentView.frame.width, height: tpCommentView.frame.height)
            }
        }
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            print("keyHeight: \(keyboardHeight)")
            if tpView.isHidden == true{
            commentTopLabel.frame = CGRect(x: commentTopLabel.frame.origin.x, y: commentTopLabel.frame.origin.y + keyboardHeight, width: commentTopLabel.frame.width, height: commentTopLabel.frame.height)
            
            backFromComments.isHidden = true
            
            commentTopLine.frame = CGRect(x: commentTopLine.frame.origin.x, y: commentTopLine.frame.origin.y + keyboardHeight, width: commentTopLine.frame.width, height: commentTopLine.frame.height)
            
            
            commentsCollect.frame = CGRect(x: commentsCollect.frame.origin.x, y: commentsCollect.frame.origin.y + keyboardHeight, width: commentsCollect.frame.width, height: commentsCollect.frame.height)
            } else {
                 //tpCommentCollect.frame = CGRect(x: tpCommentCollect.frame.origin.x, y: tpCommentCollect.frame.origin.y - keyboardHeight, width: tpCommentCollect.frame.width, height: tpCommentCollect.frame.height)
                
                //postTextView.frame = CGRect(x: postTextView.frame.origin.x, y: postTextView.frame.origin.y + keyboardHeight, width: postTextView.frame.width, height: postTextView.frame.height)
                scrollView.frame = CGRect(x: scrollView.frame.origin.x, y: scrollView.frame.origin.y + keyboardHeight, width: scrollView.frame.width, height: scrollView.frame.height)
                
                tpView.frame = CGRect(x: tpView.frame.origin.x, y: tpView.frame.origin.y + keyboardHeight, width: tpView.frame.width, height: tpView.frame.height)
                 tpCommentView.frame = CGRect(x: tpCommentView.frame.origin.x, y: tpCommentView.frame.origin.y - keyboardHeight, width: tpCommentView.frame.width, height: tpCommentView.frame.height)
            }
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
       // commentsCollect.frame = CGRect(x: commentsCollect.frame.origin.x, y: commentsCollect.frame.origin.y + 300, width: commentsCollect.frame.width, height: commentsCollect.frame.height)
    }// became first responder
    
    
    public func textFieldDidEndEditing(_ textField: UITextField){
        //add comment to post
         //commentsCollect.frame = CGRect(x: commentsCollect.frame.origin.x, y: commentsCollect.frame.origin.y - 300, width: commentsCollect.frame.width, height: commentsCollect.frame.height)
        
    } // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        print("return text")
        return false
    }
    var selectedCurAuthProfile = true
    var mentionID = String()
    var toMention = false
    func showHashTag(tagType: String, payload: String, postID: String, name: String) {
        if tagType == "mention"{
            print("mention: going to \(payload)'s profile")
            self.curName = name
            
           toMention = true
            Database.database().reference().child("usernames").observeSingleEvent(of: .value, with: { snapshot in
                let snapshots = snapshot.value as! [String:Any]
                for snap in snapshots{
                    if snap.key == payload{
                        self.mentionID = (snap.value as! [String])[0] as! String
                        if self.mentionID == Auth.auth().currentUser!.uid{
                            self.selectedCurAuthProfile = true
                        } else {
                            self.selectedCurAuthProfile = false
                        }
                       self.toMention = true
                        self.performSegue(withIdentifier: "SinglePostToProfile", sender: self)
                    }
                }
            })
        } else {
            print("hashtag: \(payload) database action")
            selectedHash = payload
            performSegue(withIdentifier: "SinglePostToHash", sender: self)
        }
        /*let alertView = UIAlertView()
         alertView.title = "\(tagType) tag detected"
         // get a handle on the payload
         alertView.message = "\(payload)"
         alertView.addButton(withTitle: "Ok")
         alertView.show()*/
    }
    var selectedHash = String()
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("shouldWork")
        switch URL.scheme {
        case "hash" :
            showHashTagAlert(tagType: "hash", payload: (URL as NSURL).resourceSpecifier!.removingPercentEncoding!)
        case "mention" :
            showHashTagAlert(tagType: "mention", payload: (URL as NSURL).resourceSpecifier!.removingPercentEncoding!)
        default:
            print("just a regular url")
        }
        
        return true
    }
    
    func showHashTagAlert(tagType:String, payload:String){
        print("show hash")
        showHashTag(tagType: tagType, payload: payload, postID: self.postID, name: (self.posterNameButton.titleLabel?.text)!)
        
    }

}
extension SinglePostViewController:PlayerDelegate {
    
    func playerReady(_ player: Player) {
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        //if player.playbackState = .
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
    
}
extension SinglePostViewController:PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        player.playbackLoops = false
    }
    
}
