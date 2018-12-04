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


class PostCatSearchSportsCell: UICollectionViewCell {
    @IBOutlet weak var catSportLabel: UILabel!
    
    
}
class PostCatSearchCell: UICollectionViewCell {
    @IBOutlet weak var catLabel: UILabel!
    
    @IBOutlet weak var catCheck: UIImageView!
}

class PostViewController: UIViewController, UITabBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate, CLLocationManagerDelegate, UICollectionViewDelegate,
UICollectionViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tagSearchBar: UISearchBar!
    @IBOutlet weak var addCat3TextPos: UIView!
    @IBOutlet weak var addCat2TextPos: UIView!
    @IBOutlet weak var addCat1TextPos: UIView!
    @IBOutlet weak var whiteShadeView: UIView!
    @IBOutlet weak var curCatsLabel: UILabel!
    
    @IBOutlet weak var shadeView2: UIView!
    @IBOutlet weak var shadeView1: UIView!
    var catLabels = ["Arms","Chest","Abs","Legs","Back", "Shoulders","Cardio","Sports","Nutrition","Stretching","Crossfit","Body Building","Speed and Agility"]
    //var catLabels = ["Abs","Arms","Back","Chest","Legs","Shoulders"]
    var placeAddress = String()
    var place: GMSPlace?
    var catLabelsRefined = [String]()
    
    
    @IBOutlet weak var sportsCollect: UICollectionView!
    @IBOutlet weak var sportsView: UIView!
    var catSportsData = ["Soccer","Football","Lacrosse", "Track & Field", "Tennis","Baseball","Swimming"]
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         if collectionView == sportsCollect{
            return catSportsData.count
         } else if collectionView == addCatCollect {
        return catLabelsRefined.count
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
            cell.catSportLabel.text = catSportsData[indexPath.row]
            
            return cell
        } else {
        let cell : PostCatSearchCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCatSearchCell", for: indexPath) as! PostCatSearchCell
        cell.catLabel.text = catLabelsRefined[indexPath.row]
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width: cell.frame.size.width, height: cell.frame.size.height)
        
        border.borderWidth = width
        cell.layer.addSublayer(border)
        cell.layer.masksToBounds = true
            return cell
        }
        
    }
    
    @IBAction func doneWithSportsButtonPressed(_ sender: Any) {
        for row in 0...self.sportsCollect.numberOfItems(inSection: 0) - 1
        {
            let indexPath = IndexPath(row: row, section: 0)
            
            print("indexPatht:\(indexPath)")
            
            if ((sportsCollect.cellForItem(at: indexPath) as! PostCatSearchSportsCell).catSportLabel.textColor == UIColor.red) {
                
                curCatsAdded.append((sportsCollect.cellForItem(at: indexPath as IndexPath) as! PostCatSearchSportsCell).catSportLabel.text!)
                
            }
        }
        print("curCatsAdded: \(curCatsAdded)")
        sportsView.isHidden = true
    }
    
    @IBOutlet weak var tagPeopleLabel: UILabel!
    
    var selectedSports = [String]()
    var taggedFriends = [[String:Any]]()
    @IBOutlet weak var doneWithSportsButton: UIButton!
    
    
    
    @IBOutlet weak var tagView: UIView!
    
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
                //cell.backgroundColor = UIColor.lightGray
                taggedFriends.append(findFriendsData[indexPath.row] as! [String:Any])
            } else {
               // cell.backgroundColor = UIColor.white
                
                
                taggedFriends.remove(at: count)
            }
                
                
    
                
            print("taggedFriends: \(taggedFriends)")
            taggedString = ""
            for dict in taggedFriends{
                taggedString = taggedString + " " + (dict["realName"] as! String) + ","
            }
            print("taggedString: \(taggedString)")
            tagPeopleLabel.text = taggedString
            tagView.isHidden = true
            tagSearchBar.text = ""
            tagSearchBar.endEditing(true)
            tagSearchBar.resignFirstResponder()
            findFriendsData.removeAll()
            DispatchQueue.main.async{
            self.tagCollect.reloadData()
            }
            
            
            
        } else if collectionView == sportsCollect{
            var sportCellSelected = collectionView.cellForItem(at: indexPath) as! PostCatSearchSportsCell
            if sportCellSelected.catSportLabel.textColor == UIColor.red {
                sportCellSelected.catSportLabel.textColor = UIColor.black
            } else {
                sportCellSelected.catSportLabel.textColor = UIColor.red
            }
         } else {
        var cellSelected = collectionView.cellForItem(at: indexPath) as! PostCatSearchCell
            print("wtf: \(cellSelected.catLabel.text!)")
        if (cellSelected.catLabel.text as! String) == "Sports"{
            sportsView.isHidden = false
        }
        if cellSelected.catLabel.textColor == UIColor.red {
            cellSelected.catLabel.textColor = UIColor.black
            
            selectedCellsArr.remove(at: selectedCellsArr.firstIndex(of: cellSelected)!)
            
            
        } else {
            cellSelected.catLabel.textColor = UIColor.red
            selectedCellsArr.append(cellSelected)
        }
            
        }
        
    }
    var selectedCellsArr = [PostCatSearchCell]()
    
    @IBOutlet weak var picViewLine1: UIView!
    @IBOutlet weak var picViewLine2: UIView!
    @IBOutlet weak var picViewLine3: UIView!
    
    
    @IBOutlet weak var addCatView: UIView!
    
    @IBOutlet weak var addCatCollect: UICollectionView!
    var picPostTextViewPos: CGRect?
    
    @IBOutlet weak var textPostTextViewPos: UIView!
    @IBOutlet weak var posterPicTextPos: UIView!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var postText: UIView!
    @IBOutlet weak var postPic: UIView!
    
    @IBOutlet weak var picVidButton: UIButton!
    @IBOutlet weak var picVidSmallFrame: UIView!
    @IBOutlet weak var addPicButton: UIButton!
    @IBAction func addPicTouched(_ sender: AnyObject) {
        currentPicker = "photo"
        /*imagePicker.allowsEditing = true
        //imagePicker.mediaTypes = ["kUTTypeImage"] //[.kUTTypeImage as String]
        self.postType = "pic"
        present(imagePicker, animated: true, completion: nil)*/
        let picker = YPImagePicker()
        self.postType = "pic"
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta) // Print exif meta data of original image.
                self.makePostView.isHidden = false
                self.cancelPostButton.isHidden = false
                self.makePostImageView.image = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var catTopLabel: UILabel!
    
    
    var extended = false
    @IBOutlet weak var picButtonPositionOut: UIView!
    @IBAction func picVidPressed(_ sender: Any) {
        startLocationManager()
        postLine.isHidden = true
        picViewLine1.isHidden = false
        picViewLine2.isHidden = false
        picViewLine3.isHidden = false
        catTopLabel.isHidden = true
        
                var config = YPImagePickerConfiguration()
                config.screens = [.library, .video]
                config.library.mediaType = .photoAndVideo
        
                
                let picker = YPImagePicker(configuration: config)
                picker.didFinishPicking { [unowned picker] items, _ in
                    
                    if let firstItem = items.first {
                        switch firstItem {
                        case .photo(let photo):
                            if let photo = items.singlePhoto {
                                print(photo.fromCamera) // Image source (camera or library)
                                print(photo.image) // Final image selected by the user
                                print(photo.originalImage) // original image selected by the user, unfiltered
                                print(photo.modifiedImage) // Transformed image, can be nil
                                print(photo.exifMeta) // Print exif meta data of original image.
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
        /*UIView.animate(withDuration: 0.5, animations: {
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
            
            
        })*/
    }
    var ogVidPosit = CGRect()
    var ogPicPosit = CGRect()
    var ogPicVidPosit = CGRect()
    var currentPicker = String()
    let picker = UIImagePickerController()
    let imagePicker = UIImagePickerController()
    var curCatsAdded = [String]()
    var taggedString = String()
    @IBAction func backFromTag(_ sender: Any) {
        
        
    }


    @IBAction func backFromTheCat(_ sender: Any) {
        
        
    }

    var curString = ""
    @IBAction func backToPostPressed(_ sender: Any) {
       // DispatchQueue.main.async{
        for cell in selectedCellsArr {
           
 
            
            
            
            
            
            if cell.catLabel.textColor == UIColor.red && cell.catLabel.text != "Sports" {
                self.curCatsAdded.append(cell.catLabel.text!)
                
            }
            
           
            
            }
      //  }
        
        for str in curCatsAdded {
            curString = curString + " " + str + ","
        }
       
       
        
        curString.removeLast()
        curCatsLabel.text = curString
        addCatView.isHidden = true
        var catLabelsSorted = catLabels.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        
        catLabelsRefined = catLabelsSorted
        addCatCollect.reloadData()
        
        postButton.isHidden = false
        cancelPostButton.isHidden = false
        makePostTextView.resignFirstResponder()
        
        
    }
    @IBOutlet weak var backToPostButton: UIButton!
    @IBOutlet weak var tagPeopleButton: UIButton!
    @IBOutlet weak var tagPeopleButtonIcon: UIButton!
    @IBAction func tagPeopleButtonPressed(_ sender: Any) {
        tagView.isHidden = false
        
    }
    @IBOutlet weak var addToCatIconButton: UIButton!
    @IBOutlet weak var addToCategoryButton: UIButton!
    @IBAction func addToCategoryButtonPressed(_ sender: Any) {
        addCatView.isHidden = false
        postButton.isHidden = true
        addCatCollect.delegate = self
        addCatCollect.dataSource = self
        //cancelPostButton.setTitle("Back", for: .normal)
        cancelPostButton.isHidden = true
        curCatsLabel.text = ""
        curCatsAdded.removeAll()
        
        
        
        
        
    }
    @IBOutlet weak var shareIconButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBAction func shareButtonPressed(_ sender: Any) {
    }
    @IBAction func textPostPressed(_ sender: Any) {
        postLine.isHidden = true
        picViewLine1.isHidden = true
        picViewLine2.isHidden = true
        picViewLine3.isHidden = true
        
        startLocationManager()
        self.postType = "text"
        //makePostTextView.layer.borderColor = UIColor.clear.cgColor
        addToCategoryButton.isHidden = true
        makePostTextView.delegate = self
        makePostTextView.becomeFirstResponder()
        makePostTextView.selectAll(nil)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.tagPeopleButton.isHidden = true
            self.tagPeopleButtonIcon.isHidden = true
            self.shareButton.isHidden = true
            self.shareIconButton.isHidden = true
            self.addToCatIconButton.isHidden = true
            self.addToCategoryButton.isHidden = true
            self.curCatsLabel.isHidden = true
            self.addToCategoryButton.isHidden = true
            self.addToCatIconButton.isHidden = true
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
            
            
        })
       
    }
    override func viewDidDisappear(_ animated: Bool) {
        makePostTextView.resignFirstResponder()
    }
    @IBOutlet weak var addVidButton: UIButton!
    
    @IBOutlet weak var posterPicIV: UIImageView!
    
    @IBOutlet weak var postLine: UIView!
    
    @IBOutlet weak var vidButtonPositionOut: UIView!
    @IBAction func chooseVidFromPhoneSelected(_ sender: AnyObject) {
       /* currentPicker = "vid"
        picker.mediaTypes = ["public.movie"]
        self.postType = "vid"
        
        present(picker, animated: true, completion: nil)
       // makePostView.isHidden = false*/
        // Here we configure the picker to only show videos, no photos.
        self.postType = "vid"
        
       // makePostTextView.layer.borderColor = UIColor.lightGray.cgColor
        addToCategoryButton.isHidden = false
        
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
    
    
    var ogCat1Pos = CGRect()
    var ogCat2Pos = CGRect()
    var ogCat3Pos = CGRect()
    var newPost: [String:Any]?
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.makePostTextView.layer.cornerRadius = 10
        posterPicIV.frame = CGRect(x: posterPicIV.frame.origin.x, y: posterPicIV.frame.origin.y, width: 28, height: 28)
        self.backToPostButton.layer.cornerRadius = 10
        picker.delegate = self
        tagSearchBar.delegate = self
        addToCategoryButton.layer.cornerRadius = 8
        addToCategoryButton.layer.masksToBounds = true
        shadeView1.layer.cornerRadius = 14
        shadeView2.layer.cornerRadius = 14
        postPic.layer.borderColor = UIColor.lightGray.cgColor
        postText.layer.borderWidth = 2
        postText.layer.borderColor = UIColor.lightGray.cgColor
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
        
       // self.sportsCollect.register(UINib(nibName: "PostCatSearchSportsCell", bundle: nil), forCellWithReuseIdentifier: "PostCatSearchSportsCell")
        tagCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        tagCollect.delegate = self
        tagCollect.dataSource = self
        sportsCollect.delegate = self
        sportsCollect.dataSource = self
        catLabelsRefined = catLabels
        
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
    
    @IBOutlet weak var addLocationButton: UIButton!
    @IBAction func addLocationPressed(_ sender: Any) {
        //print(self.city)
       //self.cityData = self.city
        //self.curCityLabel.text = self.city
        //locationManager.requestLocation()
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    @IBOutlet weak var textPostPressedLine: UIView!
    @IBOutlet weak var textPostPressedLabel: UILabel!
    
    @IBOutlet weak var curCityLabel: UILabel!
    @IBAction func cancelPostButtonPressed(_ sender: Any) {
        
        makePostImageView.image = nil
        postPlayer?.url = nil
        
        postText.isHidden = false
        postPic.isHidden = false
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
        makePostView.backgroundColor = UIColor.white
        makePostTextView.text = "Write a caption..."
        self.addToCatIconButton.isHidden = false
        self.addToCategoryButton.isHidden = false
        self.curCatsLabel.text = ""
        self.curCatsLabel.isHidden = false
        makePostTextView.frame = picPostTextViewPos!
        addToCatIconButton.frame = ogCat1Pos
        addToCategoryButton.frame = ogCat2Pos
        curCatsLabel.frame = ogCat3Pos
        makePostTextView.textColor = UIColor.darkGray
        self.tagPeopleButton.isHidden = false
        self.tagPeopleButtonIcon.isHidden = false
        self.shareButton.isHidden = false
        self.shareIconButton.isHidden = false
       
        self.cityData = nil
        self.curCityLabel.text = ""
        
            
        
        
        self.extended = false
        makePostView.isHidden = true
        
    }
    @IBOutlet weak var succesfulPostView: UIView!
    @IBOutlet weak var cancelPostButton: UIButton!
    var postType: String?
    var curUser = User()
    @IBAction func postButtonPressed(_ sender: Any) {
    
        
        SwiftOverlays.showBlockingWaitOverlayWithText("Posting to Feed...")
        //makePostView.backgroundColor = UIColor.black
        postText.isHidden = false
        postPic.isHidden = false
        
        
        newPost = [String: Any]()
        if postType == "pic"{
            //newPost!["postPic"] = self.makePostImageView.image!
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
            if self.curCatsAdded == nil || self.curCatsAdded.count == 0{
                curCatsAdded.append("Other")
            }
            self.newPost!["categories"] = self.curCatsAdded
            self.newPost!["city"] = self.curCityLabel.text
          
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
                        self.makePostTextView.text = "Write a caption..."
                        self.makePostTextView.textColor = UIColor.darkGray
                        print("This never prints in the console")
                        self.postPlayer?.url = nil
                        self.makePostImageView.image = nil
                        self.makePostView.isHidden = true
                        self.cancelPostButton.isHidden = true
                        
                        self.addToCatIconButton.isHidden = false
                        self.addToCategoryButton.isHidden = false
                    
                        self.curCatsLabel.text = ""
                        self.curCatsLabel.isHidden = false
                        self.makePostTextView.frame = self.picPostTextViewPos!
                        self.addToCatIconButton.frame = self.ogCat1Pos
                        self.addToCategoryButton.frame = self.ogCat2Pos
                        self.curCatsLabel.frame = self.ogCat3Pos
                        self.tagPeopleButton.isHidden = false
                        self.tagPeopleButtonIcon.isHidden = false
                        self.shareButton.isHidden = false
                        self.shareIconButton.isHidden = false
                        SwiftOverlays.removeAllBlockingOverlays()
                         self.performSegue(withIdentifier: "PostToFeed", sender: self)
                       // }
                       

                
            
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
                        self.makePostTextView.text = "Write a caption..."
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
                
                self.makePostTextView.text = "Write a caption..."
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
    
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var makePostView: UIView!
    
    @IBOutlet weak var makePostImageView: UIImageView!
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
    
    @IBOutlet weak var makePostTextView: UITextView!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
                
                let uRange = (uName as NSString).range(of: searchText, options: NSString.CompareOptions.literal)
                let rRange = (rName as NSString).range(of: searchText, options: NSString.CompareOptions.literal)
                print("rANDu: \(uRange) \(rRange)")
                if uRange.location != NSNotFound {
                    tempUserDict[key] = ["uName":uName, "rName":rName, "pic": pic!, "uid": uid, "picString": picString]
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

