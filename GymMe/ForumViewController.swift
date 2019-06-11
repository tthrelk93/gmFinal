//
//  ForumViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 2/10/19.
//  Copyright © 2019 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ForumPickerCell: UICollectionViewCell{
    
    @IBOutlet weak var pickerLabel: UILabel!
    
}

class ForumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ForumDelegate {
    func reloadDataAfterLike(){
        DispatchQueue.main.async{
            // self.likedByCollect.reloadData()
            // self.refresh()
        }
        // self.refresh()
    }
    @IBAction func mostRecentButtonPressed(_ sender: Any) {
        if mostRecentButton.backgroundColor == UIColor.red{
            
        } else {
        popularButton.layer.borderColor = UIColor.lightGray.cgColor
        mostRecentButton.layer.borderColor = UIColor.red.cgColor
        favoritesButton.layer.borderColor = UIColor.lightGray.cgColor
        //cell4.layer.borderColor = UIColor.lightGray.cgColor
        popularButton.backgroundColor = UIColor.white
        popularButton.setTitleColor(UIColor.lightGray, for: .normal)
        mostRecentButton.backgroundColor = UIColor.red
        mostRecentButton.setTitleColor(UIColor.white, for: .normal)
        favoritesButton.backgroundColor = UIColor.white
        favoritesButton.setTitleColor(UIColor.lightGray, for: .normal)
            DispatchQueue.main.async{
        UIView.animate(withDuration: 0.2, animations: {
            self.popularButton.frame = self.popPos1.frame
        self.favoritesButton.frame = self.favPos1.frame
        self.mostRecentButton.frame = self.mrBigFrame
        })
        
        self.topicData = self.ogTopicData
        
            self.topicCollect.reloadData()
        }
        }
       
    }
    @IBOutlet weak var mostRecentButton: UIButton!
    @IBAction func popularButtonPressed(_ sender: Any) {
        if popularButton.backgroundColor == UIColor.red{
            
        } else {
        mostRecentButton.layer.borderColor = UIColor.lightGray.cgColor
        popularButton.layer.borderColor = UIColor.red.cgColor
        favoritesButton.layer.borderColor = UIColor.lightGray.cgColor
        //cell4.layer.borderColor = UIColor.lightGray.cgColor
        mostRecentButton.backgroundColor = UIColor.white
    
        mostRecentButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        popularButton.backgroundColor = UIColor.red
        popularButton.setTitleColor(UIColor.white, for: .normal)
        
        favoritesButton.backgroundColor = UIColor.white
        favoritesButton.setTitleColor(UIColor.lightGray, for: .normal)
            DispatchQueue.main.async{
        UIView.animate(withDuration: 0.2, animations: {
        self.popularButton.frame = self.popPos2.frame
        
        self.favoritesButton.frame = self.favPos1.frame
        self.mostRecentButton.frame = CGRect(x: 6, y: self.popularButton.frame.origin.y, width: 103, height: self.mostRecentButton.frame.height)
        })
                self.topicData = self.topicData.sorted(by: { ($0["likes"] as! [[String:Any]]).count > ($1["likes"] as! [[String:Any]]).count })
        
            self.topicCollect.reloadData()
        }
        }
        
    }
    @IBOutlet weak var popularButton: UIButton!
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        if favoritesButton.backgroundColor == UIColor.red{
            
        } else {
        mostRecentButton.layer.borderColor = UIColor.lightGray.cgColor
        favoritesButton.layer.borderColor = UIColor.red.cgColor
        popularButton.layer.borderColor = UIColor.lightGray.cgColor
        //cell4.layer.borderColor = UIColor.lightGray.cgColor
        mostRecentButton.backgroundColor = UIColor.white
    
        mostRecentButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        favoritesButton.backgroundColor = UIColor.red
        favoritesButton.setTitleColor(UIColor.white, for: .normal)
        
        popularButton.backgroundColor = UIColor.white
        popularButton.setTitleColor(UIColor.lightGray, for: .normal)
            DispatchQueue.main.async{
        UIView.animate(withDuration: 0.2, animations: {
        self.favoritesButton.frame = self.favPos2.frame
        self.popularButton.frame = self.popPos3.frame
        self.mostRecentButton.frame = CGRect(x: 6, y: self.popularButton.frame.origin.y, width: 103, height: self.mostRecentButton.frame.size.height)
        })
        
        self.topicData = self.favoritedTopicsData
        
            self.topicCollect.reloadData()
        }
        }
    }
    @IBOutlet weak var favoritesButton: UIButton!
    
    @IBOutlet weak var favPos2: UIView!
    @IBOutlet weak var favPos1: UIView!
    @IBOutlet weak var popPos3: UIView!
    @IBOutlet weak var popPos2: UIView!
    @IBOutlet weak var popPos1: UIView!
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var topLabel: UILabel!
    var topicData = [[String:Any]]()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
            return topicData.count
        
    }
    var selectedCell = false
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
             let cell : ForumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForumCollectionViewCell", for: indexPath) as! ForumCollectionViewCell
        
            cell.layer.addBor(edge: .top, color: UIColor.lightGray, thickness: 0.5)
        
            var cellData = topicData[indexPath.row] as! [String:Any]
            if let messageImageUrl = URL(string: cellData["posterPic"] as! String) {
                
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    cell.posterPicImageView.image = UIImage(data: imageData as Data)
                    
                }
            }
            cell.forumData = cellData
            cell.forumID = cellData["postID"] as! String
            
            cell.posterPicImageView.frame = CGRect(x: cell.posterPicImageView.frame.origin.x, y: cell.posterPicImageView.frame.origin.y, width: 60, height: 60)
            cell.posterPicImageView.layer.cornerRadius = cell.posterPicImageView.frame.width/2
            cell.posterPicImageView.layer.masksToBounds = true
            
            cell.topicLabel.text = cellData["topicTitle"] as! String
            cell.posterNameLabel.text = cellData["posterRealName"] as! String
            
            var countString = String()
            var replies = cellData["replies"] as? [[String:Any]]
            var replyCount = replies?.count
            if replies == nil{
                countString = "0 replies"
            } else if replyCount == 1{
                countString = "1 reply"
            } else {
                countString = "\(replyCount!) replies"
            }
            cell.replyCountButton.setTitle(countString, for: .normal)
            
            let tStampDateString = cellData["timestamp"] as! String
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            let date = dateFormatter.date(from: tStampDateString)
            
            let now = Date()
            //print("tStampDateString: \(tStampDateString), date: \(date!), now: \(now)")
            var hoursBetween = Int(now.days(from: date!))
            print("hrs Between: \(hoursBetween)")
            if hoursBetween < 1{
                hoursBetween = Int(now.hours(from: date!))!
                if hoursBetween < 1 {
                    hoursBetween = Int(now.minutes(from: date!))
                    if hoursBetween == 1{
                        cell.timeStampLabel.text = "\(hoursBetween) minute ago"
                    } else {
                        cell.timeStampLabel.text = "\(hoursBetween) minutes ago"
                    }
                } else {
                    if hoursBetween == 1 {
                        cell.timeStampLabel.text = "\(hoursBetween) hour ago"
                    } else {
                        cell.timeStampLabel.text = "\(hoursBetween) hours ago"
                    }
                }
            } else {
                if hoursBetween == 1 {
                    cell.timeStampLabel.text = "\(hoursBetween) day ago"
                } else {
                    cell.timeStampLabel.text = "\(hoursBetween) days ago"
                }
            }
            
            var replyActualLikes = cellData["actualLikes"] as? [[String:Any]]
            if replyActualLikes!.count == 1{
                if (replyActualLikes!.first!)["x"] != nil {
                    cell.likesCountButton.setTitle("0 likes", for: .normal)
                } else {
                    cell.likesCountButton.setTitle("1 like", for: .normal)
                }
            } else {
                cell.likesCountButton.setTitle("\(replyActualLikes!.count) likes", for: .normal)
            }
            
            
            var replyLikes = cellData["likes"] as? [[String:Any]]
            
            if replyActualLikes != nil{
                for dict in replyActualLikes!{
                    if (dict["x"] as? String) != nil{
                        
                    } else {
                var tempDict = dict as! [String:Any]
                if tempDict["uid"] as! String == Auth.auth().currentUser!.uid{
                    cell.actualLikeTopic.setImage(UIImage(named: "likeSelected"), for: .normal)
                    break
                        }
                    }
            }
            }
            if replyLikes != nil{
                for dict in replyLikes!{
                    if (dict["x"] as? String) != nil{
                        
                    } else {
                        var tempDict = dict as! [String:Any]
                        if tempDict["uid"] as! String == Auth.auth().currentUser!.uid{
                            cell.likeTopicButton.setImage(UIImage(named: "favoritesFilled"), for: .normal)
                            break
                        }
                    }
                }
            }
            
  
            return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
            self.selectedTopicData = topicData[indexPath.row] as! [String:Any]
            performSegue(withIdentifier: "ForumToTopic", sender: self)
    }
    var selectedTopicData = [String:Any]()

    @IBOutlet weak var topicCollect: UICollectionView!
    //@IBOutlet weak var pickerCollect: UICollectionView!
    var favoritedTopics: [String]?
    var favoritedTopicsData = [[String:Any]]()
    var ogTopicData = [[String:Any]]()
    
   
    
    var mrBigFrame = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mrBigFrame = mostRecentButton.frame
       
        topLine.frame.size = CGSize(width: UIScreen.main.bounds.width,height: 0.5)
        self.topicCollect.register(UINib(nibName: "ForumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ForumCollectionViewCell")
        
        popularButton.layer.borderColor = UIColor.lightGray.cgColor
        mostRecentButton.layer.borderColor = UIColor.red.cgColor
        favoritesButton.layer.borderColor = UIColor.lightGray.cgColor
        popularButton.layer.borderWidth = 1
        mostRecentButton.layer.borderWidth = 1
        favoritesButton.layer.borderWidth = 1
        mostRecentButton.layer.cornerRadius = 10
        favoritesButton.layer.cornerRadius = 10
        popularButton.layer.cornerRadius = 10
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var userDict = snapshot.value as! [String:Any]
            self.favoritedTopics = userDict["favoritedTopics"] as? [String]
            Database.database().reference().child("forum").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var forumDict = snapshot.value as! [String:Any]
            for (key, val) in forumDict{
                if key as! String == "x"{
                    
                } else {
                var tempDict = val as! [String:Any]
                   
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    
                    let date = dateFormatter.date(from: tempDict["timestamp"] as! String)
                    tempDict["timestamp"] = date
                    
                    if self.favoritedTopics == nil{
                        
                    } else {
                    if (self.favoritedTopics?.contains(tempDict["postID"] as! String))!{
                        self.favoritedTopicsData.append(tempDict)
                    }
                    }
                    
                    
                self.topicData.append(tempDict)
                    
                    
                }
                
            }
                var counter1 = 0
                var tempArr1 = [[String:Any]]()
                for post in self.favoritedTopicsData{
                    var tempD = post
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    
                    let str = dateFormatter.string(from: post["timestamp"] as! Date)
                    tempD["timestamp"] = str as! String
                    //self.topicData[counter] = tempD
                    tempArr1.append(tempD)
                    counter1 = counter1 + 1
                }
                self.favoritedTopicsData = tempArr1
                self.favoritedTopicsData.reverse()
                
                let sortedResults = (self.topicData as NSArray).sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [[String:AnyObject]]
                self.topicData = sortedResults
                //self.topicData.reverse()
                var counter = 0
                var tempArr = [[String:Any]]()
                for post in self.topicData{
                    var tempD = post
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    
                    let str = dateFormatter.string(from: post["timestamp"] as! Date)
                    tempD["timestamp"] = str as! String
                    //self.topicData[counter] = tempD
                    tempArr.append(tempD)
                    counter = counter + 1
                }
                self.topicData = tempArr
                self.topicData.reverse()
                self.ogTopicData = self.topicData
                
                
            
        self.topicCollect.delegate = self
        self.topicCollect.dataSource = self
            
                
            })
        
            
        })
        // Do any additional setup after loading the view.
    }
    
    /*func getCell(_ indexPath: IndexPath) -> ForumPickerCell? {
        pickerCollect.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: false)
        var cell = pickerCollect.cellForItem(at: indexPath) as? ForumPickerCell
        if cell == nil {
            pickerCollect.layoutIfNeeded()
            cell = pickerCollect.cellForItem(at: indexPath) as? ForumPickerCell
        }
        if cell == nil {
            pickerCollect.reloadData()
            pickerCollect.layoutIfNeeded()
            cell = pickerCollect.cellForItem(at: indexPath) as? ForumPickerCell
        }
        return cell
    }*/
    
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "ForumToFeed", sender: self)
    }
    
    @IBAction func newTopicPressed(_ sender: Any) {
        performSegue(withIdentifier: "ForumToNewTopic", sender: self)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ForumToTopic"{
            if let vc = segue.destination as? SingleTopicViewController{
                vc.topicData = self.selectedTopicData
            }
        }
    }
    

}
extension CALayer {
    
    func addBor(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
}
