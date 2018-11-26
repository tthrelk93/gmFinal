//
//  FolloweringViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 11/26/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import SwiftOverlays

class FolloweringViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    
    
    @IBOutlet weak var ffCollect: UICollectionView!
    
    @IBOutlet weak var followerOrFollowingView: UIView!
    
    @IBAction func backFromFF(_ sender: Any) {
         performSegue(withIdentifier: "followToProf", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.ffCollect.delegate = self
        self.ffCollect.dataSource = self
        self.ffCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        // Do any additional setup after loading the view.
    }
    var followType = String()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
            if followType == "following"{
                return flwingDataArr.count
            } else {
                return flwrDataArr.count
            }
        
    }
    
    var selectedData = [String:Any]()
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       
    }
    var flwrDataArr = [[String:Any]]()
    var flwingDataArr = [[String:Any]]()
    var picOrTextData = [String]()
    var followersArr = [String]()
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("hey")
        
            let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
            if followType == "following"{
                DispatchQueue.main.async{
                    
                    cell.likedByFollowButton.setTitle("Unfollow", for: .normal)
                    
                    cell.likedByName.isHidden = false
                    cell.likedByUName.isHidden = false
                    cell.likedByFollowButton.isHidden = false
                    cell.commentName.isHidden = true
                    cell.commentTextView.isHidden = true
                    cell.commentTimestamp.isHidden = true
                    cell.likedByUName.text = (self.flwingDataArr[indexPath.row]["username"] as! String)
                    
                    cell.likedByUID = (self.flwingDataArr[indexPath.row]["uid"] as! String)
                    
                    cell.likedByName.text = self.flwingDataArr[indexPath.row]["realName"] as! String
                    if self.flwingDataArr[indexPath.row]["profPic"] as! String == "profile-placeholder"{
                        DispatchQueue.main.async{
                            cell.likedByImage.image = UIImage(named: "profile-placeholder")
                        }
                    } else {
                        if let messageImageUrl = URL(string: self.flwingDataArr[indexPath.row]["profPic"] as! String) {
                            
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                DispatchQueue.main.async{
                                    cell.likedByImage.image = UIImage(data: imageData as Data)
                                }
                                
                            }
                            
                            //}
                        }
                    }
                }
            } else {
                //follower
                DispatchQueue.main.async{
                    
                    if (self.followersArr.contains(self.flwrDataArr[indexPath.row]["uid"] as! String)){
                        cell.likedByFollowButton.setTitle("Unfollow", for: .normal)
                        cell.likedByFollowButton.backgroundColor = UIColor.red
                        
                    } else {
                        cell.likedByFollowButton.backgroundColor = UIColor.green
                    }
                    
                    cell.likedByName.isHidden = false
                    cell.likedByUName.isHidden = false
                    cell.likedByFollowButton.isHidden = false
                    cell.commentName.isHidden = true
                    cell.commentTextView.isHidden = true
                    cell.commentTimestamp.isHidden = true
                    cell.likedByUName.text = (self.flwrDataArr[indexPath.row]["username"] as! String)
                    
                    cell.likedByUID = (self.flwrDataArr[indexPath.row]["uid"] as! String)
                    
                    cell.likedByName.text = (self.flwrDataArr[indexPath.row]["realName"] as! String)
                    if self.flwrDataArr[indexPath.row]["profPic"] as! String == "profile-placeholder"{
                        DispatchQueue.main.async{
                            cell.likedByImage.image = UIImage(named: "profile-placeholder")
                        }
                    } else {
                        if let messageImageUrl = URL(string: self.flwrDataArr[indexPath.row]["profPic"] as! String) {
                            
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
