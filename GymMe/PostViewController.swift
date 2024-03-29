//
//  PostViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 6/23/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit

import FirebaseDatabase
//import Firebase

import FirebaseStorage
import FirebaseAuth
import AVFoundation
import AVKit
import Photos
import SwiftOverlays
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import CoreLocation
import YPImagePicker


class CustomViewFlowLayout: UICollectionViewFlowLayout {
    
    let cellSpacing:CGFloat = 4
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumLineSpacing = 10.0
        self.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + cellSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        return attributes
    }
}


class PostCatSearchSportsCell: UICollectionViewCell {
    @IBOutlet weak var catSportLabel: UILabel!
}

class PostCatSearchCell: UICollectionViewCell {
    @IBOutlet weak var catLabel: UILabel!
    @IBOutlet weak var catCheck: UIImageView!
    
    @IBOutlet weak var sportsArrow: UIButton!
    override func prepareForReuse(){
        self.sportsArrow.isHidden = true
        super.prepareForReuse()
        
       
    }
}

class PostViewController: UIViewController, UITabBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate, CLLocationManagerDelegate, UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, RemoveCatDelegate{
    var catLabels = ["Abs","Arms","Back","Body Building","Cardio","Chest","Crossfit", "Legs","Nutrition", "Shoulders","Sports","Stretching","Speed & Agility"]
    var catSportsData = ["Soccer","Football","Lacrosse", "Track & Field", "Tennis","Baseball","Swimming","Basketball","Rock Climbing","Softball","Golf","Ice Hockey","Boxing","Cycling","Rugby","MMA","Volleyball"]
    var placeAddress = String()
    var place: GMSPlace?
    var catLabelsRefined = [String]()
    var prevScreen = String()
    var selectedCellsArr = [PostCatSearchCell]()
    var picPostTextViewPos: CGRect?
    var extended = false
    var ogVidPosit = CGRect()
    var ogPicPosit = CGRect()
    var ogPicVidPosit = CGRect()
    var currentPicker = String()
    let picker = UIImagePickerController()
    let imagePicker = UIImagePickerController()
    var curCatsAdded = [String]()
    var taggedString = String()
    var curString = ""
    var curCatsData = [String]()
    var ogCat1Pos = CGRect()
    var ogCat2Pos = CGRect()
    var ogCat3Pos = CGRect()
    var newPost: [String:Any]?
   
    @IBOutlet weak var tagSearchBar: UISearchBar!
    @IBOutlet weak var addCat3TextPos: UIView!
    @IBOutlet weak var addCat2TextPos: UIView!
    @IBOutlet weak var addCat1TextPos: UIView!
    @IBOutlet weak var whiteShadeView: UIView!
    @IBOutlet weak var curCatsLabel: UILabel!
    @IBOutlet weak var shadeView2: UIView!
    @IBOutlet weak var shadeView1: UIView!
    @IBOutlet weak var sportsCollect: UICollectionView!
    @IBOutlet weak var sportsView: UIView!
    @IBOutlet weak var tagPeopleLabel: UILabel!
    @IBOutlet weak var doneWithSportsButton: UIButton!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var picViewLine1: UIView!
    @IBOutlet weak var picViewLine2: UIView!
    @IBOutlet weak var picViewLine3: UIView!
    @IBOutlet weak var addCatView: UIView!
    @IBOutlet weak var addCatCollect: UICollectionView!
    @IBOutlet weak var textPostTextViewPos: UIView!
    @IBOutlet weak var posterPicTextPos: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var postText: UIView!
    @IBOutlet weak var postPic: UIView!
    @IBOutlet weak var picVidButton: UIButton!
    @IBOutlet weak var picVidSmallFrame: UIView!
    @IBOutlet weak var addPicButton: UIButton!
    @IBOutlet weak var catTopLabel: UILabel!
    @IBOutlet weak var picButtonPositionOut: UIView!
    @IBOutlet weak var backToPostButton: UIButton!
    @IBOutlet weak var tagPeopleButton: UIButton!
    @IBOutlet weak var tagPeopleButtonIcon: UIButton!
    @IBOutlet weak var addToCategoryLabel: UILabel!
    @IBOutlet weak var addToCatIconButton: UIButton!
    @IBOutlet weak var addToCategoryButton: UIButton!
    @IBOutlet weak var addLocationIcon: UIButton!
    @IBOutlet weak var shareIconButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var addVidButton: UIButton!
    @IBOutlet weak var posterPicIV: UIImageView!
    @IBOutlet weak var postLine: UIView!
    @IBOutlet weak var vidButtonPositionOut: UIView!
    @IBOutlet weak var curCatsCollect: UICollectionView!
    @IBOutlet weak var topLineCat: UIView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var textPostPressedLine: UIView!
    @IBOutlet weak var textPostPressedLabel: UILabel!
    @IBOutlet weak var curCityLabel: UILabel!
    @IBOutlet weak var succesfulPostView: UIView!
    @IBOutlet weak var cancelPostButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var makePostView: UIView!
    @IBOutlet weak var makePostImageView: UIImageView!
    @IBOutlet weak var makePostTextView: UITextView!
    @IBAction func doneWithSportsButtonPressed(_ sender: Any) {
        //var count = 0
        containsSport = false
        for row in 0...self.sportsCollect.numberOfItems(inSection: 0) - 1
        {
            let indexPath = IndexPath(row: row, section: 0)
            sportsCollect.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
            if let cell = getCell(indexPath) {
                if (cell.catSportLabel.textColor == UIColor.red) {
                    containsSport = true
                    //print("sportText: \((sportsCollect.cellForItem(at: indexPath as IndexPath) as! PostCatSearchSportsCell).catSportLabel.text!)")
                    curCatsData.append((sportsCollect.cellForItem(at: indexPath as IndexPath) as! PostCatSearchSportsCell).catSportLabel.text!)
                }
            }
        }
        if containsSport == true {
            for cell in addCatCollect.visibleCells{
                if (cell as! PostCatSearchCell).catLabel.text == "Sports"{
                    (cell as! PostCatSearchCell).catLabel.textColor = UIColor.red
                }
            }
        } else {
            for cell in addCatCollect.visibleCells{
                if (cell as! PostCatSearchCell).catLabel.text == "Sports"{
                    (cell as! PostCatSearchCell).catLabel.textColor = UIColor.black
                }
            }
            for data in curCatsData{
                if catSportsData.contains(data){
                    curCatsData.remove(at: curCatsData.index(of: data)!)
                }
            }
        }
        sportsView.isHidden = true
    }
   
