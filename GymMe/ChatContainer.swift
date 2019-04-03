//
//  ChatContainer.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 6/8/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//
import UIKit
import FirebaseAuth
import FirebaseDatabase


class ChatContainer: UIViewController {
    
    @IBOutlet weak var receiverPic: UIImageView!
    @IBOutlet weak var receiverTopLabel: UILabel!
    var userID = String()
    var recipientID = String()
    var newMessage = false
    var curItemKey: String?
   
    @IBOutlet weak var topLine: UIView!
    @IBAction func BackToMessagesPressed(_ sender: Any) {
        performSegue(withIdentifier: "BackToMessages", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("sender: \(sender)")
       
       topLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        Database.database().reference().child("users").child(recipientID).observeSingleEvent(of: .value, with: { (snapshot) in
            let tempDict = snapshot.value as! [String:Any]
            self.sender = tempDict["realName"] as! String
            if let messageImageUrl = URL(string: tempDict["profPic"] as! String) {
                
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    self.receiverPic.image = UIImage(data: imageData as Data)
                }
            }
            self.receiverPic.frame.size = CGSize(width: 31, height: 31)
            self.receiverPic.layer.cornerRadius = self.receiverPic.frame.width/2
            self.receiverPic.layer.masksToBounds = true
            self.receiverTopLabel.text = self.sender
        })
      
      
        //performSegue(withIdentifier: "EmbeddedSegue", sender: self)
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var chatViewContainer: UIView!
    
    
    // MARK: - Navigation
    var sender = String()
    var prevScreen = String()
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BackToMessages"{
            if let vc = segue.destination as? MessagesTableViewController{
                vc.prevScreen = self.prevScreen
                vc.recipientID = self.recipientID
                vc.curUID = self.recipientID
                if vc.prevScreen == "profile"{
                    vc.backFromMessage = true
                } else {
                    vc.backFromMessage = false
                }
            }
        }
        if segue.identifier == "EmbeddedSegue"{
            if let vc = segue.destination as? ChatViewController{
                
                
                vc.recipientID = self.recipientID
                vc.prevScreen = self.prevScreen
                if self.sender == nil {
                    vc.senderDisplayName = "name nil"
                } else {
                    vc.senderDisplayName = self.sender as! String
                    
                }
            }
        }
        }
    
    
}
