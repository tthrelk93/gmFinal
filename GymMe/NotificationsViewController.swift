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

class NotificationsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarDelegate {
    
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
    

    @IBOutlet weak var notifyCollect: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notifyCollect.register(UINib(nibName: "NotificationCell", bundle: nil), forCellWithReuseIdentifier: "NotificationCell")
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?[3]
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    if snap.key == "notifications"{
                        self.noteCollectData = (snap.value as! [[String:Any]])
                    }
                    
                }
            }
            if self.noteCollectData?.count != 0 && self.noteCollectData != nil {
                self.noteCollectData?.reverse()
            self.notifyCollect.delegate = self
            self.notifyCollect.dataSource = self
            }
            SwiftOverlays.removeAllBlockingOverlays()
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
    var noteCollectData: [[String:Any]]?
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : NotificationCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        
        var sendString = (noteCollectData![indexPath.row]["actionText"] as! String) + (noteCollectData![indexPath.row]["timeStamp"] as! String)
        print("sendString: \(sendString)")
        cell.noteLabel.text = sendString
        cell.actionByUID = noteCollectData![indexPath.row]["actionByUID"] as! String
            cell.postTextLabel.text = noteCollectData![indexPath.row]["postText"] as? String
        cell.postTextLabel.isHidden = true
        
        if noteCollectData![indexPath.row]["actionByUserPic"] as! String == "profile-placeholder"{
                cell.actionUserPicButton.setImage(UIImage(named: "profile-placeholder"), for: .normal)
            } else {
                if let messageImageUrl = URL(string: noteCollectData![indexPath.row]["actionByUserPic"] as! String) {
                    
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        cell.actionUserPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                        
                    }
                    
                    //}
                }
            }
            //cell.delegate = self
            return cell
        }
        var selectedPostID = String()
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
            var notifCell = collectionView.cellForItem(at: indexPath) as! NotificationCell
            self.selectedPostID = (noteCollectData![indexPath.row] as! [String:Any])["postID"] as! String
            
            performSegue(withIdentifier: "postSelected", sender: self)
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
        if segue.identifier == "postSelected"{
            if let vc = segue.destination as? HomeFeedViewController{
                vc.fromNotifPostID = self.selectedPostID
            }
    }
    }
    

}
