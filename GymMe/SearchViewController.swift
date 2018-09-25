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



class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var backToCatButton: UIButton!
    
    @IBAction func backToAllCatPressed(_ sender: Any) {
        topBarCat.setTitleColor(gmRed, for: .normal)
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
        //}
    }
    var gmRed = UIColor(red: 180/255, green: 29/255, blue: 2/255, alpha: 1.0)
    @IBAction func backButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.singlePostView3.frame = self.ogCommentPos
            self.singlePostView.isHidden = true
            self.singlePostView.frame = self.curCellFrame
            self.singlePostImageView.image = nil
            self.singlePostTextView.text = nil
            self.player = nil
            self.singlePostView1.isHidden = false
           self.backToCatButton.isHidden = false
          
        })
       
    }
    @IBOutlet weak var singlePostView1: UIView!
    @IBOutlet weak var singlePostView2: UIView!
    @IBOutlet weak var singlePostView3: UIView!
    @IBOutlet weak var singlePostTextView: UITextView!
    @IBOutlet weak var singlePostImageView: UIImageView!
    @IBOutlet weak var singlePostView: UIView!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var categoriesCollect: UICollectionView!
    @IBAction func topBarSearchPressed(_ sender: Any) {
    }
    @IBOutlet weak var topBarSearchButton: UIButton!
    
    @IBOutlet weak var topBarCat: UIButton!
    
    @IBAction func topBarCatPressed(_ sender: Any) {
        topBarCat.setTitleColor(gmRed, for: .normal)
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
        topBarPop.setTitleColor(gmRed, for: .normal)
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
            var count = 0
            for dict in popCollectData{
                if (dict["postPic"] == nil && dict["postVid"] == nil){
                    print("textBeingRemoved")
                    popCollectData.remove(at: count)
                }
                count = count + 1
            }
            self.popCollect.reloadData()
            print("blue53: \(self.popCollectData)")
            print("x")
            self.popCollect.isHidden = false
        })
        
        
    }
    
    @IBOutlet weak var topBarNearby: UIButton!
    
    @IBAction func topBarNearbyPressed(_ sender: Any) {
        topBarCat.setTitleColor(UIColor.black, for: .normal)
        topBarPop.setTitleColor(UIColor.black, for: .normal)
        topBarNearby.setTitleColor(gmRed, for: .normal)
        categoriesCollect.isHidden = true
        border1.isHidden = true
        border2.isHidden = true
        border3.isHidden = false
        popCollect.isHidden = false
        topBarPressed = false
        locationManager.delegate = self
        startLocationManager()
        
    }
    var catCollectPics = ["bodybuilding-motivation-tips-part-2","dd3c303d81d5301e3c427f897bf5bd2e","thumb-1920-426586","bodybuilding-motivation-tips-part-2", "images-1", "images","thumb-1920-426586","bodybuilding-motivation-tips-part-2"]
    var catCollectData = ["Arms","Chest","Abs","Legs","Back", "Shoulders","Other"]
     //let border = CALayer()
     //let border2 = CALayer()
     //let border3 = CALayer()
    @IBOutlet weak var border3: UIView!
    
    @IBOutlet weak var border2: UIView!
    
    @IBOutlet weak var popCollect: UICollectionView!
    @IBOutlet weak var border1: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ogCommentPos = singlePostView3.frame
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        self.commentCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
       ogSinglePostViewFrame = singlePostView.frame
        
        
        self.popCollect.register(UINib(nibName: "PopCell", bundle: nil), forCellWithReuseIdentifier: "PopCell")
       
        border1.isHidden = false
        border2.isHidden = true
        border3.isHidden = true
        
        tabBar.delegate = self
        categoriesCollect.delegate = self
        categoriesCollect.dataSource = self
        
        popCollect.delegate = self
        popCollect.dataSource = self
        typeCommentTF.delegate = self
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        layout.itemSize = CGSize(width: screenWidth/2.035, height: screenWidth/2.035)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 1
        categoriesCollect!.collectionViewLayout = layout
        
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout2.sectionInset = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        layout2.itemSize = CGSize(width: screenWidth/3.045, height: screenWidth/3.045)
        layout2.minimumInteritemSpacing = 0
        layout2.minimumLineSpacing = 1
        popCollect!.collectionViewLayout = layout2
        popCollect.isHidden = true
        
        tabBar.selectedItem = tabBar.items?[1]
        topBarCat.setTitleColor(gmRed, for: .normal)
        topBarPop.setTitleColor(UIColor.black, for: .normal)
        topBarNearby.setTitleColor(UIColor.black, for: .normal)
        categoriesCollect.isHidden = false
        loadPopData()

        // Do any additional setup after loading the view.
    }
    var myPicString = String()
    var keys = [String]()
    var myName = String()
    
    func loadPopData(){
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: {(snapshot) in
            var snapDict = snapshot.value as! [String:Any]
            self.myName = snapDict["username"] as! String
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollect{
            return catCollectData.count
        } else if collectionView == popCollect {
            return popCollectData.count
        } else {
            return commentsCollectData.count
        }
    }
    var topBarPressed = false
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("hey345345")
        if collectionView == categoriesCollect{
        
        let cell : UICollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "CatCell", for: indexPath) as! CatCell)
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        (cell as! CatCell).catCellLabel.text = catCollectData[indexPath.row]
        (cell as! CatCell).catCellImageView.image = UIImage(named: catCollectPics[indexPath.row])
        
        
            return cell
        } else if collectionView == popCollect {
            let cell : PopCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "PopCell", for: indexPath) as! PopCell)
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.cgColor
            if topBarCat.titleLabel?.textColor == self.gmRed{
                
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
                            cell.player?.url = URL(string: String(describing: ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postVid"]!))
                            cell.player?.playerDelegate = self
                            cell.player?.playbackDelegate = self
                            cell.player?.playbackLoops = true
                            cell.player?.playbackPausesWhenBackgrounded = true
                            cell.player?.playbackPausesWhenResigningActive = true
                            let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: popCollect.frame.width - 28, height: cell.popPic.frame.height)
                            cell.player?.view.frame = vidFrame
                            cell.player?.view.isHidden = false
                            cell.player?.didMove(toParentViewController: self)
                            //cell.player?.url = cell.videoUrl
                            cell.player?.playbackLoops = true
                        }
                    } else {
                        if let messageImageUrl = URL(string: ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postPic"] as! String) {
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                cell.popPic.image = UIImage(data: imageData as Data)
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
                            cell.player?.url = URL(string: String(describing: ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postVid"]!))
                            cell.player?.playerDelegate = self
                            cell.player?.playbackDelegate = self
                            cell.player?.playbackLoops = true
                            cell.player?.playbackPausesWhenBackgrounded = true
                            cell.player?.playbackPausesWhenResigningActive = true
                            let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: popCollect.frame.width - 28, height: cell.popPic.frame.height)
                            cell.player?.view.frame = vidFrame
                            cell.player?.view.isHidden = false
                            cell.player?.didMove(toParentViewController: self)
                            cell.player?.playbackLoops = true
                        }
                    } else {
                        cell.popText.textColor = UIColor.white
                        if let messageImageUrl = URL(string: ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postPic"] as! String) {
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                cell.popPic.image = UIImage(data: imageData as Data)
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
                        cell.popPic.image = UIImage(named: "background2")
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            cell.popText.text = String(describing: ((self.popCollectData[indexPath.row])["postText"]!))
                            cell.player?.view.isHidden = true
                            cell.bringSubview(toFront: cell.popText)
                        })
                    } else {
                        cell.popPic.isHidden = true
                        cell.player?.url = URL(string: String(describing: (popCollectData[indexPath.row])["postVid"]!))
                        cell.player?.playerDelegate = self
                        cell.player?.playbackDelegate = self
                        cell.player?.playbackLoops = true
                        cell.player?.playbackPausesWhenBackgrounded = true
                        cell.player?.playbackPausesWhenResigningActive = true
                        let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: popCollect.frame.width - 28, height: cell.popPic.frame.height)
                        cell.player?.view.frame = vidFrame
                        cell.player?.view.isHidden = false
                        cell.player?.didMove(toParentViewController: self)
                        //cell.player?.url = cell.videoUrl
                        cell.player?.playbackLoops = true
                    }
                } else {
                    if let messageImageUrl = URL(string: self.popCollectData[indexPath.row]["postPic"] as! String) {
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            cell.popPic.image = UIImage(data: imageData as Data)
                        }
                    }
                }
                return cell
            } else {
            if (self.popCollectData[indexPath.row])["postPic"] == nil {
                if (self.popCollectData[indexPath.row])["postVid"] == nil{
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.popText.isHidden = false
                        cell.popText.text = (String(describing: ((self.popCollectData[indexPath.row]))["postText"]!))
                        cell.player?.view.isHidden = true
                        cell.bringSubview(toFront: cell.popText)
                    })
                } else {
                    cell.popText.textColor = UIColor.white
                    cell.popPic.isHidden = true
                    cell.player?.url = URL(string: String(describing: (popCollectData[indexPath.row])["postVid"]!))
                    cell.player?.playerDelegate = self
                    cell.player?.playbackDelegate = self
                    cell.player?.playbackLoops = true
                    cell.player?.playbackPausesWhenBackgrounded = true
                    cell.player?.playbackPausesWhenResigningActive = true
                    let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: popCollect.frame.width - 28, height: cell.popPic.frame.height)
                    cell.player?.view.frame = vidFrame
                    cell.player?.view.isHidden = false
                    cell.player?.didMove(toParentViewController: self)
                    cell.player?.playbackLoops = true
                }
            } else {
                cell.popText.textColor = UIColor.white
                if let messageImageUrl = URL(string: (self.popCollectData[indexPath.row])["postPic"] as! String) {
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    cell.popPic.image = UIImage(data: imageData as Data)
                    }
                }
                }
                }
            }
                
            return cell
        
        } else {
                let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
            cell.backgroundColor = UIColor.clear
            cell.commentName.textColor = UIColor.white
            cell.commentTextView.textColor = UIColor.white
            cell.commentTimestamp.textColor = UIColor.white
                cell.likedByName.isHidden = true
                cell.likedByUName.isHidden = true
                cell.likedByFollowButton.isHidden = true
                cell.commentName.isHidden = false
                cell.commentTextView.isHidden = false
                cell.commentTimestamp.isHidden = false
            cell.commentTextView.text = commentsCollectData[indexPath.row]["commentText"] as! String
            cell.commentName.text = commentsCollectData[indexPath.row]["commentorName"] as! String
            if commentsCollectData[indexPath.row]["commentorPic"] as! String == "profile-placeholder"{
                    cell.likedByImage.image = UIImage(named: "profile-placeholder")
                } else {
                    if let messageImageUrl = URL(string: commentsCollectData[indexPath.row]["commentorPic"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            cell.likedByImage.image = UIImage(data: imageData as Data)
                        }
                    }
                }
                return cell
        }
            
    }
   // @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var favoritesCount: UIButton!
    var commentsCollectData = [[String:Any]]()
    @IBOutlet weak var commentCollect: UICollectionView!
    @IBAction func shareButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var shareButton: UIButton!
    @IBAction func favoritesButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var favoritesButton: UIButton!
    //@IBAction func commentPressed(_ sender: Any) {
    //}
    
    //@IBOutlet weak var commentCount: UIButton!
    @IBOutlet weak var likeButtonCount: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction func likeButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var textPostTV: UITextView!
    var player: Player?
    var selectedCat = String()
    var allCatDataDict = [String:[[String:Any]]]()
    var ogSinglePostViewFrame = CGRect()
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell touched")
        
        if collectionView == categoriesCollect{
            backToCatButton.isHidden = false
        let cellLabel = catCollectData[indexPath.row]
            if allCatDataDict[cellLabel] == nil {
                self.allCatDataDict[cellLabel] = [[String:Any]]()
            }
            self.popCollectData = self.allCatDataDict[cellLabel]!
            var count = 0
            for dict in popCollectData{
                if (dict["postPic"] == nil && dict["postVid"] == nil){
                    print("textBeingRemoved")
                    popCollectData.remove(at: count)
                }
                count = count + 1
            }
           
            DispatchQueue.main.async{
                    self.popCollect.reloadData()
            }
                    self.popCollect.isHidden = false
                    self.categoriesCollect.isHidden = true
           

        } else if collectionView == popCollect{
            
            
            if topBarCat.titleLabel?.textColor == self.gmRed{
                backToCatButton.isHidden = true
                
                let cellLabel = catCollectData[indexPath.row]
                if allCatDataDict[cellLabel] == nil {
                    self.allCatDataDict[cellLabel] = [[String:Any]]()
                }
                //print("selectedData for \(cellLabel): \(self.popCollectData[indexPath.row])")
                //show single post view
                singlePostView.frame = (popCollect.visibleCells[indexPath.row] as! PopCell).frame
                self.curCellFrame = (popCollect.visibleCells[indexPath.row] as! PopCell).frame
                
                //did select picture cell
                if ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postPic"] as? String != nil {
                    if let messageImageUrl = URL(string: ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postPic"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            singlePostImageView.image = UIImage(data: imageData as Data)
                        }
                    }
                    
                    self.curCommentCell = self.popCollectData[indexPath.row]
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    for item in (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String((((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["likes"] as! [[String:Any]]).count), for: .normal)
                        
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
                        
                        if ((((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            
                            
                            
                        } else {
                            
                            
                            
                            commentsCollectData = (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["comments"] as! [[String:Any]])
                            
                            //DispatchQueue.main.async {
                            
                            
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            DispatchQueue.main.async{
                                self.commentCollect.reloadData()
                            }
                        }
                        
                        
                    }
                    
                    for item in (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["favorites"] as! [[String:Any]]){
                        
                        favesPost = item as! [String: Any]
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        
                        
                        if (favesPost!["uName"] as! String) == self.myName{
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            favoritesCount.setTitle((((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["favorites"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    
                    textPostTV.isHidden = true
                    singlePostView2.isHidden = false
                } else if (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postVid"] as? String != nil) {
                    //vid post//////////
                    //self.singlePostView3.frame = ogCommentPos
                    self.player = Player()
                    textPostTV.isHidden = true
                    player?.url = URL(string:((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postVid"] as! String)
                    let playTap = UITapGestureRecognizer()
                    playTap.numberOfTapsRequired = 1
                    playTap.addTarget(self, action: #selector(SearchViewController.playOrPause))
                    player?.view.addGestureRecognizer(playTap)
                    
                    let vidFrame = CGRect(x: singlePostView1.frame.origin.x, y: singlePostView1.frame.origin.y, width: self.ogSinglePostViewFrame.width - 20, height: self.ogSinglePostViewFrame.height/2)
                    self.player?.view.frame = vidFrame
                    self.singlePostView1.addSubview((self.player?.view)!)
                    self.player?.didMove(toParentViewController: self)
                    singlePostView1.sendSubview(toBack: (player?.view)!)
                    
                    self.curCommentCell = self.popCollectData[indexPath.row].first?.value as! [String:Any]
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    for item in (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String((((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["likes"] as! [[String:Any]]).count), for: .normal)
                        
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
                        if ((((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            
                            
                            
                        } else {
                            
                            
                            
                            commentsCollectData = (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["comments"] as! [[String:Any]])
                            
                            //DispatchQueue.main.async {
                            
                            
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            DispatchQueue.main.async{
                                self.commentCollect.reloadData()
                            }
                        }
                        
                    }
                    
                    for item in (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["favorites"] as! [[String:Any]]){
                        
                        favesPost = item as! [String: Any]
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        
                        
                        if (favesPost!["uName"] as! String) == self.myName{
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            favoritesCount.setTitle((((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["favorites"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    
                    textPostTV.isHidden = true
                    singlePostView2.isHidden = false
                } else {
                    //text post
                    self.curCommentCell = ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    for item in (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String((((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["likes"] as! [[String:Any]]).count), for: .normal)
                        
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
                        if ((((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            
                            
                            
                        } else {
                            
                            
                            
                            commentsCollectData = (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["comments"] as! [[String:Any]])
                            
                            //DispatchQueue.main.async {
                            
                            
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            DispatchQueue.main.async{
                                self.commentCollect.reloadData()
                            }
                        }
                    }
                    
                    for item in (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["favorites"] as! [[String:Any]]){
                        
                        favesPost = item as! [String: Any]
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        if (favesPost!["uName"] as! String) == self.myName{
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            favoritesCount.setTitle((((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["favorites"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    textPostTV.isHidden = false
                    singlePostView2.isHidden = true
                    UIView.animate(withDuration: 0.5, animations: {
                        self.singlePostView3.frame = self.textPostOnlyCommentsPost.frame
                    })
                }
                textPostTV.text = (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postText"] as! String)
                singlePostTextView.text = (((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postText"] as! String)
                UIView.animate(withDuration: 0.5, animations: {
                    self.singlePostView.isHidden = false
                    self.singlePostView.frame = self.ogSinglePostViewFrame
                    
                })
                //^%%%%%%%%
            } else {
                backToCatButton.isHidden = true
                
                let cellLabel = catCollectData[indexPath.row]
                if allCatDataDict[cellLabel] == nil {
                    self.allCatDataDict[cellLabel] = [[String:Any]]()
                }
                //print("selectedData for \(cellLabel): \(self.popCollectData[indexPath.row])")
                //show single post view
                singlePostView.frame = (popCollect.visibleCells[indexPath.row] as! PopCell).frame
                self.curCellFrame = (popCollect.visibleCells[indexPath.row] as! PopCell).frame
                
                //did select picture cell
                if (self.popCollectData[indexPath.row])["postPic"] as? String != nil {
                    if let messageImageUrl = URL(string: (self.popCollectData[indexPath.row])["postPic"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            singlePostImageView.image = UIImage(data: imageData as Data)
                        }
                    }
                    
                    self.curCommentCell = self.popCollectData[indexPath.row]
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in ((self.popCollectData[indexPath.row])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    for item in ((self.popCollectData[indexPath.row])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String(((self.popCollectData[indexPath.row])["likes"] as! [[String:Any]]).count), for: .normal)
                        
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
                        if (((self.popCollectData[indexPath.row])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            
                            
                            
                        } else {
                            
                            
                            
                            commentsCollectData = ((self.popCollectData[indexPath.row])["comments"] as! [[String:Any]])
                            
                            //DispatchQueue.main.async {
                            
                            
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            DispatchQueue.main.async{
                                self.commentCollect.reloadData()
                            }
                        }
                        
                        
                    }
                    
                    for item in ((self.popCollectData[indexPath.row])["favorites"] as! [[String:Any]]){
                        
                        favesPost = item as! [String: Any]
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        
                        
                        if (favesPost!["uName"] as! String) == self.myName{
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            favoritesCount.setTitle(((self.popCollectData[indexPath.row])["favorites"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    
                    textPostTV.isHidden = true
                    singlePostView2.isHidden = false
                } else if ((self.popCollectData[indexPath.row])["postVid"] as? String != nil) {
                    //vid post//////////
                    //self.singlePostView3.frame = ogCommentPos
                    self.player = Player()
                    textPostTV.isHidden = true
                    player?.url = URL(string:(self.popCollectData[indexPath.row])["postVid"] as! String)
                    let playTap = UITapGestureRecognizer()
                    playTap.numberOfTapsRequired = 1
                    playTap.addTarget(self, action: #selector(SearchViewController.playOrPause))
                    player?.view.addGestureRecognizer(playTap)
                    
                    let vidFrame = CGRect(x: singlePostView1.frame.origin.x, y: singlePostView1.frame.origin.y, width: self.ogSinglePostViewFrame.width - 20, height: self.ogSinglePostViewFrame.height/2)
                    self.player?.view.frame = vidFrame
                    self.singlePostView1.addSubview((self.player?.view)!)
                    self.player?.didMove(toParentViewController: self)
                    singlePostView1.sendSubview(toBack: (player?.view)!)
                    
                    self.curCommentCell = self.popCollectData[indexPath.row]
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in ((self.popCollectData[indexPath.row])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    for item in ((self.popCollectData[indexPath.row])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String(((self.popCollectData[indexPath.row])["likes"] as! [[String:Any]]).count), for: .normal)
                        
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
                        if (((self.popCollectData[indexPath.row])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            
                            
                            
                        } else {
                            
                            
                            
                            commentsCollectData = ((self.popCollectData[indexPath.row])["comments"] as! [[String:Any]])
                            
                            //DispatchQueue.main.async {
                            
                            
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            DispatchQueue.main.async{
                                self.commentCollect.reloadData()
                            }
                        }
                        
                    }
                    
                    for item in ((self.popCollectData[indexPath.row])["favorites"] as! [[String:Any]]){
                        
                        favesPost = item as! [String: Any]
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        
                        
                        if (favesPost!["uName"] as! String) == self.myName{
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            favoritesCount.setTitle(((self.popCollectData[indexPath.row])["favorites"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    
                    textPostTV.isHidden = true
                    singlePostView2.isHidden = false
                } else {
                    //text post
                    self.curCommentCell = (self.popCollectData[indexPath.row])
                    var likesPost: [String:Any]?
                    var favesPost: [String:Any]?
                    var commentsPost: [String:Any]?
                    for item in ((self.popCollectData[indexPath.row])["comments"] as! [[String:Any]]){
                        
                        commentsPost = item as! [String: Any]
                        
                    }
                    for item in ((self.popCollectData[indexPath.row])["likes"] as! [[String:Any]]){
                        
                        likesPost = item as! [String: Any]
                        
                    }
                    if likesPost!["x"] != nil {
                        
                    } else {
                        
                        likeButtonCount.setTitle(String(((self.popCollectData[indexPath.row])["likes"] as! [[String:Any]]).count), for: .normal)
                        
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
                        if (((self.popCollectData[indexPath.row])["comments"] as! [[String:Any]]).first as! [String:Any])["x"] != nil{
                            
                            
                            
                        } else {
                            
                            
                            
                            commentsCollectData = ((self.popCollectData[indexPath.row])["comments"] as! [[String:Any]])
                            
                            //DispatchQueue.main.async {
                            
                            
                            self.commentCollect.delegate = self
                            self.commentCollect.dataSource = self
                            DispatchQueue.main.async{
                                self.commentCollect.reloadData()
                            }
                        }
                    }
                    
                    for item in ((self.popCollectData[indexPath.row])["favorites"] as! [[String:Any]]){
                        
                        favesPost = item as! [String: Any]
                        
                    }
                    if favesPost!["x"] != nil {
                        
                    } else {
                        if (favesPost!["uName"] as! String) == self.myName{
                            favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                            favoritesCount.setTitle(((self.popCollectData[indexPath.row])["favorites"] as! [[String:Any]]).count.description, for: .normal)
                        }
                    }
                    textPostTV.isHidden = false
                    singlePostView2.isHidden = true
                    UIView.animate(withDuration: 0.5, animations: {
                        self.singlePostView3.frame = self.textPostOnlyCommentsPost.frame
                    })
                }
                textPostTV.text = ((self.popCollectData[indexPath.row])["postText"] as! String)
                singlePostTextView.text = ((self.popCollectData[indexPath.row])["postText"] as! String)
                UIView.animate(withDuration: 0.5, animations: {
                    self.singlePostView.isHidden = false
                    self.singlePostView.frame = self.ogSinglePostViewFrame
                    
                })
            }
            }
           
        
    }
    
    var ogTextPos = CGRect()
    var ogCommentPos = CGRect()
    
    @IBOutlet weak var textPostOnlyCommentsPost: UIView!
    @IBOutlet weak var textPostOnlyView: UIView!
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }// became first responder
    
    var curCommentCell: [String:Any]?
    public func textFieldDidEndEditing(_ textField: UITextField){
        //add comment to post
        Database.database().reference().child("posts").child((curCommentCell?["postID"]!) as! String).observeSingleEvent(of: .value, with: { snapshot in
            let valDict = snapshot.value as! [String:Any]
            
            var commentsArray = valDict["comments"] as! [[String:Any]]
            if commentsArray.count == 1 && (commentsArray.first! as! [String:String]) == ["x": "x"]{
                commentsArray.remove(at: 0)
            }
            var commentsVal = commentsArray.count
            commentsVal = commentsVal + 1
            if self.myPicString == nil{
                self.myPicString = "profile-placeholder"
            }
            //add current users id and uName to comment object and upload to database
            commentsArray.append(["commentorName": self.myName, "commentorID": Auth.auth().currentUser!.uid, "commentorPic": self.myPicString, "commentText": self.typeCommentTF.text])
            Database.database().reference().child("posts").child((self.curCommentCell?["postID"]!) as! String).child("comments").setValue(commentsArray)
            Database.database().reference().child("users").child((self.curCommentCell?["posterUID"]!) as! String).child("posts").child((self.curCommentCell?["postID"]!) as! String).child("comments").setValue(commentsArray)
            
            self.typeCommentTF.text = nil
            //self.curCommentCell?.commentsCountButton.setTitle(String(commentsArray.count), for: .normal)
            //reload collect in delegate
            //print("commentsArray: \(commentsArray)")
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
                            var count = 0
                            for dict in popCollectData{
                                if (dict["postPic"] == nil && dict["postVid"] == nil){
                                    print("textBeingRemoved")
                                    popCollectData.remove(at: count)
                                }
                                count = count + 1
                            }
                            DispatchQueue.main.async{
                                self.popCollect.reloadData()
                            }
                            
                        })
                        
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
