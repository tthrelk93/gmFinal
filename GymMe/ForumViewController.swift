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
    
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var topLabel: UILabel!
    var topicData = [[String:Any]]()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == pickerCollect{
            return 3
        } else {
            return topicData.count
        }
    }
    var selectedCell = false
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == pickerCollect{
            let cell : ForumPickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForumPickerCell", for: indexPath) as! ForumPickerCell
            switch indexPath.row{
           /* case 0:
                cell.pickerLabel.text = "Featured Topics"
                if selectedCell == false{
                cell.backgroundColor = UIColor.red
                cell.pickerLabel.textColor = UIColor.white
                cell.layer.borderColor = UIColor.red.cgColor
                }*/
            case 0:
                cell.pickerLabel.text = "Most Recent"
                if selectedCell == false{
                cell.backgroundColor = UIColor.red
                cell.pickerLabel.textColor = UIColor.white
                cell.layer.borderColor = UIColor.red.cgColor
                }
            case 1:
                cell.pickerLabel.text = "Popular"
                if selectedCell == false{
                cell.backgroundColor = UIColor.white
                cell.pickerLabel.textColor = UIColor.lightGray
                cell.layer.borderColor = UIColor.lightGray.cgColor
                }
            default:
                cell.pickerLabel.text = "Favorited"
                if selectedCell == false{
                cell.backgroundColor = UIColor.white
                cell.pickerLabel.textColor = UIColor.lightGray
                cell.layer.borderColor = UIColor.lightGray.cgColor
                }
            }
            
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 8
            
            return cell
        } else {
             let cell : ForumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForumCollectionViewCell", for: indexPath) as! ForumCollectionViewCell
            
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
            
            
            
            var replyLikes = cellData["likes"] as? [[String:Any]]
            if replyLikes!.count == 1{
                if (replyLikes!.first!)["x"] != nil {
                    cell.likesCountButton.setTitle("0 likes", for: .normal)
                } else {
                cell.likesCountButton.setTitle("1 like", for: .normal)
                }
            } else {
                cell.likesCountButton.setTitle("\(replyLikes!.count) likes", for: .normal)
            }
            if replyLikes != nil{
                for dict in replyLikes!{
                    if (dict["x"] as? String) != nil{
                        
                    } else {
                var tempDict = dict as! [String:Any]
                if tempDict["uid"] as! String == Auth.auth().currentUser!.uid{
                    cell.likeTopicButton.setImage(UIImage(named: "likeSelected"), for: .normal)
                    break
                        }
                    }
            }
            }
            
            
            
            return cell
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == pickerCollect{
            //collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            //collectionView.reloadData()
            //collectionView.layoutIfNeeded()
            var cell1 = ForumPickerCell()
            var cell2 = ForumPickerCell()
            var cell3 = ForumPickerCell()
            var cell4 = ForumPickerCell()
            selectedCell = true
            
            //var scrollPos = UICollectionViewScrollPosition(rawValue: UInt(collectionView.contentOffset.x))
            
            pickerCollect.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition(), animated: false)
            if let cell = getCell(IndexPath(item: 0, section: 0)) {
                cell1 = cell
            }
            pickerCollect.scrollToItem(at: IndexPath(item: 1, section: 0), at: UICollectionViewScrollPosition(), animated: false)
            if let cell = getCell(IndexPath(item: 1, section: 0)) {
                cell2 = cell
            }
            pickerCollect.scrollToItem(at: IndexPath(item: 2, section: 0), at: UICollectionViewScrollPosition(), animated: false)
            if let cell = getCell(IndexPath(item: 2, section: 0)) {
                cell3 = cell
            }
            /*pickerCollect.scrollToItem(at: IndexPath(item: 3, section: 0), at: UICollectionViewScrollPosition(), animated: false)
            if let cell = getCell(IndexPath(item: 3, section: 0)) {
                cell4 = cell
            }*/
            
            
            switch indexPath.row {
            case 0:
                pickerCollect.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition(), animated: true)
                cell1.layer.borderColor = UIColor.red.cgColor
                cell2.layer.borderColor = UIColor.lightGray.cgColor
                cell3.layer.borderColor = UIColor.lightGray.cgColor
                //cell4.layer.borderColor = UIColor.lightGray.cgColor
                cell1.backgroundColor = UIColor.red
                cell1.pickerLabel.textColor = UIColor.white
                cell2.backgroundColor = UIColor.white
                cell2.pickerLabel.textColor = UIColor.lightGray
                cell3.backgroundColor = UIColor.white
                cell3.pickerLabel.textColor = UIColor.lightGray
                self.topicData = self.ogTopicData
                DispatchQueue.main.async{
                    self.topicCollect.reloadData()
                }
               // cell4.backgroundColor = UIColor.white
                //cell4.pickerLabel.textColor = UIColor.lightGray
            case 1:
                 pickerCollect.scrollToItem(at: IndexPath(item: 1, section: 0), at: UICollectionViewScrollPosition(), animated: true)
                cell1.layer.borderColor = UIColor.lightGray.cgColor
                cell2.layer.borderColor = UIColor.red.cgColor
                cell3.layer.borderColor = UIColor.lightGray.cgColor
                //cell4.layer.borderColor = UIColor.lightGray.cgColor
                cell1.backgroundColor = UIColor.white
                cell1.pickerLabel.textColor = UIColor.lightGray
                cell2.backgroundColor = UIColor.red
                cell2.pickerLabel.textColor = UIColor.white
                cell3.backgroundColor = UIColor.white
                cell3.pickerLabel.textColor = UIColor.lightGray
               // cell4.backgroundColor = UIColor.white
                //cell4.pickerLabel.textColor = UIColor.lightGray
               self.topicData = topicData.sorted(by: { ($0["likes"] as! [[String:Any]]).count > ($1["likes"] as! [[String:Any]]).count })
                DispatchQueue.main.async{
                    self.topicCollect.reloadData()
                }
            case 2:
                 pickerCollect.scrollToItem(at: IndexPath(item: 2, section: 0), at: UICollectionViewScrollPosition(), animated: true)
                cell1.layer.borderColor = UIColor.lightGray.cgColor
                cell2.layer.borderColor = UIColor.lightGray.cgColor
                cell3.layer.borderColor = UIColor.red.cgColor
                //cell4.layer.borderColor = UIColor.lightGray.cgColor
                cell1.backgroundColor = UIColor.white
                cell1.pickerLabel.textColor = UIColor.lightGray
                cell2.backgroundColor = UIColor.white
                cell2.pickerLabel.textColor = UIColor.lightGray
                cell3.backgroundColor = UIColor.red
                cell3.pickerLabel.textColor = UIColor.white
                self.topicData = self.favoritedTopicsData
                DispatchQueue.main.async{
                    self.topicCollect.reloadData()
                }
               // cell4.backgroundColor = UIColor.white
                //cell4.pickerLabel.textColor = UIColor.lightGray
                
            default:
                cell1.layer.borderColor = UIColor.lightGray.cgColor
                cell2.layer.borderColor = UIColor.lightGray.cgColor
                cell3.layer.borderColor = UIColor.lightGray.cgColor
                //cell4.layer.borderColor = UIColor.red.cgColor
                cell1.backgroundColor = UIColor.white
                cell1.pickerLabel.textColor = UIColor.lightGray
                cell2.backgroundColor = UIColor.white
                cell2.pickerLabel.textColor = UIColor.lightGray
                cell3.backgroundColor = UIColor.white
                cell3.pickerLabel.textColor = UIColor.lightGray
               // cell4.backgroundColor = UIColor.red
               // cell4.pickerLabel.textColor = UIColor.white
            
            }
        } else {
            self.selectedTopicData = topicData[indexPath.row] as! [String:Any]
            performSegue(withIdentifier: "ForumToTopic", sender: self)
        }
    }
    var selectedTopicData = [String:Any]()

    @IBOutlet weak var topicCollect: UICollectionView!
    @IBOutlet weak var pickerCollect: UICollectionView!
    var favoritedTopics: [String]?
    var favoritedTopicsData = [[String:Any]]()
    var ogTopicData = [[String:Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()

        topLine.frame.size = CGSize(width: UIScreen.main.bounds.width,height: 0.5)
        self.topicCollect.register(UINib(nibName: "ForumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ForumCollectionViewCell")
        
        self.pickerCollect.delegate = self
        self.pickerCollect.dataSource = self
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
                let sortedResults = (self.topicData as NSArray).sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [[String:AnyObject]]
                self.topicData = sortedResults
                //self.topicData.reverse()
                var counter = 0
                for post in self.topicData{
                    var tempD = post
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    
                    let str = dateFormatter.string(from: post["timestamp"] as! Date)
                    tempD["timestamp"] = str
                    self.topicData[counter] = tempD
                    counter = counter + 1
                }
                self.topicData.reverse()
                self.ogTopicData = self.topicData
                
                
            
        self.topicCollect.delegate = self
        self.topicCollect.dataSource = self
            
                
            })
        
            
        })
        // Do any additional setup after loading the view.
    }
    
    func getCell(_ indexPath: IndexPath) -> ForumPickerCell? {
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
    }
    
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
