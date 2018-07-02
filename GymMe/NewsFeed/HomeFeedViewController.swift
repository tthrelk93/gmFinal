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


class HomeFeedViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITabBarDelegate, PerformActionsInFeedDelegate,UIGestureRecognizerDelegate {
    
    @IBAction func inboxPressed(_ sender: Any) {
    }
    @IBOutlet weak var inboxButton: UIButton!
    
    var temp = FeedData()
    var temp2 = FeedData()
    var temp3 = FeedData()
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items![1]{
            performSegue(withIdentifier: "FeedToSearch", sender: self)
        } else if item == tabBar.items![2]{
            performSegue(withIdentifier: "FeedToPost", sender: self)
        } else if item == tabBar.items![3]{
            performSegue(withIdentifier: "FeedToPost", sender: self)
        } else if item == tabBar.items![4]{
            performSegue(withIdentifier: "FeedToProfile", sender: self)
        } else {
            //curScreen
        }
        
    }
    
    @IBOutlet weak var feedCollect: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedDataArray.count
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
    //var uidArray = ["Bob","Phil",Auth.auth().currentUser!.uid]
    var nameArray = ["Bob","Phil","Me"]
    var locArray = ["nowhere/test", "nowhere/test","Memphis, TN"]
    var typeOfCellAtIndexPath = [IndexPath:Int]()
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("hey")
        if feedDataArray[indexPath.row]["postPic"] == nil && feedDataArray[indexPath.row]["postVid"] == nil{
            typeOfCellAtIndexPath[indexPath] = 0
            let cell : NewsFeedCellCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsFeedCellCollectionViewCell", for: indexPath) as! NewsFeedCellCollectionViewCell
            cell.delegate = self
            if feedDataArray[indexPath.row]["postText"] != nil {
                cell.postText.text = feedDataArray[indexPath.row]["postText"] as! String
            }
            cell.postText.text = (feedDataArray[indexPath.row]["postText"] as! String)
            DispatchQueue.main.async {
                
                if let messageImageUrl = URL(string: self.feedDataArray[indexPath.row]["posterPicURL"] as! String) {
                
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    cell.profImageView.image = UIImage(data: imageData as Data)
                    
                }
                
            }
            }
            
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            cell.posterUID = (feedDataArray[indexPath.row]["posterUID"] as! String)
            cell.posterNameButton.setTitle((feedDataArray[indexPath.row]["posterName"] as! String), for: .normal)
            cell.postLocationButton.setTitle(locArray[indexPath.row], for: .normal)
            cell.cellIndexPath = indexPath
            /*let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(sender:)))
             tap.numberOfTapsRequired = 2
             
             cell.addGestureRecognizer(tap)*/
            
            
            
            
            return cell
        } else {
            typeOfCellAtIndexPath[indexPath] = 1
            let cell : NewsFeedPicCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsFeedPicCollectionViewCell", for: indexPath) as! NewsFeedPicCollectionViewCell
            cell.delegate = self
            cell.posterUID = (feedDataArray[indexPath.row]["posterUID"] as! String)
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            DispatchQueue.main.async {
                
                if let messageImageUrl = URL(string: self.feedDataArray[indexPath.row]["posterPicURL"] as! String) {
                
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    cell.posterPic.image = UIImage(data: imageData as Data)
                    
                }
                
            }
            }
            if feedDataArray[indexPath.row]["postText"] != nil {
                cell.postText.text = feedDataArray[indexPath.row]["postText"] as! String
            }
            cell.posterNameButton.setTitle((feedDataArray[indexPath.row]["posterName"] as! String), for: .normal)
            cell.postLocationButton.setTitle("post location", for: .normal)
            
            cell.cellIndexPath = indexPath
            
            
            if feedDataArray[indexPath.row]["postVid"] == nil {
                DispatchQueue.main.async{
                if let messageImageUrl = URL(string: self.feedDataArray[indexPath.row]["postPic"] as! String) {
                    
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        cell.postPic.image = UIImage(data: imageData as Data)
                        
                    }
                    
                }
                }
                cell.viewCount.isHidden = true
                
            } else {
                cell.player?.playerDelegate = self
                cell.player?.playbackDelegate = self
                cell.player?.playbackLoops = true
                cell.player?.playbackPausesWhenBackgrounded = true
                cell.player?.playbackPausesWhenResigningActive
                //var gest = UIGestureRecognizer(target: <#T##Any?#>, action: <#T##Selector?#>)
                
                let vidFrame = CGRect(x: cell.postPic.frame.origin.x, y: cell.postPic.frame.origin.y, width: feedCollect.frame.width - 28, height: cell.postPic.frame.height)
                cell.player?.view.frame = vidFrame
                
                cell.player?.url  = URL(string: feedDataArray[indexPath.row]["postVid"] as! String)
                cell.player?.view.isHidden = false
                cell.viewCount.isHidden = false
                cell.player?.didMove(toParentViewController: self)
                
                //cell.player?.url = cell.videoUrl
                
                cell.player?.playbackLoops = true
                
                let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
                tapGestureRecognizer.numberOfTapsRequired = 1
                cell.player?.view.addGestureRecognizer(tapGestureRecognizer)
            }
            
            //self.addChildViewController(cell.player)
            //self.view.addSubview(cell.player.view)
           
            
            
            
            return cell
        }
        
    }
    var selectedCell = NewsFeedPicCollectionViewCell()
    @IBAction func dubTap(_ sender: Any) {
        let tappedPoint: CGPoint = (sender as! UITapGestureRecognizer).location(in: self.feedCollect)
        
        let tappedCellPath: IndexPath = self.feedCollect.indexPathForItem(at: tappedPoint)! // [self.collectionView indexPathForItemAtPoint:tappedPoint];
        if typeOfCellAtIndexPath[tappedCellPath] == 0{
            let tappedCell = self.feedCollect.cellForItem(at: tappedCellPath) as! NewsFeedCellCollectionViewCell
            if tappedCell.likeButton.imageView?.image == UIImage(named: "like.png"){
                tappedCell.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                let curLikes = Int((tappedCell.likesCountButton.titleLabel?.text)!)
                tappedCell.likesCountButton.setTitle(String(curLikes! + 1), for: .normal)
                
                //update Database for post with new like count
                
            } else {
                tappedCell.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
                
                let curLikes = Int((tappedCell.likesCountButton.titleLabel?.text)!)
                tappedCell.likesCountButton.setTitle(String(curLikes! - 1), for: .normal)
            }
            
        } else {
            let tappedCell = self.feedCollect.cellForItem(at: tappedCellPath) as! NewsFeedPicCollectionViewCell
            if tappedCell.likeButton.imageView?.image == UIImage(named: "like.png"){
                tappedCell.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                let curLikes = Int((tappedCell.likesCountButton.titleLabel?.text)!)
                tappedCell.likesCountButton.setTitle(String(curLikes! + 1), for: .normal)
            } else {
                tappedCell.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
                let curLikes = Int((tappedCell.likesCountButton.titleLabel?.text)!)
                tappedCell.likesCountButton.setTitle(String(curLikes! - 1), for: .normal)
            }
            
            
            
            
            
        }
        
        
        
        
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if typeOfCellAtIndexPath[indexPath] == 0 {
            
        } else {
            selectedCell = collectionView.cellForItem(at: indexPath) as! NewsFeedPicCollectionViewCell
        }
    }
    
    
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("here")
        // Compute the dimension of a cell for an NxN layout with space S between
        // cells.  Take the collection view's width, subtract (N-1)*S points for
        // the spaces between the cells, and then divide by N to find the final
        // dimension for the cell's width and height.
        
        if feedDataArray[indexPath.row]["postPic"] == nil {
            let width = collectionView.frame.width - 20
            let height = CGFloat(195)
            
            return CGSize(width: width, height: height)
            
        } else {
            let width = collectionView.frame.width - 20
            let height = CGFloat(563)
            
            return CGSize(width: width, height: height)
        }
        /*let cellsAcross: CGFloat = 1
         let spaceBetweenCells: CGFloat = 10
         let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
         return CGSize(width: dim, height: dim)*/
    }
    //this may be slow if there are a ton of posts. Check back
    var curPlayingVidCell: NewsFeedPicCollectionViewCell?
    /*func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // var closestCell : UICollectionViewCell = feedCollect.visibleCells[0];
        for cell in feedCollect!.visibleCells as [UICollectionViewCell] {
            let indexPath = feedCollect.indexPath(for: cell)
            
            if typeOfCellAtIndexPath[indexPath!]! == 0{
                
            } else {
                let cell = (feedCollect.cellForItem(at: indexPath!)) as! NewsFeedPicCollectionViewCell
                if cell.videoUrl == nil {
                    
                } else {
                    cell.player?.stop()
                }
            }
            //closestCell = cell
        }
        
    }*/
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    func scrollViewDidBeginDragging(_ scrollView: UIScrollView, willAccelerate accelerate: Bool) {
        if curPlayingVidCell != nil{
            curPlayingVidCell?.player?.stop()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var closestCell = UICollectionViewCell()
        closestCell = feedCollect.visibleCells[0]
        
        for cell in feedCollect!.visibleCells as [UICollectionViewCell] {
            let closestCellDelta = abs(closestCell.center.x - feedCollect.bounds.size.width/2.0 - feedCollect!.contentOffset.x)
            let cellDelta = abs(cell.center.x - feedCollect.bounds.size.width/2.0 - feedCollect.contentOffset.x)
            if (cellDelta < closestCellDelta){
                closestCell = cell
            }
        }
        //let closestCellDelta = abs(closestCell.center.x - feedCollect.bounds.size.width/2.0 - feedCollect.contentOffset.x)
        print(closestCell.center.x)
        let indexPath = feedCollect.indexPath(for: closestCell)
        
        if typeOfCellAtIndexPath[indexPath!]! == 0{
            
        } else {
            let cell = (feedCollect.cellForItem(at: indexPath!)) as! NewsFeedPicCollectionViewCell
            if cell.videoUrl == nil {
                
            } else {
                cell.player?.playFromBeginning()
                self.curPlayingVidCell = cell as! NewsFeedPicCollectionViewCell
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Find collectionview cell nearest to the center of collectionView
        // Arbitrarily start with the last cell (as a default)
        
        //collectionView.scrollToItemAtIndexPath(indexPath!, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
    }
    
    
    
    var gmRed = UIColor(red: 237/255, green: 28/255, blue: 39/255, alpha: 1.0)
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var tabBar: UITabBar!
    var feedDataArray = [[String:Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?.first
       
        refreshControl.tintColor = gmRed
        refreshControl.addTarget(self, action: Selector("refresh"), for: .valueChanged)
        feedCollect.addSubview(refreshControl)
        feedCollect.alwaysBounceVertical = true
        
        //feedDataArray.append(temp)
        //feedDataArray.append(temp2)
        //feedDataArray.append(temp3)
        self.feedCollect.register(UINib(nibName: "NewsFeedCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsFeedCellCollectionViewCell")
        self.feedCollect.register(UINib(nibName: "NewsFeedPicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsFeedPicCollectionViewCell")
        loadFeedData()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    @objc func refresh() {
        
        print("refresh")
        feedDataArray.removeAll()
        Database.database().reference().child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    
                    self.feedDataArray.append(snap.value as! [String:Any])
                }
            }
            self.feedCollect?.reloadData()
            self.refreshControl.endRefreshing()
        })
        
    }
    func loadFeedData(){
        Database.database().reference().child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    self.feedDataArray.append(snap.value as! [String:Any])
                }
            }
            self.feedCollect.delegate = self
            self.feedCollect.dataSource = self
            
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var selectedCellUID: String?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FeedToProfile"{
            if let vc = segue.destination as? ProfileViewController{
                vc.curUID = self.selectedCellUID
                if selectedCurAuthProfile == true{
                    vc.viewerIsCurAuth = true
                    
                } else {
                    vc.viewerIsCurAuth = false
                }
                vc.curName = self.curName
                
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
    
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        
        switch (self.selectedCell.player?.playbackState.rawValue) {
        case PlaybackState.stopped.rawValue?:
            self.selectedCell.player?.playFromBeginning()
            break
        case PlaybackState.paused.rawValue?:
            self.selectedCell.player?.playFromCurrentTime()
            break
        case PlaybackState.playing.rawValue?:
            self.selectedCell.player?.pause()
            break
        case PlaybackState.failed.rawValue?:
            self.selectedCell.player?.pause()
            break
        default:
            self.selectedCell.player?.pause()
            break
        }
    }
    
}
