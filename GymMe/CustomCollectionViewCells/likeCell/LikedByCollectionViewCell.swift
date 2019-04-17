//
//  LikedByCollectionViewCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 7/18/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol ToProfileDelegate {
    
    func segueToProf(cellUID: String, name: String)
    
    
}

class LikedByCollectionViewCell: UICollectionViewCell {

    var delegate1: ToProfileDelegate?
    @IBOutlet weak var shareCheck: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentTimestamp: UILabel!
    @IBOutlet weak var commentName: UILabel!
    @IBOutlet weak var likedByUName: UILabel!
    @IBOutlet weak var likedByName: UILabel!
    @IBOutlet weak var likedByImage: UIImageView!
    @IBOutlet weak var likedByFollowButton: UIButton!
    
    var likedByUID: String?
    @IBAction func likedByFollowButtonPressed(_ sender: Any) {
        //add selected User to curUsers Following field
        if likedByFollowButton.titleLabel?.text == "Follow"{
            Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    var uploadDict = [String:Any]()
                    for snap in snapshots{
                        if snap.key == "following"{
                            var tempFollowing = snap.value as! [String]
                            tempFollowing.append(self.likedByUID!)
                            uploadDict["following"] = tempFollowing
                            break
                        }
                    }
                    Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(uploadDict)
                }
                Database.database().reference().child("users").child(self.likedByUID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        var uploadDict2 = [String:Any]()
                        for snap in snapshots{
                            if snap.key == "followers"{
                                var tempFollowing = snap.value as! [String]
                                tempFollowing.append(Auth.auth().currentUser!.uid)
                                
                                uploadDict2["followers"] = tempFollowing
                                break
                                
                            }
                        }
                        Database.database().reference().child("users").child(self.likedByUID!).updateChildValues(uploadDict2)
                    }
                    self.layer.borderColor = UIColor.red.cgColor

                    self.likedByFollowButton.setTitle("Unfollow", for: .normal)
                    self.likedByFollowButton.backgroundColor = UIColor.white
                    self.likedByFollowButton.setTitleColor(UIColor.red, for: .normal)
                })
            })
                    
        } else {
            //remove from curUsers following and selected users followers
            Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    var uploadDict = [String:Any]()
                    for snap in snapshots{
                        if snap.key == "following"{
                            var tempFollowing = snap.value as! [String]
                            tempFollowing.remove(at: tempFollowing.index(of: self.likedByUID!)!)
                            uploadDict["following"] = tempFollowing
                            break
                        }
                    }
                    Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(uploadDict)
                }
                Database.database().reference().child("users").child(self.likedByUID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        var uploadDict2 = [String:Any]()
                        for snap in snapshots{
                            if snap.key == "followers"{
                                var tempFollowers = snap.value as! [String]
                                tempFollowers.remove(at: tempFollowers.index(of: Auth.auth().currentUser!.uid)!)
                                
                                uploadDict2["followers"] = tempFollowers
                                break
                                
                            }
                        }
                        Database.database().reference().child("users").child(self.likedByUID!).updateChildValues(uploadDict2)
                    }
                    self.likedByFollowButton.setTitle("Follow", for: .normal)
                    self.layer.borderColor = UIColor.red.cgColor
                    self.likedByFollowButton.backgroundColor = UIColor.red
                    self.likedByFollowButton.setTitleColor(UIColor.white, for: .normal)
                })
            })
        }
    }
    
    @IBOutlet weak var toProfileButton: UIButton!
    @IBAction func toProfileButtonPressed(_ sender: Any) {
        delegate1?.segueToProf(cellUID: self.likedByUID!, name: self.likedByName.text!)
    }
    
    @IBAction func selectButton(_ sender: Any) {
    }
    
    @IBOutlet weak var selectButton: UIButton!
    var delegate: PerformActionsInFeedDelegate?
    var postID: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        likedByFollowButton.layer.cornerRadius = 10
        self.likedByImage.layer.cornerRadius = likedByImage.frame.height/2
        self.likedByImage.layer.masksToBounds = true
        self.shareCheck.layer.borderColor = UIColor.red.cgColor
        self.shareCheck.layer.borderWidth = 2
        self.shareCheck.layer.cornerRadius = self.shareCheck.frame.width/2
        // Initialization code
    }

}
