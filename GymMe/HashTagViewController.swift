//
//  HashTagViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 2/9/19.
//  Copyright © 2019 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class HashTagViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UITabBarDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hashTagData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : PopCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "PopCell", for: indexPath) as! PopCell)
        var curCellData = hashTagData[indexPath.row]
        if curCellData["postPic"] == nil && curCellData["postVid"] == nil{
            cell.popText.isHidden = false
            cell.popText.text = curCellData["postText"] as! String
        } else {
            cell.popPic.image = (curCellData["postPic"] as! UIImage)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedData = hashTagData[indexPath.row]
        performSegue(withIdentifier: "HashToSinglePost", sender: self)
    }
    

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var hashTagCollect: UICollectionView!
    @IBOutlet weak var hashTagImage: UIImageView!
    @IBOutlet weak var topLine: UIView!
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "HashToFeed", sender: self)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    var hashtag = String()
    var hashTagData = [[String:Any]]()
    var hashArray = [String]()
    var myUName = String()
    var myRealName = String()
    var myPicString = String()
    var following = [String]()
    var selectedData = [String:Any]()
    
    @IBOutlet weak var hashTagCount: UILabel!
    
    @IBOutlet weak var topLine2: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = "#\(self.hashtag)"
        tabBar.delegate = self
        topLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        topLine2.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        
         hashTagImage.frame = CGRect(x: hashTagImage.frame.origin.x, y: hashTagImage.frame.origin.y, width: hashTagImage.frame.width, height: hashTagImage.frame.width)
        hashTagImage.layer.cornerRadius = hashTagImage.frame.width/2
        hashTagImage.layer.masksToBounds = true
        
        self.hashTagCollect.register(UINib(nibName: "PopCell", bundle: nil), forCellWithReuseIdentifier: "PopCell")
        
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    if snap.key == "username"{
                        self.myUName = snap.value as! String
                    } else if snap.key == "following"{
                        self.following = snap.value as! [String]
                    } else if snap.key == "profPic"{
                        self.myPicString = snap.value as! String
                        if let messageImageUrl = URL(string: snap.value as! String) {
                            
                            
                            
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                              //  self.myPic = UIImage(data: imageData as Data)
                                //self.selfCommentPic.image = UIImage(data: imageData as Data)
                                
                            }
                            
                            // }
                        }
                    } else if snap.key == "realName"{
                        self.myRealName = snap.value as! String
                    }
                    
                }
            }
        })
        
        Database.database().reference().child("hashtags").child(hashtag).observeSingleEvent(of: .value, with: { snapshot in
            var valDict = snapshot.value as! [String]
            for str in valDict{
                self.hashArray.append(str)
            }
            Database.database().reference().child("posts").observeSingleEvent(of: .value, with: { snapshot in
                var valDict = snapshot.value as! [String:Any]
                for (key,val) in valDict{
                    if self.hashArray.contains(key){
                        var tempData = val as! [String:Any]
                        if tempData["postPic"] == nil && tempData["postVid"] == nil{
                            self.hashTagData.append(tempData)
                        } else {
                       
                            
                            if tempData["postPic"] == nil{
                                //vid
                            } else {
                                var picString = tempData["postPic"] as! String
                                
                                if let messageImageUrl = URL(string: picString) {
                                    
                                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                        var pic = UIImage(data: imageData as Data)
                                        tempData["postPic"] = pic as! UIImage
                                        
                                    }
                                }
                            }
                            self.hashTagData.append(tempData)
                        }
                    }
                }
                let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 20)]
                let attributedString = NSMutableAttributedString(string:String(self.hashTagData.count), attributes:attrs)
                var normalText = String()
                if self.hashTagData.count == 1{
                    normalText = " post"
                } else {
                    normalText = " posts"
                }
                let attrs2 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17, weight: .regular), NSAttributedStringKey.strokeColor: UIColor.lightGray]
                let normalString = NSMutableAttributedString(string:normalText, attributes: attrs2)
                
                
                attributedString.append(normalString)
               
                if self.hashTagData.count == 0 || ((self.hashTagData.first!)["postPic"]as? UIImage) == nil{
                    
                } else {
                self.hashTagImage.image = ((self.hashTagData.first!)["postPic"] as! UIImage)
                }
                self.hashTagCount.attributedText = attributedString
                DispatchQueue.main.async{
                self.hashTagCollect.delegate = self
                self.hashTagCollect.dataSource = self
                }
            })
                
        })
        
        // Do any additional setup after loading the view.
    }
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "HashToSinglePost"{
        if let vc = segue.destination as? SinglePostViewController{
            
            print("wuttttttt: \(self.selectedData)")
            
            vc.prevScreen = "hash"
            vc.senderScreen = "hash"
            vc.thisPostData = self.selectedData
            vc.myUName = self.myUName
            vc.following = self.following
            vc.myPicString = self.myPicString
            vc.hashtag = self.hashtag
            
            
            }
        }
    }
    

}
