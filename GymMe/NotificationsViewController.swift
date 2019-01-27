//
//  NotificationsViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 9/7/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SwiftOverlays

class NotificationsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarDelegate, PerformActionsInNotifications {
    
    @IBOutlet weak var topLine: UIView!
    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!
    var prevScreen = String()
    
    @IBAction func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            // Perform action.
            print("swipeRight: \(prevScreen)")
            if prevScreen == "feed"{
                performSegue(withIdentifier: "NotificationsToFeed", sender: self)
            }
            if prevScreen == "profile"{
                performSegue(withIdentifier: "NotificationsToProfile", sender: self)
            }
            if prevScreen == "post"{
                performSegue(withIdentifier: "NotificationsToPost", sender: self)
            }
            if prevScreen == "search"{
                performSegue(withIdentifier: "NotificationsToSearch", sender: self)
            }
            if prevScreen == "post"{
                performSegue(withIdentifier: "NotificationsToPost", sender: self)
            }
        }
    }
    
    @IBOutlet weak var tabBar: UITabBar!
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items![0]{
            performSegue(withIdentifier: "NotificationsToFeed", sender: self)
        } else if item == tabBar.items![1]{
            performSegue(withIdentifier: "NotificationsToSearch", sender: self)
        } else if item == tabBar.items![2]{
            performSegue(withIdentifier: "NotificationsToPost", sender: self)
        } else if item == tabBar.items![4]{
            performSegue(withIdentifier: "NotificationsToProfile", sender: self)
        } else {
            //curScreen
        }
        
    }
    

    var idArray = [String]()
    var picDict = [String:UIImage]()
    @IBOutlet weak var notifyCollect: UICollectionView!
    var myUName = String()
    var myPicString = String()
    var following = [String]()
    var myRealName = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        showWaitOverlayWithText("loading notifications")
        topLine.frame = CGRect(x: topLine.frame.origin.x, y: topLine.frame.origin.y, width: topLine.frame.width, height: 0.5)
        self.notifyCollect.register(UINib(nibName: "NotificationCell", bundle: nil), forCellWithReuseIdentifier: "NotificationCell")
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?[3]
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    if snap.key == "notifications"{
                        self.noteCollectData = (snap.value as! [[String:Any]])
                    } else if snap.key == "username"{
                        self.myUName = snap.value as! String
                    } else if snap.key == "following"{
                        self.following = snap.value as! [String]
                    } else if snap.key == "profPic"{
                        self.myPicString = snap.value as! String
                        if let messageImageUrl = URL(string: snap.value as! String) {
                            
                            // self.myPicString = messageImageUrl
                            
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                //self.myPic = UIImage(data: imageData as Data)
                                //self.selfCommentPic.image = UIImage(data: imageData as Data)
                                
                            }
                            
                            // }
                        }
                    } else if snap.key == "realName"{
                        self.myRealName = snap.value as! String
                    }
                    
                }
            }
            if self.noteCollectData?.count != 0 && self.noteCollectData != nil {
                self.noteCollectData?.reverse()
            self.notifyCollect.delegate = self
            self.notifyCollect.dataSource = self
            }
            for dict in self.noteCollectData!{
               // var temp = dict as! [String:Any]
                self.idArray.append(dict["postID"] as! String)
            }
            Database.database().reference().child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    
                    for snap in snapshots{
                        var temp = snap.value as! [String:Any]
                        if(self.idArray.contains(snap.key)){
                            if temp["postPic"] != nil{
                                if let messageImageUrl = URL(string: temp["postPic"] as! String) {
                                    
                                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                        self.picDict[snap.key] = UIImage(data: imageData as Data)
                                        
                                    }
                                    
                                    //}
                                }
                                
                          
                            } else if temp["postVid"] != nil {
                                //vid
                            } else {
                                //text
                            }
                        }
                            
                       
                }
                }
                DispatchQueue.main.async{
                    self.notifyCollect.reloadData()
                    self.notifyCollect.performBatchUpdates(nil, completion: {
                        (result) in
                        // ready
                        self.removeAllOverlays()
                        print("doneLoading3")
                    })
                }
                //cell.delegate = self
            })
            //SwiftOverlays.removeAllBlockingOverlays()
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noteCollectData!.count
    }
    var curName = String()
    var selectedCellUID = String()
    var noteCollectData: [[String:Any]]?
    func performSegueToProfile(uid: String, name: String){
        self.curName = name
        self.selectedCellUID = uid
        if uid == Auth.auth().currentUser!.uid {
            selectedCurAuthProfile = true
        } else {
            selectedCurAuthProfile = false
        }
        performSegue(withIdentifier: "NoteToProfile", sender: self)
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : NotificationCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.lineView.frame.size = CGSize(width: cell.frame.width, height: 0.5)
        DispatchQueue.main.async{
            cell.delegate = self
            cell.name = (self.noteCollectData![indexPath.row] as! [String:Any])["actionByUsername"] as! String
        cell.actionUserPicButton.frame = CGRect(x: cell.actionUserPicButton.frame.origin.x, y: cell.actionUserPicButton.frame.origin.y, width: 50, height: 45)
        
            var partOne = (self.noteCollectData![indexPath.row]["actionText"] as! String)
        if let first = partOne.components(separatedBy: " ").first {
            // Do something with the first component.
           if let range = partOne.range(of: first) {
                partOne.removeSubrange(range)
            
            let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)]
            let attributedString = NSMutableAttributedString(string:first, attributes:attrs)
            var normString = NSMutableAttributedString(string:partOne)
            var space = NSMutableAttributedString(string:" ")
            
            var timestamp123 = self.noteCollectData![indexPath.row]["timeStamp"] as! String
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
           // let dateFormatterPrint = DateFormatter()
            //dateFormatterPrint.dateFormat = "MMM dd, yyyy h:mm"
            
            var date = dateFormatterGet.date(from: timestamp123)
            //var dateString = dateFormatterPrint.string(from: date!)
            let now = Date()
            //print("tStampDateString: \(tStampDateString), date: \(date!), now: \(now)")
            var hoursBetween = Int(now.days(from: date!))
            var time = NSAttributedString()
            print("hrs Between: \(hoursBetween)")
            if hoursBetween < 1{
                hoursBetween = Int(now.hours(from: date!))!
                if hoursBetween < 1 {
                    hoursBetween = Int(now.minutes(from: date!))
                    if hoursBetween == 1{
                        
                        time = NSAttributedString(string:"\(hoursBetween) minute ago")
                    } else {
                        time = NSAttributedString(string:"\(hoursBetween) minutes ago")
                    }
                } else {
                    if hoursBetween == 1 {
                        time = NSAttributedString(string:"\(hoursBetween) hour ago")
                    } else {
                        time = NSAttributedString(string:"\(hoursBetween) hours ago")
                    }
                }
            } else {
                if hoursBetween == 1 {
                    time = NSAttributedString(string:"\(hoursBetween) day ago")
                } else {
                    time = NSAttributedString(string:"\(hoursBetween) days ago")
                }
            }
            
           
            
            //var time = NSMutableAttributedString(string: dateString)
            
            attributedString.append(space)
            attributedString.append(normString)
            
           attributedString.append(space)
            attributedString.append(time)
            
            var sendString = attributedString
            print("sendString: \(sendString)")
            cell.noteLabel.attributedText = attributedString
            }
        }
        
            cell.actionByUID = self.noteCollectData![indexPath.row]["actionByUID"] as! String
            cell.postTextLabel.text = self.noteCollectData![indexPath.row]["postText"] as? String
        cell.postTextLabel.isHidden = true
        
            if self.noteCollectData![indexPath.row]["actionByUserPic"] as! String == "profile-placeholder"{
                cell.actionUserPicButton.setImage(UIImage(named: "profile-placeholder"), for: .normal)
            } else {
            if let messageImageUrl = URL(string: self.noteCollectData![indexPath.row]["actionByUserPic"] as! String) {
                    
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        cell.actionUserPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                        
                    }
                    
                    //}
                }
            }
            
            if self.picDict[self.noteCollectData![indexPath.row]["postID"] as! String] != nil{
                //cell.postPic.layer.cornerRadius = cell.postPic.frame.width/2
                //cell.postPic.layer.masksToBounds = true
                cell.postPic.setImage(self.picDict[self.noteCollectData![indexPath.row]["postID"] as! String], for: .normal)
            }
        
        }
            return cell
        
        
        }
    var senderScreen = String()
        var selectedPostID = String()
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
            var notifCell = collectionView.cellForItem(at: indexPath) as! NotificationCell
            self.selectedPostID = (noteCollectData![indexPath.row] as! [String:Any])["postID"] as! String
            Database.database().reference().child("posts").child(self.selectedPostID).observeSingleEvent(of: .value, with: { (snapshot) in
                print("postData = \(snapshot.value as! [String:Any])")
                self.selectedData = snapshot.value as! [String:Any]
            
            self.performSegue(withIdentifier: "NoteToSinglePost", sender: self)
            })
        }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //var width = CGFloat()
        //var height = CGFloat()
       
            return CGSize(width: collectionView.frame.width - 20, height: 70)
        }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    var selectedCurAuthProfile = true
    var selectedData = [String:Any]()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "NoteToProfile"{
            if let vc = segue.destination as? ProfileViewController{
                vc.curUID = self.selectedCellUID
                vc.prevScreen = "feed"
                if selectedCurAuthProfile == true{
                    vc.viewerIsCurAuth = true
                    
                } else {
                    vc.viewerIsCurAuth = false
                }
                vc.curName = self.curName
                
            }
        }
        if segue.identifier == "NoteToSinglePost"{
            if let vc = segue.destination as? SinglePostViewController{
                
                print("wuttttttt: \(self.selectedData)")
                
                vc.prevScreen = "notification"
                vc.senderScreen = "notification"
                vc.thisPostData = self.selectedData
                vc.myUName = self.myUName
                vc.following = self.following
                vc.myPicString = self.myPicString
            
            
            }
    }
        if segue.identifier == "NotificationsToFeed"{
            if let vc = segue.destination as? HomeFeedViewController{
                vc.prevScreen = "notification"
            }
            
        }
        if segue.identifier == "NotificationsToProfile"{
            if let vc = segue.destination as? ProfileViewController{
                vc.prevScreen = "notification"
            }
        }
        if segue.identifier == "NotificationsToSearch"{
            if let vc = segue.destination as? SearchViewController{
                vc.prevScreen = "notification"
            }
        }
        if segue.identifier == "NotificationsToPost"{
            if let vc = segue.destination as? PostViewController{
                vc.prevScreen = "notification"
            }
        }
    }
    

}
