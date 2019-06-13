//  ViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 6/19/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import AVFoundation
import SwiftOverlays
import JSQMessagesViewController


class HomeFeedViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITabBarDelegate, PerformActionsInFeedDelegate,UIGestureRecognizerDelegate, UITextFieldDelegate, UISearchBarDelegate, CommentLike, UITextViewDelegate, ToProfileDelegate {
    
    
    func commentGoToProf(cellUID:String,name:String) {
        //print("madeIt")
        self.curName = name
        self.selectedCellUID = cellUID
        if cellUID == Auth.auth().currentUser!.uid {
            selectedCurAuthProfile = true
        } else {
            selectedCurAuthProfile = false
        }
        performSegue(withIdentifier: "FeedToProfile", sender: self)
    }
    
    func segueToProf(cellUID: String, name: String) {
        
        //
    }
    
    
   
    
    @IBOutlet weak var likeTopLabel: UILabel!
    var mentionID = String()
    func showHashTag(tagType: String, payload: String, postID: String, name: String) {
        if tagType == "mention"{
           // print("mention: going to \(payload)'s profile")
           self.curName = name
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
                       
                        self.performSegue(withIdentifier: "FeedToProfile", sender: self)
                    }
                }
            })
        } else {
           // print("hashtag: \(payload) database action")
            selectedHash = payload
            performSegue(withIdentifier: "FeedToHash", sender: self)
        }
        /*let alertView = UIAlertView()
        alertView.title = "\(tagType) tag detected"
        // get a handle on the payload
        alertView.message = "\(payload)"
        alertView.addButton(withTitle: "Ok")
        alertView.show()*/
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
       // print("show hash")
        showHashTag(tagType: tagType, payload: payload, postID: curCell.postID!, name: (self.tpPosterNameButton.titleLabel?.text)!)
        
    }
    var selectedHash = String()
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        feedCollect.collectionViewLayout.invalidateLayout()
    }
    
    func locationButtonTextCellPressed(sentBy: String, cell: NewsFeedCellCollectionViewCell){
       // print("locationTextCell")
        //SwiftOverlays.showBlockingWaitOverlayWithText("searching")
        if cell.postLocationButton.titleLabel!.text == nil{
            
        } else {
            self.locationOptionsMenu.isHidden = false
            
        
        }
        
    }
    
    @IBOutlet weak var locationOptionsMenu: UIView!
    
    @IBOutlet weak var backFromLocation: UIButton!
    @IBOutlet weak var viewPostsButton: UIButton!
    @IBAction func viewPostsPressed(_ sender: Any) {
        self.locationSegString = locSentBy
        if locCellPic == nil{
            self.locationNamePressed = locCellText!.postLocationButton.titleLabel!.text!
            self.locationPostID = locCellText!.postID!
            performSegue(withIdentifier: "FeedToAdvancedSearch", sender: self)
        } else {
            self.locationNamePressed = locCellPic!.postLocationButton.titleLabel!.text!
            self.locationPostID = locCellPic!.postID!
        performSegue(withIdentifier: "FeedToAdvancedSearch", sender: self)
        }
        
    }
    
    @IBOutlet weak var mapButton: UIButton!
    @IBAction func mapButtonPressed(_ sender: Any) {
        self.locationSegString = locSentBy
        if locCellPic == nil{
            self.locationNamePressed = locCellText!.postLocationButton.titleLabel!.text!
            self.locationPostID = locCellText!.postID!
            performSegue(withIdentifier: "FeedToMap", sender: self)
        } else {
            self.locationNamePressed = locCellPic!.postLocationButton.titleLabel!.text!
            self.locationPostID = locCellPic!.postID!
            performSegue(withIdentifier: "FeedToMap", sender: self)
        }
        
    }
    
    @IBAction func backFromLocationPressed(_ sender: Any) {
        locationOptionsMenu.isHidden = true
    }
    var locationSegString = String()
    var locationPostID = String()
    var locSentBy = String()
    var locCellPic: NewsFeedPicCollectionViewCell?
    var locCellText: NewsFeedCellCollectionViewCell?
    func locationButtonPicCellPressed(sentBy: String, cell: NewsFeedPicCollectionViewCell){
        // print("locationPicCell")
        self.locCellPic = cell
        self.locSentBy = sentBy
       locationOptionsMenu.isHidden = false //SwiftOverlays.showBlockingWaitOverlayWithText("searching")
       
    }
    func likeComment() {
        
        var count = 0
        for dict in self.feedDataArray{
            if (dict["postID"] as! String) == curPostID{
                Database.database().reference().child("posts").child(curPostID).observeSingleEvent(of: .value, with: { snapshot in
                    var tempDict = snapshot.value as! [String:Any]
                    if tempDict["postPic"] == nil && tempDict["postVid"] == nil{
                        //text
                        if (tempDict["posterPicURL"] as! String) == "profile-placeholder"{
                            
                            var tempImage = UIImage(named: "profile-placeholder")
                            tempDict["posterPicURL"] = tempImage
                            
                        } else {
                            if let messageImageUrl = URL(string: (tempDict["posterPicURL"] as! String)) {
                                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                     tempDict["posterPicString"] = tempDict["posterPicURL"]
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
                                    tempDict["posterPicString"] = tempDict["posterPicURL"]
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
                                   tempDict["postPicString"] = picString
                                    self.feedImageArray.append(pic as! UIImage)
                                    self.feedVidArray.append(URL(string: "x")!)
                                    
                                    
                                }
                            }
                        } else {
                            //vid
                            tempDict["postVidString"] = tempDict["postVid"]
                            tempDict["postVid"] = URL(string: tempDict["postVid"] as! String)!
                            
                        }
                    }
                    self.feedDataArray[count] = tempDict
                    
                    
                })
                break
                
            }
            count = count + 1
        }
        //DispatchQueue.main.async{
        //self.likedByCollect.reloadData()
        //}
        
    }
    
    
    
    func reloadDataAfterLike(){
        DispatchQueue.main.async{
           // self.likedByCollect.reloadData()
           // self.refresh()
        }
       // self.refresh()
    }
    
    func backk(){
        //DispatchQueue.main.async{
           // self.loadFeedData()
        self.inboxButton.isHidden = false
        self.commentTF.resignFirstResponder()
        self.topLabel.text = "GymMe"
        self.shareFinalizeButton.isHidden = true
        self.shareSearchBar.isHidden = true
        self.commentTFView.isHidden = true
        self.addFriendsButton.isHidden = false
        self.cellButtonsPressedView.isHidden = true
        inboxButton.isHidden = false
        self.tabBar.isHidden = false

        self.topLabel.isHidden = true
        self.logoWords.isHidden = false
        
       //self.likeTopLabel.isHidden = true
        self.backFromLikedByViewButton.isHidden = true
        self.likedByCollectData.removeAll()
        
        DispatchQueue.main.async {
            self.likedByCollect.reloadData()
        }
       // }
        
    }
    @IBOutlet weak var tpBottomLine: UIView!
    var curCell = NewsFeedCellCollectionViewCell()
    
    
    func tpLikePressed(cell:NewsFeedCellCollectionViewCell){
        var myPic = String()
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let valDict = snapshot.value as! [String:Any]
            myPic = valDict["profPic"] as! String
            
        })
        if self.tpLikeButton.imageView?.image == UIImage(named: "like.png"){
            self.tpLikeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
            // let curLikes = Int((self.likesCountButton.titleLabel?.text)!)
            //self.likesCountButton.setTitle(String(curLikes! + 1), for: .normal)
            Database.database().reference().child("posts").child(cell.postID!).observeSingleEvent(of: .value, with: { snapshot in
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
                likesArray.append(["uName": self.myUName!, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": myPic])
                
                
                Database.database().reference().child("posts").child(cell.postID!).child("likes").setValue(likesArray)
                Database.database().reference().child("users").child(cell.posterUID!).child("posts").child(cell.postID!).child("likes").setValue(likesArray)
                Database.database().reference().child("users").child(cell.posterUID!).observeSingleEvent(of: .value, with: { snapshot in
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
                        
                        let tempDict = ["actionByUsername": cell.myUName!, "postID": cell.postID!, "actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": myPic, "postText": cell.postText.text as! String] as! [String:Any]
                        noteArray.append(tempDict)
                        Database.database().reference().child("users").child(cell.posterUID!).updateChildValues(["notifications": noteArray])
                    } else {
                        let sendString = cell.myUName! + " liked your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        let tempDict = ["actionByUsername": cell.myUName! , "postID": cell.postID!, "actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": myPic, "postText": cell.postText.text] as [String : Any]
                        Database.database().reference().child("users").child(cell.posterUID!).updateChildValues(["notifications":[tempDict]])
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
                self.tpLikesCountButton.setTitle(likesString, for: .normal)
                
                //reload collect in delegate
                
            })
            
            //update Database for post with new like count
            
        } else {
            self.tpLikeButton.setImage(UIImage(named:"like.png"), for: .normal)
            
            Database.database().reference().child("posts").child(cell.postID!).observeSingleEvent(of: .value, with: { snapshot in
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
                self.tpLikesCountButton.setTitle(likesString, for: .normal)
                
                
                Database.database().reference().child("posts").child(cell.postID!).child("likes").setValue(likesArray)
                
                
                Database.database().reference().child("users").child(cell.posterUID!).child("posts").child(cell.postID!).child("likes").setValue(likesArray)
                
                
            })
            
        }
        
    }
    
    func tpFavoritePressed(cell:NewsFeedCellCollectionViewCell){
        print("here000")
        print("df: \(self.tpFavoriteButton.currentBackgroundImage)")
        if self.tpFavoriteButton.currentBackgroundImage == UIImage(named: "favoritesUnfilled.png"){
            self.tpFavoriteButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
            //print("here111")
            Database.database().reference().child("posts").child(cell.postID!).observeSingleEvent(of: .value, with: { snapshot in
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
                
                Database.database().reference().child("posts").child(cell.postID!).child("favorites").setValue(favoritesArray)
                Database.database().reference().child("users").child(cell.posterUID!).child("posts").child(cell.postID!).child("favorites").setValue(favoritesArray)
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").updateChildValues([cell.postID: cell.selfData!])
                //self.favoritesCountButton.setTitle(String(favoritesArray.count), for: .normal)
                Database.database().reference().child("users").child(cell.posterUID!).observeSingleEvent(of: .value, with: { snapshot in
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
                        
                        let tempDict = ["actionByUsername": cell.myUName! ,"postID": cell.postID!, "actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": cell.myPicString, "postText": cell.postText.text as! String] as! [String:Any]
                        noteArray.append(tempDict)
                        Database.database().reference().child("users").child(cell.posterUID!).updateChildValues(["notifications": noteArray] as [AnyHashable:Any]){ err, ref in
                           // print("done")
                        }
                    } else {
                        let sendString = cell.myUName! + " favorited your post."
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        
                        let tempDict = ["actionByUsername": cell.myUName! ,"postID": cell.postID, "actionText": sendString, "timeStamp": dateString,"actionByUID": Auth.auth().currentUser!.uid,"actionByUserPic": cell.myPicString, "postText": cell.postText.text as! String] as! [String : Any]
                        Database.database().reference().child("users").child(cell.posterUID!).updateChildValues(["notifications":[tempDict]])
                    }
                    
                })
                
                //reload collect in delegate
                
            })
            
            
            
        } else {
            self.tpFavoriteButton.setBackgroundImage(UIImage(named:"favoritesUnfilled.png"), for: .normal)
            
            
            Database.database().reference().child("posts").child(cell.postID!).observeSingleEvent(of: .value, with: { snapshot in
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
                    // self.favoritesCountButton.setTitle(String(favesArray.count), for: .normal)
                }
                
                
                Database.database().reference().child("posts").child(cell.postID!).child("favorites").setValue(favesArray)
                
                
                Database.database().reference().child("users").child(cell.posterUID!).child("posts").child(cell.postID!).child("favorites").setValue(favesArray)
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").child(cell.postID!).removeValue()
                
            })
            
        }
        
    }
    
    @IBAction func backFromLikedByViewButtonPressed(_ sender: Any) {
        //DispatchQueue.main.async{
           // self.loadFeedData()
       // }
        if textPostCommentView.isHidden == false{ curCell.likeButton.setImage(tpLikeButton.imageView!.image, for: .normal)
        curCell.favoritesButton.setBackgroundImage(tpFavoriteButton.currentBackgroundImage, for: .normal)
        
        curCell.likesCountButton.setTitle(tpLikesCountButton.titleLabel!.text, for: .normal)
        }
        
        
        tpBottomLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        likedByCollect.frame = ogLikeCollectFrame
        textPostCommentView.isHidden = true
        self.inboxButton.isHidden = false
        commentTF.resignFirstResponder()
        self.topLabel.text = "GymMe"
        shareFinalizeButton.isHidden = true
        shareSearchBar.isHidden = true
        self.commentTFView.isHidden = true
        addFriendsButton.isHidden = false
        cellButtonsPressedView.isHidden = true
        inboxButton.isHidden = false
        self.tabBar.isHidden = false
        self.topLabel.isHidden = true
        self.logoWords.isHidden = false
        //self.likeTopLabel.isHidden = true
        self.backFromLikedByViewButton.isHidden = true
        self.likedByCollectData.removeAll()
        //DispatchQueue.main.async {
           // print("reloadingFeedAfterComment")
        DispatchQueue.main.async{
            
            self.likedByCollect.reloadData()
        }
       // feedCollect.reloadItems(at: [curIndex])
            //self.feedCollect.reloadData()
       // }
        
        //self.likedByCollectData.removeAll()

    }
    
    
    
    @IBOutlet weak var backFromLikedByViewButton: UIButton!
    @IBAction func inboxPressed(_ sender: Any) {
        performSegue(withIdentifier: "FeedToMessages", sender: self)
    }
    @IBOutlet weak var inboxButton: UIButton!
    
    var temp = FeedData()
    var temp2 = FeedData()
    var temp3 = FeedData()
    var prevScreen = String()
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items![1]{
            performSegue(withIdentifier: "FeedToSearch", sender: self)
        } else if item == tabBar.items![2]{
            performSegue(withIdentifier: "FeedToPost", sender: self)
        } else if item == tabBar.items![3]{
            performSegue(withIdentifier: "FeedToNotifications", sender: self)
        } else if item == tabBar.items![4]{
            
           self.showWaitOverlay()
            SwiftOverlays.showBlockingWaitOverlayWithText("Loading Profile")
            performSegue(withIdentifier: "FeedToProfile", sender: self)
        } else {
            //curScreen
            feedCollect.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        
    }
    
    var findFriendsData = [[String:Any]]()
    
    @IBOutlet weak var likedByCollect: UICollectionView!
    @IBOutlet weak var cellButtonsPressedView: UIView!
    @IBOutlet weak var feedCollect: UICollectionView!
   /* override func viewDidDisappear(_ animated: Bool) {
        commentTF.resignFirstResponder()
    }*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == feedCollect{
            return feedDataArray.count
        } else if collectionView == likedByCollect {
            //print("likedByDataCount: \(likedByCollectData.count)")
            return likedByCollectData.count
        } else {
            return findFriendsData.count
        }
    }
    var curVidCell: NewsFeedPicCollectionViewCell?
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == feedCollect{
            if feedDataArray.count == 0{
                
            } else {
            var centerCellIndexPath: IndexPath?
            if feedCollect.indexPathForItem(at: self.view.convert(self.view.center, to: self.feedCollect)) != nil{
                centerCellIndexPath = feedCollect.indexPathForItem(at: self.view.convert(self.view.center, to: self.feedCollect))
                
                
                if (feedDataArray[centerCellIndexPath!.row])["postVid"] != nil{
                   // print("scrollingInFeedStopping: \(centerCellIndexPath)")
                    curVidCell = (feedCollect.cellForItem(at: centerCellIndexPath!) as! NewsFeedPicCollectionViewCell)
                    curVidCell!.player!.playFromBeginning() 
                }
            }
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if curVidCell != nil{
        //curVidCell!.player!.stop()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if feedDataArray.count == 0{
            
        } else {
        if (feedDataArray[indexPath.row])["postVid"] != nil{
        if let vidCell = cell as? NewsFeedPicCollectionViewCell {
            vidCell.player!.stop()
        }
        }
        }
    }
    
    var selectedCurAuthProfile = true
    var curName = String()
    func performSegueToPosterProfile(uid: String, name: String){
        self.curName = name
        self.selectedCellUID = uid
        if uid == Auth.auth().currentUser!.uid {
            selectedCurAuthProfile = true
        } else {
            selectedCurAuthProfile = false
        }
        performSegue(withIdentifier: "FeedToProfile", sender: self)
    }
    func showLikedByView(sentBy: String){
        //print("showLikedByView")
    }
    var sentBy: String?
    var selectedPostForComments = String()
    var selectedPostPosterID = String()
    @IBOutlet weak var topLabel: UILabel!
    var curIndex = IndexPath()
    func showLikedByViewTextCell(sentBy: String, cell: NewsFeedCellCollectionViewCell){
        
       
        
        self.logoWords.isHidden = true
        self.sentBy = sentBy
        self.curCommentCell = cell
        self.curIndex = (curCommentCell?.cellIndexPath!)!
        curPostID = cell.postID!
        self.cellType = "text"
        self.addFriendsButton.isHidden = true
        if sentBy == "likedBy"{
            likedByCollectData.removeAll()
            //print("likedBy")
            if ((feedDataArray[(cell.cellIndexPath?.row)!]["likes"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                commentTFView.isHidden = true
            } else {
                
                self.topLabel.text = "Likes"
                likedByCollectData = (feedDataArray[(cell.cellIndexPath?.row)!]["likes"] as! [[String:Any]])
               
                
                //self.likeTopLabel.isHidden = false
                self.backFromLikedByViewButton.isHidden = false
                //DispatchQueue.main.async {
                
                commentTFView.isHidden = true
                self.likedByCollect.delegate = self
                self.likedByCollect.dataSource = self
                DispatchQueue.main.async{
                    self.likedByCollect.reloadData()
                }
                //}
            }
        } else if sentBy == "share"{
            addFriendsButton.isHidden = true
           
            //self.likeTopLabel.isHidden = false
            backFromLikedByViewButton.isHidden = false
            commentTFView.isHidden = true
           /* */

            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

alert.addAction(UIAlertAction(title: "Send via Contacts", style: .default) { _ in
   //<handler>
    
            



    self.activityViewController = UIActivityViewController(
                activityItems: ["Download GymMe today!"],
                applicationActivities: nil)
            
    self.present(self.activityViewController!, animated: true, completion: nil)
})

alert.addAction(UIAlertAction(title: "Send via Direct Message", style: .default) { _ in
    //<handler>
    self.shareFinalizeButton.isHidden = false
            self.inboxButton.isHidden = true
    self.addFriendsButton.isHidden = true
    //self.likeTopLabel.isHidden = false
    self.backFromLikedByViewButton.isHidden = false
            //self.postCommentButton.isHidden = true
            //self.selfCommentPic.isHidden = true
    //self.commentTFView.isHidden = true
    self.shareSearchBar.isHidden = true
            
    
            Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                
                
                let followersArr = valDict["followers"] as! [String]
                let followingArr = valDict["following"] as! [String]
                var mergedArr = Array(Set(followersArr + followingArr))
                var sortedMergedArr = mergedArr.sort()
                //print("mergedArr: \(sortedMergedArr)")
             

                
                Database.database().reference().child("users").observeSingleEvent(of: .value, with: { snapshot in
                    let valDict2 = snapshot.value as! [String:Any]
                    for (key, vall) in valDict2{
                        var val = vall as! [String:Any]
                        //print("key: \(key), val: \(val)")
                        if mergedArr.contains(key){
                            var collectDataDict = ["pic": (val["profPic"] as! String), "-": self.myUName, "realName": (val["realName"] as! String), "uid":
                                key]
                            
                            self.likedByCollectData.append(collectDataDict)
                        }
                    }
                    var count = 0
                    for dict in self.likedByCollectData{
                        let tempDict = dict
                        if tempDict["x"] != nil {
                            self.likedByCollectData.remove(at: count)
                            break
                        }
                        
                        count = count + 1
                    }
                    self.likedByCollect.delegate = self
                    self.likedByCollect.dataSource = self
                    DispatchQueue.main.async{
                        self.likedByCollect.reloadData()
                    }
                    self.cellButtonsPressedView.isHidden = false
                    self.inboxButton.isHidden = true
                    self.tabBar.isHidden = true
                    self.addFriendsButton.isHidden = true
                    self.cellButtonsPressedView.isHidden = false
                   
                    //self.likeTopLabel.isHidden = false
                    
                    self.backFromLikedByViewButton.isHidden = false
                    
                    
                })
                
            })
})
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
                
                alert.dismiss(animated: true, completion: nil)
                
            })
            self.present(alert, animated: true)

            
            
        } else if sentBy == "showCommentsCount"{
            self.curCell = cell
            let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]
            let attributedString = NSMutableAttributedString(string:cell.postText.text, attributes:attrs)
            
            tpTextView.attributedText = attributedString
            
            
            self.tpTextView.resolveHashTags()
            
            
            let fixedWidth = cell.postText.frame.size.width
            let newSize = cell.postText.sizeThatFits(CGSize(width: fixedWidth, height: self.estimateFrameForText(text: cell.postText.text as! String).height))
            
            tpTextView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            tpTextView.isScrollEnabled = false
            tpTimestampLabel.text = cell.timeStambLabel.text
            
            tpImageView.image = cell.profImageView.image!
            tpLikeButton.setImage(cell.likeButton.imageView!.image, for: .normal)
            tpFavoriteButton.setBackgroundImage(cell.favoritesButton.currentBackgroundImage, for: .normal)
            
            tpTimestampLabel.text = cell.timeStambLabel.text!
            //tpPosterPicButton
            tpLikesCountButton.setTitle(cell.likesCountButton.titleLabel!.text, for: .normal)
            tpPosterNameButton.setTitle(cell.posterNameButton.titleLabel!.text, for: .normal)
            tpPostLocationButton.setTitle(cell.postLocationButton.titleLabel!.text, for: .normal)
            var viewSize = sizeForTextPostCommentView(sizeText: cell.postText.text as! String)
            
            //var comHeight = tpTopView.frame.height + viewSize.height + tpBottomView.frame.height
            print("curCellHeight: \(curCell.frame.height)")
            print("viewSizeHeight: \(viewSize.height)")
            tpPosterNameButton.frame = CGRect(x: 51, y: 5, width: tpPosterNameButton.frame.width, height: 25)
            tpPostLocationButton.frame = CGRect(x: 51, y: 26, width: tpPostLocationButton.frame.width, height: 25)
            textPostCommentView.frame = CGRect(x: textPostCommentView.frame.origin.x, y: textPostCommentView.frame.origin.y, width: viewSize.width, height: curCell.frame.height - 15)
            
            tpTopView.frame = CGRect(x: 0, y: 0, width: tpTopView.frame.width, height: 51)
            tpTextView.frame = CGRect(x: 8, y: 0 + tpTopView.frame.height, width: textPostCommentView.frame.width, height: curCell.postText.frame.height)
            tpBottomView.frame = CGRect(x: 8, y: 0 + tpTopView.frame.height + tpTextView.frame.height - 15, width: tpBottomView.frame.width, height: textPostCommentView.frame.height - tpTextView.frame.height - tpTopView.frame.height + 5)
            
            tpImageView.frame.size = CGSize(width: 35, height: 35)
            
            tpImageView.layer.cornerRadius = tpImageView.frame.width/2
            tpImageView.layer.masksToBounds = true
            
            likedByCollect.frame = CGRect(x: likedByCollect.frame.origin.x, y: likedByCollect.frame.origin.y + textPostCommentView.frame.height, width: likedByCollect.frame.width, height: likedByCollect.frame.height - textPostCommentView.frame.height)
            
            textPostCommentView.isHidden = false
            
            self.selectedPostForComments = cell.postID!
            self.selectedPostPosterID = cell.posterUID!
            self.topLabel.isHidden = false
            
            likedByCollectData.removeAll()
           // print("showCommentsCount")
           
            //self.likeTopLabel.isHidden = false
            
            self.backFromLikedByViewButton.isHidden = false
            SwiftOverlays.showBlockingTextOverlay("loading comments")
            self.likedByCollect.performBatchUpdates(nil, completion: {
                (result) in
                // ready
                self.commentTF.resignFirstResponder
                SwiftOverlays.removeAllBlockingOverlays()
                
                //print("doneLoading5")
            })
            
            self.postCommentButton.isHidden = false
            self.commentTFView.isHidden = false
            
            self.topLabel.text = "Comments"
            if ((feedDataArray[(cell.cellIndexPath?.row)!]["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil {
                
                
                
            } else {
                
                
                
                likedByCollectData = (feedDataArray[(cell.cellIndexPath?.row)!]["comments"] as! [[String:Any]])
                
                //DispatchQueue.main.async {
                
                
                self.likedByCollect.delegate = self
                self.likedByCollect.dataSource = self
                DispatchQueue.main.async{
                    self.likedByCollect.reloadData()
                    
                }
            }
        } else if sentBy == "showComments" {
            self.curCell = cell
            let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]
            let attributedString = NSMutableAttributedString(string:cell.postText.text, attributes:attrs)
            
            tpTextView.attributedText = attributedString
            
            
            self.tpTextView.resolveHashTags()
            
            
            let fixedWidth = cell.postText.frame.size.width
            let newSize = cell.postText.sizeThatFits(CGSize(width: fixedWidth, height: self.estimateFrameForText(text: cell.postText.text as! String).height))
            
            tpTextView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            tpTextView.isScrollEnabled = false
             tpTimestampLabel.text = cell.timeStambLabel.text
            
            tpImageView.image = cell.profImageView.image!
            tpLikeButton.setImage(cell.likeButton.imageView!.image, for: .normal)
            tpFavoriteButton.setBackgroundImage(cell.favoritesButton.currentBackgroundImage, for: .normal)
            tpTimestampLabel.text = cell.timeStambLabel.text!
            //tpPosterPicButton
            tpLikesCountButton.setTitle(cell.likesCountButton.titleLabel!.text, for: .normal)
            tpPosterNameButton.setTitle(cell.posterNameButton.titleLabel!.text, for: .normal)
            tpPostLocationButton.setTitle(cell.postLocationButton.titleLabel!.text, for: .normal)
            var viewSize = sizeForTextPostCommentView(sizeText: cell.postText.text as! String)
            
            textPostCommentView.frame = CGRect(x: textPostCommentView.frame.origin.x, y: textPostCommentView.frame.origin.y, width: viewSize.width, height: viewSize.height)
            
            tpImageView.frame.size = CGSize(width: 35, height: 35)
            tpImageView.layer.cornerRadius = tpImageView.frame.width/2
            tpImageView.layer.masksToBounds = true
            
            likedByCollect.frame = CGRect(x: likedByCollect.frame.origin.x, y: likedByCollect.frame.origin.y + textPostCommentView.frame.height, width: likedByCollect.frame.width, height: likedByCollect.frame.height - textPostCommentView.frame.height)
            
            textPostCommentView.isHidden = false
            self.selectedPostForComments = cell.postID!
            self.selectedPostPosterID = cell.posterUID!
            self.commentTF.delegate = self
            likedByCollectData.removeAll()
           // print("showComments")
           
            //self.likeTopLabel.isHidden = false
            
            self.backFromLikedByViewButton.isHidden = false
            SwiftOverlays.showBlockingTextOverlay("loading comments")
            self.likedByCollect.performBatchUpdates(nil, completion: {
                (result) in
                // ready
                self.commentTF.becomeFirstResponder()
                SwiftOverlays.removeAllBlockingOverlays()
                
                //print("doneLoading5")
            })
            
            //self.postCommentButton.isHidden = false
            self.commentTFView.isHidden = false
            self.logoWords.isHidden = true
            self.topLabel.text = "Comments"
            self.topLabel.isHidden = false
            if ((feedDataArray[(cell.cellIndexPath?.row)!]["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil {
                
            
                
            } else {
                
                
                
                likedByCollectData = (feedDataArray[(cell.cellIndexPath?.row)!]["comments"] as! [[String:Any]])
                
                //DispatchQueue.main.async {
                
                
                self.likedByCollect.delegate = self
                self.likedByCollect.dataSource = self
                DispatchQueue.main.async{
                    self.likedByCollect.reloadData()
                }
            }
        } else {
            commentTFView.isHidden = true
        }
        if sentBy != "share"{
            
            cellButtonsPressedView.isHidden = false
            //commentTFView.isHidden = true
            inboxButton.isHidden = true
            self.tabBar.isHidden = true
            
        }
    }
    @IBOutlet weak var shareSearchBar: UISearchBar!
    var curPostID = String()
    var cellType = String()
     var activityViewController:UIActivityViewController?
    
@IBOutlet weak var lineView: UIView!

    func showLikedByViewPicCell(sentBy: String, cell: NewsFeedPicCollectionViewCell){
       // print("showLikedByViewPicCell")
        likedByCollect.frame = ogLikeCollectFrame
        textPostCommentView.isHidden = true
        self.addFriendsButton.isHidden = true
        self.sentBy = sentBy
        self.curCommentPicCell = cell
        self.curIndex = (curCommentPicCell?.cellIndexPath!)!
        curPostID = cell.postID!
        self.logoWords.isHidden = true
        self.cellType = "pic"
        if sentBy == "likedBy"{
            commentTFView.isHidden = true
            likedByCollectData.removeAll()
           // print("likedBy")
            if ((feedDataArray[(cell.cellIndexPath?.row)!]["likes"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                commentTFView.isHidden = true
            } else {
                
                self.topLabel.text = "Likes"
                likedByCollectData = (feedDataArray[(cell.cellIndexPath?.row)!]["likes"] as! [[String:Any]])
                self.backFromLikedByViewButton.isHidden = false
                //self.likeTopLabel.isHidden = false
                
                //DispatchQueue.main.async {
                
                
                self.likedByCollect.delegate = self
                self.likedByCollect.dataSource = self
                DispatchQueue.main.async{
                    self.likedByCollect.reloadData()
                }
                //}
                
            }
            
        } else if sentBy == "share"{
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            addFriendsButton.isHidden = true
            
            self.topLabel.text = "share"
            backFromLikedByViewButton.isHidden = false
            alert.addAction(UIAlertAction(title: "Send via Contacts", style: .default) { _ in
                //<handler>
                
                
                
                
                
                self.activityViewController = UIActivityViewController(
                    activityItems: ["Download GymMe today!"],
                    applicationActivities: nil)
                
                self.present(self.activityViewController!, animated: true, completion: nil)
            })
            
            alert.addAction(UIAlertAction(title: "Send via Direct Message", style: .default) { _ in
                //<handler>
                self.shareFinalizeButton.isHidden = false
                self.inboxButton.isHidden = true
                //self.postCommentButton.isHidden = true
                //self.selfCommentPic.isHidden = true
                self.shareSearchBar.isHidden = true
                
                self.commentTFView.isHidden = true
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
                    let valDict = snapshot.value as! [String:Any]
                    
                    
                    
                    let followersArr = valDict["followers"] as! [String]
                    let followingArr = valDict["following"] as! [String]
                    var mergedArr = Array(Set(followersArr + followingArr))
                    var sortedMergedArr = mergedArr.sort()
                   // print("mergedArr: \(sortedMergedArr)")
                    
                    
                    
                    Database.database().reference().child("users").observeSingleEvent(of: .value, with: { snapshot in
                        let valDict2 = snapshot.value as! [String:Any]
                        for (key, vall) in valDict2{
                            var val = vall as! [String:Any]
                            //print("key: \(key), val: \(val)")
                            if mergedArr.contains(key){
                                var collectDataDict = ["pic": (val["profPic"] as! String), "-": self.myUName, "realName": (val["realName"] as! String), "uid":
                                    key]
                                
                                self.likedByCollectData.append(collectDataDict)
                            }
                        }
                        var count = 0
                        for dict in self.likedByCollectData{
                            let tempDict = dict
                            if tempDict["x"] != nil {
                                self.likedByCollectData.remove(at: count)
                                break
                            }
                            
                            count = count + 1
                        }
                        self.cellButtonsPressedView.isHidden = false
                        self.inboxButton.isHidden = true
                        self.tabBar.isHidden = true

                        self.likedByCollect.delegate = self
                        self.likedByCollect.dataSource = self
                        DispatchQueue.main.async{
                            self.likedByCollect.reloadData()
                        }
                        
                        
                    })
                    
                })
                
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
                    alert.dismiss(animated: true, completion: nil)
                
                })
            self.present(alert, animated: true)
        } else if sentBy == "showCommentsCount"{
            
            //print("showCommentsCountPic")
            self.selectedPostForComments = cell.postID!
            self.selectedPostPosterID = cell.posterUID!
            self.backFromLikedByViewButton.isHidden = false
            likedByCollectData.removeAll()
            SwiftOverlays.showBlockingTextOverlay("loading comments")
            self.likedByCollect.performBatchUpdates(nil, completion: {
                (result) in
                // ready
                self.commentTF.resignFirstResponder
                SwiftOverlays.removeAllBlockingOverlays()
                
               // print("doneLoading5")
            })
            //self.postCommentButton.isHidden = false
            self.commentTFView.isHidden = false
            self.topLabel.isHidden = false
            self.topLabel.text = "Comments"
            //self.likeTopLabel.isHidden = true
            if ((feedDataArray[(cell.cellIndexPath?.row)!]["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil {
                
                
                
            } else {
                
                likedByCollectData.removeAll()
                
                likedByCollectData = (feedDataArray[(cell.cellIndexPath?.row)!]["comments"] as! [[String:Any]])
                
                //DispatchQueue.main.async {
                
                
                self.likedByCollect.delegate = self
                self.likedByCollect.dataSource = self
                DispatchQueue.main.async{
                    self.likedByCollect.reloadData()
                }
            }
        } else if sentBy == "showComments" {
            likedByCollectData.removeAll()
            self.selectedPostForComments = cell.postID!
            self.selectedPostPosterID = cell.posterUID!
           // print("showComments")
            self.commentTF.delegate = self
            self.backFromLikedByViewButton.isHidden = false
            SwiftOverlays.showBlockingTextOverlay("loading comments")
            self.likedByCollect.performBatchUpdates(nil, completion: {
                (result) in
                // ready
                self.commentTF.becomeFirstResponder()
                SwiftOverlays.removeAllBlockingOverlays()
                
                //print("doneLoading5")
            })
            self.commentTFView.isHidden = false
            self.topLabel.isHidden = false
            self.topLabel.text = "Comments"
            if ((feedDataArray[(cell.cellIndexPath?.row)!]["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil {
                
                
                
            } else {
                
                
                
                likedByCollectData = (feedDataArray[(cell.cellIndexPath?.row)!]["comments"] as! [[String:Any]])
                
                
                DispatchQueue.main.async{
                    self.likedByCollect.reloadData()
                }
            }
        } else {
            commentTFView.isHidden = true
        }
        if sentBy != "share"{
            addFriendsButton.isHidden = true
            cellButtonsPressedView.isHidden = false
            //commentTFView.isHidden = true
            inboxButton.isHidden = true
            self.tabBar.isHidden = true
            backFromLikedByViewButton.isHidden = false
        }
        
    }
    
    
    @IBOutlet weak var commentTF: UITextField!
    
    var typeOfCellAtIndexPath = [IndexPath:Int]()
    var likedByCollectData = [[String:Any]]()
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       // print("hey there sd")
        
        if cellButtonsPressedView.isHidden == false && likedByCollectData[indexPath.row]["x"] == nil || sentBy == "addFriends" || collectionView == likedByCollect{
           // print("likedByCollectData at indexPath: \(likedByCollectData[indexPath.row])")
        
            if self.sentBy == "share" {
                let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
                DispatchQueue.main.async{
                    cell.contentView.layer.cornerRadius = 2.0
                    cell.contentView.layer.borderWidth = 1.0
                    cell.contentView.layer.borderColor = UIColor.clear.cgColor
                    cell.contentView.layer.masksToBounds = true
                    cell.shareCheck.isHidden = false
                    cell.shareCheck.frame.size = CGSize(width: 25, height: 25)
                    
                    
                   
                cell.selectButton.isHidden = true
                cell.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
                
                cell.likedByFollowButton.isHidden = true
                
                //cell.selectButton.isHidden = false
                cell.delegate1 = self
                cell.likedByName.isHidden = false
                cell.likedByUName.isHidden = false
                cell.commentName.isHidden = true
                cell.commentTextView.isHidden = true
                //cell.commentTimestamp.isHidden = true
                //if (likedByCollectData[indexPath.row])["x"] != nil{
                cell.likedByUName.text = ((self.likedByCollectData[indexPath.row] )["uName"] as? String)
                cell.indexPath = indexPath
                cell.likedByUID = ((self.likedByCollectData[indexPath.row])["uid"] as! String)
                
                cell.likedByName.text = ((self.likedByCollectData[indexPath.row] )["realName"] as! String)
                
                if ((self.likedByCollectData[indexPath.row])["pic"] as! String) == "profile-placeholder"{
                    DispatchQueue.main.async{
                        cell.likedByImage.image = UIImage(named: "profile-placeholder")
                    }
                    
                } else {
                    if let messageImageUrl = URL(string: self.likedByCollectData[indexPath.row]["pic"] as! String) {
                        
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

            } else if self.sentBy == "likedBy"{
                 let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
                DispatchQueue.main.async{
                    cell.contentView.layer.cornerRadius = 2.0
                    cell.contentView.layer.borderWidth = 1.0
                    cell.contentView.layer.borderColor = UIColor.clear.cgColor
                    cell.contentView.layer.masksToBounds = true
                    
                  
                    cell.layer.masksToBounds = false
                    
                    
                if (self.following?.contains(self.likedByCollectData[indexPath.row]["uid"] as! String))!{
                    cell.likedByFollowButton.setTitle("Unfollow", for: .normal)
                }
                cell.likedByName.isHidden = false
                cell.likedByUName.isHidden = false
                cell.likedByFollowButton.isHidden = false
                cell.commentName.isHidden = true
                cell.commentTextView.isHidden = true
                cell.commentTimestamp.isHidden = true
                cell.likedByUName.text = self.likedByCollectData[indexPath.row]["uName"] as! String
                
                cell.likedByUID = self.likedByCollectData[indexPath.row]["uid"] as! String
                
                cell.likedByName.text = self.likedByCollectData[indexPath.row]["realName"] as! String
                if self.likedByCollectData[indexPath.row]["pic"] as! String == "profile-placeholder"{
                    DispatchQueue.main.async{
                    cell.likedByImage.image = UIImage(named: "profile-placeholder")
                    }
                } else {
                    if let messageImageUrl = URL(string: self.likedByCollectData[indexPath.row]["pic"] as! String) {
                
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
            } else if self.sentBy == "showComments" || self.sentBy == "showCommentsCount"{
                //commentTF.becomeFirstResponder()
                 let cell : CommentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCollectionViewCell", for: indexPath) as! CommentCollectionViewCell
                //DispatchQueue.main.async{
               cell.myRealName = self.myRealName
                cell.posterUID = self.selectedPostPosterID
                cell.posterName = (self.likedByCollectData[indexPath.row]["commentorName"] as! String)
                
                cell.postID = self.selectedPostForComments
                    cell.commentDelegate = self
                    cell.indexPath = indexPath
                    cell.contentView.layer.cornerRadius = 2.0
                    cell.contentView.layer.borderWidth = 1.0
                    cell.contentView.layer.borderColor = UIColor.clear.cgColor
                    cell.contentView.layer.masksToBounds = true
                    
                
                cell.commentorPic.frame.size = CGSize(width: 35, height: 35)
                
                    cell.commentorPic.layer.cornerRadius = cell.commentorPic.frame.width/2
                cell.commentorPic.layer.masksToBounds = true
                if self.likedByCollectData.count == 0{
                    
                } else {
                    if self.likedByCollectData[indexPath.row]["likes"] as? [[String:Any]] == nil{
                        
                    } else {
                        var tempLikes = self.likedByCollectData[indexPath.row]["likes"] as? [[String:Any]]
                        
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
                    
                let nameAndComment = (self.likedByCollectData[indexPath.row]["commentorName"] as! String) + " " +  (self.likedByCollectData[indexPath.row]["commentText"] as! String)
                //print("name&Comment: \(nameAndComment)")
                    let boldNameAndComment = self.attributedText(withString: nameAndComment, boldString: (self.likedByCollectData[indexPath.row]["commentorName"] as! String), font: cell.commentTextView.font!)
                //print("boldName&Comment: \(boldNameAndComment)")
                cell.commentTextView.attributedText = boldNameAndComment
                let tStampDateString = self.likedByCollectData[indexPath.row]["commentDate"] as! String
                cell.commentTextView.resolveHashTags()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                let date = dateFormatter.date(from: tStampDateString)
                
                let now = Date()
                //print("tStampDateString: \(tStampDateString), date: \(date!), now: \(now)")
                    var hoursBetween = Int(now.days(from: date!))
                    //print("hrs Between: \(hoursBetween)")
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
                
                if self.likedByCollectData[indexPath.row]["commentorPic"] as! String == "profile-placeholder"{
                    cell.commentorPic.setImage(UIImage(named: "profile-placeholder"), for: .normal)
                } else {
                    if let messageImageUrl = URL(string: self.likedByCollectData[indexPath.row]["commentorPic"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            cell.commentorPic.setImage(UIImage(data: imageData as Data), for: .normal)
                        }
                    }
                }
                }
                return cell
            } else if sentBy == "addFriends" {
                let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
                
                DispatchQueue.main.async{
                    
                    cell.contentView.layer.cornerRadius = 2.0
                    cell.contentView.layer.borderWidth = 1.0
                    cell.contentView.layer.borderColor = UIColor.clear.cgColor
                    cell.contentView.layer.masksToBounds = true
                    
                   
                    
                if ((self.following?.contains(((self.findFriendsData[indexPath.row])["uid"] as! String)))!){
                    cell.likedByFollowButton.setTitle("Unfollow", for: .normal)
                }
                cell.likedByName.isHidden = false
                cell.likedByUName.isHidden = false
                cell.likedByFollowButton.isHidden = false
                cell.commentName.isHidden = true
                cell.commentTextView.isHidden = true
                cell.commentTimestamp.isHidden = true
                cell.likedByUName.text = ((self.findFriendsData[indexPath.row] )["uName"] as! String)
                
               cell.likedByUID = ((self.findFriendsData[indexPath.row])["uid"] as! String)
                
                cell.likedByName.text = ((self.findFriendsData[indexPath.row] )["realName"] as! String)
                if ((self.findFriendsData[indexPath.row])["picString"] as! String) == "profile-placeholder"{
                    DispatchQueue.main.async{
                    cell.likedByImage.image = UIImage(named: "profile-placeholder")
                    }
                    
                } else {
                    DispatchQueue.main.async{
                    cell.likedByImage.image = ((self.findFriendsData[indexPath.row])["profPic"] as! UIImage)
                    }
                }
                }
                return cell
            } else {
                return UICollectionViewCell()
            }
        } else {
            //else if its a feed cell
           // print("FeedCollect pic or vid cell")
        //print("PostID: \(feedDataArray[indexPath.row]["postID"])")
        if feedDataArray[indexPath.row]["postPic"] == nil && feedDataArray[indexPath.row]["postVid"] == nil {
            
            typeOfCellAtIndexPath[indexPath] = 0
            let cell : NewsFeedCellCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsFeedCellCollectionViewCell", for: indexPath) as! NewsFeedCellCollectionViewCell
            DispatchQueue.main.async{
                
                
                cell.profImageView.frame = CGRect(x: cell.profImageView.frame.origin.x, y: cell.profImageView.frame.origin.y, width: 35, height: 35)
                cell.goToPosterProfile.frame = CGRect(x: cell.profImageView.frame.origin.x, y: cell.profImageView.frame.origin.y, width: 35, height: 35)
                cell.contentView.layer.cornerRadius = 2.0
                cell.contentView.layer.borderWidth = 1.0
                cell.contentView.layer.borderColor = UIColor.clear.cgColor
                cell.contentView.layer.masksToBounds = true
                
                cell.layer.shadowColor = UIColor.gray.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 2.0);
                cell.layer.shadowRadius = 1.5;
                cell.layer.shadowOpacity = 0.3;
                cell.layer.masksToBounds = false
                cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
                

            cell.delegate = self
                var tempDict = self.feedDataArray[indexPath.row]
                //print("roll: \(tempDict["postPicString"]) \(tempDict["postPic"])")
                tempDict["postPic"] = tempDict["postPicString"]
                tempDict["posterPicURL"] = tempDict["posterPicString"]
                if tempDict["postVid"] != nil{
                    tempDict["postVid"] = tempDict["postVidString"]
                }
                cell.selfData = tempDict
            if self.feedDataArray[indexPath.row]["postText"] != nil {
                
                
                let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]
                let attributedString = NSMutableAttributedString(string:self.feedDataArray[indexPath.row]["postText"] as! String, attributes:attrs)
                
                cell.postText.attributedText = attributedString
                

                cell.postText.resolveHashTags()
                

                let fixedWidth = cell.postText.frame.size.width
                let newSize = cell.postText.sizeThatFits(CGSize(width: fixedWidth, height: self.estimateFrameForText(text: cell.postText.text as! String).height))
                
                cell.postText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                cell.postText.isScrollEnabled = false
                
                //textHere
                
            }
            
            cell.postLocationButton.setTitle(self.feedDataArray[indexPath.row]["city"] as? String, for: .normal)
            //cell.postText.text = (self.feedDataArray[indexPath.row]["postText"] as! String)
                
   

            cell.postID = self.feedDataArray[indexPath.row]["postID"] as? String
            cell.posterName = self.feedDataArray[indexPath.row]["posterName"] as? String
            cell.myRealName = self.myRealName
            cell.myPicString = self.myPicString
            cell.myUName = self.myUName!
            
            DispatchQueue.main.async{
           
                
                cell.profImageView.image = self.feedDataArray[indexPath.row]["posterPicURL"] as! UIImage
            }
            
            var likesPost: [String:Any]?
            var favesPost: [String:Any]?
            var commentsPost: [String:Any]?
            for item in (self.feedDataArray[indexPath.row]["comments"] as? [[String: Any]])!{
                
                commentsPost = item as! [String: Any]
                
            }
                var likedBySelf = false
            for item in (self.feedDataArray[indexPath.row]["likes"] as? [[String: Any]])!{
                
                likesPost = item
                if likesPost!.count == 1 && likesPost!["x"] != nil{
                    
                } else {
                if (likesPost!["uName"] as! String) == self.myUName{
                    likedBySelf = true
                }
                }
            }
            if likesPost!["x"] != nil {
                
            } else {
                DispatchQueue.main.async{
                    var likeString = String()
                    if (self.feedDataArray[indexPath.row]["likes"] as? [[String: Any]])!.count == 1 {
                        
                        likeString = String((self.feedDataArray[indexPath.row]["likes"] as? [[String: Any]])!.count) + " like"
                        
                    } else {
                        likeString = String((self.feedDataArray[indexPath.row]["likes"] as? [[String: Any]])!.count) + " likes"
                    }
                    
                    cell.likesCountButton.setTitle(likeString, for: .normal)
                
                if likedBySelf == true{
                    cell.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                }
                }
            }
            //set comments count
            var commentString = String()
            if commentsPost!["x"] != nil {
                cell.commentsCountButton.setTitle("No comments yet", for: .normal)
            } else {
                
               var comments = (self.feedDataArray[indexPath.row]["comments"] as? [[String: Any]])
                
               
                if (comments!.count == 0){
                        commentString = "0 comments"
                    } else {
                    commentString = "View \(comments!.count) comments"
                    }
            
                cell.commentsCountButton.setTitle(commentString, for: .normal)
                
                }
            var favedBySelf = false
            for item in (self.feedDataArray[indexPath.row]["favorites"] as? [[String: Any]])!{
                
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
                     DispatchQueue.main.async{
                    cell.favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                    //cell.favoritesCountButton.setTitle((self.feedDataArray[indexPath.row]["favorites"] as! [[String:Any]]).count.description, for: .normal)
                    }
                }
            }
            DispatchQueue.main.async {
             cell.profImageView.image = self.feedDataArray[indexPath.row]["posterPicURL"] as! UIImage
            
            cell.postLocationButton.setTitle(self.feedDataArray[indexPath.row]["city"] as! String, for: .normal)
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            cell.posterUID = (self.feedDataArray[indexPath.row]["posterUID"] as! String)
            cell.posterNameButton.setTitle((self.feedDataArray[indexPath.row]["posterName"] as! String), for: .normal)
            //cell.postLocationButton.setTitle("location", for: .normal)
            cell.cellIndexPath = indexPath
            let tStampDateString = self.feedDataArray[indexPath.row]["datePosted"] as! String
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            let date = dateFormatter.date(from: tStampDateString)

            let now = Date()
            //print("tStampDateString: \(tStampDateString), date: \(date!), now: \(now)")
                var hoursBetween = Int(now.days(from: date!))
               // print("hrs Between: \(hoursBetween)")
                if hoursBetween < 1{
                    hoursBetween = Int(now.hours(from: date!))!
                    if hoursBetween < 1 {
                        hoursBetween = Int(now.minutes(from: date!))
                        if hoursBetween == 1{
                            cell.timeStambLabel.text = "\(hoursBetween) minute ago"
                        } else {
                            cell.timeStambLabel.text = "\(hoursBetween) minutes ago"
                        }
                    } else {
                        if hoursBetween == 1 {
                            cell.timeStambLabel.text = "\(hoursBetween) hour ago"
                        } else {
                            cell.timeStambLabel.text = "\(hoursBetween) hours ago"
                        }
                    }
                } else {
                    if hoursBetween == 1 {
                        cell.timeStambLabel.text = "\(hoursBetween) day ago"
                    } else {
                        cell.timeStambLabel.text = "\(hoursBetween) days ago"
                    }
                }
            }
            }
            //cell.setNeedsDisplay()
            return cell
        } else {
            //print("picOrVidCell")
            
            self.typeOfCellAtIndexPath[indexPath] = 1
            let cell : NewsFeedPicCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsFeedPicCollectionViewCell", for: indexPath) as! NewsFeedPicCollectionViewCell
            DispatchQueue.main.async{
            
                cell.contentView.layer.cornerRadius = 2.0
                cell.contentView.layer.borderWidth = 1.0
                cell.contentView.layer.borderColor = UIColor.clear.cgColor

                cell.contentView.layer.masksToBounds = true
                


                cell.layer.shadowColor = UIColor.gray.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
                cell.layer.shadowRadius = 1.5;
                cell.layer.shadowOpacity = 0.3;
                cell.layer.masksToBounds = false
                cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
                
            if (self.feedDataArray[indexPath.row])["tagged"] != nil {
                var taggedString = ""
                var taggedFriends = (self.feedDataArray[indexPath.row])["tagged"] as! [[String:Any]]
                for dict in taggedFriends{
                    taggedString = taggedString + " " + (dict["realName"] as! String) + ","
                }
               // print("taggedString: \(taggedString)")
                cell.tagLabel.text = taggedString
            }
            
            
                var tempDict = self.feedDataArray[indexPath.row]
                //print("roll2: \(tempDict["postPicString"]) \(tempDict["postPic"])")
                tempDict["postPic"] = tempDict["postPicString"]
                tempDict["posterPicURL"] = tempDict["posterPicString"]
                if tempDict["postVid"] != nil{
                    tempDict["postVid"] = tempDict["postVidString"]
                }
                cell.selfData = tempDict
                
            cell.delegate = self
                
            cell.postID = self.feedDataArray[indexPath.row]["postID"] as? String
            cell.posterName = self.feedDataArray[indexPath.row]["posterName"] as? String
            cell.myUName = self.myUName!
            cell.myRealName = self.myRealName
            cell.myPicString = self.myPicString
            cell.postLocationButton.setTitle(self.feedDataArray[indexPath.row]["city"] as! String, for: .normal)
            //cell.postPic.frame = CGRect(x: cell.postPic.frame.origin.x, y: cell.postPic.frame.origin.y, width: cell.postPic.frame.width, height: cell.postPic.frame.height)
            
            var commentsPost: [String:Any]?
            for item in (self.feedDataArray[indexPath.row]["comments"] as? [[String: Any]])!{
                
                commentsPost = item as! [String: Any]
                
            }
            
            var tempPost: [String:Any]?
                var likedBySelf2 = false
            for item in (self.feedDataArray[indexPath.row]["likes"] as? [[String: Any]])!{
            
                tempPost = item as! [String: Any]
                if tempPost!.count == 1 && tempPost!["x"] != nil{
                    
                } else {
                if (tempPost!["uName"] as! String) == self.myUName{
                    likedBySelf2 = true
                }
                }
            }
            if tempPost!["x"] != nil {
                
            } else {
                
                
                let countStringNum = String((self.feedDataArray[indexPath.row]["likes"] as? [[String: Any]])!.count)
                var fullString1 = String()
                if countStringNum == "1"{
                    fullString1 = "\(countStringNum) like"
                } else {
                    fullString1 = "\(countStringNum) likes"
                }
                cell.likesCountButton.setTitle(fullString1, for: .normal)

            if likedBySelf2 == true{
                cell.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                let countStringNum = String((self.feedDataArray[indexPath.row]["likes"] as? [[String: Any]])!.count)
                var fullString = String()
                if countStringNum == "1"{
                fullString = "\(countStringNum) like"
                } else {
                    fullString = "\(countStringNum) likes"
                }
                cell.likesCountButton.setTitle(fullString, for: .normal)
                
                }
            }
            
            var favesPost: [String:Any]?
                var favedBySelf = false
                for item in (self.feedDataArray[indexPath.row]["favorites"] as? [[String: Any]])!{
                    
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
                        DispatchQueue.main.async{
                            cell.favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            
                        }
                    }
                }
            
            //set comments count
            if commentsPost!["x"] != nil {
                cell.commentsCountButton.setTitle("No comments yet", for: .normal)
            } else {
                let commStringNum = String((self.feedDataArray[indexPath.row]["comments"] as? [[String: Any]])!.count)
                var commString = String()
                if commStringNum == "1"{
                    commString = "View \(commStringNum) comment"
                } else {
                    commString = "View \(commStringNum) comments"
                }
                cell.commentsCountButton.setTitle(commString, for: .normal)
                
            }
            
            cell.postLocationButton.setTitle(self.feedDataArray[indexPath.row]["city"] as? String, for: .normal)
            
            let tStampDateString = self.feedDataArray[indexPath.row]["datePosted"] as! String
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            let date = dateFormatter.date(from: tStampDateString)

            let now = Date()
            
                var hoursBetween = Int(now.days(from: date!))
               // print("hrs Between: \(hoursBetween)")
                if hoursBetween < 1{
                    hoursBetween = Int(now.hours(from: date!))!
                    if hoursBetween < 1 {
                        hoursBetween = Int(now.minutes(from: date!))
                        if hoursBetween == 1{
                        cell.timeStampLabel.text = "\(hoursBetween) minute ago"
                    } else {
                        cell.timeStampLabel.text = "\(hoursBetween) minutes ago"
                    }
                    } else {
                        if hoursBetween == 1 {
                            cell.timeStampLabel.text = "\(hoursBetween) hour ago"
                        } else {
                            cell.timeStampLabel.text = "\(hoursBetween) hours ago"
                        }
                    }
                } else {
                    if hoursBetween == 1 {
                        cell.timeStampLabel.text = "\(hoursBetween) day ago"
                    } else {
                        cell.timeStampLabel.text = "\(hoursBetween) days ago"
                    }
                }
                
            cell.posterUID = (self.feedDataArray[indexPath.row]["posterUID"] as! String)
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
           
            DispatchQueue.main.async{
             cell.posterPic.image = self.feedDataArray[indexPath.row]["posterPicURL"] as! UIImage
            }
            if self.feedDataArray[indexPath.row]["postText"] != nil {
                
                let boldText  = (self.feedDataArray[indexPath.row]["posterName"] as! String) + " "
                let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)]
                let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
                
                let normalText = self.feedDataArray[indexPath.row]["postText"] as! String
                let attrs2 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15, weight: .regular)]
                let normalString = NSMutableAttributedString(string:normalText, attributes: attrs2)
                
                
                attributedString.append(normalString)

                cell.postText.attributedText = attributedString
                let fixedWidth = cell.postText.frame.size.width
                let newSize = cell.postText.sizeThatFits(CGSize(width: fixedWidth, height: self.estimateFrameForText(text: cell.postText.text as! String).height))

                
                    cell.postText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                    cell.postText.isScrollEnabled = false
                
                
                
                
                
                
                    cell.postText.resolveHashTags()
                
                //var extraSpace =
                //print("text: \(cell.postText.text), cellHeight: \(cell.frame.height), textPostHeight: \(cell.postText.frame.height), textPostEstimated: \(self.estimateFrameForText(text: cell.postText.text as! String).height), heightShouldBe: \(474 + self.estimateFrameForText(text: cell.postText.text as! String).height), indexPath: \(indexPath)")
                //cell.frame.size = CGSize(width: cell.frame.width, height: 474 + cell.postText.frame.height)
                
                
            }
            cell.posterNameButton.setTitle((self.feedDataArray[indexPath.row]["posterName"] as! String), for: .normal)
            //cell.postLocationButton.setTitle("post location", for: .normal)
            
            cell.cellIndexPath = indexPath
            
            
            if self.feedDataArray[(cell.cellIndexPath?.row)!]["postVid"] == nil {
                cell.soundToggle.isHidden = true
                cell.player?.view.isHidden = true
                cell.postPic.isHidden = false
                
               
                DispatchQueue.main.async{
                    cell.postPic.image = self.feedDataArray[indexPath.row]["postPic"] as! UIImage
                }
                
                cell.viewCount.isHidden = true
                
            } else {
               // print("vid not nil")
                cell.soundToggle.isHidden = false
                DispatchQueue.main.async{
                    var url = self.feedDataArray[indexPath.row]["postVid"] as! URL
                    cell.videoUrl = url
                    cell.player?.url = url
                }
                cell.postPic.isHidden = true
                
               
                cell.player?.playerDelegate = self
                cell.player?.playbackDelegate = self
                cell.player?.playbackLoops = true
                cell.player?.playbackPausesWhenBackgrounded = true
                cell.player?.playbackPausesWhenResigningActive = true
                cell.player?.playbackPausesWhenBackgrounded = true
                cell.player?.playbackPausesWhenResigningActive = true
                
                
                //var gest = UIGestureRecognizer(target: <#T##Any?#>, action: <#T##Selector?#>)
                cell.postPic.frame = CGRect(x: cell.postPic.frame.origin.x, y: cell.postPic.frame.origin.y, width: cell.postPic.frame.width, height: cell.postPic.frame.height)
                
                let vidFrame = cell.postPic.frame
                cell.player?.view.frame = vidFrame
                
                
                //cell.player?.url  = URL(string: feedDataArray[indexPath.row]["postVid"] as! String)
                var posterPicFrame = cell.posterPic.frame
                
                cell.player?.view.isHidden = false
                cell.viewCount.isHidden = false
                cell.player?.didMove(toParentViewController: self)
                //cell.sendSubview(toBack: (cell.player?.view)!)
                cell.bringSubview(toFront: cell.soundToggle)
               cell.soundToggle.frame = CGRect(x: 10, y: 10, width: cell.soundToggle.frame.width, height: cell.soundToggle.frame.height)
                cell.player!.view.addSubview(cell.soundToggle)
                cell.player!.view.bringSubview(toFront: cell.soundToggle)
                //cell.player!.view.subviews.first!.frame = CGRect(x: 0, y: 0, width: cell.player!.view.subviews.first!.frame.width, height: cell.player!.view.subviews.first!.frame.height)
                cell.player?.playbackLoops = true
                cell.posterPic.image = self.feedDataArray[indexPath.row]["posterPicURL"] as! UIImage
                cell.posterPic.frame = posterPicFrame
                cell.player?.playbackState = .playing
            }
            }
            
            return cell
            
            
            }
            
        }
        
    }
    var selectedShare = LikedByCollectionViewCell()
    var selectedCell = NewsFeedPicCollectionViewCell()
    var selectedCell2 = NewsFeedCellCollectionViewCell()
    var selectedLike = LikedByCollectionViewCell()
    
    @IBOutlet weak var textPostCommentView: UIView!
    
    @IBOutlet weak var tpTopView: UIView!
    @IBOutlet weak var tpPosterNameButton: UIButton!
    @IBAction func tpPosterNameButtonPressed(_ sender: Any) {
    }
    @IBAction func tpPostLocationButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var tpPostLocationButton: UIButton!
    @IBAction func tpPosterPicButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var tpPosterPicButton: UIButton!
    
    @IBOutlet weak var tpImageView: UIImageView!
    @IBOutlet weak var tpTimestampLabel: UILabel!
    
    @IBOutlet weak var tpTextView: UITextView!
    
    @IBOutlet weak var tpBottomView: UIView!
    
    
    @IBOutlet weak var tpLikeButton: UIButton!
    @IBAction func tpLikeButtonPressed(_ sender: Any) {
        tpLikePressed(cell: self.curCell)
    }
    @IBOutlet weak var tpCommentButton: UIButton!
    @IBAction func tpCommentButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var tpFavoriteButton: UIButton!
    @IBAction func tpLFavoriteButtonPressed(_ sender: Any) {
        tpFavoritePressed(cell: self.curCell)
    }
    @IBOutlet weak var tpShareButton: UIButton!
    @IBAction func tpShareButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var tpActionButtonsView: UIView!
    @IBOutlet weak var tpLikesCountButton: UIButton!
    @IBAction func tpLikesCountButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var tpCommentCountButton: UIButton!
    @IBAction func tpCommentCountButtonPressed(_ sender: Any) {
    }
    @IBAction func dubTap(_ sender: Any) {
        //DispatchQueue.main.async{
        var myPic = String()
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let valDict = snapshot.value as! [String:Any]
            myPic = valDict["profPic"] as! String
            
        })
       // print("inDubTap")
        let tappedPoint: CGPoint = (sender as! UITapGestureRecognizer).location(in: self.feedCollect)
        
        let tappedCellPath: IndexPath = self.feedCollect.indexPathForItem(at: tappedPoint)!
        
            if self.typeOfCellAtIndexPath[tappedCellPath] == 0{
               
            
            let tappedCell = self.feedCollect.cellForItem(at: tappedCellPath) as! NewsFeedCellCollectionViewCell
            if tappedCell.likeButton.imageView?.image == UIImage(named: "like.png"){
                tappedCell.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                Database.database().reference().child("posts").child(tappedCell.postID!).observeSingleEvent(of: .value, with: { snapshot in
                    let valDict = snapshot.value as! [String:Any]
                    
                    var likesArray = valDict["likes"] as! [[String:Any]]
                    if likesArray.count == 1 && (likesArray.first! as! [String:String]) == ["x": "x"]{
                        likesArray.remove(at: 0)
                    }
                    var likesVal = likesArray.count
                    likesVal = likesVal + 1
                   
                    likesArray.append(["uName": self.myUName!, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": myPic])
                    
                    
                    Database.database().reference().child("posts").child(tappedCell.postID!).child("likes").setValue(likesArray)
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
                    tappedCell.likesCountButton.setTitle(likesString, for: .normal)
                    
                    DispatchQueue.main.async {
                        //self.refresh()
                    }
                })
                
               
                
            } else {
                tappedCell.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
                
                
                Database.database().reference().child("posts").child(tappedCell.postID!).observeSingleEvent(of: .value, with: { snapshot in
                    let valDict = snapshot.value as! [String:Any]
                    var likesVal = Int()
                    var likesArray = valDict["likes"] as! [[String: Any]]
                    var likesString = String()
                    if likesArray.count == 1 {
                        likesArray.remove(at: 0)
                        likesArray.append(["x": "x"])
                        likesVal = 0
                         //likesString = "\(likesArray.count) like"
                        
                    } else {
                        //likesString = "\(likesArray.count) likes"
                        likesArray.remove(at: 0)
                        likesVal = likesArray.count
                        
                        
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
                    
                    tappedCell.likesCountButton.setTitle(likesString, for: .normal)
                    
                    
                   Database.database().reference().child("posts").child(tappedCell.postID!).child("likes").setValue(likesArray) 
                    
                    DispatchQueue.main.async {
                        //self.refresh()
                    }
                    
                })
            }
            
            
        } else {
            let tappedCell = self.feedCollect.cellForItem(at: tappedCellPath) as! NewsFeedPicCollectionViewCell
            if tappedCell.likeButton.imageView?.image == UIImage(named: "like.png"){
                tappedCell.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                 Database.database().reference().child("posts").child(tappedCell.postID!).observeSingleEvent(of: .value, with: { snapshot in
                    let valDict = snapshot.value as! [String:Any]
                    
                    var likesArray = valDict["likes"] as! [[String:Any]]
                    if likesArray.count == 1 && likesArray.first! as! [String:String] == ["x":"x"]{
                        likesArray.remove(at: 0)
                    }
                    var likesVal = likesArray.count
                    likesVal = likesVal + 1
                    //if self.myPicString == nil{
                    //    self.myPicString = "profile-placeholder"
                    //}
                    likesArray.append(["uName": self.myUName!, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": myPic])
                    
                    
                    Database.database().reference().child("posts").child(tappedCell.postID!).child("likes").setValue(likesArray)
                    Database.database().reference().child("users").child(tappedCell.posterUID!).child("posts").child(tappedCell.postID!).child("likes").setValue(likesArray)
                   
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
                    tappedCell.likesCountButton.setTitle(likesString, for: .normal)
                    DispatchQueue.main.async {
                       // self.refresh()
                    }
                })
                
                //update Database for post with new like count
                
            } else {
                tappedCell.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
 Database.database().reference().child("posts").child(tappedCell.postID!).observeSingleEvent(of: .value, with: { snapshot in
                    let valDict = snapshot.value as! [String:Any]
                    var likesVal = Int()
                    var likesArray = valDict["likes"] as! [[String: Any]]
    var likesString = String()
                    if likesArray.count == 1 {
                        likesArray.remove(at: 0)
                        likesArray.append(["x":"x"])
                        likesVal = 0
                        // likesString = "\(likesArray.count) like"
                        
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
    
    tappedCell.likesCountButton.setTitle(likesString, for: .normal)
    
                    
                    
                   
                    Database.database().reference().child("posts").child(tappedCell.postID!).child("likes").setValue(likesArray)
                    
                    Database.database().reference().child("users").child(tappedCell.posterUID!).child("posts").child(tappedCell.postID!).child("likes").setValue(likesArray)
                    
                    //tappedCell.likesCountButton.setTitle(String(likesArray.count), for: .normal)
    
    DispatchQueue.main.async {
        //self.refresh()
    }
    
                })
            }
      //  }
        //DispatchQueue.main.async{
            
            
        //}
       
        
        }
        
    }
    @IBOutlet weak var findFriendsSearchBar: UISearchBar!
    var fromNotifPostID: String?
    @IBAction func shareFinalizePressed(_ sender: Any) {
        
        //print("sharrrrreeeeeeeeeeee: \(sharedCellSelectedDict)")
        for (uid, val) in sharedCellSelectedDict {
            //print("beginning of share: uid: \(uid) val: \(val) myPicString: \(self.myPicString)")
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                self.curUserRef = Database.database().reference().child("users").child(uid)
                self.messageRef = self.curUserRef.child("messages").child(Auth.auth().currentUser!.uid)
                
                self.sendPhotoMessage(recipientID: uid)
                
                 let valDict = snapshot.value as! [String:Any]
                if valDict["notifications"] as? [[String:Any]] == nil {
                    var tempString = "\(self.myUName!) shared a post with you"
                    
                    
                    var date = Date()
                    var dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    var dateString = dateFormatter.string(from: date)
                    
                    var tempDict = (["actionByUID": Auth.auth().currentUser!.uid,"postID": self.curPostID, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName!,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as! [String : Any])
                    
                  // print("aboutToShare: \(tempDict)")
                    Database.database().reference().child("users").child(uid).updateChildValues((["notifications": [tempDict]] as! [String:Any]))
                    
                } else {
                    
                    var date = Date()
                    var dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    var dateString = dateFormatter.string(from: date)
                    
                    var tempString = "\(self.myUName!) shared a post with you" as! String
                    var tempDict = (["actionByUID": Auth.auth().currentUser!.uid, "postID": self.curPostID, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName!,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as! [String : Any])
                    
                    //Database.database().reference().child("users").child(uid).updateChildValues((["notifications": [tempDict]] as! [String:Any]))
                    
                    var tempNotifs = valDict["notifications"] as! [[String:Any]]
                    tempNotifs.append(tempDict)
                    //print("aboutToShare: \(uid)")
                    Database.database().reference().child("users").child(uid).updateChildValues((["notifications": tempNotifs] as! [String:Any]))
                    
                    
                }
                
                
            })
        }
        DispatchQueue.main.async{
            self.backk()
        }
        
        
    }
    
    @IBOutlet weak var shareFinalizeButton: UIButton!
    
    @IBOutlet weak var findFriendsView: UIView!
    @IBOutlet weak var findFriendsCollect: UICollectionView!
    var sharedCellSelectedDict = [String: IndexPath]()
    
    func shareCellSelected(collectionView: UICollectionView, indexPath: IndexPath){
       // print("shareSelected")
       
    }
    
    func shareCirclePressed(likedByUID: String, indexPath: IndexPath){
        print("shareCirc2: \(likedByUID) \(indexPath)")
        if (likedByCollect.cellForItem(at: indexPath) as! LikedByCollectionViewCell).shareCheck.backgroundColor == UIColor.red{
            
            (likedByCollect.cellForItem(at: indexPath) as! LikedByCollectionViewCell).shareCheck.backgroundColor = UIColor.clear
            
            sharedCellSelectedDict.removeValue(forKey: likedByCollectData[indexPath.row]["uid"] as! String)
            
            
            
        } else {
            (likedByCollect.cellForItem(at: indexPath) as! LikedByCollectionViewCell).shareCheck.backgroundColor = UIColor.red
            sharedCellSelectedDict[(likedByCollectData[indexPath.row]["uid"] as! String)] = indexPath
            
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
    //if the collection view does not equal the feed collect than load data for the each cells internal likedBy collect
        if collectionView == self.likedByCollect {
            if sentBy == "share"{
                if (collectionView.cellForItem(at: indexPath) as! LikedByCollectionViewCell).shareCheck.backgroundColor == UIColor.red{
                    
                    (collectionView.cellForItem(at: indexPath) as! LikedByCollectionViewCell).shareCheck.backgroundColor = UIColor.clear
                    
                    sharedCellSelectedDict.removeValue(forKey: likedByCollectData[indexPath.row]["uid"] as! String)
                    
                    
                    
                } else {
                    (collectionView.cellForItem(at: indexPath) as! LikedByCollectionViewCell).shareCheck.backgroundColor = UIColor.red
                    sharedCellSelectedDict[(likedByCollectData[indexPath.row]["uid"] as! String)] = indexPath
                    
                }
                //shareCellSelected(collectionView: collectionView, indexPath: indexPath)
            }
                
        } else if collectionView == findFriendsCollect {
            performSegueToPosterProfile(uid: (findFriendsData[indexPath.row])["uid"] as! String, name: (findFriendsData[indexPath.row])["uName"] as! String)
               //perform segue to the persons profile
            //print("hellomate")
        } else {
            
            if typeOfCellAtIndexPath[indexPath] == 0 {
                
                
                self.selectedCell.postID = nil
                
                likedByCollectData = feedDataArray[indexPath.row]["likes"] as! [[String : Any]]
                var tempCell = feedCollect.cellForItem(at: indexPath) as! NewsFeedCellCollectionViewCell
                showLikedByViewTextCell(sentBy: "showCommentsCount", cell: tempCell)
            } else {
                self.selectedCell2.postID = nil
                self.selectedCell = collectionView.cellForItem(at: indexPath) as! NewsFeedPicCollectionViewCell
                
                if (feedDataArray[indexPath.row])["tagged"] == nil {
                    
                } else {
                    if selectedCell.tagLabel.isHidden == false{
                        selectedCell.tagLabel.isHidden = true
                    } else {
                        selectedCell.tagLabel.isHidden = false
                    }
                   
                }
                
                if selectedCell.player?.playbackState == .stopped || selectedCell.player?.playbackState == .paused {
                selectedCell.player?.playFromBeginning()
                } else {
                    selectedCell.player?.stop()
                }
                likedByCollectData = feedDataArray[indexPath.row]["likes"] as! [[String : Any]]
            }
        }
    }
    @IBAction func createNewMessagePressed(_ sender: Any) {
    }
    
    @IBOutlet weak var createNewMessageButton: UIButton!
    @IBAction func backFromFindPressed(_ sender: Any) {
         inboxButton.isHidden = false
        sentBy = "feed"
        topLabel.isHidden = false
        findFriendsSearchBar.resignFirstResponder()
        findFriendsView.isHidden = true
        addFriendsButton.isHidden = false
        backFromFindFriendsButton.isHidden = true
    }
    @IBOutlet weak var backFromFindFriendsButton: UIButton!
    
    @IBAction func addFriendsButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "FeedToForum", sender: self)
        
    }
    @IBOutlet weak var addFriendsButton: UIButton!
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    func sizeForTextPostCommentView(sizeText:String?)->CGSize{
        
        var width = Double(textPostCommentView.frame.width)
        var height = Double()
        if(UIScreen.main.bounds.height == 896){
            //iphone xr
            print("sizingXR")
            if let text = sizeText {
                
                if (estimateFrameForText(text: text ).height) >= 70 && (estimateFrameForText(text: text as! String).height) < 140 {
                    if (estimateFrameForText(text: text ).height) >= 70 && (estimateFrameForText(text: text as! String).height) < 100{
                        height = Double(estimateFrameForText(text: text as! String).height + 160)
                        //print("suh")
                    } else if (estimateFrameForText(text: text ).height) > 100 && (estimateFrameForText(text: text as! String).height) < 110{
                        height = Double(estimateFrameForText(text: text as! String).height + 155)
                        //print("suh")
                    } else if (estimateFrameForText(text: text ).height) >= 110 && (estimateFrameForText(text: text as! String).height) < 120{
                        height = Double(estimateFrameForText(text: text as! String).height + 150)
                        
                    } else if (estimateFrameForText(text: text ).height) >= 120 && (estimateFrameForText(text: text as! String).height) < 130{
                        height = Double(estimateFrameForText(text: text as! String).height + 145)
                        
                    } else if (estimateFrameForText(text: text ).height) >= 130 {
                        
                        height = Double(estimateFrameForText(text: text as! String).height + 140)
                    }
                } else if (estimateFrameForText(text: text ).height) > 140 && (estimateFrameForText(text: text as! String).height) < 175{
                    height = Double(estimateFrameForText(text: text as! String).height + 140)
                } else if (estimateFrameForText(text: text ).height) > 175 && (estimateFrameForText(text: text as! String).height) < 210{
                    height = Double(estimateFrameForText(text: text as! String).height + 135)
                } else if (estimateFrameForText(text: text ).height) > 210 && (estimateFrameForText(text: text as! String).height) < 230{
                    height = Double(estimateFrameForText(text: text as! String).height + 130)
                } else if (estimateFrameForText(text: text ).height) >= 230 && (estimateFrameForText(text: text as! String).height) < 240{
                    height = Double(estimateFrameForText(text: text as! String).height + 130)
                } else if (estimateFrameForText(text: text ).height) > 240{
                    height = Double(estimateFrameForText(text: text as! String).height + 125)
                } else {
                    height = Double(estimateFrameForText(text: text as! String).height + 160)
                }
                print("textCell Comment height for: \(text) = \(estimateFrameForText(text: text ).height)")
                //print("text: \(text), height: \(height), indexPath: \(indexPath)")
            }
        } else {
        if let text = sizeText {
            
            if (estimateFrameForText(text: text ).height) >= 70 && (estimateFrameForText(text: text as! String).height) < 140 {
                if (estimateFrameForText(text: text ).height) >= 70 && (estimateFrameForText(text: text as! String).height) < 100{
                    height = Double(estimateFrameForText(text: text as! String).height + 160)
                    //print("suh")
                } else if (estimateFrameForText(text: text ).height) > 100 && (estimateFrameForText(text: text as! String).height) < 110{
                    height = Double(estimateFrameForText(text: text as! String).height + 155)
                    //print("suh")
                } else if (estimateFrameForText(text: text ).height) >= 110 && (estimateFrameForText(text: text as! String).height) < 120{
                    height = Double(estimateFrameForText(text: text as! String).height + 150)
                    
                } else if (estimateFrameForText(text: text ).height) >= 120 && (estimateFrameForText(text: text as! String).height) < 130{
                    height = Double(estimateFrameForText(text: text as! String).height + 145)
                    
                } else if (estimateFrameForText(text: text ).height) >= 130 {
                    
                    height = Double(estimateFrameForText(text: text as! String).height + 140)
                }
            } else if (estimateFrameForText(text: text ).height) > 140 && (estimateFrameForText(text: text as! String).height) < 175{
                height = Double(estimateFrameForText(text: text as! String).height + 140)
            } else if (estimateFrameForText(text: text ).height) > 175 && (estimateFrameForText(text: text as! String).height) < 210{
                height = Double(estimateFrameForText(text: text as! String).height + 135)
            } else if (estimateFrameForText(text: text ).height) > 210 && (estimateFrameForText(text: text as! String).height) < 230{
                height = Double(estimateFrameForText(text: text as! String).height + 130)
            } else if (estimateFrameForText(text: text ).height) >= 230 && (estimateFrameForText(text: text as! String).height) < 240{
                height = Double(estimateFrameForText(text: text as! String).height + 130)
            } else if (estimateFrameForText(text: text ).height) > 240{
                height = Double(estimateFrameForText(text: text as! String).height + 125)
            } else {
                height = Double(estimateFrameForText(text: text as! String).height + 160)
            }
            print("textCell Comment height for: \(text) = \(estimateFrameForText(text: text ).height)")
            //print("text: \(text), height: \(height), indexPath: \(indexPath)")
        }
        }
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = CGFloat()
        var height = CGFloat()
        if collectionView == self.likedByCollect || collectionView == self.findFriendsCollect{
            if collectionView == self.likedByCollect && textPostCommentView.isHidden == false{
                width = collectionView.frame.width - 20
                if let text = (likedByCollectData[indexPath.row])["commentText"] {
                    height = estimateFrameForText(text: text as! String).height + 50
                 
                }
                return CGSize(width: width, height: height)
                
            } else {
            return CGSize(width: collectionView.frame.width - 20, height: 75)
            }
        } else {
       
            if(UIScreen.main.bounds.height == 896){
                //iphone xr
                print("sizingXR")
                if feedDataArray[indexPath.row]["postPic"] == nil && feedDataArray[indexPath.row]["postVid"] == nil {
                    width = collectionView.frame.width - 20
                    if let text = (feedDataArray[indexPath.row])["postText"] {
                        if (estimateFrameForText(text: text as! String).height) >= 70 && (estimateFrameForText(text: text as! String).height) < 140 {
                            if (estimateFrameForText(text: text as! String).height) >= 70 && (estimateFrameForText(text: text as! String).height) < 100{
                                height = estimateFrameForText(text: text as! String).height + 165
                                //print("suh")
                            } else if (estimateFrameForText(text: text as! String).height) > 100 && (estimateFrameForText(text: text as! String).height) < 110{
                                height = estimateFrameForText(text: text as! String).height + 160
                                //print("suh")
                            } else if (estimateFrameForText(text: text as! String).height) >= 110 && (estimateFrameForText(text: text as! String).height) < 120{
                                height = estimateFrameForText(text: text as! String).height + 155
                                
                            } else if (estimateFrameForText(text: text as! String).height) >= 120 && (estimateFrameForText(text: text as! String).height) < 130{
                                height = estimateFrameForText(text: text as! String).height + 150
                                
                            } else if (estimateFrameForText(text: text as! String).height) >= 130 {
                                
                                height = estimateFrameForText(text: text as! String).height + 145
                            }
                        } else if (estimateFrameForText(text: text as! String).height) > 140 && (estimateFrameForText(text: text as! String).height) < 175{
                            height = estimateFrameForText(text: text as! String).height + 140
                        } else if (estimateFrameForText(text: text as! String).height) > 175 && (estimateFrameForText(text: text as! String).height) < 210{
                            height = estimateFrameForText(text: text as! String).height + 135
                        } else if (estimateFrameForText(text: text as! String).height) > 210 && (estimateFrameForText(text: text as! String).height) < 240{
                            height = estimateFrameForText(text: text as! String).height + 130
                        } else if (estimateFrameForText(text: text as! String).height) > 240{
                            height = estimateFrameForText(text: text as! String).height + 125
                        } else {
                            height = estimateFrameForText(text: text as! String).height + 180
                        }
                        print("textCell height for: \(text) = \(estimateFrameForText(text: text as! String).height)")
                    }
                } else {
                    width = collectionView.frame.width - 20
                    if let text = (feedDataArray[indexPath.row])["postText"] {
                        if (estimateFrameForText(text: text as! String).height) < 300 {
                            
                            if (estimateFrameForText(text: text as! String).height) < 40 {
                                height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 70
                            } else if (estimateFrameForText(text: text as! String).height) < 120 {
                                height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 75
                            } else if (estimateFrameForText(text: text as! String).height) < 130 {
                                height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 80
                            } else if (estimateFrameForText(text: text as! String).height) < 140 {
                                height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 85
                            } else if (estimateFrameForText(text: text as! String).height) < 150 {
                                height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 90
                            } else if (estimateFrameForText(text: text as! String).height) < 160 {
                                height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 95
                            } else if (estimateFrameForText(text: text as! String).height) < 170 {
                                height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 100
                            } else {
                                height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 105
                            }
                        } else {
                            
                            height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 110
                        }
                        print("picCell height for: \(text) = \(estimateFrameForText(text: text as! String).height)")
                    }
                }
            } else {
                //iphone X
        if feedDataArray[indexPath.row]["postPic"] == nil && feedDataArray[indexPath.row]["postVid"] == nil {
            width = collectionView.frame.width - 20
            if let text = (feedDataArray[indexPath.row])["postText"] {
                 if (estimateFrameForText(text: text as! String).height) >= 70 && (estimateFrameForText(text: text as! String).height) < 140 {
                    if (estimateFrameForText(text: text as! String).height) >= 70 && (estimateFrameForText(text: text as! String).height) < 100{
                        height = estimateFrameForText(text: text as! String).height + 145
                        //print("suh")
                    } else if (estimateFrameForText(text: text as! String).height) > 100 && (estimateFrameForText(text: text as! String).height) < 110{
                        height = estimateFrameForText(text: text as! String).height + 140
                        //print("suh")
                    } else if (estimateFrameForText(text: text as! String).height) >= 110 && (estimateFrameForText(text: text as! String).height) < 120{
                        height = estimateFrameForText(text: text as! String).height + 135
                    
                    } else if (estimateFrameForText(text: text as! String).height) >= 120 && (estimateFrameForText(text: text as! String).height) < 130{
                        height = estimateFrameForText(text: text as! String).height + 130
                        
                    } else if (estimateFrameForText(text: text as! String).height) >= 130 {
                    
                    height = estimateFrameForText(text: text as! String).height + 125
                    }
                 } else if (estimateFrameForText(text: text as! String).height) > 140 && (estimateFrameForText(text: text as! String).height) < 175{
                    height = estimateFrameForText(text: text as! String).height + 133
                 } else if (estimateFrameForText(text: text as! String).height) > 175 && (estimateFrameForText(text: text as! String).height) < 210{
                    height = estimateFrameForText(text: text as! String).height + 120
                 } else if (estimateFrameForText(text: text as! String).height) > 210 && (estimateFrameForText(text: text as! String).height) < 240{
                    height = estimateFrameForText(text: text as! String).height + 110
                 } else if (estimateFrameForText(text: text as! String).height) > 240{
                    height = estimateFrameForText(text: text as! String).height + 100
                 } else {
                    height = estimateFrameForText(text: text as! String).height + 160
                }
                print("textCell height for: \(text) = \(estimateFrameForText(text: text as! String).height)")
                
            }
            //height = CGFloat(195)
            
            
        } else {
            width = collectionView.frame.width - 20
            if let text = (feedDataArray[indexPath.row])["postText"] {
                if (estimateFrameForText(text: text as! String).height) < 300 {
                    
                    if (estimateFrameForText(text: text as! String).height) < 40 {
                        height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 55
                    } else if (estimateFrameForText(text: text as! String).height) < 120 {
                        height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 60
                    } else if (estimateFrameForText(text: text as! String).height) < 130 {
                        height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 65
                    } else if (estimateFrameForText(text: text as! String).height) < 140 {
                        height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 70
                    } else if (estimateFrameForText(text: text as! String).height) < 150 {
                        height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 75
                    } else if (estimateFrameForText(text: text as! String).height) < 160 {
                        height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 80
                    } else if (estimateFrameForText(text: text as! String).height) < 170 {
                        height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 85
                    } else {
                        height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 90
                    }
                } else {
                    
                    height = (estimateFrameForText(text: text as! String).height/1.75) + 474 + 100
                }
                print("picCell height for: \(text) = \(estimateFrameForText(text: text as! String).height)")
            }
                }
            //height = CGFloat(563)
            }
            return CGSize(width: width, height: height)
        }
        
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        //we make the height arbitrarily large so we don't undershoot height in calculation
        let height: CGFloat = 1000
        
        let size = CGSize(width: feedCollect.frame.width - 20, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)]
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
    //this may be slow if there are a ton of posts. Check back
    var curPlayingVidCell: NewsFeedPicCollectionViewCell?
   

    
    
    @IBOutlet weak var selfCommentPic: UIImageView!
    var gmRed = UIColor(red: 237/255, green: 28/255, blue: 39/255, alpha: 1.0)
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var tabBar: UITabBar!
    var feedDataArray = [[String:Any]]()
    var myRealName = String()
    var myPic: UIImage?
    var myPicString: String?
    var myUName: String?
    var ogFrame = CGRect()
    var following: [String]?
    var curUserRef = DatabaseReference()
    
    @IBOutlet weak var commentViewLine: UIView!
    @IBOutlet weak var commentBlockTopBar: UIView!
    var ogLikeCollectFrame = CGRect()
    @IBOutlet weak var commentTopLine: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.edgesForExtendedLayout = []
        ogLikeCollectFrame = self.likedByCollect.frame
       // print("startLoad")
        //self.showWaitOverlayWithText("Loading Feed")
        locationOptionsMenu.layer.cornerRadius = 6
        mapButton.layer.cornerRadius = 6
        viewPostsButton.layer.cornerRadius = 6
        print("the screen height is: \(UIScreen.main.bounds.height)")
        print("the screen width is: \(UIScreen.main.bounds.width)")
        self.view.addSubview(UIView().customActivityIndicator(view: self.view, widthView: nil, backgroundColor:UIColor.black, textColor: UIColor.white, message: "Loading Feed"))
        
       self.tpTextView.delegate = self //SwiftOverlays.showBlockingWaitOverlayWithText("Loading Feed")
        selfCommentPic.frame = CGRect(x: selfCommentPic.frame.origin.x, y: selfCommentPic.frame.origin.y, width: 30.0, height: 30.0)
       findFriendsSearchBar.showsCancelButton = true
        lineView.frame = CGRect(x: lineView.frame.origin.x, y: lineView.frame.origin.y, width: lineView.frame.width, height: 0.5)
        
        
        bottomLineView.frame = CGRect(x: bottomLineView.frame.origin.x, y: bottomLineView.frame.origin.y, width: bottomLineView.frame.width, height: 0.5)
        
        tpBottomLine.frame = CGRect(x: tpBottomLine.frame.origin.x, y: tpBottomLine.frame.origin.y, width: tpBottomLine.frame.width, height: 0.5)
        
        commentTopLine.frame = CGRect(x: commentTopLine.frame.origin.x, y: commentTopLine.frame.origin.y, width: commentTopLine.frame.width, height: 0.5)
        
        //keyboardObserver
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
        
        commentViewLine.frame = CGRect(x: commentViewLine.frame.origin.x, y: commentViewLine.frame.origin.y, width: commentViewLine.frame.width, height: 0.5)
        self.ogFrame = commentTFView.frame
        let screenWidth = UIScreen.main.bounds.width
        feedCollect.frame = CGRect(x: feedCollect.frame.origin.x, y: feedCollect.frame.origin.y, width: screenWidth, height: feedCollect.frame.height)
        //let custView = commentTFView
        //commentTF.inputAccessoryView = custView
        self.topLabel.text = "GymMe"
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?.first
        findFriendsSearchBar.delegate = self
        //commentTF.layer.cornerRadius = 13
        //fcommentTF.layer.masksToBounds = true
        
        selfCommentPic.layer.cornerRadius = selfCommentPic.frame.width/2
        selfCommentPic.layer.masksToBounds = true
        refreshControl.tintColor = gmRed
        refreshControl.addTarget(self, action: Selector("refresh"), for: .valueChanged)
        feedCollect.addSubview(refreshControl)
        feedCollect.alwaysBounceVertical = true
       //layout.estimatedItemSize = CGSize(width: 1, height: 1)
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.value as? [String:Any]{
                for snap in snapshots{
                    if snap.key == "username"{
                        self.myUName = snap.value as! String
                    } else if snap.key == "following"{
                        self.following = snap.value as! [String]
                    } else if snap.key == "profPic"{
                        self.myPicString = snap.value as! String
                        if let messageImageUrl = URL(string: snap.value as! String) {
                            
                           // self.myPicString = messageImageUrl
                            
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                //self.myPic = UIImage(data: imageData as Data)
                                self.selfCommentPic.image = UIImage(data: imageData as Data)
                                
                            }
                            
                            // }
                        }
                    } else if snap.key == "realName"{
                        self.myRealName = snap.value as! String
                    }
                    
                    
                }
                DispatchQueue.main.async{
                    //print("self: \(self.myRealName), \(self.myUName)")
                    self.loadFeedData()
                }
            }
            
           //self.loadFeedData()
        
    
            
        })
    
        
 
    }
    @objc func refresh() {
        
       // print("refresh")
        feedDataArray.removeAll()
        ogFeedCollectData.removeAll()
        DispatchQueue.main.async{
            
         Database.database().reference().child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    var tempDict = snap.value as! [String:Any]
                    self.ogFeedCollectData.append(tempDict)
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
                                    self.feedImageArray.append(pic as! UIImage)
                                    self.feedVidArray.append(URL(string: "x")!)
                                    
                                    
                                }
                            }
                        } else {
                            //vid
                            
                            tempDict["postVid"] = URL(string: tempDict["postVid"] as! String)!
                            
                        }
                    }
                    self.feedDataArray.append(tempDict)
                    
                }
            }
            self.feedDataArray.reverse()
            self.feedCollect.delegate = self
            self.feedCollect.dataSource = self
            self.commentTF.delegate = self
            //self.feedCollect?.reloadData()
       
       
            self.refreshControl.endRefreshing()
        })
        }
        
        
        
        
       // })
        
    }
    var ogFeedCollectData = [[String:Any]]()
    var feedImageArray = [UIImage]()
    var feedVidArray = [URL]()
    var defImage = UIImage(named: "profile-placeholder")
    var feedTestData = [Any]()
    func loadFeedData(){
        self.findFriendsCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        
        self.likedByCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        
        self.likedByCollect.register(UINib(nibName: "CommentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CommentCollectionViewCell")
        
        self.feedCollect.register(UINib(nibName: "NewsFeedCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsFeedCellCollectionViewCell")
        
        self.feedCollect.register(UINib(nibName: "NewsFeedPicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsFeedPicCollectionViewCell")
        Database.database().reference().child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    var tempDict = snap.value as! [String:Any]
                    self.ogFeedCollectData.append(tempDict)
                    if tempDict["postPic"] == nil && tempDict["postVid"] == nil{
                        //text
                        if (tempDict["posterPicURL"] as! String) == "profile-placeholder"{
                            
                            var tempImage = UIImage(named: "profile-placeholder")
                            tempDict["posterPicURL"] = tempImage
                            
                        } else {
                            if let messageImageUrl = URL(string: (tempDict["posterPicURL"] as! String)) {
                                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                    
                                    var tempImage = UIImage(data: imageData as Data)
                                    tempDict["posterPicString"] = tempDict["posterPicURL"] as! String
                                    tempDict["posterPicURL"] = tempImage
                                    
                                }
                            }
                        }
                    } else {
                        
                        if (tempDict["posterPicURL"] as! String) == "profile-placeholder"{
                            
                            var tempImage = UIImage(named: "profile-placeholder")
                            tempDict["posterPicString"] = "profile-placeholder"
                            tempDict["posterPicURL"] = tempImage
                            
                        } else {
                            if let messageImageUrl = URL(string: (tempDict["posterPicURL"] as! String)) {
                             if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                             
                            var tempImage = UIImage(data: imageData as Data)
                                tempDict["posterPicString"] = tempDict["posterPicURL"] as! String
                                tempDict["posterPicURL"] = tempImage
                             
                                }
                             }
                        }
                        if tempDict["postPic"] != nil{
                            var picString = tempDict["postPic"] as! String
                            
                            if let messageImageUrl = URL(string: picString) {
                                
                                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                    var pic = UIImage(data: imageData as Data)
                                    
                                    tempDict["postPicString"] = tempDict["postPic"] as! String
                                    tempDict["postPic"] = pic as! UIImage
                                    self.feedImageArray.append(pic as! UIImage)
                                    self.feedVidArray.append(URL(string: "x")!)
                                    
                                    
                                }
                            }
                        } else {
                            //vid
                            tempDict["postVidString"] = tempDict["postVid"] as! String
                            tempDict["postVid"] = URL(string: tempDict["postVid"] as! String)!
                            
                        }
                    }
                    self.feedDataArray.append(tempDict)
                    
                }
            }
            self.feedImageArray.reverse()
            self.feedDataArray.reverse()
            DispatchQueue.main.async{
                self.feedCollect.delegate = self
                self.feedCollect.dataSource = self
                self.feedCollect.performBatchUpdates(nil, completion: {
                    (result) in
                    // ready
                    //SwiftOverlays.removeAllBlockingOverlays()
                    self.removeAllOverlays()
                    self.hideLoader(removeFrom: self.view)
                  
                })
               // SwiftOverlays.removeAllBlockingOverlays()
                //self.removeAllOverlays()
            }
            DispatchQueue.main.async{
                self.likedByCollect.delegate = self
                self.likedByCollect.dataSource = self
                
            }
            DispatchQueue.main.async{
                self.findFriendsCollect.delegate = self
                self.findFriendsCollect.dataSource = self
                
            }
            
            
            //scroll to notificaiton
            if self.fromNotifPostID != nil{
            DispatchQueue.main.async{
                
                for row in 0...self.feedCollect.numberOfItems(inSection: 0) - 1
                {
                    
                    var indexPath = NSIndexPath(row: row, section: 0)
                    
                    
                    //following line of code is for invisible cells
                   // print("row: \(row) postID: \(self.fromNotifPostID!)")
                    if (self.feedDataArray[indexPath.row])["postID"] as! String == self.fromNotifPostID{
                        self.feedCollect.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
                        break
                       
                    }
                    
                    
                }
                
                }
            }
           
           
           
            
            
        })
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            //print("keyHeight: \(keyboardHeight)")
            commentTopLine.frame = CGRect(x: commentTopLine.frame.origin.x, y: commentTopLine.frame.origin.y - keyboardHeight, width: commentTopLine.frame.width, height: commentTopLine.frame.height)
            
            backFromLikedByViewButton.isHidden = false
            //self.likeTopLabel.isHidden = true
            
            textPostCommentView.frame = CGRect(x: textPostCommentView.frame.origin.x, y: textPostCommentView.frame.origin.y - keyboardHeight, width: textPostCommentView.frame.width, height: textPostCommentView.frame.height)
            topLabel.frame = CGRect(x: topLabel.frame.origin.x, y: topLabel.frame.origin.y - keyboardHeight, width: topLabel.frame.width, height: topLabel.frame.height)
            
            
            
            likedByCollect.frame = CGRect(x: likedByCollect.frame.origin.x, y: likedByCollect.frame.origin.y - keyboardHeight, width: likedByCollect.frame.width, height: likedByCollect.frame.height)
            //print("hiding keyb")
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
       
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            //print("keyHeight: \(keyboardHeight)")
            
            commentTopLine.frame = CGRect(x: commentTopLine.frame.origin.x, y: commentTopLine.frame.origin.y + keyboardHeight, width: commentTopLine.frame.width, height: commentTopLine.frame.height)
            
            backFromLikedByViewButton.isHidden = true
            //self.likeTopLabel.isHidden = true
            
            textPostCommentView.frame = CGRect(x: textPostCommentView.frame.origin.x, y: textPostCommentView.frame.origin.y + keyboardHeight, width: textPostCommentView.frame.width, height: textPostCommentView.frame.height)
            
            topLabel.frame = CGRect(x: topLabel.frame.origin.x, y: topLabel.frame.origin.y + keyboardHeight, width: topLabel.frame.width, height: topLabel.frame.height)
            
           
            
            likedByCollect.frame = CGRect(x: likedByCollect.frame.origin.x, y: likedByCollect.frame.origin.y + keyboardHeight, width: likedByCollect.frame.width, height: likedByCollect.frame.height)
            //print("showing keyb")
        }
    }
    
    
    var ogCommentFrame = CGRect()
    @IBOutlet weak var commentTFView: UIView!
    var keyBoardToolBarFrame = CGRect()
    @IBAction func postCommentPressed(_ sender: Any) {
        var textField = commentTF
        
        if textField!.text == "" || textField?.hasText == false {
            
        } else {
            var cellTypeTemp = String()
            var posterID = String()
            if self.cellType == "pic"{
                cellTypeTemp = (curCommentPicCell?.postID!)!
                posterID = (curCommentPicCell?.posterUID!)!
            } else {
                cellTypeTemp = (curCommentCell?.postID!)!
                posterID = (curCommentCell?.posterUID!)!
            }
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
                //add current users id and uName to comment object and upload to database
                var now = Date()
                //var dateFormatter = DateFormatter()
                //var dateString = dateFormatter.string(from: now)
                commentsArray.append(["commentorName": self.myUName, "commentorID": Auth.auth().currentUser!.uid, "commentorPic": self.myPicString, "commentText": self.commentTF.text, "commentDate": now.description])
                var index = 0
                for data in self.feedDataArray {
                    var dict = data as! [String:Any]
                    if (dict["postID"] as! String == cellTypeTemp){
                        dict["comments"] = commentsArray
                        self.feedDataArray[index] = dict
                    }
                    index+=1
                }
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
                        
                        var tempDict = (["actionByUID": Auth.auth().currentUser!.uid,"postID": self.curPostID, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName!,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as! [String : Any])
                        
                       // print("commentNote: \(tempDict)")
                        Database.database().reference().child("users").child(posterID).updateChildValues((["notifications": [tempDict]] as! [String:Any]))
                        
                    } else {
                        
                        var tempString = "\(self.myUName!) commented on your post" as! String
                        
                        var date = Date()
                        var dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        var dateString = dateFormatter.string(from: date)
                        
                        var tempDict = (["actionByUID": Auth.auth().currentUser!.uid, "postID": self.curPostID, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName!,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as! [String : Any])
                        
                       
                        var tempNotifs = valDict["notifications"] as! [[String:Any]]
                        tempNotifs.append(tempDict)
                        //print("acommentNote \(posterID)")
                        Database.database().reference().child("users").child(posterID).updateChildValues((["notifications": tempNotifs] as! [String:Any]))
                        
                        
                    }
                    
                    
                
                
                
                
                self.commentTF.text = nil
                
                if self.cellType == "pic"{
                    
                    let commStringNum = String(commentsArray.count)
                    var commString = String()
                    if commStringNum == "1"{
                        commString = "View \(commStringNum) comment"
                    } else {
                        commString = "View \(commStringNum) comments"
                    }
                    self.curCommentPicCell?.commentsCountButton.setTitle(commString, for: .normal)
                    
                } else {
                    
                    
                    let commStringNum = String(commentsArray.count)
                    var commString = String()
                    if commStringNum == "1"{
                        commString = "View \(commStringNum) comment"
                    } else {
                        commString = "View \(commStringNum) comments"
                    }
                    self.curCommentCell?.commentsCountButton.setTitle(commString, for: .normal)
                    
                }
                
                //reload collect in delegate
                self.likedByCollectData = commentsArray
                if commentsArray.count == 1{
                    DispatchQueue.main.async{
                        self.likedByCollect.delegate = self
                        self.likedByCollect.dataSource = self
                        self.likedByCollect.reloadData()
                        
                    }
                    
                } else {
                    
                   // print("reloading here")
                    var count = 0
                    for dict in self.feedDataArray{
                        if (dict["postID"] as! String) == cellTypeTemp{
                            Database.database().reference().child("posts").child(cellTypeTemp).observeSingleEvent(of: .value, with: { snapshot in
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
                                                self.feedImageArray.append(pic as! UIImage)
                                                self.feedVidArray.append(URL(string: "x")!)
                                                
                                                
                                            }
                                        }
                                    } else {
                                        //vid
                                        
                                        tempDict["postVid"] = URL(string: tempDict["postVid"] as! String)!
                                        
                                    }
                                }
                                tempDict["comments"] =
                                self.feedDataArray[count] = tempDict
                                DispatchQueue.main.async{
                                    
                                    self.likedByCollect.reloadData()
                                }
                                
                            })
                            break
                        
                        }
                        count = count + 1
                    }
                    
                }
                
            })
            })
        }
        self.view.endEditing(true)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var selectedCellUID: String?
    
    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBAction func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            // Perform action.
            //print("swipeRight: \(prevScreen)")
            if prevScreen == "notifications"{
                performSegue(withIdentifier: "FeedToNotifications", sender: self)
            }
            if prevScreen == "profile"{
                performSegue(withIdentifier: "FeedToProfile", sender: self)
            }
            if prevScreen == "post"{
                performSegue(withIdentifier: "FeedToPost", sender: self)
            }
            if prevScreen == "search"{
                performSegue(withIdentifier: "FeedToSearch", sender: self)
            }
            
        }
    }
    var locationNamePressed = String()
    var toMention = false
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       self.showWaitOverlay()
        if segue.identifier == "FeedToMap"{
            if let vc = segue.destination as? MapViewController{
                vc.mapType = "feed"
                vc.myCity = locationNamePressed
                
            }
        }
        if segue.identifier == "FeedToHash"{
            if let vc = segue.destination as? HashTagViewController{
                vc.hashtag = self.selectedHash
            }
        }
        if segue.identifier == "FeedToMessages"{
            if let vc = segue.destination as? MessagesTableViewController{
                vc.myRealName = self.myRealName
                vc.prevScreen = "feed"
            }
        }
        if segue.identifier == "FeedToAdvancedSearch"{
            if let vc = segue.destination as? SpecificSearchViewController{
                vc.prevScreen = "feed"
                vc.locationFromFeed = self.locationNamePressed
                vc.locationPostID = self.locationPostID
                vc.locationSegString = self.locationSegString
                    
                
            }
        }
        
        if segue.identifier == "FeedToProfile"{
            if let vc = segue.destination as? ProfileViewController{
                if toMention == true{
                    vc.curUID = self.mentionID
                } else {
                vc.curUID = self.selectedCellUID
                }
                vc.prevScreen = "feed"
                    
                if selectedCurAuthProfile == true{
                    vc.viewerIsCurAuth = true
                    
                } else {
                    vc.viewerIsCurAuth = false
                }
                vc.curName = self.curName
                
                
            }
        }
        if segue.identifier == "FeedToNotifications"{
            if let vc = segue.destination as? NotificationsViewController{
                vc.prevScreen = "feed"
            }
        }
       
        if segue.identifier == "FeedToSearch"{
            if let vc = segue.destination as? SearchViewController{
                vc.prevScreen = "feed"
            }
        }
        if segue.identifier == "FeedToPost"{
            if let vc = segue.destination as? PostViewController{
                vc.prevScreen = "feed"
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    var touchesBeganBool = Bool()
    var centerCell = UICollectionViewCell()
    
    
    
    /* touchesBeganBool = false
     
     
     if currentButtonFunc().isDisplayed == true{
     displaySessionInfo()
     }else{
     hideSessionInfo()
     }*/
    
    @IBAction func commentFieldEntered(_ sender: Any) {
        //commentBlockTopBar.isHidden = false
    }
    
   
    @IBAction func editingDidEnd(_ sender: Any) {
       // print("tfe")
        commentBlockTopBar.isHidden = true
        dumbCommentsLabel.isHidden = true
    }
    
    @IBOutlet weak var dumbCommentsLabel: UILabel!
    @IBOutlet weak var logoWords: UIImageView!
    @IBOutlet weak var postCommentButton: UIButton!
    var height = UIScreen.main.bounds.height/2.15
    @IBAction func editingDidBegin(_ sender: Any) {
        //print("tfb")
        
       /* commentBlockTopBar.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
        
            self.dumbCommentsLabel.isHidden = false
        }*/
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //commentTFView.layer.zPosition = .greatestFiniteMagnitude
       // print("heyg: \(height)")
        
        //print("balls")
        
        
    }// became first responder
    
    @IBOutlet weak var bottomLineView: UIView!
    var curCommentCell: NewsFeedCellCollectionViewCell?
    var curCommentPicCell: NewsFeedPicCollectionViewCell?
    public func textFieldDidEndEditing(_ textField: UITextField){
        //add comment to post
        //print("hereyyy")
        
       
        
    } // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        //print("return text")
        return false
    }
    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedStringKey.font: font])
        let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.findFriendsSearchBar.endEditing(true)
    }
    func hideLoader(removeFrom : UIView){
        removeFrom.subviews.last?.removeFromSuperview()
    }
    
    //search bar delegatte
    var searchActive = Bool()
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //findFriendsSearchBar.showsCancelButton = false
        searchActive = true;
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
      
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.findFriendsSearchBar.endEditing(true)
    }
    
    var allSuggested = [String]()
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        //print("SB text did change: \(searchText)")
        findFriendsData.removeAll()
        allSuggested.removeAll()
        
        var tempUserDict = [String:Any]()
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: {(snapshot) in
            //print("here: \(snapshot.value)")
            //let snapshotss = snapshot.value as? [DataSnapshot]
            //print("hereNow")
            for (key, val) in (snapshot.value as! [String:Any]){
               // print("uName=\(((val as! [String:Any])["username"] as! String))")
                let uName = ((val as! [String:Any])["username"] as! String)
                let rName = ((val as! [String:Any])["realName"] as! String)
                let picString = ((val as! [String:Any])["profPic"] as! String)
                let uid = key
                var pic: UIImage?
                if picString == "profile-placeholder"{
                  //  pic = "profile-placeholder"
                    pic = UIImage(named: "profile-placeholder")
                } else {
                if let messageImageUrl = URL(string: picString) {
                    
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        pic = UIImage(data: imageData as Data)
                        //self.editProfImageView.image = UIImage(data: imageData as Data)
                    }
                }
                }
                
                let uRange = (uName as NSString).range(of: searchText, options: NSString.CompareOptions.literal)
                let rRange = (rName as NSString).range(of: searchText, options: NSString.CompareOptions.literal)
                //print("rANDu: \(uRange) \(rRange)")
                if uRange.location != NSNotFound {
                    tempUserDict[key] = ["uName":uName, "rName":rName, "pic": pic!, "uid": uid]
                    self.allSuggested.append(rName)
                    print("curTextu: \(searchText) allSuggested1: \(self.allSuggested)")
                } else if rRange.location != NSNotFound{
                   
                    tempUserDict[key] = ["uName":uName, "rName":rName, "pic": pic!,"picString":picString, "uid": uid]
                    
                    
                    self.allSuggested.append(key)
                    print("curText: \(searchText) allSuggested: \(self.allSuggested)")
                } else if self.allSuggested.contains(key){
                    if self.allSuggested.contains(rName){
                        tempUserDict.removeValue(forKey: key)
                        self.allSuggested.remove(at: self.allSuggested.index(of: key)!)
                        //self.findFriendsData.remove(at: fin)
                    }
                    
                }
                
            }
           // print("nowHereee")
            var tempCurUids = [String]()
            for dict in self.findFriendsData{
                tempCurUids.append(dict["uid"] as! String)
                
            }
                    for (key, val) in tempUserDict {
                      //  print("snapKey: \(key)")
                        if self.allSuggested.contains(key){
                           
                            var tempDict = [String:Any]()
                            tempDict = val as! [String:Any]
                            //print("snapVal: \(val as! [String:Any])")
                            var noName = "-"
                            var uName = tempDict["uName"] as! String
                            
                            
                            var picString2 = tempDict["picString"] as! String
                            if (tempDict["rName"] as? String) != nil{
                                noName = (tempDict["rName"] as! String)
                            }
                            
                            let cellDict = ["uName":uName,"profPic": tempDict["pic"]!, "picString": picString2, "realName": noName, "uid": key] as [String:Any]
                            
                            if tempCurUids.contains(key){
                                break
                            } else {
                                self.findFriendsData.append(cellDict)
                            }
                        }
                    }
                    if(self.findFriendsData.count == 0){
                        self.searchActive = false;
                    } else {
                        self.searchActive = true;
                    }
           
            
        
            DispatchQueue.main.async{
                    self.findFriendsCollect.reloadData()
            }
            
        })
        
    } // called when text changes (including clear)
    
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.searchActive = false
        //print("in search pressed")
    } // called when keyboard search button pressed
    
    //handle message
    var messageRef = DatabaseReference()
    func sendPhotoMessage(recipientID: String) -> String? {
        
        
        var itemKey = String()
        var itemRef = DatabaseReference()
        //if newMessage == true {
        itemRef = messageRef.childByAutoId()
        itemKey = itemRef.key
        
        Database.database().reference().child("users").child(recipientID).updateChildValues(["unreadMessages": true])
        Database.database().reference().child("users").child(recipientID).child("unreadMessages").removeValue()
       Database.database().reference().child("posts").child(self.curPostID).observeSingleEvent(of: .value, with: { (snapshott) in
        
        var postDict = snapshott.value as! [String:Any]
        
        Database.database().reference().child("users").child(recipientID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var recipDict = snapshot.value as! [String:Any]
            var recipName = recipDict["realName"] as! String
            
            
            
            var now = Date()
            //print("tDate:\(now)")
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            var stringDate = dateFormatter.string(from: now)
            //print("tString: \(stringDate)")
                
                
                
            
                    
                    
                    
                    var rName = (snapshot.value as! [String:Any])["realName"]
            if (((postDict["postPic"] as? String) == nil) && ((postDict["postPic"] as? String) == nil)){
                //sendTextPost
                let messageItem = [
                    "senderId": Auth.auth().currentUser!.uid,
                    "senderName": self.myRealName,
                    "text": (postDict["postText"] as? String),
                    "timeStamp": stringDate,
                    "receiverName": recipName, "postID": self.curPostID
                ]
                
                
                
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("messages").child(recipientID).child(itemKey).setValue(messageItem)
                
                itemRef.setValue(messageItem)
                
            } else {
                    let messageItem = [
                        "photoURL": (postDict["postPic"] as? String),
                        "senderId": Auth.auth().currentUser!.uid,
                        "senderName": self.myRealName,
                        "timeStamp": stringDate,
                        "receiverName": recipName,
                        "postID": self.curPostID
                    ]
                
            
                
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("messages").child(recipientID).child(itemKey).setValue(messageItem)
                
                    itemRef.setValue(messageItem)
                    
                    //JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    
                    //self.finishSendingMessage()
                
        
            }
        })
        })
        return itemRef.key
    }
    
    
    
}

