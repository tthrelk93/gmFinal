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
    var prevScreen = String()
    let refreshControl = UIRefreshControl()
    var gmRed = UIColor(red: 237/255, green: 28/255, blue: 39/255, alpha: 1.0)
    var idArray = [String]()
    var picDict = [String:UIImage]()
    var myUName = String()
    var myPicString = String()
    var following = [String]()
    var myRealName = String()
    var curName = String()
    var selectedCellUID = String()
    var noteCollectData: [[String:Any]]?
    var senderScreen = String()
    var selectedPostID = String()
    var selectedCurAuthProfile = true
    var selectedData = [String:Any]()
    
    @IBOutlet weak var notifyCollect: UICollectionView!
    @IBOutlet weak var topLine: UIView!
    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showWaitOverlayWithText("loading notifications")
        topLine.frame = CGRect(x: topLine.frame.origin.x, y: topLine.frame.origin.y, width: topLine.frame.width, height: 0.5)
        self.notifyCollect.register(UINib(nibName: "NotificationCell", bundle: nil), forCellWithReuseIdentifier: "NotificationCell")
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?[3]
       
        refreshControl.tintColor = gmRed
        refreshControl.addTarget(self, action: Selector("refresh"), for: .valueChanged)
        notifyCollect.addSubview(refreshControl)
        notifyCollect.alwaysBounceVertical = true
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
            if self.noteCollectData == nil{
                self.removeAllOverlays()
            } else {
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
                        self.notifyCollect.isHidden = false
                        self.removeAllOverlays()
                        print("doneLoading3")
                    })
                }
                
                //cell.delegate = self
            })
            }
            //SwiftOverlays.removeAllBlockingOverlays()
        })
        

        // Do any additional setup after loading the view.
    }
    @objc func refresh() {
        
        // print("refresh")
        if (noteCollectData == nil){
            
        } else {
        noteCollectData!.removeAll()
        }
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
            if self.noteCollectData == nil{
                //self.removeAllOverlays()
            } else {
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
                           // self.removeAllOverlays()
                            self.refreshControl.endRefreshing()
                            print("doneLoading3")
                        })
                    }
                    //cell.delegate = self
                })
            }
            //SwiftOverlays.removeAllBlockingOverlays()
        })

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noteCollectData!.count
    }
    func performSegueToPost(postID: String){
        Database.database().reference().child("posts").child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.selectedData = snapshot.value as! [String:Any]
            
            self.performSegue(withIdentifier: "NoteToSinglePost", sender: self)
        })
    }
    
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
        DispatchQueue.main.async{
            
        cell.postPic.setImage(nil, for: .normal)
        cell.postPic.isHidden = false
        cell.postTextLabel.text = ""
        cell.postPic.frame = CGRect(x: cell.postPic.frame.origin.x, y: cell.postPic.frame.origin.y, width: 60, height: 60)
        cell.actionUserPicButton.frame = CGRect(x: cell.actionUserPicButton.frame.origin.x, y: cell.actionUserPicButton.frame.origin.y, width: 50, height: 50)
            cell.postTextLabel.isHidden = false
        cell.postID = (self.noteCollectData![indexPath.row] )["postID"] as! String
        if (self.noteCollectData![indexPath.row] )["isForumPost"] as? Bool != nil{
            cell.postTextLabel.text = "Forum"
            cell.postTextLabel.textColor = UIColor.red
           // cell.postTextLabel.layer.borderColor = UIColor.red.cgColor
           // cell.postTextLabel.layer.borderWidth = 2
            cell.postTextLabel.isHidden = false
        } else {
            
            cell.postTextLabel.isHidden = true
            
        }
        //lineView.frame = CGRect(x: lineView.frame.origin.x, y: lineView.frame.origin.y, width: lineView.frame.width, height: 0.5)
        
        
            cell.delegate = self
            cell.name = (self.noteCollectData![indexPath.row] as! [String:Any])["actionByUsername"] as! String
        
            //cell.postPic.frame = CGRect(x: cell.postPic.frame.origin.x, y: cell.postPic.frame.origin.y, width: 60, height: 60)
        
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
            var time = String()
            print("hrs Between: \(hoursBetween)")
            if hoursBetween < 1{
                hoursBetween = Int(now.hours(from: date!))!
                if hoursBetween < 1 {
                    hoursBetween = Int(now.minutes(from: date!))
                    if hoursBetween == 1{
                        
                        time = "\(hoursBetween) minute ago"
                    } else {
                        time = "\(hoursBetween) minutes ago"
                    }
                } else {
                    if hoursBetween == 1 {
                        time = "\(hoursBetween) hour ago"
                    } else {
                        time = "\(hoursBetween) hours ago"
                    }
                }
            } else {
                if hoursBetween == 1 {
                    time = "\(hoursBetween) day ago"
                } else {
                    time = "\(hoursBetween) days ago"
                }
            }
            
           
            
            //var time = NSMutableAttributedString(string: dateString)
            let string_to_color = time
            
            let range = (string_to_color as NSString).range(of: string_to_color)
            
            let attribute1 = NSMutableAttributedString.init(string: string_to_color)
            attribute1.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray , range: range)
            
            attributedString.append(space)
            attributedString.append(normString)
            
           attributedString.append(space)
            attributedString.append(attribute1)
            
            var sendString = attributedString
            
           
            print("sendString: \(sendString)")
            cell.noteLabel.attributedText = attributedString
            }
        }
        
            cell.actionByUID = self.noteCollectData![indexPath.row]["actionByUID"] as! String
            
        //cell.postTextLabel.isHidden = true
        
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
            cell.ogPostPicFrame = cell.postPic.frame
            if self.picDict[self.noteCollectData![indexPath.row]["postID"] as! String] != nil{
                //cell.postPic.frame = cell.ogPostPicFrame
                cell.postPic.setImage(self.picDict[self.noteCollectData![indexPath.row]["postID"] as! String], for: .normal)
            } else {
                if (self.noteCollectData![indexPath.row]["isForumPost"] as? Bool) == nil {
                   //cell.postPic.frame = cell.tpIconPosition.frame
                    cell.postPic.setBackgroundImage(UIImage(named: "List-Grey-120 copy 2"), for: .normal)
                    
                } else {
                    cell.postPic.isHidden = true
                }
            }
        
        }
      
        cell.layer.addBorder(edge: .bottom, color: UIColor.lightGray, thickness: 0.5)
        
        //cell.lineView.frame.size = CGSize(width: cell.frame.width, height: 0.5)
            return cell
        
        
        }
    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
            var notifCell = collectionView.cellForItem(at: indexPath) as! NotificationCell
            self.selectedPostID = (noteCollectData![indexPath.row] as! [String:Any])["postID"] as! String
            if ((noteCollectData![indexPath.row] )["isForumPost"] as? Bool) != nil{
                Database.database().reference().child("forum").child(self.selectedPostID).observeSingleEvent(of: .value, with: { (snapshot) in
                    print("postData = \(snapshot.value as! [String:Any])")
                    self.selectedData = snapshot.value as! [String:Any]
                    
                    self.performSegue(withIdentifier: "NoteToForumPost", sender: self)
                })
            } else {
                
             Database.database().reference().child("posts").child(self.selectedPostID).observeSingleEvent(of: .value, with: { (snapshot) in
                print("postData = \(snapshot.value as! [String:Any])")
                self.selectedData = snapshot.value as! [String:Any]
            
            self.performSegue(withIdentifier: "NoteToSinglePost", sender: self)
            })
            }
        }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //var width = CGFloat()
        //var height = CGFloat()
       
            return CGSize(width: collectionView.frame.width - 20, height: 70)
        }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
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
        if segue.identifier == "NoteToForumPost"{
            if let vc = segue.destination as? SingleTopicViewController{
                vc.topicData = self.selectedData
                vc.prevScreen = "notification"
            }
        }
    }
    

}
extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer();
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 0.5)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x:0, y:self.frame.height - thickness, width:self.frame.width, height:thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x:0, y:0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x:self.frame.width - thickness, y: 0, width: thickness, height:self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    
}
