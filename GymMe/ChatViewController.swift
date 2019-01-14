//
//  SessionChatViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 11/14/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//
import Foundation
import Photos
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

import JSQMessagesViewController


final class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate,UINavigationBarDelegate {
    // MARK: Properties
    //var getSessionID: GetSessionIDDelegate?
    var senderName = String()
    private let imageURLNotSetKey = "NOTSET"
    var thisSessionID: String!
    var sessionRef: DatabaseReference?
    var senderView = String()
    var jobID = String()
   // var job = JobPost()
    
    var curUserRef = DatabaseReference()
    //  @IBOutlet weak var navBar: UINavigationBar!
    var messageRef = DatabaseReference()
    fileprivate lazy var storageRef = Storage.storage().reference(forURL: "gs://chatchat-rw-cf107.appspot.com")
    var userIsTypingRef = DatabaseReference()
    var usersTypingQuery = DatabaseQuery()
    
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    
    //@IBAction func backButtonPressed(_ sender: Any) {
    //  }
    private var messages: [JSQMessage] = []
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    
    private var localTyping = false
    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    //var bandID = String()
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        /* if segue.identifier == "ChatBackToBand"{
         if let vc = segue.destination as? SessionMakerViewController{
         vc.sessionID = self.thisSessionID
         }
         } else {
         if let vc = segue.destination as? OneNightBandViewController{
         vc.onbID = self.thisSessionID
         }
         }*/
    }
    
    // @IBOutlet weak var backButton: UIButton!
    
    
    
    func goBack(){
        /*if self.senderView == "poster"{
         performSegue(withIdentifier: "ChatBackToBand", sender: self)
         } else {
         performSegue(withIdentifier: "ChatBackToONB", sender: self)
         }*/
        
    }
    
    
    
    var jobType = String()
    // @IBOutlet weak var navItem: UINavigationItem!
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    // MARK: View Lifecycle
    var thisUser = DatabaseReference()
    var thisUserIsTypingRef = DatabaseReference()
    var thisUsersTypingQuery = DatabaseReference()
    var myName = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    if snap.key == "realName"{
                        self.myName = snap.value as! String
                    }
                }
            }
        })
        /*Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("messages").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots{
                    if snap.key == self.recipientID{
                        let curMessages = snap.value as! [String:Any]
                        for (_, val) in curMessages {
                            var tempDict = val as! [String:Any]
                           /* if tempDict["senderId"] as! String == Auth.auth().currentUser!.uid {
                                
                            } else {*/
                            let message = JSQMessage(senderId: tempDict["senderId"] as! String, displayName: tempDict["senderName"] as! String, text: tempDict["text"] as! String)
                            self.messages.append(message!)
                            //}
                            
                        }
                    }
                }
            }
        })*/
        
        self.senderId = Auth.auth().currentUser?.uid
       
        self.curUserRef = Database.database().reference().child("users").child(self.recipientID)
        self.thisUser = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
        
        self.userIsTypingRef = self.curUserRef.child("messages").child(Auth.auth().currentUser!.uid).child("typingIndicator").child(self.senderId)
        self.usersTypingQuery = self.curUserRef.child("messages").child(Auth.auth().currentUser!.uid).child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
        self.messageRef = self.curUserRef.child("messages").child(Auth.auth().currentUser!.uid)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
       
            self.observeMessages()
        
        
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    // MARK: Collection view data source (and related) methods
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    var gmRed = UIColor(red: 237/255, green: 28/255, blue: 39/255, alpha: 1.0)
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        //cell.textView?.backgroundColor = gmRed
        if message.senderId == senderId { // 1
            cell.textView?.textColor = UIColor.white // 2
        } else {
            cell.textView?.textColor = UIColor.black // 3
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        print("thisMessage: \(message)")
        switch message.senderId {
        case senderId:
            //return NSAttributedString(string: "testerrrr")
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                print("nil")
                assertionFailure()
                return nil
               // print("testerSenderDisplayName")
            }
            //senderDisplayName = "testerrrr"
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    // MARK: Firebase related methods
    
    private func observeMessages() {
        messageRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("messages").child(self.recipientID)//curUserRef.child("messages").child()
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            print(snapshot)
            if(snapshot.childrenCount > 1){
                let messageData = snapshot.value as! Dictionary<String, String>
                
                if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                    self.addMessage(withId: id, name: name, text: text)
                    self.finishReceivingMessage()
                } else if let id = messageData["senderId"] as String!, let photoURL = messageData["photoURL"] as String! {
                    if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                        self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                        
                        if photoURL.hasPrefix("gs://") {
                            self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                        }
                    }
                } else {
                    print("Error! Could not decode message data")
                }
            }
        })
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            if(snapshot.childrenCount > 1){
                let messageData = snapshot.value as! Dictionary<String, String>
                
                if let photoURL = messageData["photoURL"] as String! {
                    // The photo has been updated.
                    if let mediaItem = self.photoMessageMap[key] {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
                    }
                }
            }
        })
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        let storageRef = Storage.storage().reference(forURL: photoURL)
        storageRef.getData(maxSize: INT64_MAX, completion: {(data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                
                mediaItem.image = UIImage.init(data: data!)
                
                self.collectionView.reloadData()
                
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
        )
    }
    
    private func observeTyping() {
        let typingIndicatorRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("messages").child(self.recipientID).child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
        
        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            
            // You're the only typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    var recipientID = String()
    var curItemKey: String?
    var newMessage = false
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // 1
        Database.database().reference().child("users").child(self.recipientID).updateChildValues(["unreadMessages": true])
        Database.database().reference().child("users").child(self.recipientID).child("unreadMessages").removeValue()
        var itemKey = String()
        var itemRef = DatabaseReference()
        //if newMessage == true {
            itemRef = messageRef.childByAutoId()
            itemKey = itemRef.key
        //} else {
          //  itemRef = messageRef.child(self.recipientID)
            //itemKey = self.recipientID
       // }
            
            // 2
        var now = Date()
        print("tDate:\(now)")
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        var stringDate = dateFormatter.string(from: now)
        print("tString: \(stringDate)")
        Database.database().reference().child("users").child(self.recipientID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var rName = (snapshot.value as! [String:Any])["realName"]
            
            let messageItem = [
                "senderId": Auth.auth().currentUser!.uid,
                "senderName": self.myName,
                "text": text!,
                "timeStamp": stringDate,
                "receiverName": rName
                ]
            
            // 3
        
       
        Database.database().reference().child("users").child(self.recipientID).child("messages").child(Auth.auth().currentUser!.uid).child(itemKey).setValue(messageItem)
            Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("messages").child(self.recipientID).child(itemKey).setValue(messageItem)
            
            // 4
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            
            // 5
            self.finishSendingMessage()
            self.isTyping = false
        })
    }
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": Auth.auth().currentUser!.uid,
            "senderName": self.myName
        ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    var userID = String()
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    // MARK: UI and User Interaction
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: gmRed)
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    // MARK: UITextViewDelegate methods
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
}

// MARK: Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        // 1
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            // Handle picking a Photo from the Photo Library
            // 2
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            // 3
            if let key = sendPhotoMessage() {
                // 4
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                    // 5
                    let path = "\(String(describing: Auth.auth().currentUser?.uid))/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    
                    // 6
                    self.storageRef.child(path).putFile(from: imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        // 7
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        } else {
            // Handle picking a Photo from the Camera - TODO
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}
