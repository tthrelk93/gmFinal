//
//  NewsFeedPicCollectionViewCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 6/19/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import AVFoundation


class NewsFeedPicCollectionViewCell: UICollectionViewCell {

    
    
    @IBAction func tapGestureRec(_ sender: Any) {
        print("liked")
        //if not liked
        self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
        //else {self.likeButton.setImage(UIImage(named:"like.png"), for: .normal)}
        
        
    }
    
    
    var delegate: PerformActionsInFeedDelegate?
    var posterUID: String?
    var curName: String?
    var cellIndexPath: IndexPath?
    let videoUrl = URL(string: "https://v.cdn.vine.co/r/videos/AA3C120C521177175800441692160_38f2cbd1ffb.1.5.13763579289575020226.mp4")!
    
    @IBOutlet weak var posterPic: UIImageView!
    @IBOutlet weak var postPic: UIImageView!
    
    var player: Player?
    @IBAction func shareButtonPressed(_ sender: Any) {
    }
    @IBAction func commentsCountButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var commentsCountButton: UIButton!
    @IBAction func commentButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var commentButton: UIButton!
    
    
    @IBAction func favoritesCountButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var favoritesCountButton: UIButton!
    @IBAction func favoritesButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var favoritesButton: UIButton!
    
    @IBOutlet weak var viewCount: UILabel!
    
    @IBAction func likesCountButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var likesCountButton: UIButton!
    @IBAction func likeButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postLocationButton: UIButton!
    @IBOutlet weak var posterNameButton: UIButton!
    @IBAction func goToPosterPressed(_ sender: Any) {
        //perform segue in feed using custom delegate method
        delegate?.performSegueToPosterProfile(uid: self.posterUID!, name: (self.posterNameButton.titleLabel?.text)!)
        
    }
    @IBOutlet weak var goToPosterProfile: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        print("picCellInit")
        posterPic.layer.cornerRadius = posterPic.frame.width/2
        posterPic.layer.masksToBounds = true
        self.player = Player()
        self.addSubview((self.player?.view)!)
        
        // Initialization code
    }

}
