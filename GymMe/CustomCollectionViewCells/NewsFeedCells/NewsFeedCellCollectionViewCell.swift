import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol PerformActionsInFeedDelegate {
    
    func performSegueToPosterProfile(uid: String, name: String)
    func showLikedByViewTextCell(sentBy: String, cell: NewsFeedCellCollectionViewCell)
     func showLikedByViewPicCell(sentBy: String, cell: NewsFeedPicCollectionViewCell)
    func reloadDataAfterLike()
    
    
}

class NewsFeedCellCollectionViewCell: UICollectionViewCell {
    var myRealName: String?
    var myPicString: String?
   
    
    @IBOutlet weak var timeStambLabel: UILabel!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    var delegate: PerformActionsInFeedDelegate?
    var posterUID: String?
    var curName: String?
    var cellIndexPath: IndexPath?
    var postID: String?
    var posterName: String?
    
    @IBOutlet weak var shareButton: UIButton!
    @IBAction func shareButtonPressed(_ sender: Any) {
    }
    @IBAction func commentsCountButtonPressed(_ sender: Any) {
        delegate?.showLikedByViewTextCell(sentBy: "showComments", cell: self)
    }
    @IBOutlet weak var commentsCountButton: UIButton!
    @IBAction func commentButtonPressed(_ sender: Any) {
        delegate?.showLikedByViewTextCell(sentBy: "showComments", cell: self)
    }
    @IBOutlet weak var commentButton: UIButton!
    
    
    @IBAction func favoritesCountButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var favoritesCountButton: UIButton!
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        print("here000")
        print("df: \(self.favoritesButton.currentBackgroundImage)")
        if self.favoritesButton.currentBackgroundImage == UIImage(named: "favoritesUnfilled.png"){
            self.favoritesButton.setBackgroundImage(UIImage(named:"favoritesFilled.png"), for: .normal)
            print("here111")
            Database.database().reference().child("posts").child(self.postID!).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                var favesArray = valDict["favorites"] as! [[String:Any]]
                if favesArray.count == 1 && (favesArray.first! as! [String:String]) == ["x": "x"]{
                    favesArray.remove(at: 0)
                }
                var favesVal = favesArray.count
                favesVal = favesVal + 1
                favesArray.append(["uName": self.myUName!, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": self.myPicString])
                
                
                Database.database().reference().child("posts").child(self.postID!).child("favorites").setValue(favesArray)
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").observeSingleEvent(of: .value, with: { (snapshot) in
                    print("snapshotttt: \(snapshot.value as! [String])")
                    var favs = snapshot.value as! [String]
                    if favs.count == 1 && favs[0] == "x"{
                        favs.remove(at: 0)
                        
                        favs.append(self.postID!)
                    } else {
                        favs.append(self.postID!)
                    }
                    Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(["favorited":favs])
                    
                    
                    
                })
                self.favoritesCountButton.setTitle(String(favesArray.count), for: .normal)
            })
            
            
            
        } else {
            self.favoritesButton.setBackgroundImage(UIImage(named:"favoritesUnfilled.png"), for: .normal)
            
            
            Database.database().reference().child("posts").child(self.postID!).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                var favesVal = Int()
                var favesArray = valDict["favorites"] as! [[String: Any]]
                if favesArray.count == 1 {
                    favesArray.remove(at: 0)
                    favesArray.append(["x": "x"])
                    favesVal = 0
                    self.favoritesCountButton.setTitle("0", for: .normal)
                } else {
                    favesVal = favesArray.count
                    //favesArray.remove(at: favesArray.index(of: ))
                    self.favoritesCountButton.setTitle(String(favesArray.count), for: .normal)
                }
                
                
                Database.database().reference().child("posts").child(self.postID!).child("favorites").setValue(favesArray)
                //var uploadDictForUser =
                Database.database().reference().child("users").child(self.posterUID!).child("posts").child(self.postID!).child("favorites").setValue(favesArray)
                
               Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("favorited").observeSingleEvent(of: .value, with: { (snapshot) in
                print("snapshot: \(snapshot.value as! [String])")
                var favs = snapshot.value as! [String]
                    if favs.count == 1 && favs[0] != "x"{
                        favs.remove(at: 0)

                        favs.append("x")
                    } else {
                        
                        if favs.count == 1 && favs[0] == "x" {
                            favs.append(self.postID!)
                            favs.remove(at: favs.index(of: "x")!)
                        } else if favs.count >= 1{
                            favs.remove(at: favs.index(of: self.postID!)!)
                        }
                        
                }
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(["favorited":favs])
                
                self.favoritesCountButton.setTitle(String(favesArray.count), for: .normal)
                
               })
                
                
                
            })
        }
    }
    @IBOutlet weak var favoritesButton: UIButton!
    
    
    @IBAction func likesCountButtonPressed(_ sender: Any) {
        //self.delegate?.reloadDataAfterLike()
        delegate?.showLikedByViewTextCell(sentBy: "likedBy", cell: self)
        
        
    }
    @IBOutlet weak var likesCountButton: UIButton!
    var myUName: String?
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        if self.likeButton.imageView?.image == UIImage(named: "like.png"){
            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
            // let curLikes = Int((self.likesCountButton.titleLabel?.text)!)
            //self.likesCountButton.setTitle(String(curLikes! + 1), for: .normal)
            Database.database().reference().child("posts").child(self.postID!).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                
                var likesArray = valDict["likes"] as! [[String:Any]]
                if likesArray.count == 1 && (likesArray.first! as! [String:String]) == ["x": "x"]{
                    likesArray.remove(at: 0)
                }
                var likesVal = likesArray.count
                likesVal = likesVal + 1
                if self.myPicString == nil{
                    self.myPicString = "profile-placeholder"
                }
                likesArray.append(["uName": self.myUName!, "realName": self.myRealName, "uid": Auth.auth().currentUser!.uid, "pic": self.myPicString])
                
                
                Database.database().reference().child("posts").child(self.postID!).child("likes").setValue(likesArray)
                Database.database().reference().child("users").child(self.posterUID!).child("posts").child(self.postID!).child("likes").setValue(likesArray)
                self.likesCountButton.setTitle(String(likesArray.count), for: .normal)
                //reload collect in delegate
                
            })
            
            //update Database for post with new like count
            
        } else {
            self.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
            
            Database.database().reference().child("posts").child(self.postID!).observeSingleEvent(of: .value, with: { snapshot in
                let valDict = snapshot.value as! [String:Any]
                var likesVal = Int()
                var likesArray = valDict["likes"] as! [[String: Any]]
                if likesArray.count == 1 {
                    likesArray.remove(at: 0)
                    likesArray.append(["x": "x"])
                    likesVal = 0
                    self.likesCountButton.setTitle("0", for: .normal)
                } else {
                    likesArray.remove(at: 0)
                    likesVal = likesArray.count
                    self.likesCountButton.setTitle(String(likesArray.count), for: .normal)
                }
                
                
                Database.database().reference().child("posts").child(self.postID!).child("likes").setValue(likesArray)
                
                
                Database.database().reference().child("users").child(self.posterUID!).child("posts").child(self.postID!).child("likes").setValue(likesArray)
                
            })
            
        }
        DispatchQueue.main.async {
            self.delegate?.reloadDataAfterLike()
        }
    }
    
    @IBAction func profPicButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var profImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postLocationButton: UIButton!
    @IBOutlet weak var posterNameButton: UIButton!
    @IBAction func goToPosterPressed(_ sender: Any) {
        //perform segue in feed using custom delegate method
        delegate?.performSegueToPosterProfile(uid: self.posterUID!, name: (self.posterNameButton.titleLabel?.text)!)
        
    }
    @IBOutlet weak var goToPosterProfile: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profImageView.layer.cornerRadius = self.profImageView.frame.width/2
        self.profImageView.layer.masksToBounds = true
        
        print(self.gestureRecognizers)
        // Initialization code
    }
    
}