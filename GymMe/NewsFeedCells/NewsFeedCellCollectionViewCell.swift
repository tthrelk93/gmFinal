import UIKit

protocol PerformActionsInFeedDelegate {
    
    func performSegueToPosterProfile(uid: String, name: String)
    
}

class NewsFeedCellCollectionViewCell: UICollectionViewCell {
    
    @IBAction func tapGestureRec(_ sender: Any) {
        print("liked")
        //if not liked
        self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
        //else {self.likeButton.setImage(UIImage(named:"like.png"), for: .normal)}
        
        
    }
    
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    var delegate: PerformActionsInFeedDelegate?
    var posterUID: String?
    var curName: String?
    var cellIndexPath: IndexPath?
    @IBAction func shareButtonPressed(_ sender: Any) {
    }
    @IBAction func commentsCountButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var commentsCountButton: UIButton!
    @IBAction func commentButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var commentButton: UIButton!
    
    
    @IBAction func favoritesCountButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var favoritesCountButton: UIButton!
    @IBAction func favoritesButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var favoritesButton: UIButton!
    
    
    @IBAction func likesCountButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var likesCountButton: UIButton!
    @IBAction func likeButtonPressed(_ sender: Any) {
        if self.likeButton.imageView?.image == UIImage(named: "like.png"){
            self.likeButton.setImage(UIImage(named:"likeSelected.png"), for: .normal)
            let curLikes = Int((self.likesCountButton.titleLabel?.text)!)
            self.likesCountButton.setTitle(String(curLikes! + 1), for: .normal)
            
            //update Database for post with new like count
            
        } else {
            self.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
            
            let curLikes = Int((self.likesCountButton.titleLabel?.text)!)
            self.likesCountButton.setTitle(String(curLikes! - 1), for: .normal)
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
