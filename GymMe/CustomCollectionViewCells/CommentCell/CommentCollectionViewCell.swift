//
//  CommentCollectionViewCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 9/21/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentTimeStamp: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentorPic: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //button.contentVerticalAlignment = .Top
    }
    @IBAction func likeButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func commentorPicButtonPressed(_ sender: Any) {
    }
    override func prepareForReuse(){
        super.prepareForReuse()
        
        self.commentorPic.imageView?.image = nil
        //self.commentTextView.text = nil
       
        
        
        // exampleView.backgroundColor = nil
        //exampleView.layer.cornerRadius = 0
    }
}

