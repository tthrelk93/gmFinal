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


class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var backToCatButton: UIButton!
    var prevScreen = String()
    var sportsCollectData = ["Soccer","Football","Lacrosse", "Track & Field", "Tennis","Baseball","Swimming","Basketball","Rock Climbing"]
    
    @IBOutlet weak var sportsView: UIView!
    
    
    
    @IBOutlet weak var sportsCollect: UICollectionView!
    
    @IBAction func backToAllCatPressed(_ sender: Any) {
        print("thisBackB")
        
        popCollect.frame = ogPopFrame
        noPostsLabel.isHidden = true
        makeFirstPostButton.isHidden = true
        topBarCat.setTitleColor(UIColor.red, for: .normal)
        topBarPop.setTitleColor(UIColor.black, for: .normal)
        topBarNearby.setTitleColor(UIColor.black, for: .normal)
        categoriesCollect.isHidden = false
        topBarSearchButton.isHidden = false
        topBarPressed = false
        border1.isHidden = false
        border2.isHidden = true
        border3.isHidden = true
        topBarCat.isHidden = false
        topBarPop.isHidden = false
        topBarNearby.isHidden = false
        
        specCatLabel.isHidden = true
        
        discoverLabel.isHidden = false
        //singlePostTopLabel.text = "Post"
        popCollect.isHidden = true
        popCollectData.removeAll()
        //DispatchQueue.main.async{
        self.popCollect.reloadData()
        backToCatButton.isHidden = true
        sports = false
        //}
    }
    @IBOutlet weak var specCatLabel: UILabel!
    // var gmRed = UIColor(red: 180/255, green: 29/255, blue: 2/255, alpha: 1.0)
    @IBAction func backButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            //self.singlePostView3.frame = self.ogCommentPos
            print("bPress")
            self.singlePostView.isHidden = true
            //self.singlePostView.frame = self.curCellFrame
            self.singlePostImageView.image = nil
           // self.singlePostTextView.text = nil
            self.player = nil
            //self.singlePostView1.isHidden = false
           
            self.sports = false
            if self.curTopBar == "cat"{
                self.specCatLabel.isHidden = false
                print("selectedSport: \(self.selectedSport)")
                self.specCatLabel.text = self.selectedSport
                self.backToCatButton.isHidden = false
                
            } else if self.curTopBar == "pop"{
                self.specCatLabel.isHidden = true
                self.backToCatButton.isHidden = true
                
            } else {
                
            }
           /* if self.topBarCat.titleLabel?.textColor == UIColor.red{
                self.border1.isHidden = false
                 self.border2.isHidden = true
                 self.border3.isHidden = true
            } else if self.topBarPop.titleLabel?.textColor == UIColor.red{
                 self.border1.isHidden = true
            self.border2.isHidden = false
                 self.border3.isHidden = true
            } else {
                self.border1.isHidden = true
                self.border2.isHidden = true
            self.border3.isHidden = false
            }*/
            self.tabBar.isHidden = false
           // self.backToCatButton
          
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
    var curTopBar = "cat"
    @IBAction func topBarCatPressed(_ sender: Any) {
        curTopBar = "cat"
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
        curTopBar = "pop"
        self.showWaitOverlayWithText("Loading Popular Posts")
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
            DispatchQueue.main.async{
            self.popCollect.reloadData()
            self.popCollect.performBatchUpdates(nil, completion: {
                (result) in
                // ready
                //SwiftOverlays.removeAllBlockingOverlays()
                self.removeAllOverlays()
                print("doneLoading3")
            })
            }
            print("blue53: \(self.popCollectData)")
            print("x")
            self.popCollect.isHidden = false
        })
        
        
    }
    
    @IBOutlet weak var singlePostTopLine: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var topBarNearby: UIButton!
    @IBOutlet weak var commentedByButton: UIButton!
    
    @IBAction func commentedByButtonPressed(_ sender: Any) {
        //singlePostTopLabel.isHidden = true
        commentView.isHidden = false
        commentTF.resignFirstResponder()
        tabBar.isHidden = true
       // singlePostView3.isHidden = false
    }
    @IBAction func topBarNearbyPressed(_ sender: Any) {
        self.showWaitOverlayWithText("Acquiring Location")
        curTopBar = "nearby"
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
    
    @IBOutlet weak var commentTopLine: UIView!
    @IBOutlet weak var border2: UIView!
    
    @IBOutlet weak var popCollect: UICollectionView!
    @IBOutlet weak var border1: UIView!
    
    @IBOutlet weak var backToCatFromSports: UIButton!
    @IBAction func hideCommentsPressed(_ sender: Any) {
        //singlePostTopLabel.isHidden = false
        commentView.isHidden = true
        tabBar.isHidden = false
        commentTF.resignFirstResponder()
    }
    @IBOutlet weak var hideComments: UIButton!
    var ogPopFrame = CGRect()
    override func viewDidLoad() {
        super.viewDidLoad()
        posterPicButton.frame.size = CGSize(width: 40, height: 40)
        postText.delegate = self
        
        ogPopFrame = popCollect.frame
        posterPicButton.layer.cornerRadius = posterPicButton.frame.width/2
         topLine.frame = CGRect(x: topLine.frame.origin.x, y: topLine.frame.origin.y, width: topLine.frame.width, height: 0.5)
        commentTopLine.frame = CGRect(x: commentTopLine.frame.origin.x, y: commentTopLine.frame.origin.y, width: commentTopLine.frame.width, height: 0.5)
        commentViewLine.frame = CGRect(x: commentViewLine.frame.origin.x, y: commentViewLine.frame.origin.y, width: commentViewLine.frame.width, height: 0.5)
        ogCommentPos = commentView.frame
        
        singlePostTopLine.frame = CGRect(x: singlePostTopLine.frame.origin.x, y: singlePostTopLine.frame.origin.y, width: singlePostTopLine.frame.width, height: 0.5)
        
        
        commentPic.frame = CGRect(x: commentPic.frame.origin.x, y: commentPic.frame.origin.y, width: 30.0, height: 30.0)
        commentPic.layer.cornerRadius = commentPic.frame.width/2
        commentPic.layer.masksToBounds = true
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
        
        commentCollect.delegate = self
        commentCollect.dataSource = self
        
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
        commentTF.delegate = self
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        //layout.itemSize = CGSize(width: screenWidth/2.035, height: screenWidth/2.7)
        layout.itemSize = CGSize(width: screenWidth/2.3, height: screenWidth/2.3)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 15
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
            if let messageImageUrl = URL(string: self.myPicString) {
                
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    //self.myPic = UIImage(data: imageData as Data)
                    self.commentPic.image = UIImage(data: imageData as Data)
                    
                }

            }
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
            self.posterUID = Auth.auth().currentUser!.uid
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
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
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
                            let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: popCollect.frame.width - 28, height: cell.popPic.frame.height + 30)
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
                            let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: popCollect.frame.width - 28, height: cell.popPic.frame.height + 30)
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
                        let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: popCollect.frame.width - 28, height: cell.popPic.frame.height + 30)
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
                    let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: popCollect.frame.width - 28, height: cell.popPic.frame.height + 30)
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
            cell.postID = self.postID
            cell.indexPath = indexPath
            cell.posterUID = self.posterUID
            cell.myRealName = self.myName
            DispatchQueue.main.async{
                cell.commentorPic.layer.cornerRadius = cell.commentorPic.frame.width/2
                cell.commentorPic.layer.masksToBounds = true
                if ((self.commentsCollectData.first as! [String:Any])["x"] != nil){
                    
                } else {
                let nameAndComment = (self.commentsCollectData[indexPath.row]["commentorName"] as! String) + " " +  (self.commentsCollectData[indexPath.row]["commentText"] as! String)
                
                print("name&Comment: \(nameAndComment)")
                
                
                let boldNameAndComment = self.attributedText(withString: nameAndComment, boldString: (self.commentsCollectData[indexPath.row]["commentorName"] as! String), font: (cell.commentTextView.font!))
                
                print("boldName&Comment: \(boldNameAndComment)")
                cell.commentTextView.attributedText = boldNameAndComment
                    cell.commentTextView.resolveHashTags()
                    
                var tStampDateString = String()
                if self.topBarCat.titleLabel!.textColor == UIColor.red || self.topBarNearby.titleLabel!.textColor == UIColor.red {
                tStampDateString = self.curCommentCell!["datePosted"]! as! String
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
                
                
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("favorites").setValue(favesArray)
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
    var mentionID = String()
    var curName = String()
    var selectedCurAuthProfile = true
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
                        self.performSegue(withIdentifier: "SearchToProfile", sender: self)
                    }
                }
            })
        } else {
            print("hashtaggg: \(payload) database action")
            self.selectedHash = payload
            performSegue(withIdentifier: "SearchToHash", sender: self)
        }
        /*let alertView = UIAlertView()
         alertView.title = "\(tagType) tag detected"
         // get a handle on the payload
         alertView.message = "\(payload)"
         alertView.addButton(withTitle: "Ok")
         alertView.show()*/
    }
    var selectedHash = String()
    
    @IBOutlet weak var postText: UITextView!
    
    @IBOutlet weak var singlePostTopLabel: UILabel!
    
    //@IBOutlet weak var postText: UILabel!
    @IBAction func commentPressed(_ sender: Any) {
        //singlePostTopLabel.isHidden = true
        commentView.isHidden = false
        commentView.isHidden = false
        commentCollect.isHidden = false
        likesCollect.isHidden = true
       // print("commentsArray: \(commentsArray)")
        commentCollect.delegate = self
        commentCollect.dataSource = self
        
        commentTF.becomeFirstResponder()
        tabBar.isHidden = true
        //commentTF.isHidden = false
    }
    
    var postID = String()
    var posterUID = String()
    var selfData = [String:Any]()
    
    @IBOutlet weak var discoverLabel: UILabel!
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
    var selectedSport = String()
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell touched")
        
        if collectionView == sportsCollect {
            backToCatButton.isHidden = false
            let cellLabel = sportsCollectData[indexPath.row]
            specCatLabel.text = sportsCollectData[indexPath.row]
            self.selectedSport = sportsCollectData[indexPath.row]
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
 
            }
            self.popCollectData = tempData
            //print("popCollectDataAfter: \(popCollectData.count)")
           
            
            DispatchQueue.main.async{

                self.popCollect.reloadData()
            }
            self.popCollect.isHidden = false
            self.categoriesCollect.isHidden = true
            sportsView.isHidden = true
           
            
            backToCatButton.isHidden = false
            
            
        } else if collectionView == categoriesCollect{
            backToCatButton.isHidden = false
        let cellLabel = catCollectData[indexPath.row]
            specCatLabel.isHidden = false
            discoverLabel.isHidden = true
            specCatLabel.text = cellLabel
            topBarCat.isHidden = true
            topBarPop.isHidden = true
            topBarNearby.isHidden = true
        
            border1.isHidden = true
            border2.isHidden = true
            border3.isHidden = true
            self.selectedSport = catCollectData[indexPath.row]
            topBarSearchButton.isHidden = true
            
            popCollect.frame = noPostsLabel.frame
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
            
                    self.popCollect.reloadData()
            }
                
                    self.popCollect.isHidden = false
            sportsView.isHidden = true
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
            
            if curTopBar == "cat"{
            self.selfData = ((self.popCollectData[indexPath.row]).first!.value as! [String:Any])
            } else {
                self.selfData = (self.popCollectData[indexPath.row] as! [String:Any])
            }
            self.specCatLabel.isHidden = false
            self.specCatLabel.text = "Post"
             self.posterUID = (selfData["posterUID"] as! String)
            self.postID =  (selfData["postID"] as! String)
            
            if topBarCat.titleLabel?.textColor == UIColor.red || topBarNearby.titleLabel?.textColor == UIColor.red{
                
              
                var cData = [String:Any]()
                if border3.isHidden == false {
                    cData = (self.popCollectData[indexPath.row] as! [String:Any])
                    selfData = (self.popCollectData[indexPath.row] as! [String:Any])
                } else {
                    
                    cData = ((self.popCollectData[indexPath.row]).first!.value as! [String:Any])
                }
                
                
               
                
                //did select picture cell
                if selfData["postPic"] as? String != nil {
                    self.singlePostView.bringSubview(toFront: singlePostImageView)
                    if let messageImageUrl = URL(string: selfData["postPic"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            singlePostImageView.image = UIImage(data: imageData as Data)
                        }
                    }
                    if let messageImageUrl = URL(string: selfData["posterPicURL"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            posterPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                        }
                    }
                   self.likedCollectData = (selfData["likes"] as! [[String:Any]])
                   self.cityLabel.setTitle(selfData["city"] as? String, for: .normal)
                    self.posterNameButton.setTitle(selfData["posterName"] as? String, for: .normal)
                    self.curCommentCell = selfData
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in (selfData["comments"] as! [[String:Any]]){
                        
                        commentsPost = item
                        
                    }
                    var likedBySelf = false
                    for item in (selfData["likes"] as! [[String:Any]]){
                        
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
                        if (selfData["likes"] as! [[String:Any]]).count == 1{
                       var tempString = "\((selfData["likes"] as! [[String:Any]]).count) like"
                        likeButtonCount.setTitle(tempString, for: .normal)
                            
                        } else {
                            var tempString = "\((selfData["likes"] as! [[String:Any]]).count) likes"
                            likeButtonCount.setTitle(tempString, for: .normal)
                            
                        }
                        
                        if likedBySelf == true {
                            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                           
                        }
                    }
                    //set comments count
                    
                        commentsCollectData.removeAll()
                        print("showComments")
                        commentsCollectData = (selfData["comments"] as! [[String:Any]])
                    
                    DispatchQueue.main.async{
                        self.commentCollect.reloadData()
                    }
                    
                        if ((selfData["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            commentedByButton.setTitle("View 0 comments", for: .normal)
                        } else {
             
                            
                            commentsCollectData = (selfData["comments"] as! [[String:Any]])
                            if commentsCollectData.count == 1{
                                commentedByButton.setTitle("View 1 comment", for: .normal)
                            } else {
                                commentedByButton.setTitle("View \(commentsCollectData.count) comments", for: .normal)
                            }
                            
                            
                        
                        
                    }
                    var favedBySelf = false
                    for item in (selfData["favorites"] as! [[String:Any]]){
                        
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
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            
                        }
                    }
                    
                  
                } else if (selfData["postVid"] as? String != nil) {
                    //vid post//////////
                    //self.singlePostView3.frame = ogCommentPos
                    self.player = Player()
                   // self.singlePostImageView.isHidden = true
                   // textPostTV.isHidden = true
                    self.player!.view.frame = self.singlePostImageView.frame
                    player?.url = URL(string: selfData["postVid"] as! String)
                    let playTap = UITapGestureRecognizer()
                    playTap.numberOfTapsRequired = 1
                    playTap.addTarget(self, action: #selector(SearchViewController.playOrPause))
                    player?.view.addGestureRecognizer(playTap)
                    
                   
                    self.singlePostView.addSubview((self.player?.view)!)
                    let vidFrame = singlePostImageView.frame
                    self.player?.view.frame = vidFrame
                    self.player?.didMove(toParentViewController: self)
                    singlePostView.bringSubview(toFront: (player?.view)!)
                    if let messageImageUrl = URL(string: selfData["posterPicURL"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            posterPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                        }
                    }
                    self.likedCollectData = (selfData["likes"] as! [[String:Any]])
                    self.cityLabel.setTitle(selfData["city"] as? String, for: .normal)
                    self.posterNameButton.setTitle(selfData["posterName"] as? String, for: .normal)
                    self.curCommentCell = selfData
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in (selfData["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    var likedBySelf = false
                    for item in (selfData["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        if likesPost!.count == 1 && likesPost!["x"] != nil{
                            
                        } else {
                            if (likesPost!["uName"] as! String) == self.myUName{
                                likedBySelf = true
                            }
                        }
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String((selfData["likes"] as! [[String:Any]]).count), for: .normal)
                        
                        if likedBySelf == true{
                            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                            //cell.likesCountButton.setTitle((feedDataArray[indexPath.row]["likes"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    //set comments count
                    commentsCollectData.removeAll()
                    print("showComments")
                    commentsCollectData = (selfData["comments"] as! [[String:Any]])
                    
                    DispatchQueue.main.async{
                        self.commentCollect.reloadData()
                    }
                   
                    if ((selfData["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil {
                        commentedByButton.setTitle("View 0 comments", for: .normal)
                    } else {
                        
                        
                        if commentsCollectData.count == 1{
                            commentedByButton.setTitle("View 1 comment", for: .normal)
                        } else {
                            commentedByButton.setTitle("View \(commentsCollectData.count) comments", for: .normal)
                        }
                       
                       
                        
                    }
                    var favedBySelf = false
                    for item in (selfData["favorites"] as! [[String:Any]]){
                        
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
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            
                        }
                    }
                   
                } else {
                    //text post
                    //
                    self.curCommentCell = selfData
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in (selfData["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    var likedBySelf = false
                    for item in (selfData["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        if likesPost!.count == 1 && likesPost!["x"] != nil{
                            
                        } else {
                            if (likesPost!["uName"] as! String) == self.myUName{
                                likedBySelf = true
                            }
                        }
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String((selfData["likes"] as! [[String:Any]]).count), for: .normal)
                        
                        if likedBySelf == true{
                            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                            //cell.likesCountButton.setTitle((feedDataArray[indexPath.row]["likes"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    commentsCollectData.removeAll()
                    print("showComments")
                    commentsCollectData = (selfData["comments"] as! [[String:Any]])
                    
                    DispatchQueue.main.async{
                        self.commentCollect.reloadData()
                    }
                    if ((selfData["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil {
                        commentedByButton.setTitle("View 0 comments", for: .normal)
                    } else {
                        
                        commentsCollectData = (selfData["comments"] as! [[String:Any]])
                        if commentsCollectData.count == 1{
                            commentedByButton.setTitle("View 1 comment", for: .normal)
                        } else {
                            commentedByButton.setTitle("View \(commentsCollectData.count) comments", for: .normal)
                        }
                        
                    }
                    var favedBySelf = false
                    for item in (selfData["favorites"] as! [[String:Any]]){
                        
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
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            
                        }
                    }
                    
                    
                }
                
                cityLabel.setTitle((selfData["city"] as! String), for: .normal)
                if (selfData["postText"] as? String) != nil{
            
                let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]
                let attributedString = NSMutableAttributedString(string:(selfData["postText"] as! String), attributes:attrs)
                
                postText.attributedText = attributedString
                
                
                postText.resolveHashTags()
                }
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.singlePostView.isHidden = false
                    self.backToCatButton.isHidden = true
                    self.border1.isHidden = true
                    self.border2.isHidden = true
                    self.border3.isHidden = true
                    
                    self.singlePostView.frame = self.ogSinglePostViewFrame
                    
                })
                //^%%%%%%%%
            } else if topBarPop.titleLabel!.textColor == UIColor.red {
                
                print("wut wut")
                backToCatButton.isHidden = true
                 selfData = (self.popCollectData[indexPath.row] as! [String:Any])
                
        
                self.cityLabel.titleLabel!.text = ((self.popCollectData[indexPath.row]) as! [String:Any])["city"] as? String
                self.posterNameButton.setTitle(((self.popCollectData[indexPath.row]) as! [String:Any])["posterName"] as? String, for: .normal)
                
                if let messageImageUrl = URL(string: ((self.popCollectData[indexPath.row]) as! [String:Any])["posterPicURL"] as! String) {
                    
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        posterPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                    }
                }
                if((((self.popCollectData[indexPath.row]) as! [String:Any])["postText"] as? String) != nil){
                    
                    let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]
                    let attributedString = NSMutableAttributedString(string:(((self.popCollectData[indexPath.row]) as! [String:Any])["postText"] as! String), attributes:attrs)
                    
                    postText.attributedText = attributedString
                    
                    
                    postText.resolveHashTags()
                    
                }
               
                
                //did select picture cell
                if ((self.popCollectData[indexPath.row]) as! [String:Any])["postPic"] as? String != nil {
                    self.singlePostView.bringSubview(toFront: singlePostImageView)
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
                    var likedBySelf = false
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        if likesPost!.count == 1 && likesPost!["x"] != nil{
                            
                        } else {
                            if (likesPost!["uName"] as! String) == self.myUName{
                                likedBySelf = true
                            }
                        }
                        
                        
                    }
                        
                        if likesPost!["x"] != nil{
                            
                        } else {
                            if likedBySelf == true{
                                self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                                
                            }
                        }
                   
                        var likesC = ((((self.popCollectData[indexPath.row]) )["likes"] as! [[String:Any]]).count)
                        var likeString = ""
                        if likesC == 1 {
                            if (((((self.popCollectData[indexPath.row]) as! [String:Any])["likes"] as! [[String:Any]]).first as! [String:Any])["x"] != nil){
                                likeString = "0 likes"
                            } else {
                            likeString = "1 like"
                            }
                        } else {
                            likeString = "\(likesC) likes"
                        }
                        likeButtonCount.setTitle(likeString, for: .normal)
                        
                    
                    commentsCollectData.removeAll()
                    print("showComments")
                    commentsCollectData = (selfData["comments"] as! [[String:Any]])
                    
                    DispatchQueue.main.async{
                        self.commentCollect.reloadData()
                    }
                    //set comments count
                    if ((((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil {
                        var commentString = "View 0 comments"
                        commentedByButton.setTitle(commentString, for: .normal)
                    } else {
                        
                        print("showComments")
                        //self.backFromLikedByViewButton.isHidden = false
                        
                       
                            var commentString = "View \(commentsCollectData.count) comments"
                            commentedByButton.setTitle(commentString, for: .normal)
                            
                        
                        
                    }
                    var favedBySelf = false
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["favorites"] as! [[String:Any]]){
                        
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
                    singlePostView.bringSubview(toFront: (player?.view)!)
                    
                    self.curCommentCell = self.popCollectData[indexPath.row] as! [String:Any]
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    self.posterNameButton.setTitle(((self.popCollectData[indexPath.row]) as! [String:Any])["posterName"] as? String, for: .normal)
                    
                    if let messageImageUrl = URL(string: ((self.popCollectData[indexPath.row]) as! [String:Any])["posterPicURL"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            posterPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                        }
                    }
                    var likedBySelf = false
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        if likesPost!.count == 1 && likesPost!["x"] != nil{
                            
                        } else {
                            if (likesPost!["uName"] as! String) == self.myUName{
                                likedBySelf = true
                            }
                        }
                        
                        
                    }
                    if likesPost!["x"] != nil{
                        
                    } else {
                        if likedBySelf == true{
                            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                            
                        }
                    }
                    var likesC = ((((self.popCollectData[indexPath.row]) )["likes"] as! [[String:Any]]).count)
                    var likeString = ""
                    if likesC == 1 {
                        if (((((self.popCollectData[indexPath.row]) as! [String:Any])["likes"] as! [[String:Any]]).first as! [String:Any])["x"] != nil){
                            likeString = "0 likes"
                        } else {
                            likeString = "1 like"
                        }
                    } else {
                        likeString = "\(likesC) likes"
                    }
                    likeButtonCount.setTitle(likeString, for: .normal)
                    commentsCollectData.removeAll()
                    print("showComments")
                    commentsCollectData = (selfData["comments"] as! [[String:Any]])
                    
                    DispatchQueue.main.async{
                        self.commentCollect.reloadData()
                    }
                    //set comments count
                    if ((((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil {
                        var commentString = "View 0 comments"
                        commentedByButton.setTitle(commentString, for: .normal)
                    } else {
                        
                        print("showComments")
                        //self.backFromLikedByViewButton.isHidden = false
                        
                        //self.commentTF.isHidden = false
                        
                        //self.topLabel.text = "Comments"
                        
                        
                        
                        
                        commentsCollectData = (((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]])
                        var commentString = "View \(commentsCollectData.count) comments"
                        commentedByButton.setTitle(commentString, for: .normal)
                        
                        //DispatchQueue.main.async {
                        
                        
                       
                        
                    }
                    var favedBySelf = false
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["favorites"] as! [[String:Any]]){
                        
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
                    if ((self.popCollectData[indexPath.row]) )["comments"] != nil {
                        for item in (((self.popCollectData[indexPath.row]) )["comments"] as! [[String:Any]]){
                        
                        commentsPost = item
                        
                    }
                    }
                    self.posterNameButton.setTitle(((self.popCollectData[indexPath.row]) )["posterName"] as? String, for: .normal)
                    self.cityLabel.setTitle((selfData["city"] as! String), for: .normal)
                    
                    if let messageImageUrl = URL(string: ((self.popCollectData[indexPath.row]) )["posterPicURL"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            posterPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                        }
                    }
                    var likedBySelf = false
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        if likesPost!.count == 1 && likesPost!["x"] != nil{
                            
                        } else {
                            if (likesPost!["uName"] as! String) == self.myUName{
                                likedBySelf = true
                            }
                        }
                        
                        
                    }
                    if likesPost!["x"] != nil{
                        
                    } else {
                        if likedBySelf == true{
                            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                            
                        }
                    }
                    
                    var likesC = ((((self.popCollectData[indexPath.row]) )["likes"] as! [[String:Any]]).count)
                    var likeString = ""
                    if likesC == 1 {
                        if (((((self.popCollectData[indexPath.row]) as! [String:Any])["likes"] as! [[String:Any]]).first as! [String:Any])["x"] != nil){
                            likeString = "0 likes"
                        } else {
                            likeString = "1 like"
                        }
                    } else {
                        likeString = "\(likesC) likes"
                    }
                    likeButtonCount.setTitle(likeString, for: .normal)
                    commentsCollectData.removeAll()
                    print("showComments")
                    commentsCollectData = (selfData["comments"] as! [[String:Any]])
                    
                    DispatchQueue.main.async{
                        self.commentCollect.reloadData()
                    }
                    //set comments count
                    if ((((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil {
                        var commentString = "View 0 comments"
                        commentedByButton.setTitle(commentString, for: .normal)
                    } else {
                        
                        commentsCollectData = (((self.popCollectData[indexPath.row]) as! [String:Any])["comments"] as! [[String:Any]])
                        var commentString = "View \(commentsCollectData.count) comments"
                        commentedByButton.setTitle(commentString, for: .normal)
                        
                    }
                    var favedBySelf = false
                    for item in (((self.popCollectData[indexPath.row]) as! [String:Any])["favorites"] as! [[String:Any]]){
                        
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
                        if favedBySelf == true {
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            
                        }
                    }
                  
                }
               
                UIView.animate(withDuration: 0.5, animations: {
                    self.singlePostView.isHidden = false
                    self.singlePostView.frame = self.ogSinglePostViewFrame
                    if self.topBarCat.titleLabel?.textColor == UIColor.red{
                        self.border1.isHidden = false
                        self.border2.isHidden = true
                        self.border3.isHidden = true
                    } else if self.topBarPop.titleLabel?.textColor == UIColor.red{
                        self.border1.isHidden = true
                        self.border2.isHidden = false
                        self.border3.isHidden = true
                    } else {
                        self.border1.isHidden = true
                        self.border2.isHidden = true
                        self.border3.isHidden = false
                    }
                    self.backToCatButton.isHidden = true
                    
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
    @IBOutlet weak var commentTF: UITextField!
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
    
    @IBOutlet weak var commentViewLine: UIView!
    @IBOutlet weak var topLine: UIView!
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    var toMention = false
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SearchToHash"{
            if let vc = segue.destination as? HashTagViewController{
                vc.prevScreen = "search"
                vc.hashtag = self.selectedHash
            }
        }
        if segue.identifier == "SearchToFeed"{
            if let vc = segue.destination as? HomeFeedViewController{
                vc.prevScreen = "search"
            }
            
        }
        
        if segue.identifier == "SearchToProfile"{
            if let vc = segue.destination as? ProfileViewController{
                vc.prevScreen = "search"
                if toMention == true{
                    vc.curUID = self.mentionID
                } else {
                    vc.curUID = self.posterUID
                }
                vc.prevScreen = "search"
                
                if selectedCurAuthProfile == true{
                    vc.viewerIsCurAuth = true
                    
                } else {
                    vc.viewerIsCurAuth = false
                }
                vc.curName = self.curName
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
    
   /* public func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }// became first responder*/
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
        showHashTag(tagType: tagType, payload: payload, postID: self.postID, name: (self.posterNameButton.titleLabel?.text)!)
    }
    
    @IBOutlet weak var commentTFView: UIView!
    var curCommentCell: [String:Any]?
    
    @IBAction func commentFieldEntered(_ sender: Any) {
        //commentBlockTopBar.isHidden = false
    }
    
    @IBOutlet weak var commentBlockTopBar: UIView!
    
    @IBOutlet weak var dumbCommentsLabel: UILabel!
    @IBAction func editingDidEnd(_ sender: Any) {
        print("tfe")
        commentBlockTopBar.isHidden = true
        dumbCommentsLabel.isHidden = true
        
    }
    @IBOutlet weak var commentPic: UIImageView!
    @IBOutlet weak var postCommentButton: UIButton!
    @IBAction func editingDidBegin(_ sender: Any) {
        print("tfb")
        
        commentBlockTopBar.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            
            self.dumbCommentsLabel.isHidden = false
        }
    }
    @IBOutlet weak var backFromCommentsButton: UIButton!
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        commentTFView.layer.zPosition = .greatestFiniteMagnitude
        print("heyg: \(height)")
       // inboxButton.frame = CGRect(x: inboxButton.frame.origin.x, y: inboxButton.frame.origin.y + height, width: inboxButton.frame.width, height: inboxButton.frame.height)
        
        //logoWords.frame = CGRect(x: logoWords.frame.origin.x, y: logoWords.frame.origin.y + height, width: logoWords.frame.width, height: logoWords.frame.height)
        backFromCommentsButton.frame = CGRect(x: backFromCommentsButton.frame.origin.x, y: backFromCommentsButton.frame.origin.y + height, width: backFromCommentsButton.frame.width, height: backFromCommentsButton.frame.height)
        
        commentCollect.frame = CGRect(x: commentCollect.frame.origin.x, y: commentCollect.frame.origin.y + height, width: commentCollect.frame.width, height: commentCollect.frame.height)
        print("balls")
        
        
    }// became first responder
    var height = UIScreen.main.bounds.height/2.15
    @IBOutlet weak var bottomLineView: UIView!
    public func textFieldDidEndEditing(_ textField: UITextField){
        //add comment to post
        print("hereyyy")
        
        //inboxButton.frame = CGRect(x: inboxButton.frame.origin.x, y: inboxButton.frame.origin.y - height, width: inboxButton.frame.width, height: inboxButton.frame.height)
        
       // logoWords.frame = CGRect(x: logoWords.frame.origin.x, y: logoWords.frame.origin.y - height, width: logoWords.frame.width, height: logoWords.frame.height)
         backFromCommentsButton.frame = CGRect(x:  backFromCommentsButton.frame.origin.x, y:  backFromCommentsButton.frame.origin.y - height, width:  backFromCommentsButton.frame.width, height:  backFromCommentsButton.frame.height)
        
        commentCollect.frame = CGRect(x: commentCollect.frame.origin.x, y: commentCollect.frame.origin.y - height, width: commentCollect.frame.width, height: commentCollect.frame.height)
        
    } // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        print("return text")
        return false
    }
    
    @IBAction func postCommentPressed(_ sender: Any) {
        var textField = commentTF
        
        if textField!.text == "" || textField?.hasText == false {
            
        } else {
            var cellTypeTemp = String()
            var posterID = String()
            //if self.cellType == "pic"{
                cellTypeTemp = selfData["postID"] as! String
                posterID = selfData["posterUID"] as! String
            
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
                        
                        var tempDict = (["actionByUID": Auth.auth().currentUser!.uid,"postID": self.postID, "actionByUserPic": self.myPicString,"actionByUsername": self.myUName,"actionText": tempString,"postText": "postText", "timeStamp": dateString] as! [String : Any])
                        
                        print("commentNote: \(tempDict)")
                        Database.database().reference().child("users").child(posterID).updateChildValues((["notifications": [tempDict]] as! [String:Any]))
                        
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
                        Database.database().reference().child("users").child(posterID).updateChildValues((["notifications": tempNotifs] as! [String:Any]))
                        
                        
                    }
               
                    self.commentTF.text = nil
                    
                   
                        
                        
                        let commStringNum = String(commentsArray.count)
                        var commString = String()
                        if commStringNum == "1"{
                            commString = "View \(commStringNum) comment"
                        } else {
                            commString = "View \(commStringNum) comments"
                        }
                        self.commentedByButton.setTitle(commString, for: .normal)
                    
                    
                    //reload collect in delegate
                    self.commentsCollectData = commentsArray
                    if commentsArray.count == 1 {
                        DispatchQueue.main.async{
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            self.commentCollect.reloadData()
                            
                        }
                        
                    } else {
                        
                        print("reloading here")
                        var count = 0
                       
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
                                                    //self.feedImageArray.append(pic as! UIImage)
                                                    //self.feedVidArray.append(URL(string: "x")!)
                                                    
                                                    
                                                }
                                            }
                                        } else {
                                            //vid
                                            
                                            tempDict["postVid"] = URL(string: tempDict["postVid"] as! String)!
                                            
                                        }
                                    }
                                    self.selfData = tempDict
                                    DispatchQueue.main.async{
                                        
                                        self.commentCollect.reloadData()
                                    }
                                    
                                })
                        
                    }
                    
                })
            })
        }
        self.view.endEditing(true)
    }
    
    
    
    /*public func textFieldDidEndEditing(_ textField: UITextField){
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
    } // may be called if*/
    
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
        
        backToCatButton.isHidden = true
        border1.isHidden = false
        border2.isHidden = true
        border3.isHidden = true
        topBarCat.isHidden = false
        topBarPop.isHidden = false
        topBarNearby.isHidden = false
        
        specCatLabel.isHidden = true
        
        discoverLabel.isHidden = false
        
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // if you need to get latest data you can get locations.last to check it if the device has been moved
        print("inDidUpdateLoc")
        let latestLocation = locations.last!
        
        // here check if no need to continue just return still in the same place
        if latestLocation.horizontalAccuracy < 0 {
            print("firstif: \(latestLocation)")
            return
        }
        // if it location is nil or it has been moved
        if location == nil || location!.horizontalAccuracy > latestLocation.horizontalAccuracy {
            print("secondif: \(location)")
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
                            
                       DispatchQueue.main.async{
                        
                            self.popCollect.reloadData()
                        self.popCollect.performBatchUpdates(nil, completion: {
                            (result) in
                            // ready
                            SwiftOverlays.removeAllOverlaysFromView(self.view)
                            SwiftOverlays.removeAllBlockingOverlays()
                            self.removeAllOverlays()
                            
                            self.stopLocationManager()
                            print("doneLoading3")
                        })
                        }
                        })
                    }
                } else {
                    print("inLastElsePlaceMark:\(self.placemark), error: \(error?.localizedDescription)")
                }
            })
        } else {
            print("inSecondElse")
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
                            
                            DispatchQueue.main.async{
                                
                                self.popCollect.reloadData()
                                self.popCollect.performBatchUpdates(nil, completion: {
                                    (result) in
                                    // ready
                                    SwiftOverlays.removeAllOverlaysFromView(self.view)
                                    SwiftOverlays.removeAllBlockingOverlays()
                                    self.removeAllOverlays()
                                    
                                    self.stopLocationManager()
                                    print("doneLoading3")
                                })
                            }
                        })
                    }
                } else {
                    print("inLastElsePlaceMark:\(self.placemark), error: \(error?.localizedDescription)")
                }
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
