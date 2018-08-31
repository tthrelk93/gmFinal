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
    

    var selectedMessageKey: String?
    var newMessage = false
    @IBOutlet weak var suggestedLabel: UILabel!
    @IBOutlet weak var messagesSearchBar: UISearchBar!
    @IBOutlet weak var allMessagesTableView: UITableView!
    @IBAction func rightBarButtonPressed(_ sender: Any) {
        
        topLabel.text = "New Message"
        suggestedLabel.isHidden = false
        newMessage = true
        allMessagesTableView.reloadData()
        
        
    }
    @IBAction func backPressed(_ sender: Any) {
        if newMessage == true{
            newMessage = false
            topLabel.text = "Messages"
            suggestedLabel.isHidden = true
            allMessagesTableView.reloadData()
        } else {
            performSegue(withIdentifier: "MessagesToFeed", sender: self)
        }
    }
    
    @IBOutlet weak var topLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesSearchBar.delegate = self
        
        //tableViewData = [[String:Any]]()//[["receiverUID":"dlIJLLijOBR6mOBXGNoO3oCPo7M2", "messageText": "blah bal  sdfkjlhhl lsdjkkj sjkdfkl hsdlf","receiverName": "Thomas","receiverPic":"picccccc"],["receiverUID":"reasdfaacieverUIDDddd", "messageText": "blaaaaasdfdaaaah bal  sdfkjlhhl lsdjkkj sjkdfkl hsdlf","receiverName": "Thomaaaaaas","receiverPic":"piaaaacccccc"]]
       //suggestedTableViewData = [["receiverUID":"dlIJLLijOBR6mOBXGNoO3oCPo7M2", "messageText": "blah ssssssssbal  sdfkjlhhl lsdjkkj sjkdfkl hsdlf","receiverName": "Thssssomas","receiverPic":"picccssssssccc"]]
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("messages").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                 print("messageDictSnapshot: \(snapshot)")
                for snap in snapshots{
                   
                    var messageDict = snap.value as! [String:Any]
                    print("md: \(messageDict)")
                    var tempDict = ["receiverUID":snap.key, "messageText":((messageDict.first?.value as! [String:Any])["text"] as! String), "receiverName":/*((messageDict.first?.value as! [String:Any])["senderName"] as! String)*/"recName", "messageKey": messageDict.first?.key]
                    self.tableViewData.append(tempDict)
                    
                    
                    }
                self.allMessagesTableView.register(UINib(nibName: "MessagesTableViewCell", bundle: nil), forCellReuseIdentifier: "MessagesTableViewCell")
               
                    self.allMessagesTableView.delegate = self
                    self.allMessagesTableView.dataSource = self
                    DispatchQueue.main.async {
                        self.allMessagesTableView.reloadData()
                    }
                
                
                }
            })
        

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var tableViewData = [[String:Any]]()
    //var newMessage = false
    var suggestedTableViewData = [[String:Any]]()
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
            let recPic = UIImage()
            //make image from ((tableViewData[indexPath.row] as! [String:Any])["receiverPic"] as! String)
            //cell.receiverPic.image = recPic
            cell.receiverUID = ((suggestedTableViewData[indexPath.row] )["receiverUID"] as! String)
            cell.messageKey = ((suggestedTableViewData[indexPath.row] )["messageKey"] as! String)
            cell.messageText.text = ((suggestedTableViewData[indexPath.row])["messageText"] as! String)
            cell.receiverName.text = ((suggestedTableViewData[indexPath.row] )["receiverName"] as! String)
            
            return cell
        } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesTableViewCell") as! MessagesTableViewCell
            let recPic = UIImage()
        //make image from ((tableViewData[indexPath.row] as! [String:Any])["receiverPic"] as! String)
        //cell.receiverPic.image = recPic
        cell.messageKey = ((tableViewData[indexPath.row] )["messageKey"] as! String)
        cell.receiverUID = ((tableViewData[indexPath.row] )["receiverUID"] as! String)
        cell.messageText.text = ((tableViewData[indexPath.row] )["messageText"] as! String)
        cell.receiverName.text = ((tableViewData[indexPath.row] )["receiverName"] as! String)
        
        return cell
        }
            
    }
    var selectedRecip = String()
    var searchActive = Bool()
    var curMessageKey = String()
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
            print("yo")
            print(self.selectedRecip)
            if let vc = segue.destination as? ChatContainer{
                vc.recipientID = self.selectedRecip
                vc.curItemKey = self.selectedRecip
            }
        }
    }
    
    //search bar functions
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }

    var allSuggested = [String]()
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        print("SB text did change: \(searchText)")
        suggestedTableViewData.removeAll()
        allSuggested.removeAll()
        
        Database.database().reference().child("usernames").observeSingleEvent(of: .value, with: {(snapshot) in
            print("here: \(snapshot.value)")
            //let snapshotss = snapshot.value as? [DataSnapshot]
                print("hereNow")
            for (key, val) in (snapshot.value as! [String:Any]){
                    print("uName=\(key)")
                    let uName = key
                    let rName = (val as! String)
                let uRange = (uName as NSString).range(of: searchText, options: NSString.CompareOptions.literal)
                    let rRange = (rName as NSString).range(of: searchText, options: NSString.CompareOptions.literal)
                    print("rANDu: \(uRange) \(rRange)")
                if uRange.location != NSNotFound {
                    self.allSuggested.append(rName)
                    print("curTextu: \(searchText) allSuggested1: \(self.allSuggested)")
                } else if rRange.location != NSNotFound{
                        self.allSuggested.append(rName)
                        print("curText: \(searchText) allSuggested: \(self.allSuggested)")
                } else if self.allSuggested.contains(rName){
                        if self.allSuggested.contains(rName){
                            self.allSuggested.remove(at: self.allSuggested.index(of: rName)!)
                        }
                        
                }
                
            }
                print("nowHereee")
                Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                    print("nowHereeeeee")
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        print("nowHereerrrrreeerererererererre")
                        for snap in snapshots{
                            print("snapKey: \(snap.key)")
                            if self.allSuggested.contains(snap.key){
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
                        if(self.suggestedTableViewData.count == 0){
                    self.searchActive = false;
                        } else {
                    self.searchActive = true;
                        }
                       
                            self.allMessagesTableView.reloadData()
                        
                
                    }
                })
        })
        
    } // called when text changes (including clear)
        
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.searchActive = false
        print("in search pressed")
    } // called when keyboard search button pressed
    

}