extension HomeFeedViewController:PlayerDelegate {
    
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

// MARK: - PlayerPlaybackDelegate

extension HomeFeedViewController:PlayerPlaybackDelegate {
    
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
extension HomeFeedViewController {
    
   
    
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> String {
        var hrs = Calendar.current.dateComponents([.hour], from: date, to: self).hour!
        if hrs >= 24{
            hrs = hrs%24
        }
        return String(hrs)
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the amount of nanoseconds from another date
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        //if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        if nanoseconds(from: date) > 0 { return "\(nanoseconds(from: date))ns" }
        return ""
    }
}

class SafeAreaFixTabBar: UITabBar {
    
    var oldSafeAreaInsets = UIEdgeInsets.zero
    
    @available(iOS 11.0, *)
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        
        if oldSafeAreaInsets != safeAreaInsets {
            oldSafeAreaInsets = safeAreaInsets
            
            invalidateIntrinsicContentSize()
            superview?.setNeedsLayout()
            superview?.layoutSubviews()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        if #available(iOS 11.0, *) {
            let bottomInset = safeAreaInsets.bottom
            if bottomInset > 0 && size.height < 50 && (size.height + bottomInset < 90) {
                size.height += bottomInset
            }
        }
        return size
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var tmp = newValue
            if let superview = superview, tmp.maxY !=
                superview.frame.height {
                tmp.origin.y = superview.frame.height - tmp.height
            }
            
