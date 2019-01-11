//
//  SpecificSearchViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 11/26/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SpecificSearchViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UISearchBarDelegate {
var myUName = String()
    var following = [String]()
    var myPicString = String()
    var myRealName = String()
    
    @IBAction func swipeBack(_ sender: Any) {
        performSegue(withIdentifier: "specificToGeneralSearch", sender: self)
    }
    @objc func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.value as? [String:Any]{
                for snap in snapshots{
                    if snap.key == "username"{
                        self.myUName = snap.value as! String
                    } else if snap.key == "following"{
                        self.following = snap.value as! [String]
                    } else if snap.key == "profPic"{
                        self.myPicString = snap.value as! String
                        if let messageImageUrl = URL(string: snap.value as! String) {
                            
                            // self.myPicString = messageImageUrl
                            
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                //self.myPic = UIImage(data: imageData as Data)
                                //self.selfCommentPic.image = UIImage(data: imageData as Data)
                                
                            }
                            
                            // }
                        }
                    } else if snap.key == "realName"{
                        self.myRealName = snap.value as! String
                    }
                    
                    
                }
                DispatchQueue.main.async{
                    print("self: \(self.myRealName), \(self.myUName)")
                    //self.loadFeedData()
                }
            }
            
            //self.loadFeedData()
            
            
            
        })
        
        
        
        
        searchCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        searchCollect.delegate = self
        searchCollect.dataSource = self
        searchBar.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addFriendsButtonPressed(_ sender: Any) {
        
        
    }
    
     @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "specificToGeneralSearch", sender: self)
        
    }
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchSegment: UISegmentedControl!
    
    @IBOutlet weak var searchCollect: UICollectionView!
    
    @IBOutlet weak var addFriendsButton: UIButton!
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = CGFloat()
        var height = CGFloat()
        
            return CGSize(width: collectionView.frame.width - 20, height: 70)
    }
     public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
    
        if collectionView == searchCollect {
    
            if searchSegment.selectedSegmentIndex == 0 {
            performSegueToPosterProfile(uid: (findFriendsData[indexPath.row])["uid"] as! String, name: (findFriendsData[indexPath.row])["uName"] as! String)
            } else {
                self.selectedData = findFriendsData[indexPath.row] as! [String:Any]
                performSegue(withIdentifier: "AdvancedSearchToSinglePost", sender: self)
            }
            //perform segue to the persons profile
    
            print("hellomate")
        }
    }
    
    var findFriendsData = [[String:Any]]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
            return findFriendsData.count
        
    }
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
        
        DispatchQueue.main.async{
            if self.searchSegment.selectedSegmentIndex != 0 {
                cell.likedByFollowButton.isHidden = true
            } else {
                
                cell.likedByFollowButton.isHidden = false
            }
            
            
            cell.likedByImage.frame = CGRect(x:cell.likedByImage.frame.origin.x, y: cell.likedByImage.frame.origin.y, width: 63.0, height: 63.0)
            cell.contentView.layer.cornerRadius = 2.0
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.masksToBounds = true
            
            //cell.layer.shadowColor = UIColor.gray.cgColor
            //cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            //cell.layer.shadowRadius = 2.0;
            //cell.layer.shadowOpacity = 1.0;
            //cell.layer.masksToBounds = false
            //cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
            
            if ((self.following.contains(((self.findFriendsData[indexPath.row])["uid"] as! String)))){
                cell.likedByFollowButton.setTitle("Unfollow", for: .normal)
            }
            cell.likedByName.isHidden = false
            cell.likedByUName.isHidden = false
            
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
        return cell

    }
    
    var selectedCurAuthProfile = true
    var selectedCellUID = String()
    var curName = String()
    func performSegueToPosterProfile(uid: String, name: String){
        self.curName = name
        self.selectedCellUID = uid
        if uid == Auth.auth().currentUser!.uid {
            selectedCurAuthProfile = true
        } else {
            selectedCurAuthProfile = false
        }
        performSegue(withIdentifier: "advanceSearchToProfile", sender: self)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    var selectedData = [String:Any]()
    var prevScreen = String()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "advanceSearchToProfile"{
            if let vc = segue.destination as? ProfileViewController{
                vc.curUID = self.selectedCellUID
                if selectedCurAuthProfile == true{
                    vc.viewerIsCurAuth = true
                    
                } else {
                    vc.viewerIsCurAuth = false
                }
                vc.curName = self.curName
                vc.prevScreen = "search"
                
            }
        }
        if segue.identifier == "AdvancedSearchToSinglePost"{
            if let vc = segue.destination as? SinglePostViewController{
                selectedData["postID"] = selectedData["uid"] as! String
                vc.thisPostData = self.selectedData
                vc.myUName = self.myUName
                vc.following = self.following
                vc.myPicString = self.myPicString
                vc.prevScreen = "advancedSearch"
            }
        }
    }
    
    
    
    
    //searchBarDelegate
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //findFriendsSearchBar.showsCancelButton = false
        searchActive = true;
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.searchBar.endEditing(true)
    }
    var searchActive = Bool()
    var allSuggested = [String]()
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        print("SB text did change: \(searchText)")
        
        
        var tempUserDict = [String:Any]()
        if searchSegment.selectedSegmentIndex == 0 {
            
            Database.database().reference().child("users").observeSingleEvent(of: .value, with: {(snapshot) in
                
                self.findFriendsData.removeAll()
                self.allSuggested.removeAll()
            //print("here: \(snapshot.value)")
            //let snapshotss = snapshot.value as? [DataSnapshot]
            print("hereNow")
            for (key, val) in (snapshot.value as! [String:Any]){
                //print("uName=\(((val as! [String:Any])["username"] as! String))")
                let uName = ((val as! [String:Any])["username"] as! String)
                let rName = ((val as! [String:Any])["realName"] as! String)
                let picString = ((val as! [String:Any])["profPic"] as! String)
                let uid = key
                var pic: UIImage?
                if picString == "profile-placeholder"{
                    pic = UIImage(named: "profile-placeholder")
                } else {
                    if let messageImageUrl = URL(string: picString) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            pic = UIImage(data: imageData as Data)
                        }
                    }
                    
                }
                let uRange = (uName as NSString).range(of: searchText, options: NSString.CompareOptions.literal)
                let rRange = (rName as NSString).range(of: searchText, options: NSString.CompareOptions.literal)
                //print("rANDu: \(uRange) \(rRange)")
                if uRange.location != NSNotFound {
                    tempUserDict[key] = ["uName":uName, "rName":rName, "pic": pic!, "uid": uid]
                    self.allSuggested.append(rName)
                   // print("curTextu: \(searchText) allSuggested1: \(self.allSuggested)")
                } else if rRange.location != NSNotFound{
                    tempUserDict[key] = ["uName":uName, "rName":rName, "pic": pic!,"picString":picString, "uid": uid]
                    self.allSuggested.append(key)
                    //print("curText: \(searchText) allSuggested: \(self.allSuggested)")
                } else if self.allSuggested.contains(key){
                    if self.allSuggested.contains(rName){
                        tempUserDict.removeValue(forKey: key)
                        self.allSuggested.remove(at: self.allSuggested.index(of: key)!)
                    }
                }
            }
                var tempCurUids = [String]()
                for dict in self.findFriendsData{
                    tempCurUids.append(dict["uid"] as! String)
                    
                }
                for (key, val) in tempUserDict {
                    // print("snapKey: \(key)")
                    if self.allSuggested.contains(key){
                        
                        var tempDict = [String:Any]()
                        tempDict = val as! [String:Any]
                        // print("snapVal: \(val as! [String:Any])")
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
                    print("hey: \(self.findFriendsData)")
                    self.searchCollect.reloadData()
                }
                
            })
        } else if searchSegment.selectedSegmentIndex == 1 {
            
            //search for places
               var picString: String?
            Database.database().reference().child("posts").observeSingleEvent(of: .value, with: {(snapshot) in
                
                self.findFriendsData.removeAll()
                self.allSuggested.removeAll()
                //print("here: \(snapshot.value)")
                print("hereNow")
                for (key, val) in (snapshot.value as! [String:Any]){
                //print("uName=\(((val as! [String:Any])["username"] as! String))")
                let location = ((val as! [String:Any])["city"] as! String)
                
                var profPicString: String?
                var posterName = ((val as! [String:Any])["posterName"] as! String)
                
                if ((val as! [String:Any])["postPic"] as? String) != nil {
                    picString = ((val as! [String:Any])["postPic"] as! String)
               
                    profPicString = ((val as! [String:Any])["posterPicURL"] as! String)
                
                } else if ((val as! [String:Any])["postVid"] as? String) != nil {
                    profPicString = ((val as! [String:Any])["posterPicURL"] as! String)
                
                } else {
                    profPicString = ((val as! [String:Any])["posterPicURL"] as! String)
                
                }
                let postID = key
                let uid = ((val as! [String:Any])["posterUID"] as! String)
                var pic: UIImage?
                if picString != nil {
                    
                } else {
                    picString = profPicString
                    }
                if picString == "profile-placeholder"{
                    pic = UIImage(named: "profile-placeholder")
                } else {
                    if let messageImageUrl = URL(string: picString!) {
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                pic = UIImage(data: imageData as Data)
                        }
                    }
                    
                }
                let uRange = (location as NSString).range(of: searchText, options: NSString.CompareOptions.literal)
               // print("rANDu: \(uRange) \(rRange)")
                if uRange.location != NSNotFound {
                tempUserDict[key] = ["uName":posterName, "rName":location, "pic": pic!, "uid": uid]
                self.allSuggested.append(key)
                //print("curTextu: \(searchText) allSuggested1: \(self.allSuggested)")
                } else if self.allSuggested.contains(key){
               // if self.allSuggested.contains(location){
                   // tempUserDict.removeValue(forKey: key)
                    //self.allSuggested.remove(at: self.allSuggested.index(of: location)!)
                   // }
                    }
                    }
                    var tempCurUids = [String]()
                    for dict in self.findFriendsData{
                        tempCurUids.append(dict["uid"] as! String)
                        
                    }
                    for (key, val) in tempUserDict {
                        // print("snapKey: \(key)")
                        if self.allSuggested.contains(key){
                            
                            var tempDict = [String:Any]()
                            tempDict = val as! [String:Any]
                            // print("snapVal: \(val as! [String:Any])")
                            var noName = "-"
                            var uName = tempDict["uName"] as! String
                            
                            
                            var picString2 = picString
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
                        print("hey: \(self.findFriendsData)")
                        self.searchCollect.reloadData()
                    }
                    
                    
            })
                } else {
            
            //search for category
            Database.database().reference().child("posts").observeSingleEvent(of: .value, with: {(snapshot) in
                
                self.findFriendsData.removeAll()
                self.allSuggested.removeAll()
                //print("here: \(snapshot.value)")
                //print("hereNow")
                for (key, val) in (snapshot.value as! [String:Any]){
                    //print("uName=\(((val as! [String:Any])["username"] as! String))")
                    let categories = ((val as! [String:Any])["categories"] as! [String])
                    var picString: String?
                    var profPicString: String?
                    var posterName = ((val as! [String:Any])["posterName"] as! String)
                    
                    if ((val as! [String:Any])["postPic"] as? String) != nil {
                        picString = ((val as! [String:Any])["postPic"] as! String)
                        
                        profPicString = ((val as! [String:Any])["posterPicURL"] as! String)
                        
                    } else if ((val as! [String:Any])["postVid"] as? String) != nil {
                        profPicString = ((val as! [String:Any])["posterPicURL"] as! String)
                        picString = ((val as! [String:Any])["posterPicURL"] as! String)
                        
                    } else {
                        profPicString = ((val as! [String:Any])["posterPicURL"] as! String)
                        picString = ((val as! [String:Any])["posterPicURL"] as! String)
                        
                    }
                    let postID = key
                    let uid = ((val as! [String:Any])["posterUID"] as! String)
                    var pic: UIImage?
                    if picString != nil {
                        if picString == "profile-placeholder"{
                            pic = UIImage(named: "profile-placeholder")
                        } else {
                            if let messageImageUrl = URL(string: picString!) {
                                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                    pic = UIImage(data: imageData as Data)
                                }
                            }
                        }
                    }
                    
                    for cat in categories{
                        
                    let uRange = (cat as NSString).range(of: searchText, options: NSString.CompareOptions.literal)
                    print("rANDu: \(uRange)")
                        print("cats: \(cat)")
                    if uRange.location != NSNotFound {
                        tempUserDict[key] = ["uName":posterName, "rName":cat, "pic": pic!, "uid": uid]
                        self.allSuggested.append(postID)
                        //print("curTextu: \(searchText) allSuggested1: \(self.allSuggested)")
                    } else if self.allSuggested.contains(key){
                        if self.allSuggested.contains(cat){
                            tempUserDict.removeValue(forKey: key)
                            self.allSuggested.remove(at: self.allSuggested.index(of: cat)!)
                        }
                        }
                    }
                }
                var tempCurUids = [String]()
                for dict in self.findFriendsData{
                    tempCurUids.append(dict["uid"] as! String)
                    
                }
                for (key, val) in tempUserDict {
                     print("snapKey: \(key)")
                    print("allSugg: \(self.allSuggested)")
                    if self.allSuggested.contains(key){
                        
                        var tempDict = [String:Any]()
                        tempDict = val as! [String:Any]
                        // print("snapVal: \(val as! [String:Any])")
                        var noName = "-"
                        var uName = tempDict["uName"] as! String
                        
                        
                        //var picString2 = picString
                        if (tempDict["rName"] as? String) != nil{
                            noName = (tempDict["rName"] as! String)
                        }
                        
                        let cellDict = ["uName":uName,"profPic": tempDict["pic"]!, "picString": "pic", "realName": noName, "uid": key] as [String:Any]
                        
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
                    print("hey: \(self.findFriendsData)")
                    self.searchCollect.reloadData()
                }
                
            })
            
            
            
            
            }
    
            //print("nowHereee")
        
        
        
    } // called when text changes (including clear)
    
    
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.searchActive = false
        print("in search pressed")
    } // called when keyboard search button pressed

}
