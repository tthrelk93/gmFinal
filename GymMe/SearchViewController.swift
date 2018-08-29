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

var gmRed = UIColor(red: 180/255, green: 29/255, blue: 2/255, alpha: 1.0)
class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarDelegate, UICollectionViewDelegateFlowLayout {
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
            self.popCollect.reloadData()
            print(self.popCollectData)
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
        popCollect.isHidden = true
        topBarPressed = false
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
    var keys = [String]()
    func loadPopData(){
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
            //performSegue(withIdentifier: "SearchToNotifications", sender: self)
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
        } else {
            return popCollectData.count
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
        } else {
            let cell : PopCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "PopCell", for: indexPath) as! PopCell)
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.cgColor
            print("this popcelldata = \(popCollectData[indexPath.row] )")
            if topBarPressed == true{
                if self.popCollectData[indexPath.row]["postPic"] == nil {
                    if (self.popCollectData[indexPath.row])["postVid"] == nil{
                       // print("Text: \(String(describing: ((popCollectData[indexPath.row]).first?.value as! [String:Any])["postText"]!))")
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            cell.popText.text = String(describing: ((self.popCollectData[indexPath.row])["postText"]!))
                            cell.player?.view.isHidden = true
                            cell.bringSubview(toFront: cell.popText)
                            
                        })
                        
                    } else {
                       
                        //cell.popPic.image = UIImage(named: "video-481821_960_720")
                        //cell.videoUrl = URL(string: popCollectData[indexPath.row]["postVid"] as! String)
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
                        
                        //}
                    }
                    //cell.popPic.image =
                }
                return cell
                
            } else {
            if (self.popCollectData[indexPath.row][self.popCollectData[indexPath.row].keys.first!] as! [String:Any])["postPic"] == nil {
                if (self.popCollectData[indexPath.row][self.popCollectData[indexPath.row].keys.first!] as! [String:Any])["postVid"] == nil{
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        
                        cell.popText.isHidden = false
                        cell.popText.text = (String(describing: ((self.popCollectData[indexPath.row]).first?.value as! [String:Any])["postText"]!))
                        cell.player?.view.isHidden = true
                        cell.bringSubview(toFront: cell.popText)
                        
                    })
                    
                    
                } else {
                    
                    cell.popText.isHidden = true
                    
                    cell.popPic.isHidden = true
                    cell.player?.url = URL(string: String(describing: ((popCollectData[indexPath.row]).first?.value as! [String:Any])["postVid"]!))
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
               
                cell.popText.isHidden = true
                
                if let messageImageUrl = URL(string: (self.popCollectData[indexPath.row][self.popCollectData[indexPath.row].keys.first!] as! [String:Any])["postPic"] as! String) {
                
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    cell.popPic.image = UIImage(data: imageData as Data)
                    
                }
                
                //}
            }
            //cell.popPic.image =
            }
            return cell
            
        }
        }
        
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
           
                    
                    self.popCollect.reloadData()
                    self.popCollect.isHidden = false
                    self.categoriesCollect.isHidden = true
           

        } else if collectionView == popCollect{
            backToCatButton.isHidden = true
            if topBarPressed == true{
                
            } else {
            let cellLabel = catCollectData[indexPath.row]
            if allCatDataDict[cellLabel] == nil {
                self.allCatDataDict[cellLabel] = [[String:Any]]()
            }
            print("selectedData for \(cellLabel): \(self.popCollectData[indexPath.row])")
            //show single post view
            singlePostView.frame = (popCollect.visibleCells[indexPath.row] as! PopCell).frame
            self.curCellFrame = (popCollect.visibleCells[indexPath.row] as! PopCell).frame
                
                //did select picture cell
            if (self.popCollectData[indexPath.row][self.popCollectData[indexPath.row].keys.first!] as! [String:Any])["postPic"] as? String != nil {
                if let messageImageUrl = URL(string: (self.popCollectData[indexPath.row][self.popCollectData[indexPath.row].keys.first!] as! [String:Any])["postPic"] as! String) {
                
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    singlePostImageView.image = UIImage(data: imageData as Data)
                    }
                }
                textPostTV.isHidden = true
                singlePostView2.isHidden = false
            } else if ((self.popCollectData[indexPath.row][self.popCollectData[indexPath.row].keys.first!] as! [String:Any])["postVid"] as? String != nil) {
                //vid post//////////
                //self.singlePostView3.frame = ogCommentPos
                self.player = Player()
                textPostTV.isHidden = true
                player?.url = URL(string:(self.popCollectData[indexPath.row][self.popCollectData[indexPath.row].keys.first!] as! [String:Any])["postVid"] as! String)
                let playTap = UITapGestureRecognizer()
                playTap.numberOfTapsRequired = 1
                playTap.addTarget(self, action: #selector(SearchViewController.playOrPause))
               player?.view.addGestureRecognizer(playTap)
                
                let vidFrame = CGRect(x: singlePostView1.frame.origin.x, y: singlePostView1.frame.origin.y, width: self.ogSinglePostViewFrame.width - 20, height: self.ogSinglePostViewFrame.height/2)
                self.player?.view.frame = vidFrame
                self.singlePostView1.addSubview((self.player?.view)!)
                self.player?.didMove(toParentViewController: self)
                singlePostView1.sendSubview(toBack: (player?.view)!)
                textPostTV.isHidden = true
                singlePostView2.isHidden = false
            } else {
                //text post
                textPostTV.isHidden = false
                singlePostView2.isHidden = true
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.singlePostView3.frame = self.textPostOnlyCommentsPost.frame
                   
                })
            }
        
                textPostTV.text = ((self.popCollectData[indexPath.row][self.popCollectData[indexPath.row].keys.first!] as! [String:Any])["postText"] as! String)
                singlePostTextView.text = ((self.popCollectData[indexPath.row][self.popCollectData[indexPath.row].keys.first!] as! [String:Any])["postText"] as! String)
                
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
