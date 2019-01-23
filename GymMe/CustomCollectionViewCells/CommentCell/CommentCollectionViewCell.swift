//
//  CommentCollectionViewCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 9/21/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


protocol CommentLike {
    
    func likeComment()

}

class CommentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lineView: UIView!
    
    var commentDelegate: CommentLike?
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentTimeStamp: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentorPic: UIButton!
    var likesCount = Int()
    var postID = String()
    
    var indexPath = IndexPath()
    
    override func awakeFromNib() {
        lineView.frame = CGRect(x: lineView.frame.origin.x, y: lineView.frame.origin.y, width: lineView.frame.width, height: 0.5)
        commentorPic.frame.size = CGSize(width: 35, height: 35)
        super.awakeFromNib()
        // Initialization code
        
        //button.contentVerticalAlignment = .Top
        
       
    }
    var myRealName = String()
    var posterUID = String()
    @IBAction func likeButtonPressed(_ sender: Any) {
       
        if self.likeButton.imageView?.image == UIImage(named: "like.png"){
            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
            Database.database().reference().child("posts").child(self.postID).child("comments").observeSingleEvent(of: .value, with: { snapshot in
            let valDict = snapshot.value as! [[String:Any]]
             var likesVal = Int()
            var likesArray = (valDict[self.indexPath.row] as! [String:Any])["likes"] as? [[String:Any]]
                if likesArray == nil {
                    likesVal = 1
                    likesArray = [[String:Any]]()
                } else {
                    likesVal = likesArray!.count
                    likesVal = likesVal + 1
                }
            /*if likesArray.count == 1 && (likesArray.first! as! [String:String]) == ["x": "x"]{
                likesArray.remove(at: 0)
            }*/
            
            // if self.myPicString == nil{
            // self.myPicString = "profile-placeholder"
            //}
            likesArray!.append(["name": self.myRealName, "uid": Auth.auth().currentUser!.uid])
            
            
            Database.database().reference().child("posts").child(self.postID).child("comments").child(String(self.indexPath.row)).child("likes").setValue(likesArray)
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("comments").child(String(self.indexPath.row)).child("likes").setValue(likesArray)
            
            
            var likesString = String()
                if likesArray!.count == 1 {
                    if(likesArray!.first! as! [String:String]) == ["x": "x"]{
                    likesString = "0 likes"
                } else {
                        likesString = "\(likesArray!.count) like"
                }
            } else {
                    likesString = "\(likesArray!.count) likes"
            }
            self.likesCountLabel.text = likesString
                self.commentDelegate?.likeComment()
        })
        } else {
            //unlike
            self.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
            
            Database.database().reference().child("posts").child(self.postID).child("comments").observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [[String:Any]]
                
                var likesArray = (valDict[self.indexPath.row] as! [String:Any])["likes"] as! [[String:Any]]
                var likesVal = Int()
                
                var likesString = String()
                if likesArray.count == 1 {
                    likesArray.remove(at: 0)
                    likesVal = 0
                    
                } else {
                    likesArray.remove(at: 0)
                    likesVal = likesArray.count
                    //likesString = "\(likesArray.count) likes"
                    
                }
                if likesArray.count == 1 {
                    
                        likesString = "\(likesArray.count) like"
                    } else {
                    likesString = "\(likesArray.count) likes"
                }
                
               self.likesCountLabel.text = likesString
                

                Database.database().reference().child("posts").child(self.postID).child("comments").child(String(self.indexPath.row)).child("likes").setValue(likesArray)
                
                
                Database.database().reference().child("users").child(self.posterUID).child("posts").child(self.postID).child("comments").child(String(self.indexPath.row)).child("likes").setValue(likesArray)
                
                self.commentDelegate?.likeComment()
                //self.delegate?.reloadDataAfterLike()
            })
            
        }
    }
    
    @IBAction func commentorPicButtonPressed(_ sender: Any) {
    }
    override func prepareForReuse(){
        self.likeButton.setImage(UIImage(named: "like.png"), for: .normal)
        self.likesCountLabel.text = "0 likes"
        super.prepareForReuse()
        
        self.commentorPic.imageView?.image = nil
        
        //self.commentTextView.text = nil
       
        
        
        // exampleView.backgroundColor = nil
        //exampleView.layer.cornerRadius = 0
    }
}

