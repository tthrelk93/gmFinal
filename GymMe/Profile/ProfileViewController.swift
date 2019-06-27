//
//  ProfileViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 6/21/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseMessaging
import FirebaseAuth
import FirebaseStorage
import SwiftOverlays
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import YPImagePicker


class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITabBarDelegate, UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MessagingDelegate, UISearchBarDelegate, ToProfileDelegate {
    func shareCirclePressed(likedByUID: String, indexPath: IndexPath) {
        
    }
    
   
    var profToProf = false
    func segueToProf(cellUID: String, name: String) {
        self.profToProf = true
        self.curUID = cellUID
        self.curName = name
        performSegue(withIdentifier: "ProfToDumbView", sender: self)
        
    }
    
    func loadProfToProf(){
         sepLine4.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        cityLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        nameLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        innerTabTopLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        innerTabBottomLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true

        self.bioTextView.adjustsFontForContentSizeCategory = true
        ogCollectViewSize = collectView.frame
        
        topLine.frame = CGRect(x: topLine.frame.origin.x, y: topLine.frame.origin.y + 0.5, width: topLine.frame.width, height: 0.5)
        findFriendsTopLine.frame = CGRect(x: findFriendsTopLine.frame.origin.x, y: findFriendsTopLine.frame.origin.y, width: findFriendsTopLine.frame.width, height: 0.5)
        editProfTopLine.frame = CGRect(x: editProfTopLine.frame.origin.x, y: editProfTopLine.frame.origin.y, width: editProfTopLine.frame.width, height: 0.5)
        self.showWaitOverlay()
        self.findFriendsCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        
        findFriendsSearchBar.delegate = self
        findFriendsCollect.delegate = self
        findFriendsCollect.dataSource = self
        
        scrollView.delegate = self

        FollowUnfollowButton.layer.cornerRadius = 10

        self.favoritesCollect.isScrollEnabled = false
        //no need to write following if checked in storyboard
        self.scrollView.bounces = false
        self.favoritesCollect.bounces = true
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(fromGesture:)))
        self.view.addGestureRecognizer(gesture)
        print("curUID: \(curUID)")
        if curUID == nil {
            self.curUID = Auth.auth().currentUser!.uid
        }
        print("curUID: \(curUID)")
        if curUID! == Auth.auth().currentUser!.uid{
            viewerIsCurAuth = true
            messageButton.isHidden = false
            
        } else {
            viewerIsCurAuth = false
            messageButton.isHidden = false
    
        }
        editCityTF.delegate = self
        editGymTF.delegate = self
        reauthPassTF.delegate = self
        reauthEmailTF.delegate = self
        editNameTF.delegate = self
        editEmailTF.delegate = self
        editPasswordTF.delegate = self
        editProfSaveButton.layer.cornerRadius = 10
        editProfSaveButton.layer.masksToBounds = true
        profPic.frame = CGRect(x: profPic.frame.origin.x, y: profPic.frame.origin.y, width: 140, height: 140)
        profPic.layer.borderWidth = 3
        profPic.layer.borderColor = UIColor.white.withAlphaComponent(87).cgColor
        loadViewController()
    }

    @IBOutlet weak var nameLine: UIView!
    
    @IBOutlet weak var cityLine: UIView!
    
    @IBOutlet weak var topLine: UIView!
    
    @IBAction func cancelReauthPressed(_ sender: Any) {
        reauthView.isHidden = true
    }
    
    var updateRealName = false
    var updateEmail = false
    var updatePassword = false
    @IBOutlet weak var editPasswordTF: UITextField!
    @IBOutlet weak var editEmailTF: UITextField!
    @IBOutlet weak var editBioTextView: UITextView!
    @IBOutlet weak var editProfNameTextField: UITextField!
    
    
    var currentPicker = String()
    @IBAction func editProfSelectPicPressed(_ sender: Any) {
        currentPicker = "photo"
        
        let picker = YPImagePicker()
        
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta)
                self.editProfImageView.image = photo.image
                self.updatePic = true
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
        
    }
    
    var editUpdateData = [String:Any]()
    var oldUsername = String()
    var updateCity = false
    var updateGym = false
    @IBAction func editProfSavePressed(_ sender: Any) {
        
        self.reloadCollect = false
        if self.updateUsername == false && self.updateBio == false && self.updatePic == false && updateRealName == false && updateEmail == false && updateCity == false && updateGym == false{
            //nothing to update
            let alert = UIAlertController(title: "No Changes Made", message: "There are no changes to update.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child(Auth.auth().currentUser!.uid).child("\(imageName).jpg")
        
        if self.updatePic == true{
            
        let profileImage = self.editProfImageView.image
        
        let uploadData = UIImageJPEGRepresentation(profileImage!, 0.1)
        storageRef.putData(uploadData!, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                
                self.editUpdateData["profPic"] = profileImageUrl
                if self.updateBio == true {
                    if self.editBioTextView.text == "Tap here to edit bio."{
                        self.editUpdateData["bio"] = " "
                    } else {
                        self.editUpdateData["bio"] = self.editBioTextView.text
                        self.collectView.frame = self.ogCollectViewSize
                    }
                }
                if self.updateGym == true && self.editGymTF.text! != self.curGymText{
                    self.editUpdateData["homeGym"] = self.editGymObject
                   
                }
                if self.updateCity == true{
                    self.editUpdateData["city"] = self.editCityTF.text
                    print("cityCoord: \(self.editCityObject)")
                    self.editUpdateData["cityCoord"] = self.editCityObject
                    //cit
                }
                if self.updateUsername == true {
                    self.editUpdateData["username"] = self.editProfNameTextField.text
                    Database.database().reference().child("usernames").updateChildValues([self.editProfNameTextField.text!: [Auth.auth().currentUser!.uid, self.editNameTF.text!]])
                    
                    print("oldUname: \(self.oldUsername)")
                    Database.database().reference().child("usernames").child(self.oldUsername).removeValue()
                }
                
                if self.updateRealName == true{
                    print("updateRealName: \(self.editNameTF.text!)")
                    Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["realName": self.editNameTF.text!])
                }
                if self.updateEmail == true {
                    
                    let alertVC = UIAlertController(title: "Verify Email Address", message: "Select Send to get a verification email sent to \(String(describing: self.editEmailTF.text!)). Your account will be created  and ready for use upon return to the app.", preferredStyle: .alert)
                    let alertActionOkay = UIAlertAction(title: "Send", style: .default) {
                        (_) in
                        Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                        
                        self.verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkIfTheEmailIsVerified) , userInfo: nil, repeats: true)
                    }
                    let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertVC.addAction(alertActionCancel)
                    alertVC.addAction(alertActionOkay)
                    self.present(alertVC, animated: true, completion: nil)
                } else {
                    print("emailVer == true")
                }
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(self.editUpdateData, withCompletionBlock: {(error, ref) in
                    // upload completet
                    var counter2 = 0
                    for post in self.postData{
                        var tempD = post
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        
                        let date = dateFormatter.date(from: tempD["datePosted"] as! String)
                        tempD["datePosted"] = date
                        self.postData[counter2] = tempD
                        counter2 = counter2 + 1
                    }
                    var counter3 = 0
                    for post in self.postDataText{
                        var tempD = post
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        
                        let date = dateFormatter.date(from: tempD["datePosted"] as! String)
                        tempD["datePosted"] = date
                        self.postDataText[counter3] = tempD
                        counter3 = counter3 + 1
                    }
                    self.loadViewController()
                    
                    return
                })
                for dict in self.profCollectData{
                    var tempDict = dict as! [String:Any]
                    Database.database().reference().child("posts").child((tempDict["postID"] as! String)).updateChildValues(["posterPicURL": profileImageUrl])
                }
            }
        })
        } else {
            //no new image
            if self.updateGym == true{
                self.editUpdateData["homeGym"] = self.editGymObject
            }
            if self.updateCity == true{
                self.editUpdateData["city"] = self.editCityTF.text
                self.editUpdateData["cityCoord"] = self.editCityObject
            }
            
            if self.updateBio == true {
                if self.editBioTextView.text == "Tap here to edit bio."{
                    self.editUpdateData["bio"] = " "
                } else {
                    self.editUpdateData["bio"] = self.editBioTextView.text
                    self.collectView.frame = ogCollectViewSize
                }
            }
            if self.updateUsername == true {
                self.editUpdateData["username"] = self.editProfNameTextField.text
                
                
                Database.database().reference().child("usernames").updateChildValues([self.editProfNameTextField.text!: [Auth.auth().currentUser!.uid, self.editNameTF.text!]])
                
                print("oldUname: \(self.oldUsername)")
                Database.database().reference().child("usernames").child(self.oldUsername).removeValue()
            }
            if self.updatePassword == true {
                
                Auth.auth().currentUser?.updatePassword(to: self.editPasswordTF.text!) { (error) in
                    // ...
                    if error != nil{
                        print("passError: \(error?.localizedDescription)")
                    }
                }
            }
            if self.updateRealName == true{
                print("updateRealName: \(self.editNameTF.text!)")
                Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["realName": self.editNameTF.text!])
            }
            if self.updateEmail == true {
                
                let alertVC = UIAlertController(title: "Verify Email Address", message: "Select Send to get a verification email sent to \(String(describing: self.editEmailTF.text!)). Your account will be created  and ready for use upon return to the app.", preferredStyle: .alert)
                let alertActionOkay = UIAlertAction(title: "Send", style: .default) {
                    (_) in
                    Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                    
                    self.verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkIfTheEmailIsVerified) , userInfo: nil, repeats: true)
                }
                let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertVC.addAction(alertActionCancel)
                alertVC.addAction(alertActionOkay)
                self.present(alertVC, animated: true, completion: nil)
            } else {
                print("emailVer == true")
            }
            
            
            
            //done*/
            Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(self.editUpdateData, withCompletionBlock: {(error, ref) in
                // upload completet
                var counter2 = 0
                for post in self.postData{
                    var tempD = post
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    
                    let date = dateFormatter.date(from: tempD["datePosted"] as! String)
                    tempD["datePosted"] = date
                    self.postData[counter2] = tempD
                    counter2 = counter2 + 1
                }
                var counter3 = 0
                for post in self.postDataText{
                    var tempD = post
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    
                    let date = dateFormatter.date(from: tempD["datePosted"] as! String)
                    tempD["datePosted"] = date
                    self.postDataText[counter3] = tempD
                    counter3 = counter3 + 1
                }
                self.loadViewController()
                return
            })
        }
        navBarView.isHidden = false
        editProfView.isHidden = true
        
    }
    
    var verificationTimer : Timer = Timer()    // Timer's  Global declaration
    var uploadData = [String:Any]()
    @objc func checkIfTheEmailIsVerified(){
        
        Auth.auth().currentUser?.reload(completion: { (err) in
            if err == nil{
                
                if Auth.auth().currentUser!.isEmailVerified{
                    self.verificationTimer.invalidate()     //Kill the timer
                    Auth.auth().currentUser?.updateEmail(to: self.editEmailTF.text!) { (error) in
                        // ...
                        if error != nil {
                            print(error?.localizedDescription)
                        }
                }
                        return
                
                } else {
                    
                    print("It aint verified yet")
                    
                }
            } else {
                
                print(err?.localizedDescription)
                
            }
        })
        
        
    }
    var inEditBio = false
    var ogEditBioTextViewFrame = CGRect()
    @IBOutlet weak var editProfBackButton: UIButton!
    @IBOutlet weak var editProfSaveButton: UIButton!
    @IBAction func editProfBackPressed(_ sender: Any) {
        
            navBarView.isHidden = false
            editProfView.isHidden = true
        
        //, animated: true, completion: nil)
        
    }
    @IBOutlet weak var editProfPicButton: UIButton!
    @IBOutlet weak var editProfImageView: UIImageView!
    @IBOutlet weak var editProfView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var favoritesCollect: UICollectionView!
    @IBOutlet weak var innerScreenTabBar: UITabBar!
    
    @IBOutlet weak var collectViewResize: UIView!
    
    @IBOutlet weak var collectView: UIView!
    
    @IBOutlet weak var bioTextView: UITextView!
    //@IBOutlet weak var bioLabel: UILabel!
    let picker = UIImagePickerController()
    @IBAction func editProfButtonPressed(_ sender: Any) {
        
        
        if editProfView.isHidden == true{
            navBarView.isHidden = true
            oldEmail = editEmailTF.text!
            editProfView.isHidden = false
            self.oldUsername = userNameTop.text!
            picker.delegate = self
            editBioTextView.delegate = self
            editProfNameTextField.delegate = self
        } else {
            navBarView.isHidden = false
            editProfView.isHidden = true
        }
        
    }
    @IBOutlet weak var findFriendsTopLine: UIView!
    @IBAction func findFriendsPressed(_ sender: Any) {
        addFriendsTopLabel.isHidden = false
        findFriendsView.isHidden = false
        userNameTop.isHidden = true
        findFriends.isHidden = true
        backFromFriends.isHidden = false
        topLine.isHidden = true
        messageButton.isHidden = true
        
        
    }
    @IBOutlet weak var addFriendsTopLabel: UILabel!
    @IBAction func backFromFriendsPressed(_ sender: Any) {
       addFriendsTopLabel.isHidden = true
        findFriendsSearchBar.resignFirstResponder()
        findFriendsView.isHidden = true
        backFromFriends.isHidden = true
        userNameTop.isHidden = false
       
        findFriends.isHidden = false
        topLine.isHidden = false
        messageButton.isHidden = false
    }
    @IBOutlet weak var backFromFriends: UIButton!
    
    @IBOutlet weak var findFriends: UIButton!
    @IBOutlet weak var userNameTop: UILabel!
    
    @IBOutlet weak var navBarView: UIView!
    
    
    @IBOutlet weak var editProfButton: UIButton!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var profName: UILabel!
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var topLeftNav: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func topLeftNavButton(_ sender: Any) {
        if topLeftNav.titleLabel?.text == "Back"{
            
        } else {
            do {
                try Auth.auth().signOut()
                performSegue(withIdentifier: "LogoutSegue", sender: self)
            } catch let err {
                print(err)
            }
        }
    }
    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!
    
    @IBAction func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            // Perform action.
            print("swipeRight: \(prevScreen)")
            if prevScreen == "feed"{
                performSegue(withIdentifier: "ProfileToFeed", sender: self)
            }
            if prevScreen == "forum"{
                performSegue(withIdentifier: "ProfileToForum", sender: self)
            }
            
            if prevScreen == "post"{
                performSegue(withIdentifier: "ProfileToPost", sender: self)
            }
            if prevScreen == "search"{
                performSegue(withIdentifier: "ProfileToSearch", sender: self)
            }
            if prevScreen == "notifications"{
                performSegue(withIdentifier: "ProfileToNotifications", sender: self)
            }
            if prevScreen == "favorites"{
                performSegue(withIdentifier: "ProfileToFavorites", sender: self)
            }
        }
    }
    
    @objc func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
        //Your dismiss code
        //Here you should implement your checks for the swipe gesture
        if gesture.state == .ended {
            // Perform action.
            print("swipeRight: \(prevScreen)")
            if prevScreen == "feed"{
                performSegue(withIdentifier: "ProfileToFeed", sender: self)
            }
            if prevScreen == "forum"{
                performSegue(withIdentifier: "ProfileToForum", sender: self)
            }
            if prevScreen == "singleTopic"{
                performSegue(withIdentifier: "ProfileToSingleTopic", sender: self)
            }
            
            if prevScreen == "post"{
                performSegue(withIdentifier: "ProfileToPost", sender: self)
            }
            if prevScreen == "search"{
                performSegue(withIdentifier: "ProfileToSearch", sender: self)
            }
            if prevScreen == "notifications"{
                performSegue(withIdentifier: "ProfileToNotifications", sender: self)
            }
            if prevScreen == "favorites"{
                performSegue(withIdentifier: "ProfileToFavorites", sender: self)
            }
        }
        print("in Gesture: \(gesture)")
    }
    
    
    var prevScreen = String()
    var curName = String()
    var viewerIsCurAuth = Bool()
    var curUID: String?
    let screenHeight = UIScreen.main.bounds.height
    let scrollViewContentHeight = 1200 as CGFloat
    
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    var ogCollectViewSize = CGRect()
    var messageRecipID = String()
    @IBOutlet weak var messageButton: UIButton!
    @IBAction func messageButtonPressed(_ sender: Any) {
      // centerObject(obj: profPic)
        
        if viewerIsCurAuth != true {
            messageRecipID = self.curUID!
            performSegue(withIdentifier: "ProfileToMessages", sender: self)
        } else {
       
            performSegue(withIdentifier: "ProfileToFavorites", sender: self)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editProfImageView.frame = CGRect(x: editProfImageView.frame.origin.x, y: editProfImageView.frame.origin.x, width: editProfImageView.frame.width, height: editProfImageView.frame.width)
        
        editProfImageView.layer.cornerRadius = editProfImageView.frame.width/2
        editProfImageView.layer.masksToBounds = true
        editProfPicButton.layer.cornerRadius = editProfPicButton.frame.width/2
        editProfPicButton.layer.masksToBounds = true
    }
    var singleTopic = [String:Any]()
    @IBOutlet weak var innerTabTopLine: UIView!
    var superOGCollectViewFrame = CGRect()
    @IBOutlet weak var innerTabBottomLine: UIView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.ogEditBioTextViewFrame = editBioTextView.frame
        firstLoad = true
        sepLine3.frame = CGRect(x: sepLine3.frame.origin.x, y: editGymTF.frame.origin.y + editGymTF.frame.height + 3, width: sepLine3.frame.width, height: 0.5)
        sepLine6.frame = CGRect(x: sepLine6.frame.origin.x, y: editNameTF.frame.origin.y - 1, width: sepLine6.frame.width, height: 0.5)
         sepLine4.frame.size = CGSize(width: sepLine4.frame.width, height: 0.5)
        cityLine.frame.size = CGSize(width: cityLine.frame.width, height: 0.5)
        nameLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        innerTabTopLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        innerTabBottomLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        
        self.bioTextView.adjustsFontForContentSizeCategory = true
        
        topLine.frame = CGRect(x: topLine.frame.origin.x, y: topLine.frame.origin.y + 0.5, width: topLine.frame.width, height: 0.5)
        findFriendsTopLine.frame = CGRect(x: findFriendsTopLine.frame.origin.x, y: findFriendsTopLine.frame.origin.y, width: findFriendsTopLine.frame.width, height: 0.5)
        editProfTopLine.frame = CGRect(x: editProfTopLine.frame.origin.x, y: editProfTopLine.frame.origin.y, width: editProfTopLine.frame.width, height: 0.5)
        self.showWaitOverlay()
        self.findFriendsCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        
        findFriendsSearchBar.delegate = self
        findFriendsCollect.delegate = self
        findFriendsCollect.dataSource = self
        
        scrollView.delegate = self
        
        
        FollowUnfollowButton.layer.cornerRadius = 10
        var superOGCollectViewFrame = collectView.frame
        
        self.favoritesCollect.isScrollEnabled = false
        //no need to write following if checked in storyboard
        self.scrollView.bounces = false
        self.favoritesCollect.bounces = true
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(fromGesture:)))
       self.view.addGestureRecognizer(gesture)
        print("curUID: \(curUID)")
        if curUID == nil {
            self.curUID = Auth.auth().currentUser!.uid
        }
        print("curUID: \(curUID)")
        if curUID! == Auth.auth().currentUser!.uid{
            viewerIsCurAuth = true
            messageButton.isHidden = false
            
        } else {
            viewerIsCurAuth = false
            messageButton.setImage(UIImage(named: "icons8-new-message-24"), for: .normal)
            messageButton.isHidden = false
        
        }
        editCityTF.delegate = self
        editGymTF.delegate = self
        reauthPassTF.delegate = self
        reauthEmailTF.delegate = self
        editNameTF.delegate = self
        editEmailTF.delegate = self
        editPasswordTF.delegate = self
        editProfSaveButton.layer.cornerRadius = 10
        editProfSaveButton.layer.masksToBounds = true
        profPic.frame = CGRect(x: profPic.frame.origin.x, y: profPic.frame.origin.y, width: 140, height: 140)
        profPic.layer.borderWidth = 3
        profPic.layer.borderColor = UIColor.white.withAlphaComponent(87).cgColor
        loadViewController()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        
        if tabBar == self.tabBar {
            if item == tabBar.items![0]{
                performSegue(withIdentifier: "ProfileToFeed", sender: self)
                
        } else if item == tabBar.items![1]{
            performSegue(withIdentifier: "ProfileToSearch", sender: self)
        } else if item == tabBar.items![2]{
            performSegue(withIdentifier: "ProfileToPost", sender: self)
        } else if item == tabBar.items![3]{
            performSegue(withIdentifier: "ProfileToNotifications", sender: self)
        } else if item == tabBar.items![4]{
            
                    tabBar.selectedItem = tabBar.items?[4]
                    curUID = Auth.auth().currentUser!.uid
                viewerIsCurAuth = true
                messageButton.isHidden = false
                Database.database().reference().child("users").child(curUID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        
                        for snap in snapshots{
                            if snap.key == "profPic"{
                                if let messageImageUrl = URL(string: snap.value as! String) {
                                    
                                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                        self.profPic.image = UIImage(data: imageData as Data) } }
                            } else if snap.key == "username"{
                                self.userNameTop.text = snap.value as! String
                            } else if snap.key == "realName"{
                                self.profName.text = (snap.value as! String)
                                self.realName = snap.value as! String
                            }
                        }
                    }
                })
                //reloadCollectionView
                
        } else {
            //curScreen
        }
        } else {
            profCollectData.removeAll()
            if item == innerScreenTabBar.items![0]{
                innerStat = "pop"
                favoritesCollect.isHidden = false
                profCollectData = postData
                //favoritesCollect.
            } else /*if item == innerScreenTabBar.items![1]*/ {
                innerStat = "notFav"
                favoritesCollect.isHidden = false
                
                
                profCollectData = postDataText
            }
            
            DispatchQueue.main.async{
                self.favoritesCollect.reloadData()
            }
        }
        
    }
    
    @IBOutlet weak var editGymTF: UITextField!
    
    @IBOutlet weak var editCityTF: UITextField!
    
    var realName: String?
    var favorites = [String:Any]()
    var posts = [String:Any]()
    var mToken = String()
    var favData = [[String:Any]]()
    func loadViewController(){

        innerStat = "pop"

        profPic.layer.cornerRadius = profPic.frame.width/2
        profPic.layer.masksToBounds = true
        
        Messaging.messaging().delegate = self
        self.mToken = Messaging.messaging().fcmToken!
        print("token: \(mToken)")
        var tokenDict = [String: Any]()
        
        tokenDict["deviceToken"] = [mToken: true] as [String:Any]?
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(tokenDict)
        print("vica: \(viewerIsCurAuth)")
        
       
        profName.text = curName
        
        
        editBioTextView.layer.cornerRadius = 6
        editProfBackButton.layer.cornerRadius = 6
        editProfSaveButton.layer.cornerRadius = 6
        editProfView.layer.cornerRadius = 2
        
        innerScreenTabBar.selectedItem = innerScreenTabBar.items?[0]
        
        editProfButton.layer.cornerRadius = 4
        editProfButton.layer.masksToBounds = true
        tabBar.delegate = self
        innerScreenTabBar.delegate = self
        self.editEmailTF.text = Auth.auth().currentUser?.email!
        loadThatShit()
 
        
    }
    @IBOutlet weak var ffCollect: UICollectionView!
    
    
    
    
    
    var flwrDataArr = [[String:Any]]()
    var flwingDataArr = [[String:Any]]()
    var followersFollowingArr = [String]()
    var fuckBool = false
    var following = [String]()
    var myPicString = String()
    var followersArr = [String]()
    var followingArr = [String]()
    var name = String()
    var username = String()
    var city: String?
    var homeGym: String?
    
    @IBOutlet weak var gymButtonIcon: UIButton!
    @IBOutlet weak var cityButtonIcon: UIButton!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var homeGymButton: UIButton!
    var mapType = String()
    @IBAction func cityButtonPressed(_ sender: Any) {
        self.mapType = "city"
        performSegue(withIdentifier: "ProfileToMap", sender: self)
    }
    @IBAction func homeGymButtonPressed(_ sender: Any) {
        self.mapType = "gym"
        performSegue(withIdentifier: "ProfileToMap", sender: self)
    }
    
    @IBOutlet weak var editBioFrame2: UIView!
    var ogCityFrame: CGRect?
    var ogGymFrame: CGRect?
    var ogCityIconFrame: CGRect?
    var ogGymIconFrame: CGRect?
    func fuck(snapshot: DataSnapshot){
        
        ogCityFrame = cityButton.frame
        
        ogCityIconFrame = cityButtonIcon.frame
        ogGymFrame = homeGymButton.frame
        ogGymIconFrame = gymButtonIcon.frame
        
        var snapshots = snapshot.children.allObjects as! [DataSnapshot]
        
        for snap in snapshots{
            if snap.key == "city"{
                self.cityButton.setTitle("Lives in \(snap.value as! String)", for: .normal)
                self.city = snap.value as! String
                self.editCityTF.text = (snap.value as! String)
                
            }
            if snap.key == "cityCoord"{
                self.cityCoord = ["lat":(snap.value as! [Double])[0], "long": (snap.value as! [Double])[1]]
            }
            if snap.key == "homeGym"{
                self.homeGymButton.setTitle("Trains at \(((snap.value as! [Any])[0]) as! String)", for: .normal)
                self.homeGym = (snap.value as! [Any])[0] as! String
                self.editGymTF.text = (snap.value as! [Any])[0] as! String
                self.gymCoord = (snap.value as! [Any])[1] as! [String:Any]
            }
            if snap.key == "followers"{
                var tempArr = snap.value as! [String]
                for str in tempArr{
                    if str == "x" {
                        tempArr.remove(at: tempArr.firstIndex(of: str)!)
                    }
                }
                self.followersCount.text = String(tempArr.count)
                followersArr = tempArr
                
            }
            if snap.key == "following"{
                var tempArr = snap.value as! [String]
                for str in tempArr{
                    if str == "x" {
                        tempArr.remove(at: tempArr.firstIndex(of: str)!)
                    }
                }
                self.followingCount.text = String(tempArr.count)
                followingArr = tempArr
                following = tempArr
                print("flwing: \(tempArr)")
            }
            if snap.key == "favorited"{
                if reloadCollect == true{
                var tempFav = snap.value as! [String:Any]
                if (tempFav as? [String:String]) == ["x":"x"] && tempFav.count == 1{
                    fuckBool = true
                }
                    var removeDuplicate = [String:Any]()
                    var contains = [String]()
                    
                for (key, val) in tempFav{
                    if key == "0" || key == "x"{
                        
                    } else {
                        if contains.contains((val as! [String:Any])["postID"] as! String){
                            
                        } else {
                            contains.append((val as! [String:Any])["postID"] as! String)
                            removeDuplicate[key] = val as! [String:Any]
                    self.favData.append([key:val])
                        }
                        removeDuplicate["x"] = "x"
                        
                       
                    }
                }
                    let sortedResults = (favData as NSArray).sortedArray(using: [NSSortDescriptor(key: "datePosted", ascending: true)]) as! [[String:AnyObject]]
                    favData = sortedResults
                    print("favDataSorted: \(favData)")
                
                }
                
                print("favorites: \(self.favorites)")
            }
            if snap.key == "posts"{
                if reloadCollect == true{
                self.posts = snap.value as! [String:Any]
                }
            }
            if snap.key == "realName"{
                self.profName.text = (snap.value as! String)
                self.editNameTF.text = snap.value as! String
                self.name = snap.value as! String
            }
            if snap.key == "profPic"{
                if snap.value as! String == "profile-placeholder"{
                    self.profPic.image = UIImage(named: "profile-placeholder")
                    self.myPicString = "profile-placeholder"
                } else {
                    self.myPicString = snap.value as! String
                if let messageImageUrl = URL(string: snap.value as! String) {
                    
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        self.profPic.image = UIImage(data: imageData as Data)
                        self.editProfImageView.image = UIImage(data: imageData as Data)
                    }
                }
                }
            } else if snap.key == "username"{
                self.oldUsername = snap.value as! String
                self.userNameTop.text = snap.value as! String
                self.editProfNameTextField.text = snap.value as! String
                self.username = snap.value as! String
            } else if snap.key == "bio"{
                
                self.bioTextView.text = (snap.value as? String)!
              
                self.bioTextView.delegate = self
                self.editBioTextView.text = snap.value as? String
                let newSize = bioTextView.sizeThatFits(CGSize(width: bioTextView.frame.width, height: self.estimateFrameForText(text: (snap.value as! String), type: "bio").height))
                
                bioTextView.frame.size = CGSize(width: bioTextView.frame.width, height: newSize.height)
                self.bioTextView.resolveHashTags()
                self.bioTextView.isScrollEnabled = false
               
                
                let numLines = Int((bioTextView.contentSize.height / bioTextView.font!.lineHeight))
                print("lines: \(numLines) \(bioTextView.frame.height)")
                let height = bioTextView.frame.height
                if firstLoad == true {
                    self.superOGCollectViewFrame = collectView.frame
                }
                self.ogCollectViewSize = self.superOGCollectViewFrame
                
                if height >= 30 && height <= 40{
                    if bioTextView.text == " "{
                        collectView.frame = CGRect(x: collectView.frame.origin.x, y: ogCollectViewSize.origin.y - 68, width: collectView.frame.width, height: ogCollectViewSize.height + 68)
                    } else {
                    collectView.frame = CGRect(x: collectView.frame.origin.x, y: ogCollectViewSize.origin.y - 57, width: collectView.frame.width, height: ogCollectViewSize.height + 57)
                    }
                } else if height > 40 && height <= 50{
                    collectView.frame = CGRect(x: collectView.frame.origin.x, y: ogCollectViewSize.origin.y - 43, width: collectView.frame.width, height: ogCollectViewSize.height + 43)
                } else if height >= 60 && height <= 69{
                    collectView.frame = CGRect(x: collectView.frame.origin.x, y: ogCollectViewSize.origin.y - 28, width: collectView.frame.width, height: ogCollectViewSize.height + 28)
                } else if height >= 70 && height <= 79{
                    collectView.frame = CGRect(x: collectView.frame.origin.x, y: ogCollectViewSize.origin.y - 20, width: collectView.frame.width, height: collectView.frame.height + 20)
                }else if height >= 80 && height <= 90{
                    collectView.frame = CGRect(x: collectView.frame.origin.x, y: ogCollectViewSize.origin.y - 15, width: collectView.frame.width, height: ogCollectViewSize.height + 15)
                } else if height > 90 && height <= 100 {
                    collectView.frame = CGRect(x: collectView.frame.origin.x, y: ogCollectViewSize.origin.y, width: collectView.frame.width, height: ogCollectViewSize.height)
                } else if height > 100 {
                    
                } else {
                    collectView.frame = CGRect(x: collectView.frame.origin.x, y: ogCollectViewSize.origin.y - 85, width: collectView.frame.width, height: ogCollectViewSize.height + 85)
                }
                self.ogCollectViewSize = collectView.frame
            }
            
        }
        if self.city == nil || self.homeGym == nil{
            if self.city != nil{
                self.homeGymButton.isHidden = true
                self.gymButtonIcon.isHidden = true
                self.cityButton.frame = self.homeGymButton.frame
                self.cityButtonIcon.frame = self.gymButtonIcon.frame
                self.bioTextView.frame = CGRect(x: self.bioTextView.frame.origin.x, y: self.bioTextView.frame.origin.y - 30, width: self.bioTextView.frame.width, height: self.bioTextView.frame.height + 30)
            } else if self.homeGym != nil {
                self.cityButton.isHidden = true
                self.cityButtonIcon.isHidden = true
                self.bioTextView.frame = CGRect(x: self.bioTextView.frame.origin.x, y: self.bioTextView.frame.origin.y - 30, width: self.bioTextView.frame.width, height: self.bioTextView.frame.height + 30)
            } else {
                self.cityButton.isHidden = true
                self.cityButtonIcon.isHidden = true
                self.gymButtonIcon.isHidden = true
                self.homeGymButton.isHidden = true
                self.bioTextView.frame = CGRect(x: self.bioTextView.frame.origin.x, y: self.bioTextView.frame.origin.y - 60, width: self.bioTextView.frame.width, height: self.bioTextView.frame.height + 60)
            }
        }
        if self.bioTextView.text == nil {
            self.editBioTextView.text = "Tap here to edit bio."
        }
       // if reloadCollect == true{
        for (key, val) in self.posts {
            var temp = val as! [String:Any]
            if temp["postPic"] != nil || temp["postVid"] != nil{
                var tempDict = val as! [String:Any]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                let date = dateFormatter.date(from: tempDict["datePosted"] as! String) as! Date
                tempDict["datePosted"] = date
                print("date:\(date)")
                print("yoDawg")
                self.postData.append(tempDict as! [String:Any])
                
            } else {
                var tempDict = val as! [String:Any]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                let date = dateFormatter.date(from: tempDict["datePosted"] as! String)
                tempDict["datePosted"] = date
                self.postDataText.append(tempDict as! [String:Any])
            }
        }
        //}
        postData.reverse()
        postDataText.reverse()
        var count = 0
        for dict in postData{
            var tempDict = dict
            tempDict["tag"] = count
            postData[count] = tempDict
            count = count + 1
        }
        
        
        var mergedArr = Array(Set(followersArr + followingArr))
        print("followersFollowing: \(mergedArr), followers: \(followersArr), following: \(followingArr)")
        print("curUID: \(self.curUID)")
        //var sortedMergedArr = mergedArr.sort() as! [String]
        if mergedArr.contains(Auth.auth().currentUser!.uid) {
            FollowUnfollowButton.setTitle("Unfollow", for: .normal)
            //FollowUnfollowButton.isSelected = true
            self.FollowUnfollowButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            self.FollowUnfollowButton.setTitleColor(self.gmRed, for: .normal)
            self.FollowUnfollowButton.layer.borderWidth = 1
            self.FollowUnfollowButton.layer.borderColor = self.gmRed.cgColor
        } else {
            FollowUnfollowButton.setTitle("Follow", for: .normal)
            //FollowUnfollowButton.isSelected = false
            self.FollowUnfollowButton.backgroundColor = gmRed
            self.FollowUnfollowButton.setTitleColor(UIColor.white, for: .normal)
            self.FollowUnfollowButton.layer.borderWidth = 1
            self.FollowUnfollowButton.layer.borderColor = self.gmRed.cgColor
        }
        print("vica2:\(viewerIsCurAuth)")
        if viewerIsCurAuth == false {
            editProfButton.isHidden = true
            FollowUnfollowButton.isHidden = false
            topLeftNav.isHidden = false
            topLeftNav.setTitle("Back", for: .normal)
            
            
        } else {
            editProfButton.isHidden = false
            FollowUnfollowButton.isHidden = true
            tabBar.selectedItem = tabBar.items?[4]
            curUID = Auth.auth().currentUser!.uid
            topLeftNav.isHidden = false
            topLeftNav.setTitle("Logout", for: .normal)
        }
       
        print("postData: \(self.postData)")
        self.postData.sort{
            (($0 as! Dictionary<String, AnyObject>)["datePosted"] as! Date) < (($1 as! Dictionary<String, AnyObject>)["datePosted"] as! Date)
        }
        var counter = 0
        for post in postData{
            var tempD = post
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            let str = dateFormatter.string(from: post["datePosted"] as! Date)
            tempD["datePosted"] = str
            postData[counter] = tempD
            counter = counter + 1
        }
        postData.reverse()
        self.postDataText.sort{
            (($0 as! Dictionary<String, AnyObject>)["datePosted"] as! Date) < (($1 as! Dictionary<String, AnyObject>)["datePosted"] as! Date)
        }
        var counter1 = 0
        for post in postDataText{
            var tempD = post
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            let str = dateFormatter.string(from: post["datePosted"] as! Date)
            tempD["datePosted"] = str
            postDataText[counter1] = tempD
            counter1 = counter1 + 1
        }
        postDataText.reverse()
        
        self.profCollectData = self.postData
        self.favoritesCollect.delegate = self
        self.favoritesCollect.dataSource = self
        
        
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    
                    
                    if self.followersArr.contains(snap.key) {
                        var tempD = snap.value as! [String:Any]
                        tempD["uid"] = snap.key
                        self.flwrDataArr.append(tempD)
                        
                    }
                    if self.followingArr.contains(snap.key){
                       
                        var tempD = snap.value as! [String:Any]
                        tempD["uid"] = snap.key
                        self.flwingDataArr.append(tempD)
                    }
                }
            }
       
        })
    
        
    
        
        
        self.favoritesCollect.register(UINib(nibName: "NewsFeedCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsFeedCellCollectionViewCell")
        self.favoritesCollect.register(UINib(nibName: "NewsFeedPicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsFeedPicCollectionViewCell")
        self.favoritesCollect.register(UINib(nibName: "PopCell", bundle: nil), forCellWithReuseIdentifier: "PopCell")
        
        if self.reloadCollect == true {
        self.favoritesCollect.performBatchUpdates(nil, completion: {
           (result) in
            // ready
            self.removeAllOverlays()
            print("doneLoading3")
        })
        } else {
            self.removeAllOverlays()
        }
        firstLoad = false
    }
    var firstLoad = false
    var reloadCollect = true
    //The reason that loadViewControllers calls loadThatShit which calls fuck() which is where the data actually gets loaded is because of an incredibly dumb swift/xcode bug that kept giving me a nonsense compiler error unless i seperated these into different methods. No Idea why, im sure the bug is fixed by now but since it works fine this way im not going to change it back into one method at the moment just in case bug isnt fixed.
    func loadThatShit(){
        let reff = Database.database().reference().child("users").child(curUID!)
        
        reff.observeSingleEvent(of: .value, with: { snapshot in
            self.fuck(snapshot: snapshot)
            
 
        })
    }
    var postDataText = [[String:Any]]()
    @IBOutlet weak var FollowUnfollowButton: UIButton!
    
    @IBAction func followUnfollowPressed(_ sender: Any) {
        if FollowUnfollowButton.titleLabel?.text == "Follow"{
            Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    var uploadDict = [String:Any]()
                    for snap in snapshots{
                        if snap.key == "following"{
                            var tempFollowing = snap.value as! [String]
                            tempFollowing.append(self.curUID!)
                            uploadDict["following"] = tempFollowing
                            break
                        }
                    }
                    Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(uploadDict)
                }
                Database.database().reference().child("users").child(self.curUID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        var uploadDict2 = [String:Any]()
                        for snap in snapshots{
                            if snap.key == "followers"{
                                var tempFollowing = snap.value as! [String]
                                tempFollowing.append(Auth.auth().currentUser!.uid)
                                
                                uploadDict2["followers"] = tempFollowing
                                break
                                
                            }
                        }
                        Database.database().reference().child("users").child(self.curUID!).updateChildValues(uploadDict2)
                    }
                    self.FollowUnfollowButton.setTitle("Unfollow", for: .normal)
                    self.FollowUnfollowButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                    self.FollowUnfollowButton.setTitleColor(self.gmRed, for: .normal)
                    self.FollowUnfollowButton.layer.borderWidth = 1
                    self.FollowUnfollowButton.layer.borderColor = self.gmRed.cgColor
                })
            })
            
        } else {
            //remove from curUsers following and selected users followers
            Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    var uploadDict = [String:Any]()
                    for snap in snapshots{
                        if snap.key == "following"{
                            var tempFollowing = snap.value as! [String]
                            tempFollowing.remove(at: tempFollowing.index(of: self.curUID!)!)
                            uploadDict["following"] = tempFollowing
                            break
                        }
                    }
                    Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(uploadDict)
                }
                Database.database().reference().child("users").child(self.curUID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        var uploadDict2 = [String:Any]()
                        for snap in snapshots{
                            if snap.key == "followers"{
                                var tempFollowers = snap.value as! [String]
                                tempFollowers.remove(at: tempFollowers.index(of: Auth.auth().currentUser!.uid)!)
                                
                                uploadDict2["followers"] = tempFollowers
                                break
                                
                            }
                        }
                        Database.database().reference().child("users").child(self.curUID!).updateChildValues(uploadDict2)
                    }
                    self.FollowUnfollowButton.setTitle("Follow", for: .normal)
                    self.FollowUnfollowButton.backgroundColor = self.gmRed
                    self.FollowUnfollowButton.setTitleColor(UIColor.white, for: .normal)
                    
                })
            })
        }
    }
    
    @IBAction func followerButtonPressed(_ sender: Any) {
        followType = "follower"
         performSegue(withIdentifier: "profToFollow", sender: self)
    }
    
    //findFriends
    @IBOutlet weak var findFriendsView: UIView!
    @IBOutlet weak var findFriendsCollect: UICollectionView!
    @IBOutlet weak var findFriendsSearchBar: UISearchBar!
    
    
    @IBAction func followingButtonPressed(_ sender: Any) {
        followType = "following"
        performSegue(withIdentifier: "profToFollow", sender: self)
    }
    var findFriendsData = [[String:Any]]()
    
    @IBOutlet weak var editProfTopLine: UIView!
    var innerStat = String()
    var postData = [[String:Any]]()
    var profCollectData = [Any]()
    @IBOutlet weak var feedCollect: UICollectionView!
    var followType = String()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == findFriendsCollect{
            
            return findFriendsData.count
            
        } else if collectionView == favoritesCollect{
            print("count: \(profCollectData.count)")
            return profCollectData.count
        } else {
            if followType == "following"{
                return flwingDataArr.count
            } else {
                return flwrDataArr.count
            }
        }
    }
    
    var selectedData = [String:Any]()
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == findFriendsCollect{
            
            
            
        } else if collectionView == favoritesCollect{
            
        
        
        if innerScreenTabBar.selectedItem == innerScreenTabBar.items![0]{
            print("selectedData: \(profCollectData[indexPath.row] as! [String:Any])")
            selectedData = profCollectData[indexPath.row] as! [String:Any]
            performSegue(withIdentifier: "profToSinglePost", sender: self)
        } else if (innerScreenTabBar.selectedItem == innerScreenTabBar.items![1]){
            selectedData = profCollectData[indexPath.row] as! [String:Any]
            performSegue(withIdentifier: "profToSinglePost", sender: self)
        } else {
            
        }
        } else {
            
        }
    }
    var picOrTextData = [String]()
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("hey")
        
        if collectionView == findFriendsCollect{
            let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
            cell.toProfileButton.isHidden = false
            DispatchQueue.main.async{
                
                cell.contentView.layer.cornerRadius = 2.0
                cell.contentView.layer.borderWidth = 1.0
                cell.contentView.layer.borderColor = UIColor.clear.cgColor
                cell.contentView.layer.masksToBounds = true
                
               
                if self.findFriendsData.count != 0{
                if ((self.following.contains(((self.findFriendsData[indexPath.row])["uid"] as! String)))){
                    cell.likedByFollowButton.setTitle("Unfollow", for: .normal)
                    cell.likedByFollowButton.layer.borderWidth = 1
                    cell.likedByFollowButton.layer.borderColor = UIColor.red.cgColor
                    cell.likedByFollowButton.backgroundColor = UIColor.white
                    cell.likedByFollowButton.setTitleColor(UIColor.red, for: .normal)
                }
                cell.delegate1 = self
                cell.likedByName.isHidden = false
                cell.likedByUName.isHidden = false
                cell.likedByFollowButton.isHidden = false
                cell.commentName.isHidden = true
                cell.commentTextView.isHidden = true
                cell.commentTimestamp.isHidden = true
                cell.likedByUName.text = ((self.findFriendsData[indexPath.row] )["uName"] as! String)
                
                cell.likedByUID = ((self.findFriendsData[indexPath.row])["uid"] as! String)
                
                cell.likedByName.text = ((self.findFriendsData[indexPath.row] )["realName"] as! String)
                if ((self.findFriendsData[indexPath.row])["picString"] as! String) == "profile-placeholder"{
                    DispatchQueue.main.async{
                        cell.likedByImage.image = UIImage(named: "profile-placeholder")
                    }
                    
                } else {
                    DispatchQueue.main.async{
                        cell.likedByImage.image = ((self.findFriendsData[indexPath.row])["profPic"] as! UIImage)
                    }
                }
            }
            }
            return cell
            
            
        } else if collectionView == favoritesCollect{
            var curData = [String:Any]()
        if innerStat == "fav"{
            for dict in profCollectData{
                var tempDict = (dict as! [String:Any])
                if tempDict.count != 1{
                    tempDict = (dict as! [String:Any])
                if tempDict["tag"] as! Int == indexPath.row {
                    curData = tempDict
                    }
                }
            }
            
            if (curData.count == 0){
                let cell : NewsFeedCellCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsFeedCellCollectionViewCell", for: indexPath) as! NewsFeedCellCollectionViewCell
                cell.likeButton.isHidden = true
                cell.favoritesButton.isHidden = true
                cell.commentButton.isHidden = true
                cell.shareButton.isHidden = true
                cell.layer.shadowColor = UIColor.gray.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 2.0);
                cell.layer.shadowRadius = 1.5;
                cell.layer.shadowOpacity = 0.3;
                cell.layer.masksToBounds = false
                cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
                
                return cell
            } else {
                var hasPic = false
                var hasVid = false
                
                for (key, val) in (curData as! [String:Any]){
                    //print("favData at indexPath: \((curData as! [String:Any]))")
                    
                    if key == "postPic"{
                        hasPic = true
                    }
                    if key == "postVid"{
                        hasVid = true
                    }
                }
                
                print("inFav: \(curData)")
            if (hasPic == false && hasVid == false) {
                picOrTextData[indexPath.row] = "text"
                print("textpoststtttt")
                let cell : NewsFeedCellCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsFeedCellCollectionViewCell", for: indexPath) as! NewsFeedCellCollectionViewCell
                cell.likeButton.isHidden = true
                cell.favoritesButton.isHidden = true
                cell.commentButton.isHidden = true
                cell.shareButton.isHidden = true
                cell.layer.shadowColor = UIColor.gray.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 2.0);
                cell.layer.shadowRadius = 1.5;
                cell.layer.shadowOpacity = 0.3;
                cell.layer.masksToBounds = false
                cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
                
                DispatchQueue.main.async{
                    cell.postText.text = curData["postText"] as! String
                    let fixedWidth = cell.postText.frame.size.width
                    let newSize = cell.postText.sizeThatFits(CGSize(width: fixedWidth, height: self.estimateFrameForText(text: cell.postText.text as! String, type: "notB").height))
                    
                    let tStamp = self.convertToTimestamp(date: ((curData as! [String:Any])["datePosted"] as! String))
                    
                    cell.timeStambLabel.text = tStamp
                    cell.timeStambLabel.isHidden = false
                    
                    cell.postText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                    cell.postText.isScrollEnabled = false
                    
                    if ((curData as! [String:Any])["posterName"] as! String) == nil {
                    print("why nil")
                } else {
                        print("setting text: \(((curData as! [String:Any])["postText"] as! String))")
                        cell.posterNameButton.setTitle(((curData as! [String:Any])["posterName"] as! String), for: .normal)
                        cell.postLocationButton.setTitle(((curData as! [String:Any])["city"] as! String), for: .normal)
                        cell.postText.isHidden = false
                        cell.postText.text = curData["postText"] as! String
                        let fixedWidth = cell.postText.frame.size.width
                        let newSize = cell.postText.sizeThatFits(CGSize(width: fixedWidth, height: self.estimateFrameForText(text: cell.postText.text as! String, type: "notB").height))
                        
                        cell.postText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                        cell.postText.isScrollEnabled = false
                
                //unwrap pic from storage
                        cell.profImageView.image = UIImage(named: (self.profCollectData[indexPath.row] as! [String:Any])["posterPicURL"] as! String)
                
                cell.likeButton.isEnabled = false
                cell.likesCountButton.isEnabled = false
                cell.commentButton.isEnabled = false
                cell.commentsCountButton.isEnabled = false
                cell.favoritesButton.isEnabled = false
                //cell.favoritesCountButton.isEnabled = false
                cell.shareButton.isEnabled = false
                var likesPost: [String:Any]?
                var favesPost: [String:Any]?
                var commentsPost: [String:Any]?
                        for item in (curData as! [String:Any])["comments"] as! [[String:Any]]{
                    commentsPost = item as! [String: Any] }
                        for item in (curData as! [String:Any])["likes"] as! [[String:Any]]{
                    likesPost = item as! [String: Any] }
                if likesPost!["x"] != nil { } else {
                   
                    var likesCount = ((curData as! [String:Any])["likes"] as! [[String:Any]]).count
                    var likeString = ""
                    if likesCount == 1{
                        likeString = "1 Like"
                    } else {
                        likeString = "\(likesCount) Likes"
                    }
                    cell.likesCountButton.setTitle(likeString, for: .normal)
                    if (likesPost!["uName"] as! String) == self.profName.text!{
                        cell.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal) } }
                //set comments count
                if commentsPost!["x"] != nil {
                    
                } else {
                    
                    var commentsCount = ((curData as! [String:Any])["comments"] as! [[String:Any]]).count
                    var commentString = ""
                    if commentsCount == 1{
                        commentString = "View 1 Comment"
                    } else {
                        commentString = "View \(commentsCount) Comments"
                    }
                    
                    cell.commentsCountButton.setTitle(commentString, for: .normal) }
                    for item in (curData as! [String:Any])["favorites"] as! [[String:Any]]{
                    favesPost = item as! [String: Any]
                }
                if favesPost!["x"] != nil {
                    
                } else {
                    if (favesPost!["uName"] as! String) == self.curName{
                        cell.favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                        //cell.favoritesCountButton.setTitle(String(((((self.profCollectData[indexPath.row]) as! [String:Any]).first?.value as! [String:Any])["favorites"] as! [[String:Any]]).count), for: .normal)
                        
                    }
                    
                        }
                        let tStampDateString = (curData as! [String:Any])["datePosted"] as! String
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        
                        let date = dateFormatter.date(from: tStampDateString)
                        
                        let now = Date()
                        
                        let hoursBetween = now.hours(from: date!)
                        
                        cell.timeStambLabel.text = "\(hoursBetween) hours ago"
                        cell.posterUID = (curData as! [String:Any])["posterUID"] as! String
                        cell.layer.shouldRasterize = true
                        cell.layer.rasterizationScale = UIScreen.main.scale
                        
                    }
                }
               
                return cell
            } else {
                picOrTextData[indexPath.row] = "picVid"
                print("it is a pic or vid cell")
                //picvidCell
                //typeOfCellAtIndexPath[indexPath] = 1
                print("pic or vid cell")
                let cell : NewsFeedPicCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsFeedPicCollectionViewCell", for: indexPath) as! NewsFeedPicCollectionViewCell
               
                DispatchQueue.main.async{
                //let cell = NewsFeedPicCollectionViewCell()
                    cell.postText.text = curData["postText"] as! String
                    let fixedWidth = cell.postText.frame.size.width
                    let newSize = cell.postText.sizeThatFits(CGSize(width: fixedWidth, height: self.estimateFrameForText(text: cell.postText.text as! String, type: "notB").height))
                    
                    cell.postText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                    cell.postText.isScrollEnabled = false
                    cell.postLocationButton.setTitle(((curData as! [String:Any])["city"] as! String), for: .normal)
                    
                    cell.posterPic.image = UIImage(named: (curData as! [String:Any])["posterPicURL"] as! String)
                
                    cell.posterNameButton.setTitle(((curData as! [String:Any])["posterName"] as! String), for: .normal)
                
                cell.likeButton.isEnabled = false
                cell.likesCountButton.isEnabled = false
                cell.commentButton.isEnabled = false
                cell.commentsCountButton.isEnabled = false
                cell.favoritesButton.isEnabled = false
                //cell.favoritesCountButton.isEnabled = false
                //cell.share isEnabled = false
                
                var likesPost: [String:Any]?
                var favesPost: [String:Any]?
                var commentsPost: [String:Any]?
                    for item in (curData as! [String:Any])["comments"] as! [[String:Any]]{
                    
                    commentsPost = item as! [String: Any]
                    
                }
                    for item in (curData as! [String:Any])["likes"] as! [[String:Any]]{
                    
                    likesPost = item as! [String: Any]
                    
                }
                if likesPost!["x"] != nil {
                    
                } else {
                    
                    var likesCount = ((curData as! [String:Any])["likes"] as! [[String:Any]]).count
                    var likeString = ""
                    if likesCount == 1{
                        likeString = "1 Like"
                    } else {
                        likeString = "\(likesCount) Likes"
                    }
                    cell.likesCountButton.setTitle(likeString, for: .normal)
                    
                    if (likesPost!["uName"] as! String) == self.profName.text!{
                        cell.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
                    }
                }
                //set comments count
                if commentsPost!["x"] != nil {
                    
                } else {
                    var commentsCount = ((curData as! [String:Any])["comments"] as! [[String:Any]]).count
                    var commentString = ""
                    if commentsCount == 1{
                        commentString = "View 1 Comment"
                    } else {
                        commentString = "View \(commentsCount) Comments"
                    }
                    
                    cell.commentsCountButton.setTitle(commentString, for: .normal)
                    
                }
                
                    for item in (curData as! [String:Any])["favorites"] as! [[String:Any]]{
                    
                    favesPost = item as! [String: Any]
                    
                }
                if favesPost!["x"] != nil {
                    
                } else {
                    
                    
                    if (favesPost!["uName"] as! String) == self.curName{
                        cell.favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                        
                    }
                }
                
                
                
                let tStampDateString = (curData as! [String:Any])["datePosted"] as! String
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                let date = dateFormatter.date(from: tStampDateString)
                
                let now = Date()
                
                let hoursBetween = now.hours(from: date!)
                
                cell.timeStampLabel.text = "\(hoursBetween) hours ago"
                cell.posterUID = (curData as! [String:Any])["posterUID"] as! String
                cell.layer.shouldRasterize = true
                cell.layer.rasterizationScale = UIScreen.main.scale
                
                
                if let messageImageUrl = URL(string: (curData as! [String:Any])["posterPicURL"] as! String) {
                    
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        cell.posterPic.image = UIImage(data: imageData as Data)
                        
                    }
                }
                cell.cellIndexPath = indexPath
                
                
                if (curData as! [String:Any])["postVid"] as? String == nil {
                    cell.player?.view.isHidden = true
                    cell.postPic.isHidden = false
                    
                    
                    if let messageImageUrl = URL(string: (curData as! [String:Any])["postPic"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            cell.postPic.image = UIImage(data: imageData as Data)
                            
                        }
                        
                    }
                    
                    cell.viewCount.isHidden = true
                    
                } else {
                    cell.player?.muted = true
                    cell.player?.autoplay = false
                    cell.videoUrl = URL(string: (curData as! [String:Any])["postVid"] as! String)
                    cell.postPic.isHidden = true
                    cell.player?.url = URL(string: (curData as! [String:Any])["postVid"] as! String)
                    cell.player?.playerDelegate = self
                    cell.player?.playbackDelegate = self
                    cell.player?.playbackLoops = true
                    cell.player?.playbackPausesWhenBackgrounded = true
                    cell.player?.playbackPausesWhenResigningActive
                    //var gest = UIGestureRecognizer(target: <#T##Any?#>, action: <#T##Selector?#>)
                    
                    let vidFrame = CGRect(x: cell.postPic.frame.origin.x, y: cell.postPic.frame.origin.y, width: self.favoritesCollect.frame.width - 28, height: cell.postPic.frame.height)
                    cell.player?.view.frame = vidFrame
                    cell.player?.view.isHidden = false
                    cell.viewCount.isHidden = false
                    cell.player?.didMove(toParentViewController: self)
                    cell.player?.playbackLoops = true
                }
                }
               
                return cell
                }
            }
        } else if innerStat == "notFav" {
            print("inNotFav")
            var curData = profCollectData[indexPath.row] as! [String:Any]
        
                let cell : NewsFeedCellCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsFeedCellCollectionViewCell", for: indexPath) as! NewsFeedCellCollectionViewCell
            cell.likeButton.isHidden = true
            cell.favoritesButton.isHidden = true
            cell.commentButton.isHidden = true
            cell.shareButton.isHidden = true
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 2.0);
            cell.layer.shadowRadius = 1.5;
            cell.layer.shadowOpacity = 0.3;
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
               DispatchQueue.main.async{
                cell.posterNameButton.setTitle((curData["posterName"] as! String), for: .normal)
            cell.postLocationButton.setTitle((curData["city"] as! String), for: .normal)
                cell.postText.text = curData["postText"] as! String
                let fixedWidth = cell.postText.frame.size.width
                let newSize = cell.postText.sizeThatFits(CGSize(width: fixedWidth, height: self.estimateFrameForText(text: cell.postText.text as! String, type: "notB").height))
                
                cell.postText.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                cell.postText.isScrollEnabled = false
           
                
                let tStamp = self.convertToTimestamp(date: ((curData as! [String:Any])["datePosted"] as! String))
                
                cell.timeStambLabel.text = tStamp
                cell.timeStambLabel.isHidden = false
                if let messageImageUrl = URL(string: (curData["posterPicURL"] as! String)) {
                    
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        cell.profImageView.image = UIImage(data: imageData as Data)
                       
                        
                    }
                }
           
                
               
            cell.likeButton.isEnabled = false
            cell.likesCountButton.isEnabled = false
            cell.commentButton.isEnabled = false
            cell.commentsCountButton.isEnabled = false
            cell.favoritesButton.isEnabled = false
            //cell.favoritesCountButton.isEnabled = false
            cell.shareButton.isEnabled = false
            var likesPost: [String:Any]?
            var favesPost: [String:Any]?
            var commentsPost: [String:Any]?
            for item in curData["comments"] as! [[String:Any]]{
                commentsPost = item as! [String: Any] }
            for item in curData["likes"] as! [[String:Any]]{
                likesPost = item as! [String: Any] }
            if likesPost!["x"] != nil { } else {
               
                var likesCount = (curData["likes"] as! [[String:Any]]).count
                var likeString = ""
                if likesCount == 1{
                    likeString = "1 Like"
                } else {
                    likeString = "\(likesCount) Likes"
                }
                cell.likesCountButton.setTitle(likeString, for: .normal)
                if (likesPost!["uName"] as! String) == self.profName.text!{
                    cell.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal) } }
            //set comments count
            if commentsPost!["x"] != nil { } else {
                var commentsCount = ((curData as! [String:Any])["comments"] as! [[String:Any]]).count
                var commentString = ""
                if commentsCount == 1{
                    commentString = "View 1 Comment"
                } else {
                    commentString = "View \(commentsCount) Comments"
                }
                
                cell.commentsCountButton.setTitle(commentString, for: .normal) }
            for item in curData["favorites"] as! [[String:Any]]{
                favesPost = item as! [String: Any]
            }
            if favesPost!["x"] != nil {
            } else {
                if (favesPost!["uName"] as! String) == self.curName{
                    cell.favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
                   
                    
                }
                
                }
            }
                
                return cell
       
            
        } else {
            
            let cell : PopCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "PopCell", for: indexPath) as! PopCell)
            
            DispatchQueue.main.async{
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.cgColor
                if (self.profCollectData[indexPath.row] as! [String:Any])["postPic"] == nil {
                    if (self.profCollectData[indexPath.row] as! [String:Any])["postVid"] == nil{
                        cell.popPic.image = UIImage(named: "background2")
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            cell.popText.text = String(describing: (self.profCollectData[indexPath.row] as! [String:Any])["postText"] as! String)
                            cell.player?.view.isHidden = true
                            cell.bringSubview(toFront: cell.popText)
                        })
                    } else {
                        print("needToShowVid: \((self.profCollectData[indexPath.row] as! [String:Any])["postVid"]!)")
                        DispatchQueue.main.async{
                            cell.player?.url = URL(string: String(describing: (self.profCollectData[indexPath.row] as! [String:Any])["postVid"] as! String))
                            cell.player?.playerDelegate = self
                            cell.player?.playbackDelegate = self
                            cell.player?.playbackLoops = true
                            cell.player?.playbackPausesWhenBackgrounded = true
                            cell.player?.playbackPausesWhenResigningActive = true
                        }
                        let vidFrame = CGRect(x: cell.popPic.frame.origin.x, y: cell.popPic.frame.origin.y, width: cell
                            .frame.width, height: cell.frame.height)
                        
                        cell.player?.view.frame = vidFrame
                        cell.player?.view.bounds = vidFrame
                        cell.player?.view.isHidden = false
                        cell.player?.didMove(toParentViewController: self)
                        cell.player?.playbackLoops = true
                    }
                } else {
                    if let messageImageUrl = URL(string: (self.profCollectData[indexPath.row] as! [String:Any])["postPic"] as! String) {
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            cell.popPic.image = UIImage(data: imageData as Data)
                        }
                    }
            }
            }
            
            return cell
        }
         } else {
            let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
            if followType == "following"{
            DispatchQueue.main.async{
               
            cell.likedByFollowButton.setTitle("Unfollow", for: .normal)
                
                cell.likedByName.isHidden = false
                cell.likedByUName.isHidden = false
                cell.likedByFollowButton.isHidden = false
                cell.commentName.isHidden = true
                cell.commentTextView.isHidden = true
                cell.commentTimestamp.isHidden = true
                cell.likedByUName.text = (self.flwingDataArr[indexPath.row]["username"] as! String)
                
                cell.likedByUID = (self.flwingDataArr[indexPath.row]["uid"] as! String)
                
                cell.likedByName.text = self.flwingDataArr[indexPath.row]["realName"] as! String
                if self.flwingDataArr[indexPath.row]["profPic"] as! String == "profile-placeholder"{
                    DispatchQueue.main.async{
                        cell.likedByImage.image = UIImage(named: "profile-placeholder")
                    }
                } else {
                    if let messageImageUrl = URL(string: self.flwingDataArr[indexPath.row]["profPic"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            DispatchQueue.main.async{
                                cell.likedByImage.image = UIImage(data: imageData as Data)
                            }
                            
                        }
                        
                        //}
                    }
                }
            }
            } else {
                //follower
                DispatchQueue.main.async{
                    
                    if (self.followersArr.contains(self.flwrDataArr[indexPath.row]["uid"] as! String)){
                        cell.likedByFollowButton.setTitle("Unfollow", for: .normal)
                        cell.likedByFollowButton.backgroundColor = UIColor.red
                        
                    } else {
                        cell.likedByFollowButton.backgroundColor = UIColor.green
                    }
                    
                    cell.likedByName.isHidden = false
                    cell.likedByUName.isHidden = false
                    cell.likedByFollowButton.isHidden = false
                    cell.commentName.isHidden = true
                    cell.commentTextView.isHidden = true
                    cell.commentTimestamp.isHidden = true
                    cell.likedByUName.text = (self.flwrDataArr[indexPath.row]["username"] as! String)
                    
                    cell.likedByUID = (self.flwrDataArr[indexPath.row]["uid"] as! String)
                    
                    cell.likedByName.text = (self.flwrDataArr[indexPath.row]["realName"] as! String)
                    if self.flwrDataArr[indexPath.row]["profPic"] as! String == "profile-placeholder"{
                        DispatchQueue.main.async{
                            cell.likedByImage.image = UIImage(named: "profile-placeholder")
                        }
                    } else {
                        if let messageImageUrl = URL(string: self.flwrDataArr[indexPath.row]["profPic"] as! String) {
                            
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                DispatchQueue.main.async{
                                    cell.likedByImage.image = UIImage(data: imageData as Data)
                                }
                                
                            }
                            
                            //}
                        }
                    }
                }
            }
            
            return cell
        }
   
        
    }
    var gmRed = UIColor(displayP3Red: 236/255, green: 30/255, blue: 42/255, alpha: 1.0)
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = CGFloat()
        var height = CGFloat()
        if collectionView == findFriendsCollect{
            return CGSize(width: collectionView.frame.width - 20, height: 70)
            
            
        } else if collectionView == favoritesCollect{
       if innerStat == "pop" {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        width = screenWidth/3.04
        
        height = screenWidth/3.04
        
            return CGSize(width: width, height: height)
       } else {
        var hasPic = false
        var hasVid = false
        
        //var tempArr = [String]()
        
        if innerScreenTabBar.selectedItem == innerScreenTabBar.items![1]{
           
            for (key, val) in ((profCollectData[indexPath.row] as! [String:Any])){
                
                if key == "postPic"{
                    hasPic = true
                }
                if key == "postVid"{
                    hasVid = true
                }
            }
           // }
        } else {
            if fuckBool == true{
                print("yup")
            } else {
              print("yarp")
            
        for (key, _) in ((profCollectData[indexPath.row] as! [String:Any]) as! [String:Any]){
            
            if key == "postPic"{
                hasPic = true
            }
            if key == "postVid"{
                hasVid = true
            }
                }
            }
        }
        
       // print("inFav: \(profCollectData[indexPath.row])")
        if (hasPic == false && hasVid == false) {
            picOrTextData.insert("text", at: indexPath.row)
            
            width = collectionView.frame.width - 20
            if let text = (profCollectData[indexPath.row] as! [String:Any])["postText"] {
                height = estimateFrameForText(text: text as! String, type: "notB").height + 163
                print("text: \(text), height: \(height), indexPath: \(indexPath)")
            }
        } else {
            picOrTextData.insert("picVid", at: indexPath.row)
            
            width = collectionView.frame.width - 20
            if let text = (profCollectData[indexPath.row] as! [String:Any])["postText"] {
                if (estimateFrameForText(text: text as! String, type: "notB").height) < 300 {
                    
                    if (estimateFrameForText(text: text as! String, type: "notB").height) < 40 {
                        height = (estimateFrameForText(text: text as! String, type: "notB").height/1.75) + 474 + 55
                    } else if (estimateFrameForText(text: text as! String, type: "notB").height) < 120 {
                        height = (estimateFrameForText(text: text as! String, type: "notB").height/1.75) + 474 + 60
                    } else {
                        height = (estimateFrameForText(text: text as! String, type: "notB").height/1.75) + 474 + 90
                    }
                } else {
                    
                    height = (estimateFrameForText(text: text as! String, type: "notB").height/1.75) + 474 + 100
                }
            }
        }

            return CGSize(width: width, height: height)
            }
         } else {
            return CGSize(width: collectionView.frame.width - 20, height: 70)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == favoritesCollect{
            if innerScreenTabBar.selectedItem == innerScreenTabBar.items![0]{
                return 3
            } else {
                return 10
            }
        } else {
            return 5
        }
    }
    
    private func estimateFrameForText(text: String, type: String) -> CGRect {
        //we make the height arbitrarily large so we don't undershoot height in calculation
        let height: CGFloat = 1000
        
        let size = CGSize(width: favoritesCollect.frame.width - 20, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        if type == "bio"{
            let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)]
            return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        } else {
            let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)]
            return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        }
        
        
    }
    

    var isResize = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("inScroll")
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
        if scrollView == self.scrollView {
            
            if self.scrollView.contentOffset.y >= 100{
                UIView.animate(withDuration: 0.5, animations: {
                    self.collectView.frame = self.collectViewResize.frame
                    if self.profCollectData.count > 15 && self.innerScreenTabBar.selectedItem == self.innerScreenTabBar.items![0]{
                        self.favoritesCollect.isScrollEnabled = true
                    } else {
                        self.favoritesCollect.isScrollEnabled = true
                    }
                    
                })
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    self.favoritesCollect.isScrollEnabled = false
                    self.collectView.frame = self.ogCollectViewSize
                })
            }
            
        }
        
        if scrollView == self.favoritesCollect {
            
        }
    }
    @IBOutlet weak var reauthView: UIView!
    
    @IBOutlet weak var reauthPassTF: UITextField!
    @IBOutlet weak var reauthEmailTF: UITextField!
    @IBOutlet weak var editNameTF: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var credential: AuthCredential?
    
    @IBAction func reauthButtonPressed(_ sender: Any) {
        if reauthEmailTF.hasText && reauthPassTF.hasText && editPasswordTF.hasText{
            self.credential = EmailAuthProvider.credential(withEmail: reauthEmailTF.text!, password: reauthPassTF.text!)
            updatePassword = true
            reauthView.isHidden = true
            
                Auth.auth().currentUser?.reauthenticate(with: self.credential!, completion: { (error) in
                    if error == nil {
                        Auth.auth().currentUser!.updatePassword(to: self.editPasswordTF.text!) { (error) in
                            //completion(error)
                            
                        }
                    } else {
                        //completion(error)
                        print("reauthPassError: \(error?.localizedDescription)")
                    }
                    //self.reloadCollect = false
                    self.editProfView.isHidden = true
                    self.navBarView.isHidden = false
                    
                })
                
            
        } else {
            let alert = UIAlertController(title: "Missing Info", message: "Make sure you did not leave the email or password field blank.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
    }
    
    @IBAction func updatePasswordButtonPressed(_ sender: Any) {
        reauthView.isHidden = false
    }
    var curTF = String()
    var didCancelAutopicker = false
    public func textFieldDidBeginEditing(_ textField: UITextField){
        textField.textColor = UIColor.black
        if textField == self.editCityTF{
            didCancelAutopicker = false
            updateCity = false
            curTF = "city"
            curCityText = self.gymLab.text!
            print("curCityText: \(curCityText)")
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            present(autocompleteController, animated: true, completion: nil)
        }
        if textField == self.editGymTF{
            didCancelAutopicker = false
            updateGym = false
            curTF = "gym"
            curGymText = self.gymLab.text!
            print("curGymText: \(curGymText)")
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            let filter = GMSAutocompleteFilter()
            filter.type = .establishment
            autocompleteController.autocompleteFilter = filter
           //autocompleteController.autocompleteFilter?.type =
            present(autocompleteController, animated: true, completion: nil)
            
        }
        
    }
    var curGymText = String()
    
    var curCityText = String()
    var oldEmail = String()
    public func textFieldDidEndEditing(_ textField: UITextField){
        print("tfDidEnd")
       textField.textColor = UIColor.lightGray
       /* if textField == editPasswordTF {
            editPasswordTF.text = textField.text
            reauthView.isHidden = false
            
        } else*/ if textField == editEmailTF && textField.text != oldEmail{
            self.updateEmail = true
            editEmailTF.text = textField.text
        } else if textField == editNameTF{
            self.updateRealName = true
            editNameTF.text = textField.text
        } else if textField == editCityTF{
            
            /*if didCancelAutopicker == true{
                self.updateCity = false
                editCityTF.text = curCityText
            } else {
                self.updateCity = true
                editCityTF.text = textField.text!
            }*/
            print("cityTFText: \(textField.text)")
        } else if textField == editGymTF{
            
            /*if didCancelAutopicker == true{
                self.updateGym = false
                editGymTF.text = curGymText
            } else {
                editGymTF.text = textField.text!
                self.updateGym = true*/
            //}
            print("gymTFText: \(textField.text), \(updateGym), \(didCancelAutopicker)")
        } else {
            
         Database.database().reference().child("usernames").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                var uNameTaken = false
                for snap in snapshots{
                    if snap.key == self.editProfNameTextField.text {
                        if (snap.value as! [String])[0] as! String == Auth.auth().currentUser!.uid {
                            //its me and already currentUsername
                        } else {
                            //uNameisAlreadyTaken
                            uNameTaken = true
                            break
                        }
                    }
                }
                if uNameTaken == true {
                    let alert = UIAlertController(title: "Username Taken", message: "This username is already in use by someone else.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.editProfNameTextField.text = self.profName.text
                    
                    return
                } else {
                    self.updateUsername = true
                }
            }
        })
        }
    }
    
    @IBOutlet weak var sepLine7: UIView!
    @IBOutlet weak var sepLine6: UIView!
    @IBOutlet weak var sepLine5: UIView!
    @IBOutlet weak var sepLine4: UIView!
    @IBOutlet weak var sepLine3: UIView!
    @IBOutlet weak var sepLine2: UIView!
    @IBOutlet weak var sepLine1: UIView!
    @IBOutlet weak var updatePasswordButton: UIButton!
    @IBOutlet weak var usernameLab: UILabel!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var bioLab: UILabel!
    @IBOutlet weak var emailLab: UILabel!
    @IBOutlet weak var cityLab: UILabel!
    @IBOutlet weak var passwordLab: UILabel!
    @IBOutlet weak var selectPicButton: UIButton!
    @IBOutlet weak var gymLab: UILabel!
    @IBOutlet weak var editProfTopLabel: UILabel!
    
    public func textViewDidBeginEditing(_ textView: UITextView){
        print("beginEdit")
        //inEditBio = true
        sepLine1.isHidden = true
        editProfTopLabel.text = "Edit Bio"
        //sepLine2.isHidden = true
        sepLine3.isHidden = true
        sepLine4.isHidden = true
        sepLine5.isHidden = true
        sepLine6.isHidden = true
        sepLine7.isHidden = true
        topLeftNav.isHidden = true
        editProfBackButton.isHidden = true
        editProfSaveButton.isHidden = true
        editBioTextView.frame = editBioFrame2.frame
        editNameTF.isHidden = true
        editProfNameTextField.isHidden = true
        nameLine.isHidden = true
        usernameLab.isHidden = true
        nameLab.isHidden = true
        cityLine.isHidden = true
        bioLab.isHidden = true
        editEmailTF.isHidden = true
        editCityTF.isHidden = true
        emailLab.isHidden = true
        cityLab.isHidden = true
        //passwordLab.isHidden = true
        updatePasswordButton.isHidden = true
        editProfImageView.isHidden = true
        editProfPicButton.isHidden = true
        selectPicButton.isHidden = true
        editGymTF.isHidden = true
        gymLab.isHidden = true
        
        if textView.text == "Tap here to edit bio."{
            textView.text = ""
        }
        textView.textColor = UIColor.black
    }
    
    //@available(iOS 2.0, *)
    public func textViewDidEndEditing(_ textView: UITextView){
        editProfTopLabel.text = "Edit Profile"
        sepLine1.isHidden = false
        //sepLine2.isHidden = false
        sepLine3.isHidden = false
        sepLine4.isHidden = false
        sepLine5.isHidden = false
        sepLine6.isHidden = false
        sepLine7.isHidden = false
        topLeftNav.isHidden = false
        editProfBackButton.isHidden = false
        editProfSaveButton.isHidden = false
        editBioTextView.frame = ogEditBioTextViewFrame
        editNameTF.isHidden = false
        editProfNameTextField.isHidden = false
        nameLine.isHidden = false
        usernameLab.isHidden = false
        nameLab.isHidden = false
        cityLine.isHidden = false
        bioLab.isHidden = false
        editEmailTF.isHidden = false
        editCityTF.isHidden = false
        emailLab.isHidden = false
        cityLab.isHidden = false
        //passwordLab.isHidden = false
        updatePasswordButton.isHidden = false
        editProfImageView.isHidden = false
        editProfPicButton.isHidden = false
        selectPicButton.isHidden = false
        editGymTF.isHidden = false
        gymLab.isHidden = false
        if textView.text == "" {
            textView.text = "Tap here to edit bio."
        }
        self.updateBio = true
        textView.textColor = UIColor.lightGray
        
    }
    func sizeOfString (string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: DBL_MAX),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: [NSAttributedStringKey.font: font],
                                                         context: nil).size
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        var textWidth = UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset).width
        textWidth -= 2.0 * textView.textContainer.lineFragmentPadding;
        
        let boundingRect = sizeOfString(string: newText, constrainedToWidth: Double(textWidth), font: textView.font!)
        let numberOfLines = boundingRect.height / textView.font!.lineHeight;
        if numberOfLines > 5{
            let alert = UIAlertController(title: "Max lines reached", message: "Bio cannot be longer than 5 lines.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil
            ))
            alert.show()
            //self.present(alert, animated: true, completion: nil)
        }
        
        return numberOfLines <= 5;
    }
    var mentionID = String()
    
    func showHashTag(tagType: String, payload: String, postID: String, name: String) {
        if tagType == "mention"{
            print("mention: going to \(payload)'s profile")
            //self.curName = name
            Database.database().reference().child("usernames").observeSingleEvent(of: .value, with: { snapshot in
                let snapshots = snapshot.value as! [String:Any]
                for snap in snapshots{
                    if snap.key == payload{
                        self.mentionID = (snap.value as! [String])[0] as! String
                        if self.mentionID == Auth.auth().currentUser!.uid{
                            self.curUID = Auth.auth().currentUser!.uid
                            self.curName = (snap.value as! [String])[1] as! String
                            self.selectedCurAuthProfile = true
                        } else {
                            self.curUID = self.mentionID
                            self.curName = (snap.value as! [String])[1] as! String
                            self.selectedCurAuthProfile = false
                        }
                        
                        self.toMention = true
                        
                        self.performSegue(withIdentifier: "ProfToDumbView", sender: self)
                    }
                }
            })
        } else {
            print("hashtag: \(payload) database action")
            selectedHash = payload
            performSegue(withIdentifier: "ProfToHash", sender: self)
        }
        
    }

    var toMention = false
    var selectedCurAuthProfile = true
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch URL.scheme {
        case "hash" :
            showHashTagAlert(tagType: "hash", payload: (URL as NSURL).resourceSpecifier!.removingPercentEncoding!)
        case "mention" :
            showHashTagAlert(tagType: "mention", payload: (URL as NSURL).resourceSpecifier!.removingPercentEncoding!)
        default:
            print("just a regular url")
        }
        
        return true
    }
    
    
    func showHashTagAlert(tagType:String, payload:String){
        print("show hash")
        showHashTag(tagType: tagType, payload: payload, postID: "pid", name: "name")
        
    }
    var selectedHash = String()
    var updateUsername = false
    var updatePic = false
    var updateBio = false
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("hey thereee")
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            print("si: \(selectedImage)")
            editProfImageView.image = selectedImage
            self.updatePic = true
            
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        var tokenDict = [String: Any]()
        
        
        tokenDict["deviceToken"] = [fcmToken: true] as [String: Any]?
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    print("snapKey = \(snap.key)")
                    if snap.key == Auth.auth().currentUser!.uid {
                        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(tokenDict)
                    }
                }
            }
        })
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    
    
    
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    
    func convertToTimestamp(date: String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from: date)
        
        let now = Date()
        
        var hoursBetween = Int(now.days(from: date!))
        print("hrs Between: \(hoursBetween)")
        if hoursBetween < 1{
            hoursBetween = Int(now.hours(from: date!))!
            if hoursBetween < 1 {
                hoursBetween = Int(now.minutes(from: date!))
                if hoursBetween == 1{
                    return "\(hoursBetween) minute ago"
                } else {
                    return "\(hoursBetween) minutes ago"
                }
            } else {
                if hoursBetween == 1 {
                    return "\(hoursBetween) hour ago"
                } else {
                    return "\(hoursBetween) hours ago"
                }
            }
        } else {
            if hoursBetween == 1 {
                return "\(hoursBetween) day ago"
            } else {
                return "\(hoursBetween) days ago"
            }
        }
    }
    var gymCoord = [String:Any]()
    var cityCoord = [String:Any]()
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ProfToHash"{
            if let vc = segue.destination as? HashTagViewController{
                vc.hashtag = self.selectedHash
                vc.prevScreen = "prof"
                vc.curUID = self.curUID!
                vc.curName = self.curName
            }
        }
        if segue.identifier == "ProfToDumbView"{
            if let vc = segue.destination as? DumbViewController{
                vc.curUID = self.curUID!
                vc.curName = self.curName
            }
        }
        if segue.identifier == "ProfileToMap"{
            if let vc = segue.destination as? MapViewController{
                vc.mapType = self.mapType
                if mapType == "gym"{
                    vc.myGym = self.homeGym!
                    vc.myCoord = self.gymCoord
                } else {
                    vc.myCity = self.city!
                    vc.myCoord = self.cityCoord
                }
                vc.myUName = self.userNameTop.text!
                vc.myName = self.profName.text!
                vc.myPic = self.myPicString
                vc.prevID = self.curUID!
                
                vc.followersArr = self.followingArr
            }
        }
        if segue.identifier == "ProfileToSingleTopic"{
            if let vc = segue.destination as? SingleTopicViewController{
                vc.topicData = self.singleTopic
            }
        }
        if segue.identifier == "ProfileToFavorites"{
            if let vc = segue.destination as? FavoritesViewController{
                vc.uName = self.username
                vc.realName = self.name
                vc.favData = self.favData
            }
        }
        if segue.identifier == "ProfileToMessages"{
            if let vc = segue.destination as? MessagesTableViewController{
                    print("yo")
                    print(self.curUID)
                vc.curUID = self.curUID!
                        vc.recipientID = self.messageRecipID
                        vc.curItemKey = self.messageRecipID
                        vc.prevScreen = "profile"
                vc.selectedRecip = self.curUID!
                    
                }
        }
        if segue.identifier == "profToSinglePost"{
            if let vc = segue.destination as? SinglePostViewController{
                
                vc.prevScreen = "profile"
                vc.senderScreen = "profile"
                vc.thisPostData = self.selectedData
                vc.myUName = self.userNameTop.text!
                vc.following = self.following
                vc.myPicString = self.myPicString
            }
        } else if segue.identifier == "profToFollow" {
            if let vc = segue.destination as? FolloweringViewController{
                
                vc.flwrDataArr = self.flwrDataArr
                vc.flwingDataArr = self.flwingDataArr
                vc.followType = self.followType
                vc.followersArr = self.followersArr
                vc.prevID = self.curUID!
                
                
            }
            
        }
        if segue.identifier == "ProfileToFeed"{
            if let vc = segue.destination as? HomeFeedViewController{
                vc.prevScreen = "profile"
            }
            
        }
        if segue.identifier == "ProfileToNotifications"{
            if let vc = segue.destination as? NotificationsViewController{
                vc.prevScreen = "profile"
            }
        }
        if segue.identifier == "ProfileToSearch"{
            if let vc = segue.destination as? SearchViewController{
                vc.prevScreen = "profile"
            }
        }
        if segue.identifier == "ProfileToPost"{
            if let vc = segue.destination as? PostViewController{
                vc.prevScreen = "profile"
            }
        }
    }
    var editCityObject = [Any]()
    var editGymObject = [Any]()
    var searchActive = Bool()
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //findFriendsSearchBar.showsCancelButton = false
        searchActive = true;
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.findFriendsSearchBar.endEditing(true)
    }
    
    var allSuggested = [String]()
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        print("SB text did change: \(searchText)")
        findFriendsData.removeAll()
        allSuggested.removeAll()
        
        var tempUserDict = [String:Any]()
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: {(snapshot) in
            print("here: \(snapshot.value)")
            //let snapshotss = snapshot.value as? [DataSnapshot]
            print("hereNow")
            for (key, val) in (snapshot.value as! [String:Any]){
                print("uName=\(((val as! [String:Any])["username"] as! String))")
                let uName = ((val as! [String:Any])["username"] as! String)
                let rName = ((val as! [String:Any])["realName"] as! String)
                let picString = ((val as! [String:Any])["profPic"] as! String)
                let uid = key
                var pic: UIImage?
                if picString == "profile-placeholder"{
                    //  pic = "profile-placeholder"
                    pic = UIImage(named: "profile-placeholder")
                } else {
                    if let messageImageUrl = URL(string: picString) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            pic = UIImage(data: imageData as Data)
                            //self.editProfImageView.image = UIImage(data: imageData as Data)
                        }
                    }
                }
                
                let uRange = (uName as NSString).range(of: searchText, options: NSString.CompareOptions.literal)
                let rRange = (rName as NSString).range(of: searchText, options: NSString.CompareOptions.literal)
                print("rANDu: \(uRange) \(rRange)")
                if uRange.location != NSNotFound {
                    tempUserDict[key] = ["uName":uName, "rName":rName, "pic": pic!, "uid": uid]
                    self.allSuggested.append(rName)
                    print("curTextu: \(searchText) allSuggested1: \(self.allSuggested)")
                } else if rRange.location != NSNotFound{
                    
                    tempUserDict[key] = ["uName":uName, "rName":rName, "pic": pic!,"picString":picString, "uid": uid]
                    
                    
                    self.allSuggested.append(key)
                    print("curText: \(searchText) allSuggested: \(self.allSuggested)")
                } else if self.allSuggested.contains(key){
                    if self.allSuggested.contains(rName){
                        tempUserDict.removeValue(forKey: key)
                        self.allSuggested.remove(at: self.allSuggested.index(of: key)!)
                        //self.findFriendsData.remove(at: fin)
                    }
                    
                }
                
            }
            print("nowHereee")
            var tempCurUids = [String]()
            for dict in self.findFriendsData{
                tempCurUids.append(dict["uid"] as! String)
                
            }
            for (key, val) in tempUserDict {
                print("snapKey: \(key)")
                if self.allSuggested.contains(key){
                    
                    var tempDict = [String:Any]()
                    tempDict = val as! [String:Any]
                    print("snapVal: \(val as! [String:Any])")
                    var noName = "-"
                    var uName = tempDict["uName"] as! String
                    
                    
                    var picString2 = tempDict["picString"] as! String
                    if (tempDict["rName"] as? String) != nil{
                        noName = (tempDict["rName"] as! String)
                    }
                    
                    let cellDict = ["uName":uName,"profPic": tempDict["pic"]!, "picString": picString2, "realName": noName, "uid": key] as [String:Any]
                    
                    if tempCurUids.contains(key){
                        break
                    } else {
                        self.findFriendsData.append(cellDict)
                    }
                }
            }
            if(self.findFriendsData.count == 0){
                self.searchActive = false;
            } else {
                self.searchActive = true;
            }
            
            
            
            DispatchQueue.main.async{
                self.findFriendsCollect.reloadData()
            }
            
        })
        
    } // called when text changes (including clear)
    
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.searchActive = false
        print("in search pressed")
        findFriendsSearchBar.resignFirstResponder()
    } // called when keyboard search button pressed
    
    
    

}
extension ProfileViewController:PlayerDelegate {
    
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

extension ProfileViewController:PlayerPlaybackDelegate {
    
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
extension ProfileViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("didAutoComplete")
        if curTF == "city"{
        self.editCityTF.text = place.name
        //self.updateCity = true
            self.editCityObject = [place.coordinate.latitude, place.coordinate.longitude]
        } else {
            self.editGymObject = [place.name, ["lat":(place.coordinate.latitude ), "long": (place.coordinate.longitude )]]
            self.editGymTF.text = place.name
            //editGymTF.text = textField.text!
            self.updateGym = true
            //self.updateGym = true
        }
        //jobPost.location = place.formattedAddress
        //self.place = place
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.didCancelAutopicker = true
        if curTF == "city"{
            updateCity = false
        } else {
            updateGym = false
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
extension ProfileViewController {
    
    /* @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
     
     switch (self.selectedCell.player?.playbackState.rawValue) {
     case PlaybackState.stopped.rawValue?:
     self.selectedCell.player?.playFromBeginning()
     break
     case PlaybackState.paused.rawValue?:
     self.selectedCell.player?.playFromCurrentTime()
     break
     case PlaybackState.playing.rawValue?:
     self.selectedCell.player?.pause()
     break
     case PlaybackState.failed.rawValue?:
     self.selectedCell.player?.pause()
     break
     default:
     self.selectedCell.player?.pause()
     break
     }*/
    //}
    
}

public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