    @IBAction func addPicTouched(_ sender: AnyObject) {
        currentPicker = "photo"
        
        let picker = YPImagePicker()
        
        self.postType = "pic"
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.makePostView.isHidden = false
                self.cancelPostButton.isHidden = false
                self.makePostImageView.image = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
        
    }
    
    @IBAction func picVidPressed(_ sender: Any) {
        startLocationManager()
        postLine.isHidden = true
        picViewLine1.isHidden = false
        picViewLine2.isHidden = false
        picViewLine3.isHidden = false
        //catTopLabel.isHidden = true
        
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .video]
        config.library.mediaType = .photoAndVideo
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    if let photo = items.singlePhoto {
                        self.makePostView.isHidden = false
                        self.cancelPostButton.isHidden = false
                        // var //tempImage = photo.image.
                        self.makePostImageView.image = photo.image
                        self.postType = "pic"
                        
                    }
                case .video(let video):
                    if let video = items.singleVideo {
                        print(video.fromCamera)
                        print(video.thumbnail)
                        print(video.url)
                        self.makePostView.isHidden = false
                        self.cancelPostButton.isHidden = false
                        self.postPlayer?.url = video.url
                        let videoURL = video.url as! NSURL
                        do {
                            let video1 = try NSData(contentsOf: videoURL as URL, options: .mappedIfSafe)
                            self.vidData = video1
                            self.postType = "vid"
                        } catch {
                            print(error)
                            return
                        }
                    }
                }
                picker.dismiss(animated: true, completion: nil)
            }
        }
        present(picker, animated: true, completion: nil)
        
    }
    @IBAction func backFromTag(_ sender: Any) {
  
    }
    @IBAction func backFromTheCat(_ sender: Any) {
    
    }
    @IBAction func backFuq(_ sender: Any){
        addCatView.isHidden = true
        cancelPostButton.isHidden = false
        postButton.isHidden = false
    }
    @IBAction func backToPostPressed(_ sender: Any) {
        // DispatchQueue.main.async{
        print("curCatsAdded: \(self.curCatsAdded), curCatsData: \(self.curCatsData), selectedCellsArr: \(self.selectedCellsArr)")
        //add for loop here that loops through sports collect and checks if red text
        curCatsData = Array(Set(curCatsData))
        addCatView.isHidden = true
        var catLabelsSorted = catLabels.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        
        catLabelsRefined = catLabelsSorted
        addCatCollect.reloadData()
        curCatsCollect.reloadData()
        postButton.isHidden = false
        cancelPostButton.isHidden = false
        makePostTextView.resignFirstResponder()
        
  
    }
    
    @IBAction func tagPeopleButtonPressed(_ sender: Any) {
        postButton.isHidden = true
        tagView.isHidden = false
        
    }
    @IBAction func addToCategoryButtonPressed(_ sender: Any) {
        addCatView.isHidden = false
        postButton.isHidden = true
        cancelPostButton.isHidden = true
        curCatsLabel.text = ""
        curCatsAdded.removeAll()

    }

    @IBAction func shareButtonPressed(_ sender: Any) {
    }
    @IBAction func textPostPressed(_ sender: Any) {
        postLine.isHidden = true
        picViewLine1.isHidden = true
        picViewLine2.isHidden = true
        picViewLine3.isHidden = true
        startLocationManager()
        self.postType = "text"
        addToCategoryLabel.isHidden = true
        addToCategoryButton.isHidden = true
        self.addToCategoryLabel.isHidden = true
        makePostTextView.delegate = self
        makePostTextView.selectAll(nil)
        UIView.animate(withDuration: 0.5, animations: {
            self.tagPeopleButton.isHidden = true
            self.tagPeopleButtonIcon.isHidden = true
            //self.shareButton.isHidden = true
            //self.shareIconButton.isHidden = true
            self.addToCatIconButton.isHidden = true
            self.addToCategoryLabel.isHidden = true
            self.addToCategoryButton.isHidden = true
            self.curCatsLabel.isHidden = true
            
            self.curCatsLabel.isHidden = true
            self.makePostTextView.frame = self.textPostTextViewPos.frame
            self.addToCatIconButton.frame = self.addCat1TextPos.frame
            self.addToCategoryButton.frame = self.addCat2TextPos.frame
            self.curCatsLabel.frame = self.addCat3TextPos.frame
            self.makePostTextView.text = "What's going on?"
            self.cancelPostButton.isHidden = false
            self.makePostView.isHidden = false
            self.makePostImageView.isHidden = true
            self.postPlayer?.view.isHidden = true
            self.makePostView.backgroundColor = UIColor.white
            self.postText.isHidden = true
            self.postPic.isHidden = true
            self.makePostTextView.becomeFirstResponder()
        })
    }
    
    @IBAction func chooseVidFromPhoneSelected(_ sender: AnyObject) {
        self.postType = "vid"
        addToCategoryButton.isHidden = false
        addToCategoryLabel.isHidden = false
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .video]
        config.library.mediaType = .photoAndVideo
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let video = items.singleVideo {
                print(video.fromCamera)
                print(video.thumbnail)
                print(video.url)
                self.makePostView.isHidden = false
                self.cancelPostButton.isHidden = false
                self.postPlayer?.url = video.url
                let videoURL = video.url as! NSURL
                do {
                    let video1 = try NSData(contentsOf: videoURL as URL, options: .mappedIfSafe)
                    self.vidData = video1
                } catch {
                    print(error)
                    return
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func addLocationPressed(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    @IBAction func cancelPostButtonPressed(_ sender: Any) {
        
        if tagView.isHidden == false{
            postButton.isHidden = false
            tagView.isHidden = true
            tagSearchBar.resignFirstResponder()
        } else {
            postLine.isHidden = false //makePostTextView.resignFirstResponder()
            makePostImageView.image = nil
            postPlayer?.url = nil
            taggedFriends.removeAll()
            postText.isHidden = false
            postPic.isHidden = false
            self.addPicButton.frame = self.ogPicPosit
            self.addVidButton.frame = self.ogVidPosit
            self.picVidButton.frame = self.ogPicVidPosit
            self.addVidButton.alpha = 0.0
            self.addPicButton.alpha = 0.0
            self.picVidButton.alpha = 1.0
            makePostImageView.isHidden = false
            cancelPostButton.isHidden = true
            makePostView.backgroundColor = UIColor.white
            makePostTextView.text = "Write a caption..."
            self.addToCatIconButton.isHidden = false
            self.addToCategoryButton.isHidden = false
            self.addToCategoryLabel.isHidden = false
            self.curCatsLabel.text = ""
            self.curCatsLabel.isHidden = false
            makePostTextView.frame = picPostTextViewPos!
            addToCatIconButton.frame = ogCat1Pos
            addToCategoryButton.frame = ogCat2Pos
            curCatsLabel.frame = ogCat3Pos
            makePostTextView.textColor = UIColor.darkGray
            self.tagPeopleButton.isHidden = false
            self.tagPeopleButtonIcon.isHidden = false
            self.cityData = nil
            self.curCityLabel.text = ""
            self.extended = false
            makePostView.isHidden = true
        }
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        SwiftOverlays.showBlockingWaitOverlayWithText("Posting to Feed...")
        postText.isHidden = false
        postPic.isHidden = false
        newPost = [String: Any]()
        if postType == "pic"{
            newPost!["posterUID"] = Auth.auth().currentUser!.uid
            newPost!["posterName"] = self.curUser.username
            print("cUpP2: \(curUser.profPic!)")
            newPost!["posterPicURL"] = curUser.profPic!
            self.newPost!["likes"] = [["x":"x"]]
            self.newPost!["favorites"] = [["x":"x"]]
            self.newPost!["shares"] = [["x":"x"]]
            self.newPost!["comments"] = [["x":"x"]]
            var finalTag = [[String:Any]]()
            
            for dict in taggedFriends{
                var temp = dict as! [String:Any]
                temp.removeValue(forKey: "profPic")
                finalTag.append(temp)
            }
            
            self.newPost!["tagged"] = finalTag
            if self.curCatsData == nil || self.curCatsData.count == 0{
                curCatsData.append("Other")
            }
            self.newPost!["categories"] = self.curCatsData
            self.newPost!["city"] = self.curCityLabel.text
            if(self.place == nil){
                print("no place coord")
            } else {
                self.newPost!["postCoord"] = ["lat":Double((self.place?.coordinate.latitude)!),"long": Double((self.place?.coordinate.longitude)!)]
            }
            
            //let curLoc = locationManager.location
            //newPost![location]
            if self.makePostTextView.text != "Write a caption..."{
                newPost!["postText"] = self.makePostTextView.text
            }
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("FeedPosts").child("ImagePosts").child(Auth.auth().currentUser!.uid).child("\(imageName).jpg")
            print("makePostImageView: \(self.makePostImageView.image!)")
            if let uploadData = UIImageJPEGRepresentation(self.makePostImageView.image!, 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return  };
                    print("makePostImageView: \(self.makePostImageView.image!)")
                    
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
                        self.checkForTags(postID: key)
                        
                        
                        self.makePostTextView.textColor = UIColor.darkGray
                        print("This never prints in the console")
                        self.postPlayer?.url = nil
                        self.makePostImageView.image = nil
                        self.makePostView.isHidden = true
                        self.cancelPostButton.isHidden = true
                        
                        self.addToCatIconButton.isHidden = false
                        self.addToCategoryButton.isHidden = false
                        self.addToCategoryLabel.isHidden = false
                        
                        self.curCatsLabel.text = ""
                        self.curCatsLabel.isHidden = false
                        self.makePostTextView.frame = self.picPostTextViewPos!
                        self.addToCatIconButton.frame = self.ogCat1Pos
                        self.addToCategoryButton.frame = self.ogCat2Pos
                        self.curCatsLabel.frame = self.ogCat3Pos
                        self.tagPeopleButton.isHidden = false
                        self.tagPeopleButtonIcon.isHidden = false
                        SwiftOverlays.removeAllBlockingOverlays()
                        self.performSegue(withIdentifier: "PostToFeed", sender: self)
                    })
                })
            }
        } else if postType == "vid" {
            print("uploadingVid")
            newPost!["posterUID"] = Auth.auth().currentUser!.uid
            newPost!["posterName"] = self.curUser.username
            if self.curCatsAdded == nil || self.curCatsAdded.count == 0{
                curCatsAdded.append("Other")
            }
            self.newPost!["categories"] = self.curCatsAdded
            print("cUpP3: \(curUser.profPic!)")
            newPost!["posterPicURL"] = curUser.profPic!
            self.newPost!["city"] = self.curCityLabel.text
            if self.makePostTextView.text != "Write a caption..."{
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
                if(self.place == nil){
                    print("no place coord")
                } else {
                    self.newPost!["postCoord"] = ["lat":Double((self.place?.coordinate.latitude)!),"long": Double((self.place?.coordinate.longitude)!)]
                }
                self.newPost!["postVid"] = (metadata?.downloadURL()?.absoluteString)!
                self.newPost!["datePosted"] = Date().description
                self.newPost!["likes"] = [["x":"x"]]
                self.newPost!["favorites"] = [["x":"x"]]
                self.newPost!["shares"] = [["x":"x"]]
                self.newPost!["comments"] = [["x":"x"]]
                //self.newPost!["categories"] = self.curCatsAdded
                self.newPost!["posterPicURL"] = self.curUser.profPic!
                let key = Database.database().reference().child("posts").childByAutoId().key
                self.newPost!["postID"] = key
                
                let childUpdates = ["/posts/\(key)": self.newPost,
                                    "/users/\(Auth.auth().currentUser!.uid)/posts/\(key)/": self.newPost]
                Database.database().reference().updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                    if error != nil{
                        print(error?.localizedDescription)
                        return
                    }
                    self.checkForTags(postID: key)
                    
                    self.makePostTextView.textColor = UIColor.darkGray
                    print("This never prints in the console")
                    self.postPlayer?.url = nil
                    self.makePostImageView.image = nil
                    self.makePostView.isHidden = true
                    self.cancelPostButton.isHidden = true
                    SwiftOverlays.removeAllBlockingOverlays()
                    self.performSegue(withIdentifier: "PostToFeed", sender: self)
                    
                })
            }
        } else {
            if self.makePostTextView.hasText == false || self.makePostTextView.text == "Write a caption..." || self.makePostTextView.text == "What's going on?" || self.makePostTextView.text == "" {
                let alert = UIAlertController(title: "Missing Info", message: "You cannot make an empty post.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                SwiftOverlays.removeAllBlockingOverlays()
                return
            }
            makePostTextView.resignFirstResponder()
            newPost!["posterUID"] = Auth.auth().currentUser!.uid
            newPost!["posterName"] = self.curUser.username
            print("cUpP: \(curUser.profPic!)")
            newPost!["posterPicURL"] = curUser.profPic
            
            self.newPost!["comments"] = [["x":"x"]]
            newPost!["likes"] = [["x":"x"]]
            newPost!["favorites"] = [["x":"x"]]
            newPost!["shares"] = [["x":"x"]]
            if self.curCatsAdded == nil || self.curCatsAdded.count == 0{
                curCatsAdded.append("Other")
            }
            self.newPost!["categories"] = self.curCatsAdded
            
            newPost!["postText"] = self.makePostTextView.text
            
            self.newPost!["datePosted"] = Date().description
            let key = Database.database().reference().child("posts").childByAutoId().key
            self.newPost!["postID"] = key
            print("self.cityInPost: \(self.city)")
            self.newPost!["city"] = self.curCityLabel.text
            let childUpdates = ["/posts/\(key)": self.newPost,
                                "/users/\(Auth.auth().currentUser!.uid)/posts/\(key)/": self.newPost]
            Database.database().reference().updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                if error != nil{
                    print(error?.localizedDescription)
                    return
                }
                self.checkForTags(postID: key)
                
                self.makePostTextView.textColor = UIColor.darkGray
                print("This never prints in the console")
                self.postPlayer?.url = nil
                self.makePostImageView.image = nil
                self.makePostView.isHidden = true
                self.cancelPostButton.isHidden = true
                SwiftOverlays.removeAllBlockingOverlays()
                
                self.performSegue(withIdentifier: "PostToFeed", sender: self)
            })
        }
        DispatchQueue.main.async{
            self.makePostTextView.frame = self.picPostTextViewPos!
            self.addToCatIconButton.frame = self.ogCat1Pos
            self.addToCategoryButton.frame = self.ogCat2Pos
            self.curCatsLabel.frame = self.ogCat3Pos
            self.makePostImageView.isHidden = false
            self.postPlayer?.view.isHidden = true
            self.cityData = nil

        }
    }
    @IBAction func postSuccButtonPressed(_ sender: Any) {
        self.curCityLabel.text = ""
        for cell in self.addCatCollect.visibleCells{
            let tempCell = cell as! PostCatSearchCell
            tempCell.catLabel.textColor = UIColor.black
        }
        self.curCatsAdded.removeAll()
        self.curCatsLabel.text = ""
        succesfulPostView.isHidden = true
        
    }
    @IBAction func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            // Perform action.
            print("swipeRight: \(prevScreen)")
            if prevScreen == "feed"{
                performSegue(withIdentifier: "PostToFeed", sender: self)
            }
            if prevScreen == "profile"{
                performSegue(withIdentifier: "PostToProfile", sender: self)
            }
            
            if prevScreen == "search"{
                performSegue(withIdentifier: "PostToSearch", sender: self)
            }
            if prevScreen == "notifications"{
                performSegue(withIdentifier: "PostToNotifications", sender: self)
            }
        }
    }
    
    func removeCat(catLabel: String) {
        print("inremoveDel2")
        var i = 0
        for str in curCatsData{
            if str == catLabel{
                curCatsData.remove(at: i)
            }
            i = i + 1
        }
        curCatCount = curCatCount - 1
        curCatsAdded = curCatsData
        DispatchQueue.main.async{
            self.curCatsCollect.reloadData()
            self.addCatCollect.reloadData()
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         if collectionView == sportsCollect{
            return catSportsData.count
         } else if collectionView == addCatCollect {
        return catLabelsRefined.count
         } else if collectionView == curCatsCollect{
            return curCatsData.count
         } else {
            return findFriendsData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tagCollect {
            
            let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
          
            cell.likedByFollowButton.isHidden = true
            cell.likedByName.isHidden = false
            cell.likedByUName.isHidden = false
            
            cell.commentName.isHidden = true
            cell.commentTextView.isHidden = true
            cell.commentTimestamp.isHidden = true
            cell.likedByUName.text = ((findFriendsData[indexPath.row] )["uName"] as! String)
            
            cell.likedByUID = ((findFriendsData[indexPath.row])["uid"] as! String)
            
            cell.likedByName.text = ((findFriendsData[indexPath.row] )["realName"] as! String)
            if ((findFriendsData[indexPath.row])["picString"] as! String) == "profile-placeholder"{
                cell.likedByImage.image = UIImage(named: "profile-placeholder")
                
            } else {
                cell.likedByImage.image = ((findFriendsData[indexPath.row])["profPic"] as! UIImage)
            }
            return cell
            
            
        } else if collectionView == sportsCollect{
            let cell : PostCatSearchSportsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCatSearchSportsCell", for: indexPath) as! PostCatSearchSportsCell
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            
            cell.catSportLabel.text = catSportsData[indexPath.row]
            
            return cell
        } else if collectionView == curCatsCollect{
            let cell : CurCatsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurCatsCollectionViewCell", for: indexPath) as! CurCatsCollectionViewCell
            cell.delegate = self
            cell.curCatLabel.text = curCatsData[indexPath.row]
            
            let margins = cell.layoutMarginsGuide
            cell.removeCatButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
            
            return cell
        } else {
        let cell : PostCatSearchCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCatSearchCell", for: indexPath) as! PostCatSearchCell
            if curCatsData.contains(catLabelsRefined[indexPath.row]){
                cell.catLabel.textColor = UIColor.red
                
            } else {
                cell.catLabel.textColor = UIColor.black
            }
        cell.catLabel.text = catLabelsRefined[indexPath.row]
            if catLabelsRefined[indexPath.row] == "Sports"{
                cell.sportsArrow.isHidden = false
                if containsSport == true{
                    cell.catLabel.textColor = UIColor.red
                } else {
                    cell.catLabel.textColor = UIColor.black
                }
            }
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width: cell.frame.size.width, height: 0.5)
        
        border.borderWidth = width
        cell.layer.addSublayer(border)
        cell.layer.masksToBounds = true
            return cell
        }
        
    }
    var containsSport = false
    
    func getCell(_ indexPath: IndexPath) -> PostCatSearchSportsCell? {
        sportsCollect.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
        var cell = sportsCollect.cellForItem(at: indexPath) as? PostCatSearchSportsCell
        if cell == nil {
            print("nil1")
            sportsCollect.layoutIfNeeded()
            cell = sportsCollect.cellForItem(at: indexPath) as? PostCatSearchSportsCell
        }
        if cell == nil {
            print("nil2")
            sportsCollect.reloadData()
            sportsCollect.layoutIfNeeded()
            cell = sportsCollect.cellForItem(at: indexPath) as? PostCatSearchSportsCell
        }
        return cell
    }

    var selectedSports = [String]()
    var taggedFriends = [[String:Any]]()
    var curCatCount = 0
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == tagCollect{
            var cell = collectionView.cellForItem(at: indexPath) as! LikedByCollectionViewCell
            var containsUid = false
            var count = 0
            for dict in taggedFriends {
                if dict["uid"] as! String == (findFriendsData[indexPath.row])["uid"] as! String{
                    containsUid = true
                    break
                }
                count = count + 1
            }
            if containsUid == false{
                 taggedFriends.append(findFriendsData[indexPath.row] as! [String:Any])
            } else {

                taggedFriends.remove(at: count)
            }
            //print("taggedFriends: \(taggedFriends)")
            taggedString = ""
            for dict in taggedFriends{
                taggedString = taggedString + " " + (dict["realName"] as! String) + ","
            }
            //print("taggedString: \(taggedString)")
            tagPeopleLabel.text = taggedString
            tagView.isHidden = true
            postButton.isHidden = false
            tagSearchBar.text = ""
            tagSearchBar.endEditing(true)
            tagSearchBar.resignFirstResponder()
            findFriendsData.removeAll()
            DispatchQueue.main.async{
            self.tagCollect.reloadData()
            }
            
            
            
        } else if collectionView == curCatsCollect{
            
        } else if collectionView == sportsCollect {
            var sportCellSelected = collectionView.cellForItem(at: indexPath) as! PostCatSearchSportsCell
            if sportCellSelected.catSportLabel.textColor == UIColor.red {
                curCatCount = curCatCount - 1
                sportCellSelected.catSportLabel.textColor = UIColor.black
            } else {
                
                if curCatCount == 6{
                    let alert = UIAlertController(title: "Maximum Categories", message: "You cannot add more than 6 categories to a post.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                } else {
                    curCatCount = curCatCount + 1
                sportCellSelected.catSportLabel.textColor = UIColor.red
                }
            }
         } else {
        var cellSelected = collectionView.cellForItem(at: indexPath) as! PostCatSearchCell
            print("wtf: \(cellSelected.catLabel.text!)")
        /*if (cellSelected.catLabel.text as! String) == "Sports"{
            if curCatCount == 6{
                let alert = UIAlertController(title: "Maximum Categories", message: "You cannot add more than 6 categories to a post.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return
            } else {
                sportsView.isHidden = false
                return
            }
        }*/
        if cellSelected.catLabel.textColor == UIColor.red && cellSelected.catLabel.text != "Sports"{
            cellSelected.catLabel.textColor = UIColor.black
            var indexPa = IndexPath()
            var count = 0
            print("trying to remove \(cellSelected.catLabel.text)")
            for str in curCatsData{
                print("trying to removeee \(cellSelected.catLabel.text), \(str)")
                if str == cellSelected.catLabel.text!{
                    indexPa = IndexPath(row: count, section: 0)
                }
                count = count + 1
            }
            curCatsData.remove(at: indexPa.row/*selectedCellsArr.firstIndex(of: cellSelected)!*/)
            curCatCount = curCatCount - 1
            
            
        } else {
            if curCatCount == 6 && cellSelected.catLabel.text != "Sports"{
                //alert
                let alert = UIAlertController(title: "Maximum Categories", message: "You cannot add more than 6 categories to a post.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
               
                return
            } else {
                if cellSelected.catLabel.text == "Sports"{
                    sportsView.isHidden = false
                } else {
                curCatCount = curCatCount + 1
            cellSelected.catLabel.textColor = UIColor.red
            curCatsData.append(cellSelected.catLabel.text!)
                }
            }
        }
            
        }
        
    }
   
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == curCatsCollect{
           
            let string = curCatsData[indexPath.row] as! String
            
            // your label font.
            let font = UIFont.systemFont(ofSize: 12)
            let fontAttribute = [NSAttributedStringKey.font: font]
            
            // to get the exact width for label according to ur label font and Text.
            let size = string.size(withAttributes: fontAttribute)
            
            // some extraSpace give if like so.
            let extraSpace : CGFloat = 30.0
            let width = size.width + extraSpace
            return CGSize(width:width, height: 24)
        } else if collectionView == tagCollect {
            return CGSize(width: collectionView.frame.width - 20, height: 70)
        } else if collectionView == sportsCollect {
            return CGSize(width: collectionView.frame.width/2 - 10, height: 40)
            
        } else {
            return CGSize(width: collectionView.frame.width - 20, height: 41)
        }
        
    }
    
    
    


    
    

    
    
    override func viewDidDisappear(_ animated: Bool) {
        makePostTextView.resignFirstResponder()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //sportsCollect.isPrefetchingEnabled = false
        doneWithSportsButton.layer.cornerRadius = 12
        doneWithSportsButton.layer.masksToBounds = true
        postPic.layer.shadowColor = UIColor.black.cgColor
        postPic.layer.shadowOpacity = 0.35
        postPic.layer.shadowOffset = CGSize.zero
        postPic.layer.shadowRadius = 10
        postText.layer.shadowColor = UIColor.black.cgColor
        postText.layer.shadowOpacity = 0.35
        postText.layer.shadowOffset = CGSize.zero
        postText.layer.shadowRadius = 10
        postPic.layer.borderColor = UIColor.red.cgColor
        postText.layer.borderColor = UIColor.red.cgColor
        postLine.frame.size = CGSize(width: UIScreen.main.bounds.width,height: 0.5)
        picViewLine1.frame.size = CGSize(width: UIScreen.main.bounds.width,height: 0.5)
        picViewLine2.frame.size = CGSize(width: UIScreen.main.bounds.width,height: 0.5)
        picViewLine3.frame.size = CGSize(width: UIScreen.main.bounds.width,height: 0.5)
        topLineCat.frame = CGRect(x: topLineCat.frame.origin.x, y: topLineCat.frame.origin.y, width: topLineCat.frame.width, height: 0.5)
        //self.makePostTextView.layer.cornerRadius = 10
        
        posterPicIV.frame = CGRect(x: posterPicIV.frame.origin.x, y: posterPicIV.frame.origin.y, width: 28, height: 28)
        self.backToPostButton.layer.cornerRadius = 10
        picker.delegate = self
        tagSearchBar.delegate = self
        addToCategoryButton.layer.cornerRadius = 8
        addToCategoryButton.layer.masksToBounds = true
        shadeView1.layer.cornerRadius = 14
        shadeView2.layer.cornerRadius = 14
        
        postText.layer.borderWidth = 2
        
        postPic.layer.borderWidth = 2
        makePostTextView.delegate = self
        
        self.picPostTextViewPos = makePostTextView.frame
        self.ogCat1Pos = self.addToCatIconButton.frame
        self.ogCat2Pos = self.addToCategoryButton.frame
        self.ogCat3Pos = self.curCatsLabel.frame
        self.posterPicIV.layer.cornerRadius = posterPicIV.frame.width/2
        posterPicIV.layer.masksToBounds = true
        //makePostTextView.layer.borderColor = UIColor.black.cgColor
        //makePostTextView.layer.borderWidth = 1
        whiteShadeView.layer.cornerRadius = 5
        imagePicker.delegate = self
        ogVidPosit = addVidButton.frame
        ogPicPosit = addPicButton.frame
        ogPicVidPosit = picVidButton.frame
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?[2]
        postPic.layer.cornerRadius = 15
        postText.layer.cornerRadius = 15
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
        
       // self.sportsCollect.register(UINib(nibName: "PostCatSearchSportsCell", bundle: nil), forCellWithReuseIdentifier: "PostCatSearchSportsCell")
        tagCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        curCatsCollect.register(UINib(nibName: "CurCatsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CurCatsCollectionViewCell")
        
        tagCollect.delegate = self
        tagCollect.dataSource = self
        sportsCollect.delegate = self
        sportsCollect.dataSource = self
        catLabelsRefined = catLabels
        addCatCollect.delegate = self
        addCatCollect.dataSource = self
        curCatsCollect.delegate = self
        curCatsCollect.dataSource = self
        curCatsCollect.collectionViewLayout = columnLayout
        if #available(iOS 11.0, *) {
            curCatsCollect.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
        }
        var tap = UITapGestureRecognizer(target: self, action : #selector(handleTap(sender:)))
        tap.numberOfTapsRequired = 1
        curCatsCollect.addGestureRecognizer(tap)
        //locationManager delegate assignment etcc...
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
       
        //DispatchQueue.main.async{
            print("loc: \(self.locationManager.location)")
          //  self.startLocationManager()
       // }
        
        // here you can call the start location function
        
        
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
                        var messImgUrl: String?
                        if (snap.value as! String) == "profile-placeholder"{
                            self.posterPicIV.image = UIImage(named: "profile-placeholder")
                            self.curUser.profPic = "profile-placeholder"
                            
                        } else {
                        
                            if let messageImageUrl = URL(string: snap.value as! String) {
                                
                                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                    self.posterPicIV.image = UIImage(data: imageData as Data) } }
                            
                            
                        self.curUser.profPic = snap.value as! String
                        }
                    } else if snap.key == "username"{
                        self.curUser.username = snap.value as! String
                    }
                }
            }
            SwiftOverlays.removeAllBlockingOverlays()
        })
        
        

        // Do any additional setup after loading the view.
    }
    let columnLayout = CustomViewFlowLayout()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func estimateFrameForText(text: String, type: String) -> CGRect {
        //we make the height arbitrarily large so we don't undershoot height in calculation
        let height: CGFloat = 1000
        
        let size = CGSize(width: makePostTextView.frame.width, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)]
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        
    }
    @objc func handleTap(sender: AnyObject) {
        addCatView.isHidden = false
        postButton.isHidden = true
        
        //cancelPostButton.setTitle("Back", for: .normal)
        cancelPostButton.isHidden = true
        curCatsLabel.text = ""
        curCatsAdded.removeAll()
        
        
        
        
    }
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items![0]{
            performSegue(withIdentifier: "PostToFeed", sender: self)
        } else if item == tabBar.items![1]{
            performSegue(withIdentifier: "PostToSearch", sender: self)
        } else if item == tabBar.items![2]{
            //performSegue(withIdentifier: "", sender: self)
        } else if item == tabBar.items![3]{
            performSegue(withIdentifier: "PostToNotifications", sender: self)
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
                print("pastDismissPhoto0")
                self.makePostView.isHidden = false
                self.cancelPostButton.isHidden = false
                self.postPlayer?.url = movieURL as URL
                
            }
        }
        
    }
    
    
    
    
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    var postPlayer: Player?
    
    
    
    var postType: String?
    var curUser = User()
    
    
    
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostToFeed"{
            if let vc = segue.destination as? HomeFeedViewController{
                vc.prevScreen = "post"
            }
            
        }
        if segue.identifier == "PostToProfile"{
            if let vc = segue.destination as? ProfileViewController{
                vc.prevScreen = "post"
            }
        }
        if segue.identifier == "PostToSearch"{
            if let vc = segue.destination as? SearchViewController{
                vc.prevScreen = "post"
            }
        }
        if segue.identifier == "PostToNotifications"{
            if let vc = segue.destination as? NotificationsViewController{
                vc.prevScreen = "post"
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    //keyboardNotifications
    @objc func keyboardWillHide(notification: NSNotification) {
        if postType == "text"{
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            //print("keyHeight: \(keyboardHeight)")
           //makePostView.frame = CGRect(x: makePostView.frame.origin.x, y: makePostView.frame.origin.y - 150, width: makePostView.frame.width, height: makePostView.frame.height)
            /*postButton.frame = CGRect(x: postButton.frame.origin.x, y: postButton.frame.origin.y - 50, width: postButton.frame.width, height: postButton.frame.height)
            
            //backFromLikedByViewButton.isHidden = false
            //self.likeTopLabel.isHidden = true
            
            addLocationIcon.frame = CGRect(x: addLocationIcon.frame.origin.x, y: addLocationIcon.frame.origin.y - 50, width: addLocationIcon.frame.width, height: addLocationIcon.frame.height)
            
           cancelPostButton.frame = CGRect(x: cancelPostButton.frame.origin.x, y: cancelPostButton.frame.origin.y - 50, width: cancelPostButton.frame.width, height: cancelPostButton.frame.height)
            
            
            
            posterPicIV.frame = CGRect(x: posterPicIV.frame.origin.x, y: posterPicIV.frame.origin.y - 50, width: posterPicIV.frame.width, height: posterPicIV.frame.height)
            
            makePostTextView.frame = CGRect(x: makePostTextView.frame.origin.x, y: makePostTextView.frame.origin.y - 50, width: makePostTextView.frame.width, height: makePostTextView.frame.height)
            
            //print("hiding keyb")*/
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if postType == "text"{
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            //makePostView.frame = CGRect(x: makePostView.frame.origin.x, y: makePostView.frame.origin.y + 150, width: makePostView.frame.width, height: makePostView.frame.height)
            //print("keyHeight: \(keyboardHeight)")
            //print("keyboardHeight")
           /* postButton.frame = CGRect(x: postButton.frame.origin.x, y: postButton.frame.origin.y + 50, width: postButton.frame.width, height: postButton.frame.height)
            
            //backFromLikedByViewButton.isHidden = false
            //self.likeTopLabel.isHidden = true
            
            addLocationIcon.frame = CGRect(x: addLocationIcon.frame.origin.x, y: addLocationIcon.frame.origin.y + 50, width: addLocationIcon.frame.width, height: addLocationIcon.frame.height)
            
            cancelPostButton.frame = CGRect(x: cancelPostButton.frame.origin.x, y: cancelPostButton.frame.origin.y + 50, width: cancelPostButton.frame.width, height: cancelPostButton.frame.height)
            
            
            posterPicIV.frame = CGRect(x: posterPicIV.frame.origin.x, y: posterPicIV.frame.origin.y + 50, width: posterPicIV.frame.width, height: posterPicIV.frame.height)
            
            makePostTextView.frame = CGRect(x: makePostTextView.frame.origin.x, y: makePostTextView.frame.origin.y + 50, width: makePostTextView.frame.width, height: makePostTextView.frame.height)
            //print("showing keyb")*/
            }
        }
    }
    
    //TextViewDelegate
    //@available(iOS 2.0, *)
    
    public func textViewDidBeginEditing(_ textView: UITextView){
        print("tvEdit")
        if postType == "text"{
        DispatchQueue.main.async{
            self.makePostTextView.selectAll(nil)
        }
        }
       
        if textView.text == "Write a caption..." || self.makePostTextView.text == "What's going on?"{
            textView.text = ""
        }
            textView.textColor = UIColor.black
    }
    
    //@available(iOS 2.0, *)
    public func textViewDidEndEditing(_ textView: UITextView){
        if textView.text == "" {
            if makePostTextView.frame == textPostTextViewPos.frame {
                makePostTextView.text = "What's going on?"
            } else {
                makePostTextView.text = "Write a caption..."
            }
        }
        textView.textColor = UIColor.darkGray
        textView.resolveHashTags()
        
    }
    
    public func checkForTags(possibleUserDisplayNames:[String]? = nil, postID: String) {
        print("in check for tags")
        let schemeMap = [
            "#":"hash",
            "@":"mention"
        ]
        
        // Separate the string into individual words.
        // Whitespace is used as the word boundary.
        // You might see word boundaries at special characters, like before a period.
        // But we need to be careful to retain the # or @ characters.
        let words = makePostTextView.text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        let attributedString = makePostTextView.attributedText.mutableCopy() as! NSMutableAttributedString
        
        // keep track of where we are as we interate through the string.
        // otherwise, a string like "#test #test" will only highlight the first one.
        var bookmark = makePostTextView.text.startIndex
        
        // Iterate over each word.
        // So far each word will look like:
        // - I
        // - visited
        // - #123abc.go!
        // The last word is a hashtag of #123abc
        // Use the following hashtag rules:
        // - Include the hashtag # in the URL
        // - Only include alphanumeric characters.  Special chars and anything after are chopped off.
        // - Hashtags can start with numbers.  But the whole thing can't be a number (#123abc is ok, #123 is not)
        for word in words {
            
            var scheme:String? = nil
            
            if word.hasPrefix("#") {
                print("thisWordHashtag: \(word)")
                //myDelegate?.performHashtagDatabaseAction(hashtag: word, postID: self.myPostID!)
                
                scheme = schemeMap["#"]
               var wordWithTagRemoved = String(word.characters.dropFirst())
                
                Database.database().reference().child("hashtags").observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapshots = snapshot.value as! [String:Any]
                    var keyFound = false
                    for snap in snapshots{
                        if snap.key == wordWithTagRemoved{
                            keyFound = true
                            var tempData = snap.value as! [String]
                            tempData.append(postID)
                            Database.database().reference().child("hashtags").updateChildValues([wordWithTagRemoved:tempData])
                            break
                        }
                    }
                    if keyFound == false{
                        Database.database().reference().child("hashtags").updateChildValues([wordWithTagRemoved:[postID]])
                    }
                
                })
            } else if word.hasPrefix("@") {
                scheme = schemeMap["@"]
            }
            
        }
        self.makePostTextView.text = "Write a caption..."
    }
    
    
    //locationManagerDelegate
    
    var location: CLLocation?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?

    var city: String?
    var cityData: String?
    var locDict = [String:Any]()
    let locationManager = CLLocationManager()
    
    func startLocationManager() {
        print("startLocMan")
        // always good habit to check if locationServicesEnabled
        if CLLocationManager.locationServicesEnabled() {
            print("startLocManIF")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            print(locationManager.location)
        }
    }
    
    func stopLocationManager() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // if you need to get latest data you can get locations.last to check it if the device has been moved
       // print("inDidUpdateLoc")
        let latestLocation = locations.last!
        
        // here check if no need to continue just return still in the same place
        if latestLocation.horizontalAccuracy < 0 {
            return
        }
        // if it location is nil or it has been moved
        if location == nil || location!.horizontalAccuracy > latestLocation.horizontalAccuracy {
            
            location = latestLocation
            // stop location manager
            //stopLocationManager()
            
            // Here is the place you want to start reverseGeocoding
            geocoder.reverseGeocodeLocation(latestLocation, completionHandler: { (placemarks, error) in
                // always good to check if no error
                // also we have to unwrap the placemark because it's optional
                // I have done all in a single if but you check them separately
                if error == nil, let placemark = placemarks, !placemark.isEmpty {
                    var curPlacemark = placemark.last
                    if let city = curPlacemark?.locality, !city.isEmpty {
                        // here you have the city name
                        // assign city name to our iVar
                        self.city = city
                        print("self.city: \(city)")
                        
                    }
                }
                // a new function where you start to parse placemarks to get the information you need
                //self.parsePlacemarks()
                
            })
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // print the error to see what went wrong
        print("didFailwithError\(error)")
        // stop location manager if failed
        stopLocationManager()
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        // Use the last reported location.
        print("lookupLoc")
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                                            completionHandler: { (placemarks, error) in
                                                if error == nil {
                                                    let firstLocation = placemarks?[0]
                                                    completionHandler(firstLocation)
                                                }
                                                else {
                                                    // An error occurred during geocoding.
                                                    completionHandler(nil)
                                                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
    
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
        self.tagSearchBar.endEditing(true)
    }
    var findFriendsData = [[String:Any]]()
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
                
                let uRange = (uName.lowercased() as NSString).range(of: searchText.lowercased(), options: NSString.CompareOptions.literal)
                let rRange = (rName.lowercased() as NSString).range(of: searchText.lowercased(), options: NSString.CompareOptions.literal)
                print("rANDu: \(uRange) \(rRange)")
                if uRange.location != NSNotFound {
                    tempUserDict[key] = ["uName":uName, "rName":rName, "pic": pic!, "uid": uid, "picString": picString]
                    self.allSuggested.append(rName)
                    print("curTextu: \(searchText) allSuggested1: \(self.allSuggested),\(uName)")
                } else if rRange.location != NSNotFound{
                    
                    tempUserDict[key] = ["uName":uName, "rName":rName, "pic": pic!,"picString":picString, "uid": uid]
                    
                    
                    self.allSuggested.append(rName)
                    print("curText: \(searchText) allSuggested: \(self.allSuggested)")
                } else if self.allSuggested.contains(rName){
                    /*self.allSuggested.contains(key){
                     if*/
                    tempUserDict.removeValue(forKey: key)
                    self.allSuggested.remove(at: self.allSuggested.index(of: rName)!)
                    //self.findFriendsData.remove(at: fin)
                    //}
                    
                }
                
            }
            print("nowHereee")
            var tempCurUids = [String]()
            for dict in self.findFriendsData{
                tempCurUids.append(dict["uid"] as! String)
                
            }
            for (key, val) in tempUserDict {
                print("snapKey: \(key)")
                if self.allSuggested.contains((val as! [String:Any])["rName"] as! String){
                    
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
                self.tagCollect.reloadData()
            }
            
        })
        
    } // called when text changes (including clear)
    
    @IBOutlet weak var tagCollect: UICollectionView!
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.searchActive = false
        print("in search pressed")
    } // called when keyboard
    
    

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

extension PostViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        
        curCityLabel.text = place.name
        addLocationButton.setTitle(place.name, for: .normal)
        //jobPost.location = place.formattedAddress
        self.place = place
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
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
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}


