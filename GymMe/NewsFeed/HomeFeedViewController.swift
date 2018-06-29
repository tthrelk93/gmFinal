//
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
    var feedDataArray = [FeedData]()
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
    var uidArray = ["Bob","Phil",Auth.auth().currentUser!.uid]
    var nameArray = ["Bob","Phil","Me"]
    var locArray = ["nowhere/test", "nowhere/test","Memphis, TN"]
    var typeOfCellAtIndexPath = [IndexPath:Int]()
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("hey")
        if feedDataArray[indexPath.row].postPic == nil{
            typeOfCellAtIndexPath[indexPath] = 0
            let cell : NewsFeedCellCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsFeedCellCollectionViewCell", for: indexPath) as! NewsFeedCellCollectionViewCell
            cell.delegate = self
        
            cell.posterUID = uidArray[indexPath.row]
            cell.posterNameButton.setTitle(nameArray[indexPath.row], for: .normal)
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
            cell.posterUID = uidArray[indexPath.row]
            cell.posterNameButton.setTitle(nameArray[indexPath.row], for: .normal)
            cell.postLocationButton.setTitle(locArray[indexPath.row], for: .normal)

            cell.cellIndexPath = indexPath
            cell.player?.playerDelegate = self
            cell.player?.playbackDelegate = self
            cell.player?.playbackLoops = true
           cell.player?.playbackPausesWhenBackgrounded = true
            cell.player?.playbackPausesWhenResigningActive
            //var gest = UIGestureRecognizer(target: <#T##Any?#>, action: <#T##Selector?#>)
            var vidFrame = CGRect(x: cell.postPic.frame.origin.x, y: cell.postPic.frame.origin.y, width: feedCollect.frame.width - 28, height: cell.postPic.frame.height)
            cell.player?.view.frame = vidFrame
            if cell.videoUrl == nil {
                cell.viewCount.isHidden = true
                
            } else {
                cell.player?.view.isHidden = true
                cell.viewCount.isHidden = false
            }
            
            //self.addChildViewController(cell.player)
            //self.view.addSubview(cell.player.view)
            cell.player?.didMove(toParentViewController: self)
            
            cell.player?.url = cell.videoUrl
            
            cell.player?.playbackLoops = true
            
            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            cell.player?.view.addGestureRecognizer(tapGestureRecognizer)
            
            
           
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
        
        if feedDataArray[indexPath.row].postPic == nil {
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
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
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
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var closestCell : UICollectionViewCell = feedCollect.visibleCells[0];
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
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?.first
        temp.posterName = "Bill"
        temp2.posterName = "Frank"
        temp2.postPic = "FU"
        temp3.posterName = "Hailey"
        
        
        refreshControl.tintColor = gmRed
        refreshControl.addTarget(self, action: Selector("refresh"), for: .valueChanged)
        feedCollect.addSubview(refreshControl)
        feedCollect.alwaysBounceVertical = true
        
        feedDataArray.append(temp)
        feedDataArray.append(temp2)
        feedDataArray.append(temp3)
        self.feedCollect.register(UINib(nibName: "NewsFeedCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsFeedCellCollectionViewCell")
        self.feedCollect.register(UINib(nibName: "NewsFeedPicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsFeedPicCollectionViewCell")
        loadFeedData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @objc func refresh() {
        
        print("refresh")
        self.feedCollect?.reloadData()
        
        refreshControl.endRefreshing()
        
    }
    func loadFeedData(){
        
        self.feedCollect.delegate = self
        self.feedCollect.dataSource = self
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

