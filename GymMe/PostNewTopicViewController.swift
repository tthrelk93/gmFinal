//
//  PostNewTopicViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 2/10/19.
//  Copyright © 2019 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class PostNewTopicViewController: UIViewController, UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView){
        print("tvEdit")
        
        if textView == topicTitleTextView{
            DispatchQueue.main.async{
                self.topicTitleTextView.selectAll(nil)
            }
        
        
        if textView.text == "Enter topic title here..."{
            textView.text = ""
        }
        } else {
            topicDescriptionTextView.selectAll(nil)
            if textView.text == "Enter topic description here..."{
                textView.text = ""
            }
        }
        textView.textColor = UIColor.black
    }
    
    //@available(iOS 2.0, *)
    public func textViewDidEndEditing(_ textView: UITextView){
        if textView == topicTitleTextView{
        if textView.text == "" {
           
                topicTitleTextView.text = "Enter topic title here..."
            textView.textColor = UIColor.lightGray
        }
        
        //textView.resolveHashTags()
        } else {
            if textView.text == "" {
                
                topicDescriptionTextView.text = "Enter topic description here..."
                textView.textColor = UIColor.lightGray
            }
        }
        
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "NewTopicToForum", sender: self)
    }
    
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var posterPic: UIImageView!
    
    @IBOutlet weak var topicTitleTextView: UITextView!
    
    @IBOutlet weak var topicDescriptionTextView: UITextView!
    
    @IBAction func postButtonPressed(_ sender: Any) {
        if topicDescriptionTextView.text == "Enter topic description here..." || topicDescriptionTextView.text == "" || topicDescriptionTextView.hasText == false || topicTitleTextView.text == "Enter topic title here..." || topicTitleTextView.text == "" || topicTitleTextView.hasText == false{
            //alertView
            let alertView = UIAlertView()
            alertView.title = "Missing Info"
            // get a handle on the payload
            alertView.message = "Make sure you did not leave the title or description blank."
            alertView.addButton(withTitle: "Ok")
            alertView.show()
            return
        } else {
        let key = Database.database().reference().child("forum").childByAutoId().key
        self.postData["postID"] = key
        postData["topicTitle"] = topicTitleTextView.text
        postData["topicDescription"] = topicDescriptionTextView.text
            postData["posterID"] = Auth.auth().currentUser!.uid 
            postData["posterPic"] = posterPicString
            postData["posterUsername"] = self.username
            postData["posterRealName"] = self.realName
            postData["likes"] = [["x": "x"]]
            var date = Date()
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            var dateString = dateFormatter.string(from: date)
            postData["timestamp"] = dateString
            postData["replies"] = [["x":"x"]]
            
        let childUpdates = ["/forum/\(key)": self.postData,
                            "/users/\(Auth.auth().currentUser!.uid)/forumPosts/\(key)/": self.postData]
        Database.database().reference().updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
            if error != nil{
                print(error?.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: "NewTopicToForum", sender: self)
        })
        }
    }
    var postData = [String:Any]()
    var profPic = UIImage()
    var username = String()
    var realName = String()
    var posterPicString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topicTitleTextView.delegate = self
        topicDescriptionTextView.delegate = self

        topLine.frame = CGRect(x: topLine.frame.origin.x, y: topLine.frame.origin.y, width: topLine.frame.width, height: 0.5)
        posterPic.frame = CGRect(x: posterPic.frame.origin.x, y: posterPic.frame.origin.y, width: 60, height: 60)
        
       posterPic.layer.cornerRadius = posterPic.frame.width/2
        posterPic.layer.masksToBounds = true
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    if snap.key == "profPic"{
                        self.posterPicString = snap.value as! String
                        if let messageImageUrl = URL(string: snap.value as! String) {
                            
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                self.posterPic.image = UIImage(data: imageData as Data) } }
                    } else if snap.key == "username"{
                        self.username = snap.value as! String
                    } else if snap.key == "realName"{
                        
                        self.realName = snap.value as! String
                    }
                }
            }
            
            
        })
        
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
