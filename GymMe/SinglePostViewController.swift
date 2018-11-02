//
//  SinglePostViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 11/2/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit

class SinglePostViewController: UIViewController {

    @IBAction func backPressed(_ sender: Any) {
        performSegue(withIdentifier: "backToProfile", sender: self)
    }
    var thisPostData = [String:Any]()
    @IBAction func sharePressed(_ sender: Any) {
    }
    @IBAction func favoritesButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var favoritesButton: UIButton!
    
    @IBAction func commentButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var postText: UILabel!
    @IBAction func commentsCountPressed(_ sender: Any) {
    }
    @IBOutlet weak var commentsCountButton: UIButton!
    @IBOutlet weak var likesCountButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction func likesCountButtonPressed(_ sender: Any) {
    }
    @IBAction func likeButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var postPic: UIImageView!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var commentTF: UITextField!
    
    @IBOutlet weak var commentsCollect: UICollectionView!
    @IBAction func closeCommentsButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var commentView: UIView!
    
    @IBAction func posterPicButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var posterNameButton: UIButton!
    
    @IBOutlet weak var posterPicButton: UIButton!
    var player: Player?
    var myUName = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        posterPicButton.layer.cornerRadius = posterPicButton.frame.width/2
        posterPicButton.layer.masksToBounds = true
        
        

        if thisPostData["postVid"] == nil && thisPostData["postPic"] == nil{
            //textPost
        } else {
            if thisPostData["postVid"] == nil{
                //pic post
                posterNameButton.setTitle((thisPostData["posterName"] as! String), for: .normal)
                
                if let messageImageUrl = URL(string: (self.thisPostData["posterPicURL"] as! String)) {
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                       
                        posterPicButton.setImage(UIImage(data: imageData as Data), for: .normal)
                        
                    }
                }
                if let messageImageUrl = URL(string: (self.thisPostData["postPic"] as! String)) {
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        
                        postPic.image = UIImage(data: imageData as Data)
                        
                    }
                }
                if thisPostData["postText"] == nil{
                    
                } else {
                    postText.text = (thisPostData["postText"] as! String)
                }
                if thisPostData["city"] != nil{
                    cityButton.setTitle((thisPostData["city"] as! String), for: .normal)
                }
                
                var commentsPost: [String:Any]?
                for item in (self.thisPostData["comments"] as? [[String: Any]])!{
                    
                    commentsPost = item as! [String: Any]
                    
                }
                
                var tempPost: [String:Any]?
                for item in (self.thisPostData["likes"] as? [[String: Any]])!{
                    
                    tempPost = item as! [String: Any]
                    
                }
                if tempPost!["x"] != nil {
                    
                } else {
                    
                    
                    let countStringNum = String((self.thisPostData["likes"] as? [[String: Any]])!.count)
                    
                    var fullString1 = String()
                    if countStringNum == "1"{
                        fullString1 = "\(countStringNum) like"
                    } else {
                        fullString1 = "\(countStringNum) likes"
                    }
                    self.likesCountButton.setTitle(fullString1, for: .normal)
                    
                    if (thisPostData["posterName"] as? String) == self.myUName{
                        self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                        let countStringNum = String((self.thisPostData["likes"] as? [[String: Any]])!.count)
                        var fullString = String()
                        if countStringNum == "1"{
                            fullString = "\(countStringNum) like"
                        } else {
                            fullString = "\(countStringNum) likes"
                        }
                        self.likesCountButton.setTitle(fullString, for: .normal)
                       
                    }
                }
                
                var favesPost: [String:Any]?
                for item in (thisPostData["favorites"] as? [[String: Any]])!{
                    
                    favesPost = item as! [String: Any]
                    
                }
                if favesPost!["x"] != nil {
                    
                } else {
                    
                    
                    if (favesPost!["uName"] as! String) == self.myUName{
                        self.favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                        //cell.favoritesCountButton.setTitle((self.feedDataArray[indexPath.row]["favorites"] as! [[String:Any]]).count.description, for: .normal)
                    }
                }
                
                //set comments count
                if commentsPost!["x"] != nil {
                    
                } else {
                    let commStringNum = String((self.thisPostData["comments"] as? [[String: Any]])!.count)
                    var commString = String()
                    if commStringNum == "1"{
                        commString = "View \(commStringNum) comment"
                    } else {
                        commString = "View \(commStringNum) comments"
                    }
                    self.commentsCountButton.setTitle(commString, for: .normal)
                    
                }
                
                
            } else {
                //vidPost
                self.player = Player()
                self.player!.muted = true
                let playTap = UITapGestureRecognizer()
                playTap.numberOfTapsRequired = 1
                playTap.addTarget(self, action: #selector(NewsFeedPicCollectionViewCell.playOrPause))
                self.view.addSubview((self.player?.view)!)
            }
        }
        print("thisData: \(self.thisPostData)")
        // Do any additional setup after loading the view.
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
