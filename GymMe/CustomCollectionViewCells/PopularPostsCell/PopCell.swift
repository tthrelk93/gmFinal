//
//  PopCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 6/28/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit

class PopCell: UICollectionViewCell {

    @IBOutlet weak var popText: UILabel!
    @IBOutlet weak var popPic: UIImageView!
    var player: Player?
    var videoUrl: URL?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.player = Player()
        
        let playTap = UITapGestureRecognizer()
        playTap.numberOfTapsRequired = 1
        playTap.addTarget(self, action: #selector(NewsFeedPicCollectionViewCell.playOrPause))
        
        let vidFrame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        
        self.player?.view.frame = vidFrame
        player?.fillMode = PlayerFillMode.resizeAspectFill.avFoundationType
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
       
        self.popPic.image = nil
        self.popText.text = nil
        self.player?.view.isHidden = true
        
        
        // exampleView.backgroundColor = nil
        //exampleView.layer.cornerRadius = 0
    }
        
    

}
