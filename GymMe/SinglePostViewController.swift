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

class SinglePostViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    var prevScreen = String()
    var senderScreen = String()
    var hashtag = String()
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
    var thisPostData = [String:Any]()
    var activityViewController:UIActivityViewController?
    @IBAction func sharePressed(_ sender: Any) {
        activityViewController = UIActivityViewController(
            activityItems: ["Download GymMe today!"],
            applicationActivities: nil)
        
        present(activityViewController!, animated: true, completion: nil)
    }
    var myPicString = String()
    
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        if self.favoritesButton.currentBackgroundImage == UIImage(named: "favoritesUnfilled.png"){
            self.favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
            print("here111")
            Database.database().reference().child("posts").child(self.postID ).observeSingleEvent(of: .value, with: { snapshot in
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
                favoritesArray.append(["uName": self.myUName, "realName": self.myUName, "uid": Auth.auth().currentUser!.uid, "pic": self.myPicString])
                
                Database.database().reference().child("posts").child(self.postID).child("favorites").setValue(favoritesArray)
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("favorites").setValue(favoritesArray)
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").updateChildValues([self.postID: self.thisPostData])
                self.favoritesButton.setTitle(String(favoritesArray.count), for: .normal)
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
                        
                        
                        let tempDict = ["actionByUsername": self.myUName , "postID": self.postID,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": self.myPicString, "postText": "notification"] as! [String:Any]
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
                        
                        let tempDict = ["actionByUsername": self.myUName ,"postID": self.postID,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": self.myPicString, "postText": "notification"] as [String : Any]
                        Database.database().reference().child("users").child(self.posterUID).updateChildValues(["notifications":[tempDict]])
                    }
                    
                })
                
                //reload collect in delegate
                
            })
        } else {
            self.favoritesButton.setBackgroundImage(UIImage(named:"favoritesUnfilled.png"), for: .normal)
            
            
            Database.database().reference().child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                var favesVal = Int()
                var favesArray = valDict["favorites"] as! [[String: Any]]
                if favesArray.count == 1 {
                    favesArray.remove(at: 0)
                    favesArray.append(["x": "x"])
                    favesVal = 0
                    self.favoritesButton.setTitle("0", for: .normal)
                } else {
                    favesArray.remove(at: 0)
                    favesVal = favesArray.count
                    self.favoritesButton.setTitle(String(favesArray.count), for: .normal)
                }
                
                
                Database.database().reference().child("posts").child(self.postID).child("favorites").setValue(favesArray)
                
                
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("favorited").setValue(favesArray)
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").setValue(favesArray)
                
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
    }
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var postText: UILabel!
    @IBAction func commentsCountPressed(_ sender: Any) {
        commentView.isHidden = false
        commentView.isHidden = false
        commentsCollect.isHidden = false
        likesCollect.isHidden = true
        print("commentsArray: \(commentsArray)")
        commentsCollect.delegate = self
        commentsCollect.dataSource = self
        commentTF.isHidden = false
        //DispatchQueue.main.async{
              //  self.commentsCollect.reloadData()
      //  }
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
        print("like")
        var myPic = String()
        print("fuqqqqq")
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
                likesArray.append(["uName": self.myUName, "realName": self.myUName, "uid": Auth.auth().currentUser!.uid, "pic": myPic])
                
                
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
                
                //self.delegate?.reloadDataAfterLike()
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
                        
                        let tempDict = ["actionByUsername": self.myUName ,"postID": self.postID,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": myPic, "postText": "notification"] as! [String:Any]
                        noteArray.append(tempDict)
                        Database.database().reference().child("users").child(self.posterUID).updateChildValues(["notifications": noteArray])
                    } else {
                        
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        let sendString = self.myUName + " liked your post."
                        let tempDict = ["actionByUsername": self.myUName ,"postID": self.postID,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": myPic, "postText": "notification"] as [String : Any]
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
                
                
                DispatchQueue.main.async{
                    self.likesCollect.reloadData()
                }
            })
        }
        DispatchQueue.main.async {
            // self.delegate?.reloadDataAfterLike()
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
    var postID = String()
    var posterUID = String()
    var player: Player?
    var myUName = String()
    var commentsArray = [[String:Any]]()
    var likesArray = [[String:Any]]()
    var advancedData = [String:Any]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        posterPicButton.frame.size = CGSize(width: 40, height: 40)
       posterPicButton.layer.cornerRadius = posterPicButton.frame.width/2
        posterPicButton.layer.masksToBounds = true
       
        
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
        
            self.likesCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        

            self.commentTF.delegate = self
        
            if self.thisPostData["postVid"] == nil && self.thisPostData["postPic"] == nil{
            //textPost
                self.posterNameButton.setTitle((self.thisPostData["posterName"] as! String), for: .normal)
            
            if let messageImageUrl = URL(string: (self.thisPostData["posterPicURL"] as! String)) {
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    
                    self.posterPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                    
                }
            }
           
                if self.thisPostData["postText"] == nil{
                
            } else {
                    self.commentsCountButton.frame = CGRect(x: self.commentsCountButton.frame.origin.x, y: self.postText.frame.origin.y + 8, width: self.commentsCountButton.frame.width, height: self.commentsCountButton.frame.height)
                    self.postTextView.isHidden = false
                    self.postTextView.text = (self.thisPostData["postText"] as! String)
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
            for item in (self.thisPostData["likes"] as? [[String: Any]])!{
                
                tempPost = item as! [String: Any]
                
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
                
                if (self.thisPostData["posterName"] as? String) == self.myUName{
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
                for item in (self.thisPostData["favorites"] as? [[String: Any]])!{
                
                favesPost = item as! [String: Any]
                
            }
            if favesPost!["x"] != nil {
                
            } else {
                
                
                if (favesPost!["uName"] as! String) == self.myUName{
                    self.favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                    //cell.favoritesCountButton.setTitle((self.feedDataArray[indexPath.row]["favorites"] as! [[String:Any]]).count.description, for: .normal)
                }
            }
            
            //set comments count
            self.commentsArray = ((self.thisPostData["comments"] as? [[String: Any]])!)
            
            
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
                        self.postText.text = (self.thisPostData["postText"] as! String)
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
                for item in (self.thisPostData["likes"] as? [[String: Any]])!{
                    
                    tempPost = item as! [String: Any]
                    
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
                    
                    if (self.thisPostData["posterName"] as? String) == self.myUName{
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
                    for item in (self.thisPostData["favorites"] as? [[String: Any]])!{
                    
                    favesPost = item as! [String: Any]
                    
                }
                if favesPost!["x"] != nil {
                    
                } else {
                    
                    
                    if (favesPost!["uName"] as! String) == self.myUName{
                        self.favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                        //cell.favoritesCountButton.setTitle((self.feedDataArray[indexPath.row]["favorites"] as! [[String:Any]]).count.description, for: .normal)
                    }
                }
                
                //set comments count
                 self.commentsArray = ((self.thisPostData["comments"] as? [[String: Any]])!)
            
                
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
                self.player = Player()
                self.player!.muted = true
                let playTap = UITapGestureRecognizer()
                playTap.numberOfTapsRequired = 1
                playTap.addTarget(self, action: #selector(NewsFeedPicCollectionViewCell.playOrPause))
                self.view.addSubview((self.player?.view)!)
            }
        }
            print("thisData: \(self.thisPostData)")
        })
        
        // Do any additional setup after loading the view.
    }
    var curCollect = String()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == commentsCollect{
            return commentsArray.count
        } else {
            return likesArray.count
        }
    }
    
    var following = [String]()
    
    @IBOutlet weak var likesCollect: UICollectionView!
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
    DispatchQueue.main.async{
    cell.commentorPic.layer.cornerRadius = cell.commentorPic.frame.width/2
    cell.commentorPic.layer.masksToBounds = true
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
    

    var favData = [[String:Any]]()
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SinglePostToFav"{
            if let vc = segue.destination as? SinglePostViewController{
                vc.favData = self.favData
            }
        }
        if segue.identifier == "SinglePostToHash"{
            if let vc = segue.destination as? HashTagViewController{
                vc.hashtag = self.hashtag
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
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        commentsCollect.frame = CGRect(x: commentsCollect.frame.origin.x, y: commentsCollect.frame.origin.y + 300, width: commentsCollect.frame.width, height: commentsCollect.frame.height)
    }// became first responder
    
    
    public func textFieldDidEndEditing(_ textField: UITextField){
        //add comment to post
         commentsCollect.frame = CGRect(x: commentsCollect.frame.origin.x, y: commentsCollect.frame.origin.y - 300, width: commentsCollect.frame.width, height: commentsCollect.frame.height)
        if textField.text == "" || textField.hasText == false {
            
        } else {
            var cellTypeTemp = String()
            var posterID = String()
           
            Database.database().reference().child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                var cArray = valDict["comments"] as! [[String:Any]]
                if cArray.count == 1 && (cArray.first! as! [String:String]) == ["x": "x"]{
                    cArray.remove(at: 0)
                }
                var commentsVal = cArray.count
                commentsVal = commentsVal + 1
                if self.myPicString == nil{
                    self.myPicString = "profile-placeholder"
                }
                //add current users id and uName to comment object and upload to database
                var now = Date()
                //var dateFormatter = DateFormatter()
                //var dateString = dateFormatter.string(from: now)
                self.commentsArray.append(["commentorName": self.myUName, "commentorID": Auth.auth().currentUser!.uid, "commentorPic": self.myPicString, "commentText": self.commentTF.text!, "commentDate": now.description])
                Database.database().reference().child("posts").child(self.postID).child("comments").setValue(self.commentsArray)
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("comments").setValue(self.commentsArray)
                
                Database.database().reference().child("users").child(self.posterUID).observeSingleEvent(of: .value, with: { (snapshot) in
                    let valDict = snapshot.value as! [String:Any]
                    if valDict["notifications"] as? [[String:Any]] == nil {
                        var tempString = "\(self.myUName) commented on your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        var tempDict = (["actionByUID": Auth.auth().currentUser!.uid,"postID": self.postID, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as [String : Any])
                        
                        print("commentNote: \(tempDict)")
                        Database.database().reference().child("users").child(self.posterUID).updateChildValues((["notifications": [tempDict]] as! [String:Any]))
                        
                    } else {
                        
                        var tempString = "\(self.myUName) commented on your post" as! String
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        var tempDict = (["actionByUID": Auth.auth().currentUser!.uid, "postID": self.postID, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as! [String : Any])
                        
                        //Database.database().reference().child("users").child(uid).updateChildValues((["notifications": [tempDict]] as! [String:Any]))
                        
                        var tempNotifs = valDict["notifications"] as! [[String:Any]]
                        tempNotifs.append(tempDict)
                        print("acommentNote \(posterID)")
                        Database.database().reference().child("users").child(self.posterUID).updateChildValues((["notifications": tempNotifs] as! [String:Any]))
                        
                        
                    }
                    
                    
                })
                
                
                
                self.commentTF.text = nil
                
               
                    
                let commStringNum = String(self.commentsArray.count)
                    var commString = String()
                    if commStringNum == "1"{
                        commString = "View \(commStringNum) comment"
                    } else {
                        commString = "View \(commStringNum) comments"
                    }
                    self.commentsCountButton.setTitle(commString, for: .normal)
                
                    

                
                //reload collect in delegate
                
                if self.commentsArray.count == 1{
                    DispatchQueue.main.async{
                        self.commentsCollect.delegate = self
                        self.commentsCollect.dataSource = self
                        DispatchQueue.main.async{
                            self.commentsCollect.reloadData()
                        }
                    }
                    
                } else {
                    self.commentsCollect.delegate = self
                    self.commentsCollect.dataSource = self
                    DispatchQueue.main.async{
                        self.commentsCollect.reloadData()
                    }
                }
                
            })
        }
    } // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        print("return text")
        return false
    }

}
