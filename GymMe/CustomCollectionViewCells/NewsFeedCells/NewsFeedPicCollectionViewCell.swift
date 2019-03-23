//
//  NewsFeedPicCollectionViewCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 6/19/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase
import FirebaseAuth


class NewsFeedPicCollectionViewCell: UICollectionViewCell, UITextViewDelegate {

    
    @IBAction func postLocationPressed(_ sender: Any) {
        delegate?.locationButtonPicCellPressed(sentBy: "locationPicCell", cell: self)
    }
    
    
    @IBAction func soundTogglePressed(_ sender: Any) {
        if soundToggle.imageView?.image! == UIImage(named: "Octicons-mute.svg"){
            self.player?.muted = false
        soundToggle.setImage(UIImage(named: "unmute-512"), for: .normal)
            //soundToggle.frame = CGRect(x: 10, y: 10, width: soundToggle.frame.width, height: soundToggle.frame.height)
        } else {
            
            
            self.player?.muted = true
            soundToggle.setImage(UIImage(named: "Octicons-mute.svg"), for: .normal)
            
            //soundToggle.frame = CGRect(x: 10, y: 10, width: soundToggle.frame.width, height: soundToggle.frame.height)
        }
    }
    @IBOutlet weak var soundToggle: UIButton!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    @IBAction func tapGestureRec(_ sender: Any) {
        print("liked")
        
        
    }
    
    var selfData: [String:Any]?
    var delegate: PerformActionsInFeedDelegate?
    var posterUID: String?
    var curName: String?
    var cellIndexPath: IndexPath?
    var videoUrl: URL? 
    var myRealName: String?
    var myPicString: String?
    @IBOutlet weak var posterPic: UIImageView!
    @IBOutlet weak var postPic: UIImageView!
    var postID: String?
    var player: Player?
    var posterName: String?
    @IBAction func shareButtonPressed(_ sender: Any) {
        delegate?.showLikedByViewPicCell(sentBy: "share", cell: self)
    }
    
   
  
    @IBOutlet weak var tagLabel: UILabel!
    
