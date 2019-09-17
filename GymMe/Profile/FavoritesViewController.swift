//
//  FavoritesViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 2/15/19.
//  Copyright © 2019 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class FavoritesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITabBarDelegate, UITextViewDelegate, PerformActionsInFeedDelegate {
    
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "FavoritesToProfile", sender: self)
    }
    @IBOutlet weak var favoritesCollect: UICollectionView!
    @IBOutlet weak var tabBar: UITabBar!
    
    func performSegueToPosterProfile(uid: String, name: String) {
        self.curName = name
        self.selectedCellUID = uid
        if uid == Auth.auth().currentUser!.uid {
            selectedCurAuthProfile = true
        } else {
            selectedCurAuthProfile = false
        }
        performSegue(withIdentifier: "FavoritesToProfile", sender: self)
    }
    var curName = String()
    var selectedCellUID: String?
    
    
    func showLikedByViewTextCell(sentBy: String, cell: NewsFeedCellCollectionViewCell) {
        
    }
    
    func showLikedByViewPicCell(sentBy: String, cell: NewsFeedPicCollectionViewCell) {
        
    }
    
    func locationButtonTextCellPressed(sentBy: String, cell: NewsFeedCellCollectionViewCell) {
        
    }
    
    func locationButtonPicCellPressed(sentBy: String, cell: NewsFeedPicCollectionViewCell) {
        
    }
    
    func reloadDataAfterLike() {
        
    }
    var selectedCurAuthProfile = true
    var mentionID = String()
    var toMention = false
    func showHashTag(tagType: String, payload: String, postID: String, name: String) {
        if tagType == "mention"{
            print("mention: going to \(payload)'s profile")
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
                        
                        self.performSegue(withIdentifier: "FavoritesToProfile", sender: self)
                    }
                }
            })
        } else {
            print("hashtag: \(payload) database action")
            selectedHash = payload
            performSegue(withIdentifier: "FavoritesToHash", sender: self)
        }
        /*let alertView = UIAlertView()
         alertView.title = "\(tagType) tag detected"
         // get a handle on the payload
         alertView.message = "\(payload)"
         alertView.addButton(withTitle: "Ok")
         alertView.show()*/
    }
    var selectedHash = String()
    
    var favPicVid = [[String:Any]]()
    var favText = [[String:Any]]()
    var selectedData = [String:Any]()
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        DispatchQueue.main.async{
            
            self.favoritesCollect.reloadData()
            if item == tabBar.items![0]{
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
                self.favoritesCollect.collectionViewLayout.invalidateLayout()
                
                self.favoritesCollect.layoutIfNeeded()
                self.favoritesCollect!.collectionViewLayout = layout
            } else {
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
                layout.minimumInteritemSpacing = 1
                layout.minimumLineSpacing = 10
               self.favoritesCollect.collectionViewLayout.invalidateLayout()
                self.favoritesCollect.layoutIfNeeded()
                self.favoritesCollect!.collectionViewLayout = layout
            }
            //self.favoritesCollect.collectionViewLayout.invalidateLayout()
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if tabBar.selectedItem == tabBar.items![0]{
           var tempDict = favPicVid[indexPath.row] as! [String:Any]
            print("selectedData: \(selectedData)")
            Database.database().reference().child("posts").child(tempDict["postID"] as! String).observeSingleEvent(of: .value, with: { snapshot in
                var snapDict = snapshot.value as! [String:Any]
                 print("snapshottt \(snapDict)")
                self.selectedData = snapDict
            
            
            self.performSegue(withIdentifier: "FavToSinglePost", sender: self)
            })
        } else {
            selectedData = favText[indexPath.row] as! [String:Any]
            performSegue(withIdentifier: "FavToSinglePost", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // return favData.count
       if tabBar.selectedItem == tabBar.items![0]{
            return favPicVid.count
        } else {
            return favText.count
        }
    }
    var uName = String()
    var realName = String()
    var picOrTextData = [String:Any]()
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if tabBar.selectedItem == tabBar.items![0]{
            let cell : PopCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopCell", for: indexPath) as! PopCell
            var curCell = favPicVid[indexPath.row] as! [String:Any]
            
            DispatchQueue.main.async{
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.white.cgColor
                if curCell["postPic"] == nil {
                    if curCell["postVid"] == nil{
                        
                    } else {
                        cell.popPic.isHidden = true
                        
                       // print("needToShowVid: \((self.profCollectData[indexPath.row] as! [String:Any])["postVid"]!)")
                        DispatchQueue.main.async{
                           cell.player?.url = URL(string: String(describing: curCell["postVid"] as! String))
                            cell.player?.playerDelegate = self
                            cell.player?.playbackDelegate = self
                            cell.player?.playbackLoops = true
                            cell.player?.playbackPausesWhenBackgrounded = true
                            cell.player?.playbackPausesWhenResigningActive = true
                        }
                        let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: cell
                            .frame.width, height: cell.frame.height)
                        
                        cell.player?.view.frame = vidFrame
                        cell.player?.view.bounds = vidFrame
                        cell.player?.view.isHidden = false
                        cell.player?.didMove(toParentViewController: self)
                        cell.player?.playbackLoops = true
                    }
                } else {
                    
                    if let messageImageUrl = URL(string: curCell["postPic"] as! String) {
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            cell.popPic.image = UIImage(data: imageData as Data)
                            cell.popPic.isHidden = false
                            cell.bringSubview(toFront: cell.popPic)
                        }
                    }
                }
            }
            
            return cell
        } else {
            var curData = favText[indexPath.row] as! [String:Any]
            if (curData.count == 0){
                let cell : NewsFeedCellCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsFeedCellCollectionViewCell", for: indexPath) as! NewsFeedCellCollectionViewCell
                
                return cell
            } else {
 
                    print("textpoststtttt")
                    let cell : NewsFeedCellCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsFeedCellCollectionViewCell", for: indexPath) as! NewsFeedCellCollectionViewCell
                
                    DispatchQueue.main.async{
                        let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]
                        let attributedString = NSMutableAttributedString(string:curData["postText"] as! String, attributes:attrs)
                        
                        cell.postText.attributedText = attributedString
                        cell.postID = curData["postID"] as! String
                        
                       cell.delegate = self
                        cell.postText.resolveHashTags()
                        
                        let fixedWidth = cell.postText.frame.size.width
                        let newSize = cell.postText.sizeThatFits(CGSize(width: fixedWidth, height: self.estimateFrameForText(text: cell.postText.text as! String).height))
                        
                        cell.postText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                        cell.postText.isScrollEnabled = false
                        
                        if ((curData as! [String:Any])["posterName"] as! String) == nil {
                            print("why nil")
                        } else {
                            print("setting text: \(((curData as! [String:Any])["postText"] as! String))")
                            cell.posterNameButton.setTitle(((curData as! [String:Any])["posterName"] as! String), for: .normal)
                            cell.postLocationButton.setTitle(((curData as! [String:Any])["city"] as! String), for: .normal)
                            cell.postText.isHidden = false
                            
                            
                            //unwrap pic from storage
                            cell.profImageView.image = curData["posterPicURL"] as! UIImage
                            
                            cell.likeButton.isEnabled = false
                            cell.likesCountButton.isEnabled = false
                            cell.commentButton.isEnabled = false
                            cell.commentsCountButton.isEnabled = false
                            cell.favoritesButton.isEnabled = false
                            //cell.favoritesCountButton.isEnabled = false
                            cell.shareButton.isEnabled = false
                            var likesPost: [String:Any]?
                            var favesPost: [String:Any]?
                            var commentsPost: [String:Any]?
                            for item in (curData as! [String:Any])["comments"] as! [[String:Any]]{
                                commentsPost = item as! [String: Any] }
                            for item in (curData as! [String:Any])["likes"] as! [[String:Any]]{
                                likesPost = item as! [String: Any] }
                            if likesPost!["x"] != nil { } else {
                                
                                var likesCount = ((curData as! [String:Any])["likes"] as! [[String:Any]]).count
                                var likeString = ""
                                if likesCount == 1{
                                    likeString = "1 Like"
                                } else {
                                    likeString = "\(likesCount) Likes"
                                }
                                cell.likesCountButton.setTitle(likeString, for: .normal)
                                if (likesPost!["uName"] as! String) == self.uName{
                                    cell.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal) } }
                            //set comments count
                            if commentsPost!["x"] != nil {
                                
                            } else {
                                
                                var commentsCount = ((curData as! [String:Any])["comments"] as! [[String:Any]]).count
                                var commentString = ""
                                if commentsCount == 1{
                                    commentString = "View 1 Comment"
                                } else {
                                    commentString = "View \(commentsCount) Comments"
                                }
                                
                                cell.commentsCountButton.setTitle(commentString, for: .normal) }
                            for item in (curData as! [String:Any])["favorites"] as! [[String:Any]]{
                                favesPost = item as! [String: Any]
                            }
                            if favesPost!["x"] != nil {
                                
                            } else {
                                if (favesPost!["uName"] as! String) == self.uName{
                                    cell.favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                                }
                                
                            }
                            let tStampDateString = (curData as! [String:Any])["datePosted"] as! String
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                            
                            let date = dateFormatter.date(from: tStampDateString)
                            
                            let now = Date()
                            
                            let hoursBetween = now.hours(from: date!)
                            
                            cell.timeStambLabel.text = "\(hoursBetween) hours ago"
                            cell.posterUID = (curData as! [String:Any])["posterUID"] as! String
                            cell.layer.shouldRasterize = true
                            cell.layer.rasterizationScale = UIScreen.main.scale
                            
                        }
                        
                    }
                return cell
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = CGFloat()
        var height = CGFloat()
        if tabBar.selectedItem == tabBar.items![0]{
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            width = screenWidth/3.04
            
            height = screenWidth/3.04
            
            return CGSize(width: width, height: height)
        } else {
            width = collectionView.frame.width - 20
            if let text = (favText[indexPath.row])["postText"] {
                height = estimateFrameForText(text: text as! String).height + 163
                print("text: \(text), height: \(height), indexPath: \(indexPath)")
            }
            return CGSize(width: width, height: height)
        }
        
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        //we make the height arbitrarily large so we don't undershoot height in calculation
        let height: CGFloat = 1000
        
        let size = CGSize(width: favoritesCollect.frame.width - 20, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)]
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
    

    var favData = [[String:Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topLine.frame.size = CGSize(width: UIScreen.main.bounds.width,height: 0.5)
        topLine.frame.origin = CGPoint(x: topLine.frame.origin.x, y: tabBar.frame.origin.y)
        bottomLine.frame.size = CGSize(width: UIScreen.main.bounds.width,height: 0.5)
        
        tabBar.selectedItem = tabBar.items![0]
        tabBar.delegate = self
        ogFavData = self.favData
        
        for dict in favData{
            var tempDict = dict.first?.value as! [String:Any]
            if tempDict["postPic"] == nil && tempDict["postVid"] == nil{
                if tempDict["posterPicURL"] as? String == nil || tempDict["posterPicURL"] as! String == "profile-placeholder"{
                    tempDict["posterPicURL"] = UIImage(named: "profile-placeholder")
                    //self.myPicString = "profile-placeholder"
                } else {
                    
                    if let messageImageUrl = URL(string: tempDict["posterPicURL"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            tempDict["posterPicURLString"] = tempDict["posterPicURL"] as! String
                            tempDict["posterPicURL"] = UIImage(data: imageData as Data)
                            
                        }
                    }
                }
                favText.append(tempDict)
            } else {
                favPicVid.append(tempDict)
            }
        }
        print("favData1234: \(self.favData)")
        print("favPicVidData: \(self.favPicVid)")
        self.favoritesCollect.register(UINib(nibName: "NewsFeedCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsFeedCellCollectionViewCell")
       // self.favoritesCollect.register(UINib(nibName: "NewsFeedPicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsFeedPicCollectionViewCell")
        self.favoritesCollect.register(UINib(nibName: "PopCell", bundle: nil), forCellWithReuseIdentifier: "PopCell")
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        favoritesCollect!.collectionViewLayout = layout
        favoritesCollect.delegate = self
        favoritesCollect.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    var ogFavData = [[String:Any]]()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.FavoritesToHash
        if segue.identifier == "FavoritesToHash"{
            if let vc = segue.destination as? HashTagViewController{
                
                vc.hashtag = self.selectedHash
            }
        }
        if segue.identifier == "FavToSinglePost"{
            if let vc = segue.destination as? SinglePostViewController{
              
                
                vc.prevScreen = "Favorites"
                
                
                    vc.thisPostData = selectedData
                
                vc.favData = self.ogFavData
                
            }
        }
        if segue.identifier == "FavoritesToProfile"{
            if let vc = segue.destination as? ProfileViewController{
                if toMention == true{
                    vc.curUID = self.mentionID
                } else {
                    vc.curUID = self.selectedCellUID
                }
                vc.prevScreen = "favorites"
                
                if selectedCurAuthProfile == true{
                    vc.viewerIsCurAuth = true
                    
                } else {
                    vc.viewerIsCurAuth = false
                }
                vc.curName = self.curName
            }
        }
    }
}

extension FavoritesViewController:PlayerDelegate {
    
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

extension FavoritesViewController:PlayerPlaybackDelegate {
    
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
