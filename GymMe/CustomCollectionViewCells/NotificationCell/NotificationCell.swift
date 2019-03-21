//
//  NotificationCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 9/7/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit

protocol PerformActionsInNotifications {
    
    func performSegueToProfile(uid: String, name: String)
    func performSegueToPost(postID: String)
    
    
    
}


class NotificationCell: UICollectionViewCell {

    @IBAction func posterNameButtonPressed(_ sender: Any) {
        print("posterNamePressed")
        delegate?.performSegueToProfile(uid: actionByUID!, name: self.name)
    }
    
    var delegate: PerformActionsInNotifications?
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBAction func postPicPressed(_ sender: Any) {
        delegate?.performSegueToPost(postID: self.postID)
    }
    @IBOutlet weak var postPic: UIButton!
    @IBOutlet weak var noteLabel: UILabel!
    var name = String()
    @IBAction func actionUserPressed(_ sender: Any) {
        delegate?.performSegueToProfile(uid: actionByUID!, name: self.name)
    }
    @IBOutlet weak var actionUserPicButton: UIButton!
    var player: Player?
    var videoUrl: URL?
    var timeStamp: String?
    var actionByUID: String?
    var postID = String()
    
    override func awakeFromNib() {
        lineView.frame = CGRect(x: lineView.frame.origin.x, y: lineView.frame.origin.y, width: lineView.frame.width, height: 0.5)
        super.awakeFromNib()
        // Initialization code
        self.player = Player()
        postPic.frame = CGRect(x: postPic.frame.origin.x, y: postPic.frame.origin.y, width: 60, height: 60)
        self.actionUserPicButton.layer.cornerRadius = actionUserPicButton.frame.width/2
        self.actionUserPicButton.layer.masksToBounds = true
        
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
        self.postPic.imageView?.image = nil
        self.postTextLabel.text = ""
        self.player?.view.isHidden = true
        super.prepareForReuse()
       
        
        
        
        // exampleView.backgroundColor = nil
        //exampleView.layer.cornerRadius = 0
    }

}