    @IBAction func commentsCountButtonPressed(_ sender: Any) {
        delegate?.showLikedByViewPicCell(sentBy: "showCommentsCount", cell: self)
    }
    @IBOutlet weak var commentsCountButton: UIButton!
    @IBAction func commentButtonPressed(_ sender: Any) {
        delegate?.showLikedByViewPicCell(sentBy: "showComments", cell: self)
    }
    @IBOutlet weak var commentButton: UIButton!
    
    
    @IBAction func favoritesCountButtonPressed(_ sender: Any) {
    }
    //@IBOutlet weak var favoritesCountButton: UIButton!
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        print("here000")
        print("df: \(self.favoritesButton.currentBackgroundImage)")
        if self.favoritesButton.currentBackgroundImage == UIImage(named: "favoritesUnfilled.png"){
            self.favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
            print("here111")
            Database.database().reference().child("posts").child(self.postID!).observeSingleEvent(of: .value, with: { snapshot in
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
                favoritesArray.append(["uName": self.myUName!, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": self.myPicString])
                
                Database.database().reference().child("posts").child(self.postID!).child("favorites").setValue(favoritesArray)
                Database.database().reference().child("users").child(self.posterUID!).child("posts").child(self.postID!).child("favorites").setValue(favoritesArray)
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").updateChildValues([self.postID!: self.selfData!])
               // self.favoritesCountButton.setTitle(String(favoritesArray.count), for: .normal)
                Database.database().reference().child("users").child(self.posterUID!).observeSingleEvent(of: .value, with: { snapshot in
                    var uploadDict = [String:Any]()
                    var snapDict = snapshot.value as! [String:Any]
                    var noteArray = [[String:Any]]()
                    if snapDict["notifications"] != nil{
                        noteArray = snapDict["notifications"] as! [[String:Any]]
                        let sendString = self.myUName! + " favorited your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName! , "postID": self.postID!,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": self.myPicString, "postText": self.postText.text as! String] as! [String:Any]
                        noteArray.append(tempDict)
                        Database.database().reference().child("users").child(self.posterUID!).updateChildValues(["notifications": noteArray] as [AnyHashable:Any]){ err, ref in
                            print("done")
                        }
                    } else {
                        let sendString = self.myUName! + " favorited your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName! ,"postID": self.postID!,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": self.myPicString, "postText": self.postText.text] as [String : Any]
                        Database.database().reference().child("users").child(self.posterUID!).updateChildValues(["notifications":[tempDict]])
                    }
                    
                })
                
                //reload collect in delegate
                
            })
        } else {
            self.favoritesButton.setBackgroundImage(UIImage(named:"favoritesUnfilled.png"), for: .normal)
            
            
            Database.database().reference().child("posts").child(self.postID!).observeSingleEvent(of: .value, with: { snapshot in
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
                
                
                Database.database().reference().child("posts").child(self.postID!).child("favorites").setValue(favesArray)
                
                
                Database.database().reference().child("users").child(self.posterUID!).child("posts").child(self.postID!).child("favorites").setValue(favesArray)
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").child(self.postID!).removeValue()
                
            })
            
        }
        
    }
    @IBOutlet weak var favoritesButton: UIButton!
    
    @IBOutlet weak var viewCount: UILabel!
    
    @IBAction func likesCountButtonPressed(_ sender: Any) {
       // self.delegate?.reloadDataAfterLike()
        delegate?.showLikedByViewPicCell(sentBy: "likedBy", cell: self)
    }
    @IBOutlet weak var likesCountButton: UIButton!
    var myUName: String?
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
            Database.database().reference().child("posts").child(self.postID!).observeSingleEvent(of: .value, with: { snapshot in
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
                likesArray.append(["uName": self.myUName!, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": myPic])
                
                
                Database.database().reference().child("posts").child(self.postID!).child("likes").setValue(likesArray)
                Database.database().reference().child("users").child(self.posterUID!).child("posts").child(self.postID!).child("likes").setValue(likesArray)
                
                
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
                
                self.delegate?.reloadDataAfterLike()
                Database.database().reference().child("users").child(self.posterUID!).observeSingleEvent(of: .value, with: { snapshot in
                    var uploadDict = [String:Any]()
                    var snapDict = snapshot.value as! [String:Any]
                    var noteArray = [[String:Any]]()
                    if snapDict["notifications"] != nil{
                        noteArray = snapDict["notifications"] as! [[String:Any]]
                        let sendString = self.myUName! + " liked your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName! ,"postID": self.postID!,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": myPic, "postText": self.postText.text!] as! [String:Any]
                        noteArray.append(tempDict)
                        Database.database().reference().child("users").child(self.posterUID!).updateChildValues(["notifications": noteArray])
                    } else {
                        let sendString = self.myUName! + " liked your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": self.myUName! ,"postID": self.postID!,"actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": myPic, "postText": self.postText.text] as [String : Any]
                        Database.database().reference().child("users").child(self.posterUID!).updateChildValues(["notifications":[tempDict]])
                    }
                    
                })
                
            })
            
            //update Database for post with new like count
            
        } else {
            self.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
            
            Database.database().reference().child("posts").child(self.postID!).observeSingleEvent(of: .value, with: { snapshot in
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
                    
                   
                
                
                
                Database.database().reference().child("posts").child(self.postID!).child("likes").setValue(likesArray)
                
       
                Database.database().reference().child("users").child(self.posterUID!).child("posts").child(self.postID!).child("likes").setValue(likesArray)
                
                
                self.delegate?.reloadDataAfterLike()
            })
        }
        DispatchQueue.main.async {
            self.delegate?.reloadDataAfterLike()
        }
        
    }
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var sizeView: UIView!
    @IBOutlet weak var postText: UITextView!
    //@IBOutlet weak var postText: UILabel!
    @IBOutlet weak var postLocationButton: UIButton!
    @IBOutlet weak var posterNameButton: UIButton!
    @IBAction func goToPosterPressed(_ sender: Any) {
        //perform segue in feed using custom delegate method
        delegate?.performSegueToPosterProfile(uid: self.posterUID!, name: (self.posterNameButton.titleLabel?.text)!)
        
    }
    @IBOutlet weak var goToPosterProfile: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        print("picCellInit")
         self.postText.delegate = self
        posterPic.layer.cornerRadius = posterPic.frame.width/2
        posterPic.layer.masksToBounds = true
        self.player = Player()
        self.player!.muted = true
        let playTap = UITapGestureRecognizer()
        playTap.numberOfTapsRequired = 1
        playTap.addTarget(self, action: #selector(NewsFeedPicCollectionViewCell.playOrPause))
        self.addSubview((self.player?.view)!)
        //self.translatesAutoresizingMaskIntoConstraints = false
        /*postPic.translatesAutoresizingMaskIntoConstraints = false
        postPic.topAnchor.constraint(equalTo: posterPic.bottomAnchor, constant: -10)
        postPic.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0)
        postPic.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)*/
        
        //cell.commentsCountButton.topAnchor.constraint(equalTo: cell.postText.bottomAnchor).isActive = true
        
        // Initialization code
    }
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
    override func prepareForReuse(){
        super.prepareForReuse()
        //self.setNeedsDisplay()
        //self.videoUrl = nil
        //self.postText.text = nil
        //self.postPic.image = nil
        self.postText.text = nil
        //self.player = nil
        //self.postPic.image = nil
        self.posterPic.image = nil
        self.cellIndexPath = nil
        
       // exampleView.backgroundColor = nil
        //exampleView.layer.cornerRadius = 0
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
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
        delegate?.showHashTag(tagType: tagType, payload: payload, postID: self.postID!, name: (self.posterNameButton.titleLabel?.text)!)
        
    }
    

}
