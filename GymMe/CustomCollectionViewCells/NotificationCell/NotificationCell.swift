//
//  NotificationCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 9/7/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit

class NotificationCell: UICollectionViewCell {

    @IBOutlet weak var postTextLabel: UILabel!
    @IBAction func postPicPressed(_ sender: Any) {
    }
    @IBOutlet weak var postPic: UIButton!
    @IBOutlet weak var noteLabel: UILabel!
    @IBAction func actionUserPressed(_ sender: Any) {
    }
    @IBOutlet weak var actionUserPicButton: UIButton!
    var player: Player?
    var videoUrl: URL?
    var timeStamp: String?
    var actionByUID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.player = Player()
        
        let playTap = UITapGestureRecognizer()
        playTap.numberOfTapsRequired = 1
        playTap.addTarget(self, action: #selector(NewsFeedPicCollectionViewCell.playOrPause))
        
        let vidFrame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        self.player?.view.frame = vidFrame
        self.addSubview((self.player?.view)!)
        
        // Initialization code
    }
    @objc func playOrPause(){
        if self.player?.playbackState == PlaybackState.paused || self.player?.playbackState == PlaybackState.stopped{
            if self.player?.playbackState == PlaybackState.paused{
                player?.playFromCurrentTime()
            } else {
                player?.playFromBeginning()
            }
        } else {
            player?.stop()
        }
    }
    override func prepareForReuse(){
        super.prepareForReuse()
        
        self.postPic.imageView?.image = nil
        self.postTextLabel.text = nil
        self.player?.view.isHidden = true
        
        
        // exampleView.backgroundColor = nil
        //exampleView.layer.cornerRadius = 0
    }

}
