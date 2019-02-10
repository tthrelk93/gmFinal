//
//  ForumCollectionViewCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 2/10/19.
//  Copyright © 2019 Thomas Threlkeld. All rights reserved.
//

import UIKit

class ForumCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var posterPicImageView: UIImageView!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBAction func likeTopicPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var likeTopicButton: UIButton!
    @IBAction func replyCountButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var replyCountButton: UIButton!
    
    @IBOutlet weak var posterNameLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBAction func posterPicButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var posterPicButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        posterPicImageView.frame = CGRect(x: posterPicImageView.frame.origin.x, y: posterPicImageView.frame.origin.y, width: 60, height: 60)
    }

}