            super.frame = tmp
        }
    }
}

extension UIView{
    func customActivityIndicator(view: UIView, widthView: CGFloat?,backgroundColor: UIColor?, textColor:UIColor?, message: String?) -> UIView{
        
        //Config UIView
        self.backgroundColor = backgroundColor?.withAlphaComponent(0.3) //Background color of your view which you want to set
        
        var selfWidth = view.frame.width
        if widthView != nil{
            selfWidth = widthView ?? selfWidth
        }
        
        let selfHeigh = view.frame.height
        let loopImages = UIImageView()
        
       let imageListArray = [UIImage(named:"spin1.png")!,UIImage(named:"spin2.png")!, UIImage(named:"spin3.png")!, UIImage(named:"spin5.png")!, UIImage(named:"spin6.png")!, UIImage(named:"spin7.png")!, UIImage(named:"spin8.png")!, UIImage(named:"spin9.png")!, UIImage(named:"spin11.png")!, UIImage(named:"spin12.png")!, UIImage(named:"spin13.png")!, UIImage(named:"spin14.png")!, UIImage(named:"spin15.png")!, UIImage(named:"spin16.png")!, UIImage(named:"spin17.png")!, UIImage(named:"spin18.png")!, UIImage(named:"spin19.png")!, UIImage(named:"spin20.png")!, UIImage(named:"spin21.png")!, UIImage(named:"spin22.png")!, UIImage(named:"spin23.png")!] as! [UIImage] // Put your desired array of images in a specific order the way you want to display animation.
        // let imageListArray = [UIImage(named:"spin1"), UIImage(named:"spin2")] as! [UIImage]
        
        loopImages.animationImages = imageListArray
        loopImages.animationDuration = TimeInterval(0.9 )
        loopImages.startAnimating()
        
        let imageFrameX = (selfWidth / 2) - 30
        let imageFrameY = (selfHeigh / 2) - 60
        var imageWidth = CGFloat(60)
        var imageHeight = CGFloat(60)
        
        if widthView != nil{
            imageWidth = widthView ?? imageWidth
            imageHeight = widthView ?? imageHeight
        }
        
        //ConfigureLabel
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white.withAlphaComponent(0.68)
       // label.font = UIFont(name: "System", size: 17.0)! // Your Desired UIFont Style and Size
        label.numberOfLines = 0
        label.text = message ?? ""
        //label.textColor = textColor ?? UIColor.clear
        label.alpha = 1.0
        
        //Config frame of label
        let labelFrameX = (selfWidth / 2) - 100
        let labelFrameY = (selfHeigh / 2) - 30
        let labelWidth = CGFloat(200)
        let labelHeight = CGFloat(70)
        
        // Define UIView frame
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height)
        
        
        //ImageFrame
        loopImages.frame = CGRect(x: imageFrameX, y: imageFrameY, width: imageWidth, height: imageHeight)
        loopImages.alpha = 0.4
        
        //LabelFrame
        label.frame = CGRect(x: labelFrameX, y: labelFrameY, width: labelWidth, height: labelHeight)
        
       
        
        //add loading and label to customView
        self.addSubview(loopImages)
        self.addSubview(label)
        //label.blink()
       
        return self }}

