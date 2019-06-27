//
//  MessagesTableViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 7/19/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MessagesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var backFromMessage = false
    var selectedMessageKey: String?
    var newMessage = false
    var curUID = String()
    var tableViewData = [[String:Any]]()
    var suggestedTableViewData = [[String:Any]]()
    var myRealName = String()
    var prevScreen = String()
    var recipientID = String()
    var curItemKey = String()
    var selectedRecip = String()
    var searchActive = Bool()
    var curMessageKey = String()
    var allSuggested = [String]()
    @IBOutlet weak var selectRecipLabel: UILabel!
    @IBOutlet weak var suggestedLabel: UILabel!
    @IBOutlet weak var messagesSearchBar: UISearchBar!
    @IBOutlet weak var allMessagesTableView: UITableView!
    @IBAction func rightBarButtonPressed(_ sender: Any) {
        selectRecipLabel.isHidden = false
        topLabel.isHidden = true
        
        suggestedLabel.isHidden = false
        newMessage = true
        messagesSearchBar.becomeFirstResponder()
        allMessagesTableView.reloadData()
    }
    @IBAction func backPressed(_ sender: Any) {
        
        if newMessage == true{
            newMessage = false
            selectRecipLabel.isHidden = true
            topLabel.isHidden = false
            suggestedLabel.isHidden = true
            allMessagesTableView.reloadData()
        } else if self.prevScreen == "profile"{
            print("prevScreenProfile")
            performSegue(withIdentifier: "MessageToProfile", sender: self)
        } else {
            performSegue(withIdentifier: "MessagesToFeed", sender: self)
        }
    }
    
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var topLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesSearchBar.delegate = self
        
       topLine.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 0.5)
        Database.database().reference().child("users").observeSingleEvent(of: .value, with:
            { (snapshott) in
                 var snapshotss = snapshott.value as! [String:Any]
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("messages").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    var thisUser = snapshotss[snap.key] as! [String:Any]
                    var tableDict = [String:Any]()
                    tableDict["receiverUID"] = snap.key
                    var messageDict = snap.value as! [String:Any]
                    //print("mddd: \((messageDict.values))")
                    var mArray = [[String:Any]]()
                    var count = 0
                    for dict in messageDict{
                        if dict.key == "typingIndicator"{
                            print("typingindicator")
                        } else {
                            var tDict = dict.value as! [String:Any]
                            var dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                            var date = dateFormatter.date(from: tDict["timeStamp"] as! String)
                            tDict["timeStamp"] = date
                            mArray.append(tDict)
                        }
                    }
                    let sortedResults = (mArray as NSArray).sortedArray(using: [NSSortDescriptor(key: "timeStamp", ascending: true)]) as! [[String:AnyObject]]
                    
                            tableDict["receiverName"] = thisUser["realName"] as! String
                            tableDict["senderName"] = (sortedResults.last as! [String:Any])["senderName"] as! String
                            tableDict["messageKey"] = messageDict.first?.key
                            if ((sortedResults.last as! [String:Any])["text"] as? String == nil){
                            tableDict["photoURL"] = (sortedResults.last as! [String:Any])["photoURL"] as! String
                                tableDict["messageText"] = ""
                            } else {
                                tableDict["messageText"] = (sortedResults.last as! [String:Any])["text"] as! String
                            }
                            self.tableViewData.append(tableDict)
                    
                }
                self.allMessagesTableView.register(UINib(nibName: "MessagesTableViewCell", bundle: nil), forCellReuseIdentifier: "MessagesTableViewCell")
                self.allMessagesTableView.delegate = self
                self.allMessagesTableView.dataSource = self
               
               
                        // ready
                self.allMessagesTableView.reloadData()
                
                
                
                if self.prevScreen == "profile"{
                    if self.backFromMessage == true{
                        self.performSegue(withIdentifier: "MessageToProfile", sender: self)
                    } else {
                        print("prevScreen = profile curUID: \(self.curUID)")
                        self.performSegue(withIdentifier: "MessagesToChat", sender: self)
                    }
                }
                
                }
            
                })
            })
        

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return self.suggestedTableViewData.count
        } else {
            return self.tableViewData.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(searchActive) {
            
           let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesTableViewCell") as! MessagesTableViewCell
            if suggestedTableViewData.count == 0{
                
            } else {
                
             Database.database().reference().child("users").child(((suggestedTableViewData[indexPath.row])["receiverUID"] as! String)).observeSingleEvent(of: .value, with: { (snapshot) in
                var userPic = (snapshot.value as! [String:Any])["profPic"] as! String
            
            let recPic = UIImage()
                cell.receiverPic.frame = CGRect(x: cell.receiverPic.frame.origin.x, y: cell.receiverPic.frame.origin.y, width: 40, height: 40)
                cell.receiverPic.layer.cornerRadius = cell.receiverPic.frame.width/2
                cell.receiverPic.layer.masksToBounds = true
                
            if let messageImageUrl = URL(string: userPic) {
                
                if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                    cell.receiverPic.image = UIImage(data: imageData as Data)
                    
                }}
            //make image from ((tableViewData[indexPath.row] as! [String:Any])["receiverPic"] as! String)
            //cell.receiverPic.image = recPic
            cell.receiverUID = ((self.suggestedTableViewData[indexPath.row] )["receiverUID"] as! String)
            cell.messageKey = ((self.suggestedTableViewData[indexPath.row] )["messageKey"] as! String)
            cell.messageText.text = ((self.suggestedTableViewData[indexPath.row])["messageText"] as! String)
            cell.receiverName.text = ((self.suggestedTableViewData[indexPath.row] )["receiverName"] as! String)
            
            
                })
            }
            return cell
        } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesTableViewCell") as! MessagesTableViewCell
            Database.database().reference().child("users").child(((tableViewData[indexPath.row])["receiverUID"] as! String)).observeSingleEvent(of: .value, with: { (snapshot) in
                var userPic = (snapshot.value as! [String:Any])["profPic"] as! String
                
                let recPic = UIImage()
                cell.receiverPic.frame = CGRect(x: cell.receiverPic.frame.origin.x, y: cell.receiverPic.frame.origin.y, width: 40, height: 40)
                cell.receiverPic.layer.cornerRadius = cell.receiverPic.frame.width/2
                cell.receiverPic.layer.masksToBounds = true
                
                
                if let messageImageUrl = URL(string: userPic) {
                    
                    if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                        cell.receiverPic.image = UIImage(data: imageData as Data)
                        
                    }}
                cell.messageKey = ((self.tableViewData[indexPath.row] )["messageKey"] as! String)
                cell.receiverUID = ((self.tableViewData[indexPath.row] )["receiverUID"] as! String)
                cell.messageText.text = ((self.tableViewData[indexPath.row] )["messageText"]! as! String)
                //if ((self.tableViewData[indexPath.row] )["senderName"] as! String) != self.myRealName {
                    cell.receiverName.text = (snapshot.value as! [String:Any])["realName"] as! String
           // } else {
               //     cell.receiverName.text = ((self.tableViewData[indexPath.row] )["receiverName"] as! String)
            //}
            })
        return cell
        }
            
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //performSegue to chatViewController
         if(searchActive) {
            selectedRecip = (suggestedTableViewData[indexPath.row] )["receiverUID"] as! String
            print("selectedRecip: \(self.selectedRecip)")
            self.curMessageKey = (suggestedTableViewData[indexPath.row] )["messageKey"] as! String
            print("curMessageKey: \(self.curMessageKey)")
            performSegue(withIdentifier: "MessagesToChat", sender: self)
         } else {
        selectedRecip = (tableViewData[indexPath.row] )["receiverUID"] as! String
        performSegue(withIdentifier: "MessagesToChat", sender: self)
        }
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 60
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "MessagesToChat"{
            print("yo:")
            print(self.selectedRecip)
            if let vc = segue.destination as? ChatContainer{
                
                vc.recipientID = self.selectedRecip
                vc.curItemKey = self.selectedRecip
                vc.prevScreen = self.prevScreen
            }
        }
        if segue.identifier == "MessageToProfile"{
            if let vc = segue.destination as? ProfileViewController{
                vc.curUID = self.curUID
            }
        }
    }
    
    //search bar functions
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        /*searchActive = true;
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            print("nowHereeeeee")
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                print("nowHereerrrrreeerererererererre")
                for snap in snapshots{
                    print("snapKey: \(snap.key)")
                    var tempDict = [String:Any]()
                    tempDict = snap.value as! [String:Any]
                    print("snapVal: \(snap.value as! [String:Any])")
                    var noName = "-"
                    if (tempDict["realName"] as? String) != nil{
                        noName = (tempDict["realName"] as! String)
                    }
                    // var messages = tempDict["messages"]
                    var cellDict = ["receiverUID":snap.key, "messageText": (tempDict["username"] as! String),"receiverName": noName,"receiverPic":"picccssssssccc", "messageKey": snap.key] as [String:Any]
                    self.suggestedTableViewData.append(cellDict)
                }
            }
            self.allMessagesTableView.reloadData()
        })*/
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }

    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        print("SB text did change: \(searchText)")
        
           
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshott) in
            print("nowHereeeeee")
            if let snapshotss = snapshott.children.allObjects as? [DataSnapshot]{
                Database.database().reference().child("usernames").observeSingleEvent(of: .value, with: {(snapshot) in
                    self.suggestedTableViewData.removeAll()
                    self.allSuggested.removeAll()
                    var lowerText = searchText.lowercased()
            print("here: \(snapshot.value)")
            //let snapshotss = snapshot.value as? [DataSnapshot]
                print("hereNow")
                    
            for (key, val) in (snapshot.value as! [String:Any]){
                    print("uName=\(key)")
                if key != "fuck"{
                    let uName = key.lowercased()
                    let rName = ((val as! [String])[1]).lowercased()
                    let uNameID = ((val as! [String])[0])
                let uRange = (uName as NSString).range(of: lowerText, options: NSString.CompareOptions.literal)
                    let rRange = (rName as NSString).range(of: lowerText, options: NSString.CompareOptions.literal)
                    print("rANDu: \(uRange) \(rRange)")
                if uRange.location != NSNotFound || rRange.location != NSNotFound {
                     if self.allSuggested.contains(uNameID) == false {
                        self.allSuggested.append(uNameID)
                        print("curTextu: \(lowerText) allSuggested1: \(self.allSuggested)")
                    }
                    
                } else if self.allSuggested.contains(uNameID) == true{
                            self.allSuggested.remove(at: self.allSuggested.index(of: uNameID)!)
                        }
                }
                        
            }
            print("nowHereee: \(self.allSuggested)")
            
                    //print("nowHereerrrrreeerererererererre: \(self.allSuggested)")
                        for snap in snapshotss{
                            print("snapKey: \(snap.key)")
                            if self.allSuggested.contains(snap.key){
                                var tempDict = [String:Any]()
                                tempDict = snap.value as! [String:Any]
                                //print("snapVal: \(snap.value as! [String:Any])")
                                var noName = "-"
                                if (tempDict["realName"] as? String) != nil{
                                    noName = (tempDict["realName"] as! String)
                                }
                               // var messages = tempDict["messages"]
                                var cellDict = ["receiverUID":snap.key, "messageText": (tempDict["username"] as! String),"receiverName": noName,"receiverPic":"picccssssssccc", "messageKey": snap.key] as [String:Any]
                                self.suggestedTableViewData.append(cellDict)
                            }
                        }
                        if(self.suggestedTableViewData.count == 0){
                            print("sugg: \(self.suggestedTableViewData.count)")
                    self.searchActive = false;
                        } else {
                    self.searchActive = true;
                        }
                    DispatchQueue.main.async{
                    self.allMessagesTableView.reloadData()
                    }
                    
                    
                })
            }
        })
        
        
    } // called when text changes (including clear)
        
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.searchActive = false
        searchBar.endEditing(true)
        print("in search pressed")
    } // called when keyboard search button pressed
    

}
