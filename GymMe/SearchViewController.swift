//
//  SearchViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 6/21/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation
import SwiftOverlays


class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var backToCatButton: UIButton!
    var prevScreen = String()
    var sportsCollectData = ["Soccer","Football","Lacrosse", "Track & Field", "Tennis","Baseball","Swimming"]
    
    @IBOutlet weak var sportsView: UIView!
    
    
    
    @IBOutlet weak var sportsCollect: UICollectionView!
    
    @IBAction func backToAllCatPressed(_ sender: Any) {
        noPostsLabel.isHidden = true
        makeFirstPostButton.isHidden = true
        topBarCat.setTitleColor(UIColor.red, for: .normal)
        topBarPop.setTitleColor(UIColor.black, for: .normal)
        topBarNearby.setTitleColor(UIColor.black, for: .normal)
        categoriesCollect.isHidden = false
        topBarPressed = false
        border1.isHidden = false
        border2.isHidden = true
        border3.isHidden = true
        popCollect.isHidden = true
        popCollectData.removeAll()
        //DispatchQueue.main.async{
        self.popCollect.reloadData()
        backToCatButton.isHidden = true
        sports = false
        //}
    }
   // var gmRed = UIColor(red: 180/255, green: 29/255, blue: 2/255, alpha: 1.0)
    @IBAction func backButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            //self.singlePostView3.frame = self.ogCommentPos
            self.singlePostView.isHidden = true
            self.singlePostView.frame = self.curCellFrame
            self.singlePostImageView.image = nil
           // self.singlePostTextView.text = nil
            self.player = nil
            //self.singlePostView1.isHidden = false
           self.backToCatButton.isHidden = false
            self.sports = false
          
        })
       
    }
   
    
    @IBOutlet weak var singlePostImageView: UIImageView!
    @IBOutlet weak var singlePostView: UIView!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var categoriesCollect: UICollectionView!
    @IBAction func topBarSearchPressed(_ sender: Any) {
        performSegue(withIdentifier:"generalToSpecificSearch", sender: self)
        
    }
    @IBOutlet weak var topBarSearchButton: UIButton!
    
    @IBOutlet weak var topBarCat: UIButton!
    
    @IBAction func topBarCatPressed(_ sender: Any) {
        topBarCat.setTitleColor(UIColor.red, for: .normal)
        topBarPop.setTitleColor(UIColor.black, for: .normal)
        topBarNearby.setTitleColor(UIColor.black, for: .normal)
        categoriesCollect.isHidden = false
        topBarPressed = false
        border1.isHidden = false
        border2.isHidden = true
        border3.isHidden = true
        popCollect.isHidden = true
        popCollectData.removeAll()
        //DispatchQueue.main.async{
            self.popCollect.reloadData()
        //}
    }
    
    @IBOutlet weak var topBarPop: UIButton!
    
    var popData = [[String:Any]]()
    @IBAction func topBarPopPressed(_ sender: Any) {
        topBarCat.setTitleColor(UIColor.black, for: .normal)
        topBarPop.setTitleColor(UIColor.red, for: .normal)
        topBarNearby.setTitleColor(UIColor.black, for: .normal)
        categoriesCollect.isHidden = true
        border1.isHidden = true
        border2.isHidden = false
        border3.isHidden = true
        topBarPressed = true
        popCollectData.removeAll()
        Database.database().reference().child("posts").observeSingleEvent(of: .value, with: {(snapshot) in
            // print(snapshot.value)
            //if let snapshots = snapshot.value as? [DataSnapshot]{
            var tempData = [[String:Any]]()
            for (key, val) in (snapshot.value as! [String:Any]) {
                let tempDict = val as! [String:Any]
                if tempDict["likes"] != nil {
                    tempData.append(tempDict)
                }
                
            }
            self.popCollectData = tempData.sorted(by: { ($0["likes"] as! [[String:Any]]).count > ($1["likes"] as! [[String:Any]]).count })
            var tempData2 = [[String:Any]]()
            for dict in self.popCollectData{
                if ((dict as! [String:Any])["postPic"] == nil && (dict as! [String:Any])["postVid"] == nil){
                    print("textBeingRemoved2")
                    // popCollectData.remove(at: popCollectData.index(of: dict))
                } else {
                    tempData2.append(dict)
                }
            }
                self.popCollectData = tempData2
            self.popCollect.reloadData()
            print("blue53: \(self.popCollectData)")
            print("x")
            self.popCollect.isHidden = false
        })
        
        
    }
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var topBarNearby: UIButton!
    @IBOutlet weak var commentedByButton: UIButton!
    
    @IBAction func commentedByButtonPressed(_ sender: Any) {
        commentView.isHidden = false
       // singlePostView3.isHidden = false
    }
    @IBAction func topBarNearbyPressed(_ sender: Any) {
        topBarCat.setTitleColor(UIColor.black, for: .normal)
        topBarPop.setTitleColor(UIColor.black, for: .normal)
        topBarNearby.setTitleColor(UIColor.red, for: .normal)
        categoriesCollect.isHidden = true
        border1.isHidden = true
        border2.isHidden = true
        border3.isHidden = false
        popCollect.isHidden = false
        topBarPressed = false
        locationManager.delegate = self
        startLocationManager()
        
    }
    var catCollectPics = ["arms","chest","abs","legs", "back", "shoulders","cardio","sports","nutrition","stretching","crossfit","bodybuilding","agility"]
    var catCollectData = ["Arms","Chest","Abs","Legs","Back", "Shoulders","Cardio","Sports","Nutrition","Stretching","Crossfit","Body Building","Speed and Agility"]
     //let border = CALayer()
     //let border2 = CALayer()
     //let border3 = CALayer()
    @IBOutlet weak var border3: UIView!
    
    @IBOutlet weak var border2: UIView!
    
    @IBOutlet weak var popCollect: UICollectionView!
    @IBOutlet weak var border1: UIView!
    
    @IBOutlet weak var backToCatFromSports: UIButton!
    @IBAction func hideCommentsPressed(_ sender: Any) {
        commentView.isHidden = true
    }
    @IBOutlet weak var hideComments: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        ogCommentPos = commentView.frame
        //posterPicButton.layer.cornerRadius = posterPicButton.frame.width/2
        //posterPicButton.layer.masksToBounds = true
       makeFirstPostButton.layer.cornerRadius = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
      backToCatFromSports.layer.cornerRadius = 10
        commentCollect.register(UINib(nibName: "CommentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CommentCollectionViewCell")
        
        likesCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        //shareCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
       ogSinglePostViewFrame = singlePostView.frame
        
        
        self.popCollect.register(UINib(nibName: "PopCell", bundle: nil), forCellWithReuseIdentifier: "PopCell")
       
        border1.isHidden = false
        border2.isHidden = true
        border3.isHidden = true
        
        tabBar.delegate = self
        categoriesCollect.delegate = self
        categoriesCollect.dataSource = self
        
        //shareCollect.delegate = self
        //shareCollect.dataSource = self
        sportsCollect.delegate = self
        sportsCollect.dataSource = self
        popCollect.delegate = self
        popCollect.dataSource = self
        typeCommentTF.delegate = self
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        //layout.itemSize = CGSize(width: screenWidth/2.035, height: screenWidth/2.7)
        layout.itemSize = CGSize(width: screenWidth/2.045, height: screenWidth/2.045)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        categoriesCollect!.collectionViewLayout = layout
        
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout2.sectionInset = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        layout2.itemSize = CGSize(width: screenWidth/3.045, height: screenWidth/3.045)
        layout2.minimumInteritemSpacing = 0
        layout2.minimumLineSpacing = 1
        popCollect!.collectionViewLayout = layout2
        popCollect.isHidden = true
        
        tabBar.selectedItem = tabBar.items?[1]
        topBarCat.setTitleColor(UIColor.red, for: .normal)
        topBarPop.setTitleColor(UIColor.black, for: .normal)
        topBarNearby.setTitleColor(UIColor.black, for: .normal)
        categoriesCollect.isHidden = false
        loadPopData()
        

        // Do any additional setup after loading the view.
    }
    var myPicString = String()
    var keys = [String]()
    var myName = String()
    var myUName = String()
    
    func loadPopData(){
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: {(snapshot) in
            var snapDict = snapshot.value as! [String:Any]
            self.myName = snapDict["realName"] as! String
            self.myUName = snapDict["username"] as! String
            self.myPicString = snapDict["profPic"] as! String
        Database.database().reference().child("posts").observeSingleEvent(of: .value, with: {(snapshot) in
           // print(snapshot.value)
            //if let snapshots = snapshot.value as? [DataSnapshot]{
            for (key, val) in (snapshot.value as! [String:Any]) {
                let tempDict = val as! [String:Any]
                if tempDict["categories"] != nil {
                    for cat in (tempDict["categories"] as! [String]){
                        var tempArr = self.allCatDataDict[cat]
                        if self.allCatDataDict[cat] != nil {
                            tempArr!.append([key:tempDict])
                            
                        } else {
                            tempArr = [[key: tempDict]]
                        }
                        self.allCatDataDict[cat] = tempArr
                    }
                } else {
                    
                    var tempArr2 = self.allCatDataDict["other"]
                    if self.allCatDataDict["other"] != nil {
                        tempArr2!.append([key:tempDict])
                    } else {
                        tempArr2 = [[key: tempDict]]
                    }
                    self.allCatDataDict["other"] = tempArr2
                }
            }
            //SwiftOverlays.removeAllBlockingOverlays()
        })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items![0]{
            performSegue(withIdentifier: "SearchToFeed", sender: self)
        } else if item == tabBar.items![2]{
            performSegue(withIdentifier: "SearchToPost", sender: self)
        } else if item == tabBar.items![3]{
            performSegue(withIdentifier: "SearchToNotifications", sender: self)
        } else if item == tabBar.items![4]{
            performSegue(withIdentifier: "SearchToProfile", sender: self)
        } else {
            //curScreen
        }
        
    }
    var popCollectData = [[String:Any]]()
    @IBOutlet weak var feedCollect: UICollectionView!
    
    @IBOutlet weak var makeFirstPostButton: UIButton!
    @IBAction func makeFirstPostPressed(_ sender: Any) {
        performSegue(withIdentifier: "SearchToPost", sender: self)
    }
    var sports = false
    @IBOutlet weak var noPostsLabel: UILabel!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == sportsCollect {
            
            return sportsCollectData.count
        } else if collectionView == categoriesCollect{
            return catCollectData.count
        } else if collectionView == popCollect {
            if self.popCollectData.count == 0 && sports == true {
                print("popCollectData0: \(self.popCollectData.count) \(sports)")
                self.noPostsLabel.isHidden = false
                self.makeFirstPostButton.isHidden = false
                //self.reloadInputViews()
               //DispatchQueue self.makeFirstPostButton.isHidden = false
            }
            return popCollectData.count
        } else if collectionView == commentCollect{
            return commentsCollectData.count
        } else {
            return likedCollectData.count
        }
    }
    var topBarPressed = false
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("hey345345")
        if collectionView == sportsCollect{
            print("sportsCollecttttt")
            let cell : PostCatSearchSportsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCatSearchSportsCell", for: indexPath) as! PostCatSearchSportsCell
            cell.layer.cornerRadius = 10
            
            cell.catSportLabel.text = sportsCollectData[indexPath.row]
            
            return cell
        } else if collectionView == categoriesCollect{
        
        let cell : UICollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "CatCell", for: indexPath) as! CatCell)
        //cell.layer.borderWidth = 2
        //cell.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        (cell as! CatCell).catCellLabel.text = catCollectData[indexPath.row]
        (cell as! CatCell).catCellImageView.image = UIImage(named: catCollectPics[indexPath.row])
        
        
            return cell
        } else if collectionView == popCollect {
            let cell : PopCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "PopCell", for: indexPath) as! PopCell)
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.cgColor
            if topBarCat.titleLabel?.textColor == UIColor.red{
                
                //print("this popcelldata = \(popCollectData[indexPath.row] )")
                if topBarPressed == true{
                    if ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postPic"] == nil {
                        if ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postVid"] == nil {
                            
                            cell.popPic.image = UIImage(named: "background2")
                            UIView.animate(withDuration: 0.5, animations: {
                                
                                cell.popText.text = String(describing: ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postText"]!)
                                cell.player?.view.isHidden = true
                                cell.bringSubview(toFront: cell.popText)
                            })
                        } else {
                            cell.popPic.isHidden = true
                            DispatchQueue.main.async{
                            cell.player?.url = URL(string: String(describing: ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postVid"]!))
                            cell.player?.playerDelegate = self
                            cell.player?.playbackDelegate = self
                            cell.player?.playbackLoops = true
                            cell.player?.playbackPausesWhenBackgrounded = true
                            cell.player?.playbackPausesWhenResigningActive = true
                            }
                            let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: popCollect.frame.width - 28, height: cell.popPic.frame.height)
                            cell.player?.view.frame = vidFrame
                            cell.player?.view.isHidden = false
                            cell.player?.didMove(toParentViewController: self)
                            //cell.player?.url = cell.videoUrl
                            cell.player?.playbackLoops = true
                        }
                    } else {
                        DispatchQueue.main.async{
                        if let messageImageUrl = URL(string: ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postPic"] as! String) {
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                cell.popPic.image = UIImage(data: imageData as Data)
                            }
                        }
                        }
                    }
                    return cell
                } else {
                    if (((self.popCollectData[indexPath.row]).first?.value as! [String:Any]))["postPic"] == nil {
                        if ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postVid"] == nil{
                            UIView.animate(withDuration: 0.5, animations: {
                                cell.popText.isHidden = false
                                cell.popText.text = (String(describing: ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postText"]!))
                                cell.player?.view.isHidden = true
                                cell.bringSubview(toFront: cell.popText)
                            })
                        } else {
                            cell.popText.textColor = UIColor.white
                            cell.popPic.isHidden = true
                            DispatchQueue.main.async{
                            cell.player?.url = URL(string: String(describing: ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postVid"]!))
                            cell.player?.playerDelegate = self
                            cell.player?.playbackDelegate = self
                            cell.player?.playbackLoops = true
                            cell.player?.playbackPausesWhenBackgrounded = true
                            cell.player?.playbackPausesWhenResigningActive = true
                            }
                            let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: popCollect.frame.width - 28, height: cell.popPic.frame.height)
                            cell.player?.view.frame = vidFrame
                            cell.player?.view.isHidden = false
                            cell.player?.didMove(toParentViewController: self)
                            cell.player?.playbackLoops = true
                        }
                    } else {
                        cell.popText.textColor = UIColor.white
                        DispatchQueue.main.async{
                        if let messageImageUrl = URL(string: ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postPic"] as! String) {
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                cell.popPic.image = UIImage(data: imageData as Data)
                            }
                        }
                        }
                    }
                }
            
            return cell
            
                
            } else {
            //print("this popcelldata = \(popCollectData[indexPath.row] )")
            if topBarPressed == true{
                if self.popCollectData[indexPath.row]["postPic"] == nil {
                    if (self.popCollectData[indexPath.row])["postVid"] == nil{
                        DispatchQueue.main.async{
                        cell.popPic.image = UIImage(named: "background2")
                        }
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            cell.popText.text = String(describing: ((self.popCollectData[indexPath.row])["postText"]!))
                            cell.player?.view.isHidden = true
                            cell.bringSubview(toFront: cell.popText)
                        })
                    } else {
                        cell.popPic.isHidden = true
                         DispatchQueue.main.async{
                            cell.player?.url = URL(string: String(describing: (self.popCollectData[indexPath.row])["postVid"]!))
                        cell.player?.playerDelegate = self
                        cell.player?.playbackDelegate = self
                        cell.player?.playbackLoops = true
                        cell.player?.playbackPausesWhenBackgrounded = true
                        cell.player?.playbackPausesWhenResigningActive = true
                        }
                        let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: popCollect.frame.width - 28, height: cell.popPic.frame.height)
                        cell.player?.view.frame = vidFrame
                        cell.player?.view.isHidden = false
                        cell.player?.didMove(toParentViewController: self)
                        //cell.player?.url = cell.videoUrl
                        cell.player?.playbackLoops = true
                    }
                } else {
                     DispatchQueue.main.async{
                    if let messageImageUrl = URL(string: self.popCollectData[indexPath.row]["postPic"] as! String) {
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            cell.popPic.image = UIImage(data: imageData as Data)
                        }
                    }
                    }
                }
                return cell
            } else {
            if (self.popCollectData[indexPath.row])["postPic"] == nil {
                if (self.popCollectData[indexPath.row])["postVid"] == nil{
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.popText.isHidden = false
                        if ((self.popCollectData[indexPath.row])["postText"] as? String) != nil {
                        cell.popText.text = (String(describing: ((self.popCollectData[indexPath.row]))["postText"]!))
                        }
                        cell.player?.view.isHidden = true
                        cell.bringSubview(toFront: cell.popText)
                    })
                } else {
                    cell.popText.textColor = UIColor.white
                    cell.popPic.isHidden = true
                     DispatchQueue.main.async{
                        cell.player?.url = URL(string: String(describing: (self.popCollectData[indexPath.row])["postVid"]!))
                    cell.player?.playerDelegate = self
                    cell.player?.playbackDelegate = self
                    cell.player?.playbackLoops = true
                    cell.player?.playbackPausesWhenBackgrounded = true
                    cell.player?.playbackPausesWhenResigningActive = true
                    }
                    let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: popCollect.frame.width - 28, height: cell.popPic.frame.height)
                    cell.player?.view.frame = vidFrame
                    cell.player?.view.isHidden = false
                    cell.player?.didMove(toParentViewController: self)
                    cell.player?.playbackLoops = true
                }
            } else {
                cell.popText.textColor = UIColor.white
                 DispatchQueue.main.async{
                if let messageImageUrl = URL(string: (self.popCollectData[indexPath.row])["postPic"] as! String) {
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    cell.popPic.image = UIImage(data: imageData as Data)
                    
                    }
                    }
                }
                }
            }
        }
                
            return cell
        
        } else if collectionView == commentCollect {
            let cell : CommentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCollectionViewCell", for: indexPath) as! CommentCollectionViewCell
            DispatchQueue.main.async{
                cell.commentorPic.layer.cornerRadius = cell.commentorPic.frame.width/2
                cell.commentorPic.layer.masksToBounds = true
                let nameAndComment = (self.commentsCollectData[indexPath.row]["commentorName"] as! String) + " " +  (self.commentsCollectData[indexPath.row]["commentText"] as! String)
                
                print("name&Comment: \(nameAndComment)")
                
                
                let boldNameAndComment = self.attributedText(withString: nameAndComment, boldString: (self.commentsCollectData[indexPath.row]["commentorName"] as! String), font: (cell.commentTextView.font!))
                
                print("boldName&Comment: \(boldNameAndComment)")
                cell.commentTextView.attributedText = boldNameAndComment
                var tStampDateString = String()
                if self.topBarCat.titleLabel!.textColor == UIColor.red || self.topBarNearby.titleLabel!.textColor == UIColor.red {
                tStampDateString = ((self.curCommentCell! as! [String:Any]).first!.value as! [String:Any])["datePosted"]! as! String
                } else {
                    tStampDateString = (self.curCommentCell! as! [String:Any])["datePosted"]! as! String
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                let date = dateFormatter.date(from: tStampDateString)
                
                let now = Date()
                //print("tStampDateString: \(tStampDateString), date: \(date!), now: \(now)")
                let hoursBetween = now.hours(from: date!)
                //let tString = dateFormatter.string(from: tDate!)
                cell.commentTimeStamp.text = "\(hoursBetween) hours ago"
                
                if self.commentsCollectData[indexPath.row]["commentorPic"] as! String == "profile-placeholder"{
                    cell.commentorPic.setImage(UIImage(named: "profile-placeholder"), for: .normal)
                } else {
                    if let messageImageUrl = URL(string: self.commentsCollectData[indexPath.row]["commentorPic"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            cell.commentorPic.setImage(UIImage(data: imageData as Data), for: .normal)
                        }
                    }
                }
            }
            return cell
        } else {
            let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
            if (self.likedCollectData .count == 1 && (self.likedCollectData[indexPath.row])["x"] != nil){
                
                return cell
                
            } else {
                DispatchQueue.main.async{
                    
                    /*if (self.following.contains(self.likedCollectData[indexPath.row]["uid"] as! String)){
                        cell.likedByFollowButton.setTitle("Unfollow", for: .normal)
                    }*/
                    cell.likedByName.isHidden = false
                    cell.likedByUName.isHidden = false
                    cell.likedByFollowButton.isHidden = true
                    cell.commentName.isHidden = true
                    cell.commentTextView.isHidden = true
                    cell.commentTimestamp.isHidden = true
                    cell.likedByUName.text = self.likedCollectData[indexPath.row]["uName"] as! String
                    
                    cell.likedByUID = self.likedCollectData[indexPath.row]["uid"] as! String
                    
                    cell.likedByName.text = self.likedCollectData[indexPath.row]["realName"] as! String
                    if self.likedCollectData[indexPath.row]["pic"] as! String == "profile-placeholder"{
                        DispatchQueue.main.async{
                            cell.likedByImage.image = UIImage(named: "profile-placeholder")
                        }
                    } else {
                        if let messageImageUrl = URL(string: self.likedCollectData[indexPath.row]["pic"] as! String) {
                            
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                DispatchQueue.main.async{
                                    cell.likedByImage.image = UIImage(data: imageData as Data)
                                }
                                
                            }
                            
                            //}
                        }
                    }
                }
            }
            
            return cell
        }
            
    }
    
   
    
    @IBOutlet weak var shareCollectView: UIView!
    @IBOutlet weak var shareCollect: UICollectionView!
    // @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var favoritesCount: UIButton!
    var commentsCollectData = [[String:Any]]()
    @IBOutlet weak var commentCollect: UICollectionView!
    
     var activityViewController:UIActivityViewController?
    @IBAction func shareButtonPressed(_ sender: Any) {
        
        activityViewController = UIActivityViewController(
            activityItems: ["Download GymMe today!"],
            applicationActivities: nil)
        
        present(activityViewController!, animated: true, completion: nil)
        //shareFinalizeButton.isHidden = false
        //self.inboxButton.isHidden = true
        
        //self.selfCommentPic.isHidden = true
        //shareSearchBar.isHidden = true
        
        //commentTF.isHidden = true
       /* Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let valDict = snapshot.value as! [String:Any]
            
            
            
            let followersArr = valDict["followers"] as! [String]
            let followingArr = valDict["following"] as! [String]
            var mergedArr = Array(Set(followersArr + followingArr))
            var sortedMergedArr = mergedArr.sort()
            print("mergedArr: \(sortedMergedArr)")
            
            Database.database().reference().child("users").observeSingleEvent(of: .value, with: { snapshot in
                let valDict2 = snapshot.value as! [String:Any]
                for (key, vall) in valDict2{
                    var val = vall as! [String:Any]
                    print("key: \(key), val: \(val)")
                    if mergedArr.contains(key){
                        var collectDataDict = ["pic": (val["profPic"] as! String), "uName": self.myUName, "realName": (val["realName"] as! String), "uid":
                            key]
                        
                        self.likedCollectData.append(collectDataDict)
                    }
                }
                self.shareCollect.delegate = self
                self.shareCollect.dataSource = self
                DispatchQueue.main.async{
                    self.shareCollect.reloadData()
                }
                
                self.shareCollectView.isHidden = false
                
            })
            
        })*/
    }
    var likedCollectData = [[String:Any]]()
    @IBOutlet weak var shareButton: UIButton!
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
                favoritesArray.append(["uName": self.myUName, "realName": self.myName, "uid": Auth.auth().currentUser!.uid, "pic": self.myPicString])
                
                Database.database().reference().child("posts").child(self.postID).child("favorites").setValue(favoritesArray)
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("favorites").setValue(favoritesArray)
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").updateChildValues([self.postID: self.selfData])
                //self.favoritesButton.setTitle(String(favoritesArray.count), for: .normal)
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
                    //self.favoritesButton.setTitle("0", for: .normal)
                } else {
                    favesArray.remove(at: 0)
                    favesVal = favesArray.count
                    //self.favoritesButton.setTitle(String(favesArray.count), for: .normal)
                }
                
                
                Database.database().reference().child("posts").child(self.postID).child("favorites").setValue(favesArray)
                
                
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("favorited").setValue(favesArray)
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").setValue(favesArray)
                
            })
            
        }
    }
    @IBOutlet weak var favoritesButton: UIButton!
    //@IBAction func commentPressed(_ sender: Any) {
    //}
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var likesCollect: UICollectionView!
    //@IBOutlet weak var commentCount: UIButton!
    @IBOutlet weak var likeButtonCount: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction func likeButtonPressed(_ sender: Any) {
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
                likesArray.append(["uName": self.myUName, "realName": self.myName, "uid": Auth.auth().currentUser!.uid, "pic": myPic])
                
                
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
                self.likeButtonCount.setTitle(likesString, for: .normal)
                
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
                
                self.likeButtonCount.setTitle(likesString, for: .normal)
                
                
                
                
                
                Database.database().reference().child("posts").child(self.postID).child("likes").setValue(likesArray)
                
                
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("likes").setValue(likesArray)
                
                
                DispatchQueue.main.async{
                    //self.shareCollect.reloadData()
                }
            })
        }
        DispatchQueue.main.async {
           // self.delegate?.reloadDataAfterLike()
        }
    }
    
    
    
    @IBOutlet weak var postText: UILabel!
    @IBAction func commentPressed(_ sender: Any) {
        commentView.isHidden = false
        commentView.isHidden = false
        commentCollect.isHidden = false
        likesCollect.isHidden = true
       // print("commentsArray: \(commentsArray)")
        commentCollect.delegate = self
        commentCollect.dataSource = self
        //commentTF.isHidden = false
    }
    
    var postID = String()
    var posterUID = String()
    var selfData = [String:Any]()
    
    @IBAction func posterNameButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var posterNameButton: UIButton!
    @IBAction func posterPicButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var posterPicButton: UIButton!
    //@IBOutlet weak var textPostTV: UITextView!
    var player: Player?
    var selectedCat = String()
    var allCatDataDict = [String:[[String:Any]]]()
    var ogSinglePostViewFrame = CGRect()
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell touched")
        
        if collectionView == sportsCollect {
            backToCatButton.isHidden = false
            let cellLabel = sportsCollectData[indexPath.row]
            if allCatDataDict[cellLabel] == nil {
                self.allCatDataDict[cellLabel] = [[String:Any]]()
            }
            self.popCollectData = self.allCatDataDict[cellLabel]!
            
            print("popCollectDataBefore: \(popCollectData)")
            var tempData = [[String:Any]]()
            for dict in popCollectData{
                print("dict1: \(dict)")
                if ((dict.first?.value as! [String:Any])["postPic"] == nil && (dict.first?.value as! [String:Any])["postVid"] == nil){
                    print("textBeingRemoved1")
                    // popCollectData.remove(at: popCollectData.index(of: dict))
                } else {
                    print("dict: \(dict)")
                    tempData.append(dict)
                }
                
                
                //print("popCollectData: \(popCollectData)" \(count))
                // count = count + 1
            }
            self.popCollectData = tempData
            //print("popCollectDataAfter: \(popCollectData.count)")
           
            
            DispatchQueue.main.async{
                //self.popCollect.delegate = self
                //self.popCollect.dataSource = self
               
                self.popCollect.reloadData()
            }
            self.popCollect.isHidden = false
            self.categoriesCollect.isHidden = true
            sportsView.isHidden = true
           
            
            backToCatButton.isHidden = false
            
            
        } else if collectionView == categoriesCollect{
            backToCatButton.isHidden = false
        let cellLabel = catCollectData[indexPath.row]
            
            if cellLabel == "Sports"{
                sportsView.isHidden = false
                sports = true
                backToCatButton.isHidden = true
            } else {
            if allCatDataDict[cellLabel] == nil {
                self.allCatDataDict[cellLabel] = [[String:Any]]()
            }
            self.popCollectData = self.allCatDataDict[cellLabel]!
            
            print("popCollectDataBefore: \(popCollectData)")
            var tempData = [[String:Any]]()
            for dict in popCollectData{
                print("dict1: \(dict)")
                if ((dict.first?.value as! [String:Any])["postPic"] == nil && (dict.first?.value as! [String:Any])["postVid"] == nil){
                    print("textBeingRemoved1")
                   // popCollectData.remove(at: popCollectData.index(of: dict))
                } else {
                    print("dict: \(dict)")
                    tempData.append(dict)
                }
                
                //print("popCollectData: \(popCollectData)" \(count))
               // count = count + 1
            }
            self.popCollectData = tempData
           print("popCollectDataAfter: \(popCollectData)")
            DispatchQueue.main.async{
            //self.popCollect.delegate = self
            //self.popCollect.dataSource = self
                    self.popCollect.reloadData()
            }
                
                    self.popCollect.isHidden = false
            sportsCollect.isHidden = true
                    self.categoriesCollect.isHidden = true
           
            }
        } else if collectionView == shareCollect {
            
            let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
            
            cell.selectButton.isHidden = true
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            
            cell.likedByFollowButton.isHidden = true
            
            //cell.selectButton.isHidden = false
            
            cell.likedByName.isHidden = false
            cell.likedByUName.isHidden = false
            cell.commentName.isHidden = true
            cell.commentTextView.isHidden = true
            //cell.commentTimestamp.isHidden = true
            cell.likedByUName.text = ((likedCollectData[indexPath.row] )["uName"] as! String)
            
            cell.likedByUID = ((likedCollectData[indexPath.row])["uid"] as! String)
            
            cell.likedByName.text = ((likedCollectData[indexPath.row] )["realName"] as! String)
            
            if ((likedCollectData[indexPath.row])["pic"] as! String) == "profile-placeholder"{
                cell.likedByImage.image = UIImage(named: "profile-placeholder")
                
            } else {
                if let messageImageUrl = URL(string: likedCollectData[indexPath.row]["pic"] as! String) {
                    
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        
                        cell.likedByImage.image = UIImage(data: imageData as Data)
                        
                    }
                    
                    //}
                }
            }
           // return cell
            
            
            
            
        } else if collectionView == popCollect{
            
            
            if topBarCat.titleLabel?.textColor == UIColor.red || topBarNearby.titleLabel?.textColor == UIColor.red{
                
                
                let cellLabel = catCollectData[indexPath.row]
                if allCatDataDict[cellLabel] == nil {
                    self.allCatDataDict[cellLabel] = [[String:Any]]()
                }
                //print("selectedData for \(cellLabel): \(self.popCollectData[indexPath.row])")
                //show single post view
                singlePostView.frame = (popCollect.visibleCells[indexPath.row] as! PopCell).frame
                self.curCellFrame = (popCollect.visibleCells[indexPath.row] as! PopCell).frame
                self.selfData = ((self.popCollectData[indexPath.row]).first!.value as! [String:Any])
                
                self.posterUID = (selfData["posterUID"] as! String)
                
                self.cityLabel.titleLabel!.text = ((self.popCollectData[indexPath.row]) as! [String:Any])["city"] as? String
                
                self.postID =  (selfData["postID"] as! String)
                
                //did select picture cell
                if selfData["postPic"] as? String != nil {
                    if let messageImageUrl = URL(string: ((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["postPic"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            singlePostImageView.image = UIImage(data: imageData as Data)
                        }
                    }
                    if let messageImageUrl = URL(string: ((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["posterPicURL"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            posterPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                        }
                    }
                   self.likedCollectData = (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["likes"] as! [[String:Any]])
                    self.posterNameButton.setTitle(((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["posterName"] as? String, for: .normal)
                    self.curCommentCell = self.popCollectData[indexPath.row]
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    for item in (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        if (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["likes"] as! [[String:Any]]).count == 1{
                       var tempString = "\((((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["likes"] as! [[String:Any]]).count) like"
                        likeButtonCount.setTitle(tempString, for: .normal)
                            
                        } else {
                            var tempString = "\((((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["likes"] as! [[String:Any]]).count) likes"
                            likeButtonCount.setTitle(tempString, for: .normal)
                            
                        }
                        
                        if (likesPost!["uName"] as! String) == self.myUName{
                            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                            //cell.likesCountButton.setTitle((feedDataArray[indexPath.row]["likes"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    //set comments count
                    if commentsPost!["x"] != nil {
                        
                    } else {
                        commentsCollectData.removeAll()
                        print("showComments")
                        
                        if ((((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            
                            
                            
                        } else {
                            
                            
                            
                            commentsCollectData = (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["comments"] as! [[String:Any]])
                            
                            //DispatchQueue.main.async {
                            
                            
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            DispatchQueue.main.async{
                                self.commentCollect.reloadData()
                            }
                        }
                        
                        
                    }
                    
                    for item in (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["favorites"] as! [[String:Any]]){
                        
                        favesPost = item as! [String: Any]
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        
                        
                        if (favesPost!["uName"] as! String) == self.myName{
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            //favoritesCount.setTitle((((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["favorites"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    
                   // textPostTV.isHidden = true
                   // singlePostView2.isHidden = false
                } else if (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["postVid"] as? String != nil) {
                    //vid post//////////
                    //self.singlePostView3.frame = ogCommentPos
                    self.player = Player()
                   // textPostTV.isHidden = true
                    player?.url = URL(string:((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["postVid"] as! String)
                    let playTap = UITapGestureRecognizer()
                    playTap.numberOfTapsRequired = 1
                    playTap.addTarget(self, action: #selector(SearchViewController.playOrPause))
                    player?.view.addGestureRecognizer(playTap)
                    
                    let vidFrame = singlePostImageView.frame
                    self.player?.view.frame = vidFrame
                    self.singlePostView.addSubview((self.player?.view)!)
                    self.player?.didMove(toParentViewController: self)
                    singlePostView.sendSubview(toBack: (player?.view)!)
                    
                    self.curCommentCell = (self.popCollectData[indexPath.row]).first!.value as! [String:Any]
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    for item in (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String((((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["likes"] as! [[String:Any]]).count), for: .normal)
                        
                        if (likesPost!["uName"] as! String) == self.myName{
                            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                            //cell.likesCountButton.setTitle((feedDataArray[indexPath.row]["likes"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    //set comments count
                    if commentsPost!["x"] != nil {
                        
                    } else {
                        commentsCollectData.removeAll()
                        print("showComments")
                        if ((((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            
                            
                            
                        } else {
                            
                            
                            
                            commentsCollectData = (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["comments"] as! [[String:Any]])
                            
                            //DispatchQueue.main.async {
                            
                            
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            DispatchQueue.main.async{
                                self.commentCollect.reloadData()
                            }
                        }
                        
                    }
                    
                    for item in (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["favorites"] as! [[String:Any]]){
                        
                        favesPost = item as! [String: Any]
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        
                        
                        if (favesPost!["uName"] as! String) == self.myName{
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            //favoritesCount.setTitle((((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["favorites"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    
                    //textPostTV.isHidden = true
                    //singlePostView2.isHidden = false
                } else {
                    //text post
                    self.curCommentCell = ((self.popCollectData[indexPath.row]).first!.value as! [String:Any])
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    for item in (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String(((((self.popCollectData[indexPath.row]) as! [String:Any]).first!.value as! [String:Any])["likes"] as! [[String:Any]]).count), for: .normal)
                        
                        if (likesPost!["uName"] as! String) == self.myName{
                            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                            //cell.likesCountButton.setTitle((feedDataArray[indexPath.row]["likes"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    //set comments count
                    if commentsPost!["x"] != nil {
                        
                    } else {
                        commentsCollectData.removeAll()
                        print("showComments")
                        //self.backFromLikedByViewButton.isHidden = false
                        
                        //self.commentTF.isHidden = false
                        
                        //self.topLabel.text = "Comments"
                        if ((((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            
                            
                            
                        } else {
                            
                            
                            
                            commentsCollectData = (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["comments"] as! [[String:Any]])
                            
                            //DispatchQueue.main.async {
                            
                            
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            DispatchQueue.main.async{
                                self.commentCollect.reloadData()
                            }
                        }
                    }
                    
                    for item in (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["favorites"] as! [[String:Any]]){
                        
                        favesPost = item as! [String: Any]
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        if (favesPost!["uName"] as! String) == self.myName{
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            //favoritesCount.setTitle((((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["favorites"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    //textPostTV.isHidden = false
                    //singlePostView2.isHidden = true
                    UIView.animate(withDuration: 0.5, animations: {
                        //self.singlePostView3.frame = self.textPostOnlyCommentsPost.frame
                    })
                }
                postText.text = (((self.popCollectData[indexPath.row]).first!.value as! [String:Any])["postText"] as! String)
                //singlePostTextView.text = (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postText"] as! String)
                UIView.animate(withDuration: 0.5, animations: {
                    self.singlePostView.isHidden = false
                    self.singlePostView.frame = self.ogSinglePostViewFrame
                    
                })
                //^%%%%%%%%
            } else if topBarPop.titleLabel!.textColor == UIColor.red {
                print("wut wut")
                backToCatButton.isHidden = true
                
                let cellLabel = catCollectData[indexPath.row]
                if allCatDataDict[cellLabel] == nil {
                    self.allCatDataDict[cellLabel] = [[String:Any]]()
                }
                //print("selectedData for \(cellLabel): \(self.popCollectData[indexPath.row])")
                //show single post view
                singlePostView.frame = (popCollect.visibleCells[indexPath.row] as! PopCell).frame
                self.curCellFrame = (popCollect.visibleCells[indexPath.row] as! PopCell).frame
                //g
                self.cityLabel.titleLabel!.text = ((self.popCollectData[indexPath.row]) as! [String:Any])["city"] as? String
                
                //did select picture cell
                if ((self.popCollectData[indexPath.row]) as! [String:Any])["postPic"] as? String != nil {
                    if let messageImageUrl = URL(string: ((self.popCollectData[indexPath.row]) as! [String:Any])["postPic"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            singlePostImageView.image = UIImage(data: imageData as Data)
                        }
                    }
                    
                    self.curCommentCell = ((self.popCollectData[indexPath.row]) as! [String:Any])
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String((((self.popCollectData[indexPath.row]) as! [String:Any])["likes"] as! [[String:Any]]).count), for: .normal)
                        
                        if (likesPost!["uName"] as! String) == self.myName{
                            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                            //cell.likesCountButton.setTitle((feedDataArray[indexPath.row]["likes"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    //set comments count
                    if commentsPost!["x"] != nil {
                        
                    } else {
                        commentsCollectData.removeAll()
                        print("showComments")
                        //self.backFromLikedByViewButton.isHidden = false
                        
                        //self.commentTF.isHidden = false
                        
                        //self.topLabel.text = "Comments"
                        if ((((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            
                            var commentString = "View 0 comments"
                            commentedByButton.setTitle(commentString, for: .normal)
                            
                        } else {
                            
                            
                            
                            commentsCollectData = (((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]])
                            var commentString = "View \(commentsCollectData.count) comments"
                            commentedByButton.setTitle(commentString, for: .normal)
                            
                            //DispatchQueue.main.async {
                            
                            
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            DispatchQueue.main.async{
                                self.commentCollect.reloadData()
                            }
                        }
                        
                        
                    }
                    
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["favorites"] as! [[String:Any]]){
                        
                        favesPost = item as! [String: Any]
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        
                        
                        if (favesPost!["uName"] as! String) == self.myName{
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            //favoritesCount.setTitle(((self.popCollectData[indexPath.row])["favorites"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    
                    //textPostTV.isHidden = true
                   // singlePostView2.isHidden = false
                } else if (((self.popCollectData[indexPath.row]) as! [String:Any])["postVid"] as? String != nil) {
                    //vid post//////////
                    //self.singlePostView3.frame = ogCommentPos
                    self.player = Player()
                    //textPostTV.isHidden = true
                    player?.url = URL(string:((self.popCollectData[indexPath.row]) as! [String:Any])["postVid"] as! String)
                    let playTap = UITapGestureRecognizer()
                    playTap.numberOfTapsRequired = 1
                    playTap.addTarget(self, action: #selector(SearchViewController.playOrPause))
                    player?.view.addGestureRecognizer(playTap)
                    
                    let vidFrame = singlePostImageView.frame
                    self.player?.view.frame = vidFrame
                    self.singlePostView.addSubview((self.player?.view)!)
                    self.player?.didMove(toParentViewController: self)
                    singlePostView.sendSubview(toBack: (player?.view)!)
                    
                    self.curCommentCell = self.popCollectData[indexPath.row] as! [String:Any]
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String((((self.popCollectData[indexPath.row]) as! [String:Any])["likes"] as! [[String:Any]]).count), for: .normal)
                        
                        if (likesPost!["uName"] as! String) == self.myName{
                            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                            //cell.likesCountButton.setTitle((feedDataArray[indexPath.row]["likes"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    //set comments count
                    if commentsPost!["x"] != nil {
                        
                    } else {
                        commentsCollectData.removeAll()
                        print("showComments")
                        //self.backFromLikedByViewButton.isHidden = false
                        
                        //self.commentTF.isHidden = false
                        
                        //self.topLabel.text = "Comments"
                        if ((((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            
                            
                            
                        } else {
                            
                            
                            
                            commentsCollectData = (((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]])
                            
                            //DispatchQueue.main.async {
                            
                            
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            DispatchQueue.main.async{
                                self.commentCollect.reloadData()
                            }
                        }
                        
                    }
                    
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["favorites"] as! [[String:Any]]){
                        
                        favesPost = item as! [String: Any]
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        
                        
                        if (favesPost!["uName"] as! String) == self.myName{
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            //favoritesCount.setTitle(((self.popCollectData[indexPath.row])["favorites"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    
                    //textPostTV.isHidden = true
                   // singlePostView2.isHidden = false
                } else {
                    //text post
                    self.curCommentCell = ((self.popCollectData[indexPath.row]) as! [String:Any])
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    if ((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] != nil {
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    }
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String((((self.popCollectData[indexPath.row]) as! [String:Any])["likes"] as! [[String:Any]]).count), for: .normal)
                        
                        if (likesPost!["uName"] as! String) == self.myName{
                            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                            //cell.likesCountButton.setTitle((feedDataArray[indexPath.row]["likes"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    //set comments count
                    if commentsPost!["x"] != nil {
                        
                    } else {
                        commentsCollectData.removeAll()
                        print("showComments")
                        //self.backFromLikedByViewButton.isHidden = false
                        
                        //self.commentTF.isHidden = false
                        
                        //self.topLabel.text = "Comments"
                        if ((((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            
                            
                            
                        } else {
                            
                            
                            
                            commentsCollectData = (((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]])
                            
                            //DispatchQueue.main.async {
                            
                            
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            DispatchQueue.main.async{
                                self.commentCollect.reloadData()
                            }
                        }
                    }
                    
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["favorites"] as! [[String:Any]]){
                        
                        favesPost = item as! [String: Any]
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        if (favesPost!["uName"] as! String) == self.myName{
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            //favoritesCount.setTitle(((self.popCollectData[indexPath.row])["favorites"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                   // textPostTV.isHidden = false
                    //singlePostView2.isHidden = true
                }
                postText.text = (((self.popCollectData[indexPath.row]) as! [String:Any])["postText"] as! String)
                //singlePostTextView.text = ((self.popCollectData[indexPath.row])["postText"] as! String)
                UIView.animate(withDuration: 0.5, animations: {
                    self.singlePostView.isHidden = false
                    self.singlePostView.frame = self.ogSinglePostViewFrame
                    
                })
            }
        } else {
            //nearby
        }
           
        
    }
    
    var ogTextPos = CGRect()
    var ogCommentPos = CGRect()
    
    //@IBOutlet weak var textPostOnlyCommentsPost: UIView!
    //@IBOutlet weak var textPostOnlyView: UIView!
    @IBOutlet weak var typeCommentTF: UITextField!
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
  var curCellFrame = CGRect()

    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!
    @objc func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            // Perform action.
            print("swipeRight: \(prevScreen)")
            if border1.backgroundColor == UIColor.red && popCollect.isHidden == false{
                //back to main cat
                print("backToCat2")
                topBarCat.setTitleColor(UIColor.red, for: .normal)
                topBarPop.setTitleColor(UIColor.black, for: .normal)
                topBarNearby.setTitleColor(UIColor.black, for: .normal)
                categoriesCollect.isHidden = false
                topBarPressed = false
                border1.isHidden = false
                border2.isHidden = true
                border3.isHidden = true
                popCollect.isHidden = true
                popCollectData.removeAll()
                //DispatchQueue.main.async{
                self.popCollect.reloadData()
                backToCatButton.isHidden = true
            } else {
            if prevScreen == "feed"{
                performSegue(withIdentifier: "SearchToFeed", sender: self)
            }
            if prevScreen == "profile"{
                performSegue(withIdentifier: "SearchToProfile", sender: self)
            }
            if prevScreen == "post"{
                performSegue(withIdentifier: "SearchToPost", sender: self)
            }
            
            if prevScreen == "notifications"{
                performSegue(withIdentifier: "SearchToNotifications", sender: self)
            }
            }
        }
    }
    
    @IBAction func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            // Perform action.
            print("swipeRightt: \(prevScreen)")
            if border1.isHidden == false && popCollect.isHidden == false || border2.isHidden == false && popCollect.isHidden == false || border3.isHidden == false && popCollect.isHidden == false{
                //back to main cat
                print("backToCat2")
                topBarCat.setTitleColor(UIColor.red, for: .normal)
                topBarPop.setTitleColor(UIColor.black, for: .normal)
                topBarNearby.setTitleColor(UIColor.black, for: .normal)
                categoriesCollect.isHidden = false
                topBarPressed = false
                border1.isHidden = false
                border2.isHidden = true
                border3.isHidden = true
                popCollect.isHidden = true
                popCollectData.removeAll()
                //DispatchQueue.main.async{
                self.popCollect.reloadData()
                backToCatButton.isHidden = true
            } else {
            if prevScreen == "feed"{
                SwiftOverlays.showBlockingWaitOverlayWithText("Loading")
                performSegue(withIdentifier: "SearchToFeed", sender: self)
            }
            if prevScreen == "profile"{
                SwiftOverlays.showBlockingWaitOverlayWithText("Loading")
                performSegue(withIdentifier: "SearchToProfile", sender: self)
            }
            if prevScreen == "post"{
                performSegue(withIdentifier: "SearchToPost", sender: self)
            }
           
            if prevScreen == "notifications"{
                performSegue(withIdentifier: "SearchToNotifications", sender: self)
            }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SearchToFeed"{
            if let vc = segue.destination as? HomeFeedViewController{
                vc.prevScreen = "search"
            }
            
        }
        if segue.identifier == "SearchToProfile"{
            if let vc = segue.destination as? ProfileViewController{
                vc.prevScreen = "search"
            }
        }
        if segue.identifier == "SearchToNotifications"{
            if let vc = segue.destination as? NotificationsViewController{
                vc.prevScreen = "search"
            }
        }
        if segue.identifier == "SearchToPost"{
            if let vc = segue.destination as? PostViewController{
                vc.prevScreen = "search"
            }
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }// became first responder
    
    var curCommentCell: [String:Any]?
    public func textFieldDidEndEditing(_ textField: UITextField){
        //add comment to post
        Database.database().reference().child("posts").child((self.curCommentCell!.first?.value as! [String:Any])["postID"]! as! String).observeSingleEvent(of: .value, with: { snapshot in
            let valDict = snapshot.value as! [String:Any]
            
            var commentsArray = valDict["comments"] as! [[String:Any]]
            if commentsArray.count == 1 && (commentsArray.first! as! [String:String]) == ["x": "x"]{
                commentsArray.remove(at: 0)
            }
            var commentsVal = commentsArray.count
            commentsVal = commentsVal + 1
            if self.myPicString == nil {
                self.myPicString = "profile-placeholder"
            }
            //add current users id and uName to comment object and upload to database
            commentsArray.append(["commentorName": self.myName, "commentorID": Auth.auth().currentUser!.uid, "commentorPic": self.myPicString, "commentText": self.typeCommentTF.text])
            Database.database().reference().child("posts").child((self.curCommentCell!.first?.value as! [String:Any])["postID"]! as! String).child("comments").setValue(commentsArray)
            Database.database().reference().child("users").child((self.curCommentCell!.first?.value as! [String:Any])["posterUID"]! as! String).child("posts").child((self.curCommentCell!.first?.value as! [String:Any])["postID"]! as! String).child("comments").setValue(commentsArray)
            
            self.typeCommentTF.text = nil
            self.commentsCollectData = commentsArray
            if commentsArray.count == 1{
                DispatchQueue.main.async{
                    self.commentCollect.delegate = self
                    self.commentCollect.dataSource = self
                }
                
            } else {
                print("reloadhereeee")
                //DispatchQueue.main.async{
                    self.commentCollect.reloadData()
                //}
            }
            
        })
    } // may be called if
    
    @IBOutlet weak var cityLabel: UIButton!
    
    
    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedStringKey.font: font])
        let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    var location: CLLocation?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    
    var city: String?
    var cityData: String?
    var locDict = [String:Any]()
    let locationManager = CLLocationManager()
    
    func startLocationManager() {
        print("startLocMan")
        // always good habit to check if locationServicesEnabled
        if CLLocationManager.locationServicesEnabled() {
            print("startLocManIF")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            print(locationManager.location)
        }
    }
    
    func stopLocationManager() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    @IBAction func doneWithSports(_ sender: Any) {
        sportsView.isHidden = true
        
        backToCatButton.isHidden = false
        
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // if you need to get latest data you can get locations.last to check it if the device has been moved
        print("inDidUpdateLoc")
        let latestLocation = locations.last!
        
        // here check if no need to continue just return still in the same place
        if latestLocation.horizontalAccuracy < 0 {
            return
        }
        // if it location is nil or it has been moved
        if location == nil || location!.horizontalAccuracy > latestLocation.horizontalAccuracy {
            
            location = latestLocation
            // stop location manager
            //stopLocationManager()
            
            // Here is the place you want to start reverseGeocoding
            geocoder.reverseGeocodeLocation(latestLocation, completionHandler: { (placemarks, error) in
                // always good to check if no error
                // also we have to unwrap the placemark because it's optional
                // I have done all in a single if but you check them separately
                if error == nil, let placemark = placemarks, !placemark.isEmpty {
                    var curPlacemark = placemark.last
                    if let city = curPlacemark?.locality, !city.isEmpty {
                        // here you have the city name
                        // assign city name to our iVar
                        self.city = city
                        print("self.city: \(city)")
                        Database.database().reference().child("posts").observeSingleEvent(of: .value, with: {(snapshot) in
                            var tempArr = [[String:Any]]()
                            for (key, val) in (snapshot.value as! [String:Any]) {
                                let tempDict = val as! [String:Any]
                                if tempDict["city"] as! String == self.city{
                                    tempArr.append(tempDict)
                                }
                            }
                            self.popCollectData = tempArr
                            var tempData = [[String:Any]]()
                            //(dict.first?.value as! [String:Any])["postVid"]
                            for dict in self.popCollectData{
                                if (dict["postPic"] == nil && dict["postVid"] == nil){
                                    print("textBeingRemoved3")
                                    // popCollectData.remove(at: popCollectData.index(of: dict))
                                } else {
                                    tempData.append(dict)
                                }
                            }
                            print("here")
                                self.popCollectData = tempData
                            
                            
                        })
                       // DispatchQueue.main.async{
                            self.popCollect.reloadData()
                        //}
                        
                    }
                }
                // a new function where you start to parse placemarks to get the information you need
                //self.parsePlacemarks()
                
            })
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // print the error to see what went wrong
        print("didFailwithError\(error)")
        // stop location manager if failed
        stopLocationManager()
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        // Use the last reported location.
        print("lookupLoc")
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                                            completionHandler: { (placemarks, error) in
                                                if error == nil {
                                                    let firstLocation = placemarks?[0]
                                                    completionHandler(firstLocation)
                                                }
                                                else {
                                                    // An error occurred during geocoding.
                                                    completionHandler(nil)
                                                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
    

}
extension SearchViewController:PlayerDelegate {
    
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
extension SearchViewController:PlayerPlaybackDelegate {
    
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
