//
//  PostViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 6/23/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import SwiftOverlays

class PostViewController: UIViewController, UITabBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var postText: UIView!
    @IBOutlet weak var postPic: UIView!
    
    @IBOutlet weak var picVidButton: UIButton!
    @IBOutlet weak var picVidSmallFrame: UIView!
    @IBOutlet weak var addPicButton: UIButton!
    @IBAction func addPicTouched(_ sender: AnyObject) {
        currentPicker = "photo"
        imagePicker.allowsEditing = true
        //imagePicker.mediaTypes = ["kUTTypeImage"] //[.kUTTypeImage as String]
        self.postType = "pic"
        present(imagePicker, animated: true, completion: nil)
        
    }
    var extended = false
    @IBOutlet weak var picButtonPositionOut: UIView!
    @IBAction func picVidPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            if self.extended == false {
            self.addPicButton.frame = self.picButtonPositionOut.frame
            self.addVidButton.frame = self.vidButtonPositionOut.frame
            self.picVidButton.frame = self.picVidSmallFrame.frame
                self.addVidButton.alpha = 0.7
                self.addPicButton.alpha = 0.75
                self.picVidButton.alpha = 0.8
                self.extended = true
            } else {
                self.addPicButton.frame = self.ogPicPosit
                self.addVidButton.frame = self.ogVidPosit
                self.picVidButton.frame = self.ogPicVidPosit
                self.addVidButton.alpha = 0.0
                self.addPicButton.alpha = 0.0
                self.picVidButton.alpha = 1.0
                self.extended = false
            }
            
        })
    }
    var ogVidPosit = CGRect()
    var ogPicPosit = CGRect()
    var ogPicVidPosit = CGRect()
    var currentPicker = String()
    let picker = UIImagePickerController()
    let imagePicker = UIImagePickerController()
    
    @IBAction func textPostPressed(_ sender: Any) {
        self.postType = "text"
        makePostView.isHidden = false
        makePostImageView.isHidden = true
    }
    @IBOutlet weak var addVidButton: UIButton!
    
    @IBOutlet weak var vidButtonPositionOut: UIView!
    @IBAction func chooseVidFromPhoneSelected(_ sender: AnyObject) {
        currentPicker = "vid"
        picker.mediaTypes = ["public.movie"]
        self.postType = "vid"
        present(picker, animated: true, completion: nil)
    }
    
    var newPost: [String:Any]?
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        imagePicker.delegate = self
        ogVidPosit = addVidButton.frame
        ogPicPosit = addPicButton.frame
        ogPicVidPosit = picVidButton.frame
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?[2]
        postPic.layer.cornerRadius = 15
        postText.layer.cornerRadius = 15
        
        //make post video player setup
        postPlayer = Player()
        self.makePostView.addSubview((self.postPlayer?.view)!)
        self.postPlayer?.playerDelegate = self as! PlayerDelegate
        self.postPlayer?.playbackDelegate = self
        self.postPlayer?.playbackLoops = true
        self.postPlayer?.playbackPausesWhenBackgrounded = true
        self.postPlayer?.playbackPausesWhenResigningActive
        
        //var gest = UIGestureRecognizer(target: <#T##Any?#>, action: <#T##Selector?#>)
        var vidFrame = CGRect(x: makePostImageView.frame.origin.x, y: makePostImageView.frame.origin.y, width: makePostImageView.frame.width, height: makePostImageView.frame.height)
        self.postPlayer?.view.frame = vidFrame
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    if snap.key == "profPic"{
                        self.curUser.profPic = snap.value as! String
                    } else if snap.key == "username"{
                        self.curUser.username = snap.value as! String
                    }
                }
            }
        })
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items![0]{
            performSegue(withIdentifier: "PostToFeed", sender: self)
        } else if item == tabBar.items![1]{
            performSegue(withIdentifier: "PostToSearch", sender: self)
        } else if item == tabBar.items![2]{
            //performSegue(withIdentifier: "", sender: self)
        } else if item == tabBar.items![3]{
            //performSegue(withIdentifier: "FeedToNote", sender: self)
        } else {
            performSegue(withIdentifier: "PostToProfile", sender: self)
        }
        
    }
    var vidData:NSData?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if currentPicker == "photo"{
            print("imagePickerSelected")
            var selectedImageFromPicker: UIImage?
            if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
                selectedImageFromPicker = editedImage
            } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                selectedImageFromPicker = originalImage
            }
            
            self.dismiss(animated: true, completion: nil)
            print("pastDismissPhoto")
           
            
            self.makePostView.isHidden = false
            self.cancelPostButton.isHidden = false
            makePostImageView.image = selectedImageFromPicker
            
        } else {
            //if senderView == "main"{
            print("vidPickerSelected")
            if let movieURL = info[UIImagePickerControllerMediaURL] as? NSURL{
                print("MOVURL: \(movieURL)")
                //print("MOVPath: \(moviePath)")
                
                //do this when they press post button
                if let data = NSData(contentsOf: movieURL as! URL){
                    self.vidData = data
                    //self.addedVidDataArray.append(data as Data)
                    
                }
                //movieURLFromPicker = movieURL
                dismiss(animated: true, completion: nil)
                print("pastDismissPhoto")
                self.makePostView.isHidden = false
                self.cancelPostButton.isHidden = false
                self.postPlayer?.url = movieURL as URL
                //var tempArray1 = [String]()
                /*if totalVidArray.count != 0{
                    self.currentCollectID = "vidFromPhone"
                    //self.isYoutubeCell = false
                    self.totalVidArray.append(movieURL)
                    self.vidFromPhoneCollectionView.performBatchUpdates({
                        let insertionIndexPath = IndexPath(row: self.totalVidArray.count - 1, section: 0)
                        self.vidFromPhoneCollectionView.insertItems(at: [insertionIndexPath])}, completion: nil)
                }else{
                    self.currentCollectID = "vidFromPhone"
                    self.totalVidArray.insert(movieURL, at: 0)
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                    self.vidFromPhoneCollectionView.dataSource = self
                    self.vidFromPhoneCollectionView.delegate = self
                }*/
            }
        }
        
    }
    
    
    
    
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    var postPlayer: Player?
    
    @IBOutlet weak var textPostPressedLine: UIView!
    @IBOutlet weak var textPostPressedLabel: UILabel!
    @IBAction func cancelPostButtonPressed(_ sender: Any) {
        makePostTextView.text = "Type a description or caption here."
        makePostImageView.image = nil
        postPlayer?.url = nil
        makePostView.isHidden = true
        self.addPicButton.frame = self.ogPicPosit
        self.addVidButton.frame = self.ogVidPosit
        self.picVidButton.frame = self.ogPicVidPosit
        self.addVidButton.alpha = 0.0
        self.addPicButton.alpha = 0.0
        self.picVidButton.alpha = 1.0
       // textPostPressedLine.isHidden = true
        //textPostPressedLabel.isHidden = true
        makePostImageView.isHidden = false
        cancelPostButton.isHidden = true
        
        self.extended = false
        
    }
    @IBOutlet weak var cancelPostButton: UIButton!
    var postType: String?
    var curUser = User()
    @IBAction func postButtonPressed(_ sender: Any) {
        SwiftOverlays.showBlockingWaitOverlayWithText("Posting to Feed...")
        newPost = [String: Any]()
        if postType == "pic"{
            //newPost!["postPic"] = self.makePostImageView.image!
            newPost!["posterUID"] = Auth.auth().currentUser!.uid
            newPost!["posterName"] = self.curUser.username
            newPost!["posterPicURL"] = curUser.profPic
            if self.makePostTextView.text != "Type a description or caption here."{
                newPost!["postText"] = self.makePostTextView.text
            }
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("FeedPosts").child("ImagePosts").child(Auth.auth().currentUser!.uid).child("\(imageName).jpg")
            if let uploadData = UIImageJPEGRepresentation(self.makePostImageView.image!, 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return  };
                    

                    self.newPost!["postPic"] = (metadata?.downloadURL()?.absoluteString)!
                    
            self.newPost!["datePosted"] = Date().description
            
            let key = Database.database().reference().child("posts").childByAutoId().key
            self.newPost!["postID"] = key
            let childUpdates = ["/posts/\(key)": self.newPost,
                                "/users/\(Auth.auth().currentUser!.uid)/posts/\(key)/": self.newPost]
                    Database.database().reference().updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                        if error != nil{
                            print(error?.localizedDescription)
                            return
                        }
                        print("This never prints in the console")
                        self.postPlayer?.url = nil
                        self.makePostImageView.image = nil
                        self.makePostView.isHidden = true
                        self.cancelPostButton.isHidden = true
                        SwiftOverlays.removeAllBlockingOverlays()

                
            
                    })
                })
            }
            
            
        } else if postType == "vid" {
            print("uploadingVid")
            newPost!["posterUID"] = Auth.auth().currentUser!.uid
            newPost!["posterName"] = self.curUser.username
            newPost!["posterPicURL"] = curUser.profPic!
            if self.makePostTextView.text != "Type a description or caption here."{
                newPost!["postText"] = self.makePostTextView.text
            }
                let videoName = NSUUID().uuidString
                
                let storageRef = Storage.storage().reference().child("FeedPosts").child("VideoPosts").child(Auth.auth().currentUser!.uid).child("\(videoName).mov")
                
                var videoRef = storageRef.fullPath
                
                let uploadMetadata = StorageMetadata()
                
                uploadMetadata.contentType = "video/quicktime"
                
                _ = storageRef.putData(self.vidData! as Data, metadata: uploadMetadata){(metadata, error) in
                    if(error != nil){
                        print("got an error: \(error)") }
                    print("metaData: \(metadata)")
                    print("metaDataURL: \((metadata?.downloadURL()?.absoluteString)!)")
                    self.newPost!["postVid"] = (metadata?.downloadURL()?.absoluteString)!
                    self.newPost!["datePosted"] = Date().description
                    
                    let key = Database.database().reference().child("posts").childByAutoId().key
                    self.newPost!["postID"] = key
                    
                    let childUpdates = ["/posts/\(key)": self.newPost,
                                        "/users/\(Auth.auth().currentUser!.uid)/posts/\(key)/": self.newPost]
                    Database.database().reference().updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                        if error != nil{
                            print(error?.localizedDescription)
                            return
                        }
                        print("This never prints in the console")
                        self.postPlayer?.url = nil
                        self.makePostImageView.image = nil
                        self.makePostView.isHidden = true
                        self.cancelPostButton.isHidden = true
                        SwiftOverlays.removeAllBlockingOverlays()
                    })
                    
                    
                   
                }
        } else {
            if self.makePostTextView.text == "Type a description or caption here." || self.makePostTextView.text == "" || self.makePostTextView.hasText == false{
                let alert = UIAlertController(title: "Missing Info", message: "You cannot make an empty post.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            newPost!["posterUID"] = Auth.auth().currentUser!.uid
            newPost!["posterName"] = self.curUser.username
            newPost!["posterPicURL"] = curUser.profPic!
           
                newPost!["postText"] = self.makePostTextView.text
            
            self.newPost!["datePosted"] = Date().description
            let key = Database.database().reference().child("posts").childByAutoId().key
            self.newPost!["postID"] = key
            
            let childUpdates = ["/posts/\(key)": self.newPost,
                                "/users/\(Auth.auth().currentUser!.uid)/posts/\(key)/": self.newPost]
            Database.database().reference().updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                if error != nil{
                    print(error?.localizedDescription)
                    return
                }
                print("This never prints in the console")
                self.postPlayer?.url = nil
                self.makePostImageView.image = nil
                self.makePostView.isHidden = true
                self.cancelPostButton.isHidden = true
                SwiftOverlays.removeAllBlockingOverlays()
            })
        }
        
    }
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var makePostView: UIView!
    
    @IBOutlet weak var makePostImageView: UIImageView!
    
    @IBOutlet weak var makePostTextView: UITextView!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PostViewController:PlayerDelegate {
    
    func playerReady(_ player: Player) {
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        //if player.playbackState = .
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
    
}

// MARK: - PlayerPlaybackDelegate

extension PostViewController:PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        player.playbackLoops = false
    }
    
}
extension PostViewController {
    
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        
        switch (self.postPlayer?.playbackState.rawValue) {
        case PlaybackState.stopped.rawValue?:
            self.postPlayer?.playFromBeginning()
            break
        case PlaybackState.paused.rawValue?:
            self.postPlayer?.playFromCurrentTime()
            break
        case PlaybackState.playing.rawValue?:
            self.postPlayer?.pause()
            break
        case PlaybackState.failed.rawValue?:
            self.postPlayer?.pause()
            break
        default:
            self.postPlayer?.pause()
            break
        }
    }
    
}

