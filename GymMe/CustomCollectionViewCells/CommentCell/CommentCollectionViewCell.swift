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
    
    func likeComment(indexPath: IndexPath, type: String)

}

class CommentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lineView: UIView!
    
    var commentDelegate: CommentLike?
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentTimeStamp: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentorPic: UIButton!
    
    var indexPath = IndexPath()
    
    override func awakeFromNib() {
        lineView.frame = CGRect(x: lineView.frame.origin.x, y: lineView.frame.origin.y, width: lineView.frame.width, height: 0.5)
        super.awakeFromNib()
        // Initialization code
        
        //button.contentVerticalAlignment = .Top
        
       
    }
    @IBAction func likeButtonPressed(_ sender: Any) {
        if self.likeButton.imageView!.image == UIImage(named: "like.png"){
            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
            commentDelegate?.likeComment(indexPath: self.indexPath, type: "unlike")
        } else {
            print("likeCommentElse")
            self.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
            commentDelegate?.likeComment(indexPath: self.indexPath, type: "like")
        }
    }
    
    @IBAction func commentorPicButtonPressed(_ sender: Any) {
    }
    override func prepareForReuse(){
        self.likeButton.setImage(UIImage(named: "like.png"), for: .normal)
        super.prepareForReuse()
        
        self.commentorPic.imageView?.image = nil
        
        //self.commentTextView.text = nil
       
        
        
        // exampleView.backgroundColor = nil
        //exampleView.layer.cornerRadius = 0
    }
}

