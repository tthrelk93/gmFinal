//
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import SwiftOverlays
import UserNotifications
//import FirebaseMessaging
import FirebaseStorage

class LoginRegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MessagingDelegate {
    @IBOutlet weak var logoSpinPosition2: UIImageView!
    var ogSignInPos = CGRect()
    var ogForgotLabelPos = CGRect()
    var ogForgotButtonPos = CGRect()
    var ogFirstNamePos = CGRect()
    var ogLastNamePos = CGRect()
    var ogUserNamePos = CGRect()
    
    @IBOutlet weak var logoSpinner: UIImageView!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var CAForgotTextPosition: UIView!
    
    @IBOutlet weak var CAFirstNamePosition: UIView!
    @IBOutlet weak var CAForgotButtonPosition: UIView!
    
    @IBOutlet weak var CASignInPosition: UIView!
    
    @IBOutlet weak var CAUserNamePosition: UIView!
    
    @IBOutlet weak var createAccountView: UIView!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var CAPasswordPosition: UIView!
    @IBOutlet weak var CAEmailPosition: UIView!
    var crypt = String()
    var user = User()
    var emailVerificationSent = false
    var profPicked = false
    @IBAction func signInButtonPressed(_ sender: Any) {
        Database.database().reference().child("usernames").observeSingleEvent(of: .value, with: {(snapshot) in
            self.signInButton.setTitleColor(self.gmRed, for: .selected)
            print(self.logRegIndex)
            if self.signInButton.titleLabel?.text == "Send Password Reset"{
                Auth.auth().sendPasswordReset(withEmail: self.userNameTextField.text!) { error in
                // Your code here
                
            }
        } else {
                if self.logRegIndex == 1 {
                if self.uNameTextField.hasText == true && self.userNameTextField.hasText == true && self.confirmEmailTextField.hasText == true &&  self.passwordTextField.hasText == true && self.confirmPasswordTextField.hasText == true && self.firstNameTextField.hasText && self.lastNameTextField.hasText {
                    if self.confirmPasswordTextField.text != self.passwordTextField.text{
                        //present error passwords don't match
                        let alert = UIAlertController(title: "Password Error", message: "Passwords do not match.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                        
                        var tempDict = snapshot.value as! [String:Any]
                        print("tempDictUnames: \(tempDict)")
                        for (key, val) in tempDict {
                            if key == self.uNameTextField.text{
                                let alert = UIAlertController(title: "Username already taken", message: "Please choose a different username", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                        }
                    self.user.username = self.uNameTextField.text
                    self.user.email = self.userNameTextField.text
                    Auth.auth().createUser(withEmail: self.user.email!, password: self.passwordTextField.text!, completion: { (authResult, error) in
                        if error != nil {
                            let alert = UIAlertController(title: "Login/Register Failed", message: "Check that you entered the correct information.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                    
                        
                        self.uploadData["username"] = self.uNameTextField.text
                    self.uploadData["email"] = self.userNameTextField.text
                    let imageName = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child("profile_images").child(Auth.auth().currentUser!.uid).child("\(imageName).jpg")
                    self.uploadData["profPic"] = "profile-placeholder"
                        self.uploadData["favorited"] = ["x":"x"]
                    self.uploadData["shared"] = ["x"]
                    self.uploadData["liked"] = ["x"]
                    self.uploadData["following"] = ["x"]
                    self.uploadData["followers"] = ["x"]
                    //self.uploadData["notifications"] =
                    self.uploadData["realName"] = self.firstNameTextField.text! + " " + self.lastNameTextField.text!
                    
                    Database.database().reference().child("usernames").updateChildValues([self.uNameTextField.text!: [Auth.auth().currentUser!.uid, self.uploadData["realName"] as! String]])
                    
                    
                    Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(self.uploadData, withCompletionBlock: {(error, ref) in
                        //SwiftOverlays.showBlockingWaitOverlayWithText("Loading Feed")
                        self.performSegue(withIdentifier: "LoginToFeed", sender: self)
                        return
                    })
                    })
                    
                    
                    
                } else {
                    
                    let alert = UIAlertController(title: "Login/Register Failed", message: "Check that you entered the correct information.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                //copy done
            } else if self.logRegIndex == 0 {
                
                guard let email = self.userNameTextField.text, let password = self.passwordTextField.text
                    else{
                        // SwiftOverlays.removeAllBlockingOverlays()
                        let alert = UIAlertController(title: "Login/Register Failed", message: "Check that you entered the correct information.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                }
                
                
                
                Auth.auth().signIn(withEmail: email, password: password, completion: {
                    (authResult, error) in
                    
                    if error != nil{
                        // SwiftOverlays.removeAllBlockingOverlays()
                        let alert = UIAlertController(title: "Login/Register Failed", message: "Check that you entered the correct information.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        return
                    }
                    else{
                        // self.user = (user?.uid)!
                        print("Successful Login")
                        var userBool = false
                         //SwiftOverlays.showBlockingWaitOverlayWithText("Loading Feed")
                        self.performSegue(withIdentifier: "LoginToFeed", sender: self)
                        
                    }
                    
                })
                
            }
            
        }
        })
    }
    var verificationTimer : Timer = Timer()    // Timer's  Global declaration
    var uploadData = [String:Any]()
    @objc func checkIfTheEmailIsVerified(){
        
        Auth.auth().currentUser?.reload(completion: { (err) in
            if err == nil{
                
                if Auth.auth().currentUser!.isEmailVerified{
                    
                    
                    self.verificationTimer.invalidate()     //Kill the timer
                    
                    
                    
                    //start
                    let imageName = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child("profile_images").child(Auth.auth().currentUser!.uid).child("\(imageName).jpg")
                    
                    
                    /*let profileImage = self.profPicImageView.image
                    let uploadData = UIImageJPEGRepresentation(profileImage!, 0.1)
                    storageRef.putData(uploadData!, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            print(error as Any)
                            return
                        }
                        
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                            
                            self.uploadData["profPic"] = profileImageUrl
                            
                            //values["location"] = self.locDict
                            
                            //done
 */
                    
                    self.uploadData["profPic"] = "profile-placeholder"
                    self.uploadData["favorited"] = ["x":"x"]
                    self.uploadData["shared"] = ["x"]
                    self.uploadData["liked"] = ["x"]
                    self.uploadData["following"] = ["x"]
                    self.uploadData["followers"] = ["x"]
                    //self.uploadData["notifications"] = 
                    self.uploadData["realName"] = self.firstNameTextField.text! + " " + self.lastNameTextField.text!
                    
                    Database.database().reference().child("usernames").updateChildValues([self.uNameTextField.text!: Auth.auth().currentUser!.uid])
                    
                    
                            Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(self.uploadData, withCompletionBlock: {(error, ref) in
                                 //SwiftOverlays.showBlockingWaitOverlayWithText("Loading Feed")
                                self.performSegue(withIdentifier: "LoginToFeed", sender: self)
                                return
                            })
                       // }
                   // })
                    
                    
                } else {
                    
                    print("It aint verified yet")
                    
                }
            } else {
                
                print(err?.localizedDescription)
                
            }
        })
        
        
    }
    let picker = UIImagePickerController()
    @IBOutlet weak var profPicLabel: UILabel!
    @IBAction func selectProfPicPressed(_ sender: Any) {
        
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    @IBOutlet weak var thirdImageView: UIImageView!
    
    @IBOutlet weak var whiteLineForUName: UIView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var forgotLabel: UILabel!
    @IBOutlet weak var profPicImageView: UIImageView!
    @IBOutlet weak var selectProfPicView: UIView!
    var logRegIndex = 0
    @IBAction func signUpButtonPressed(_ sender: Any) {
        if logRegIndex == 0{
            logRegIndex = 1
            UIView.animate(withDuration: 0.5, animations: {
                self.forgotPasswordButton.isHidden = true
                self.userNameTextField.frame = self.CAEmailPosition.frame
                
                self.passwordTextField.frame = self.CAPasswordPosition.frame
                self.uNameTextField.frame = self.CAUserNamePos.frame
                self.uNameTextField.bounds = self.CAUserNamePos.frame
                self.uNameTextField.layer.frame = self.CAUserNamePos.frame
                self.uNameTextField.layer.bounds = self.CAUserNamePos.frame
                self.firstNameTextField.isHidden = false
                self.firstNameTextField.frame = self.CAFirstNamePosition.frame
                self.signInButton.frame = self.CASignInPosition.frame
                self.lastNameTextField.isHidden = false
                self.forgotLabel.isHidden = true
                self.forgotPasswordButton.isHidden = true
                self.uNameTextField.isHidden = false
                self.selectProfPicView.isHidden = true
               
                
                //self.logo.isHidden = true
                
                self.signUpButton.setTitle("Back", for: .normal)
                self.signInButton.setTitle("Sign Up", for: .normal)
                
                self.whiteLineForUName.isHidden = false
            }, completion: {(error) in
                
                self.confirmPasswordTextField.isHidden = false
                self.confirmEmailTextField.isHidden = false
            })
        } else {
            logRegIndex = 0
            UIView.animate(withDuration: 0.5, animations: {
                
                self.forgotPasswordButton.isHidden = false
                self.userNameTextField.frame = self.OGEmailPosition
                
                self.uNameTextField.frame = self.OGUNamePosition
                self.uNameTextField.bounds = self.OGUNamePosition
                self.uNameTextField.layer.frame = self.OGUNamePosition
                self.uNameTextField.layer.bounds = self.OGUNamePosition
                self.confirmEmailTextField.isHidden = true
                self.passwordTextField.frame = self.OGPasswordPosition
                self.firstNameTextField.isHidden = true
                self.firstNameTextField.frame = self.ogFirstNamePos
                self.signInButton.frame = self.ogSignInPos
                self.lastNameTextField.isHidden = true
                self.forgotLabel.isHidden = false
                self.forgotPasswordButton.isHidden = false
                self.confirmPasswordTextField.isHidden = true
                self.uNameTextField.isHidden = true
                self.signUpButton.setTitle("Don't have an account? Sign Up!", for: .normal)
                self.signInButton.titleLabel?.text = "Sign In"
                self.selectProfPicView.isHidden = true
               // self.logo.isHidden = false
                self.whiteLineForUName.isHidden = true
                
            }, completion: nil)
        }
    }
    
    @IBOutlet weak var CAUserNamePos: UIView!
    @IBOutlet weak var keepMeLoggedIn: UISwitch!
    
    @IBOutlet weak var passResetLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var notSignedUpLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        if forgotPasswordButton.titleLabel?.text == "Back"{
            UIView.animate(withDuration: 0.5, animations: {
                self.signUpButton.isHidden = false
                
                self.userNameTextField.frame = self.OGEmailPosition
                self.passwordTextField.frame = self.OGPasswordPosition
                self.passResetLabel.isHidden = true
                self.userNameTextField.isHidden = false
                self.passwordTextField.isHidden = false
                self.confirmEmailTextField.isHidden = true
                self.confirmPasswordTextField.isHidden = true
                self.signInButton.setTitle("Sign In", for: .normal)
                self.forgotPasswordButton.setTitle("Forgot Password", for: .normal)
            })
            
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.signUpButton.isHidden = true
                self.userNameTextField.frame = self.OGEmailPosition
                self.passwordTextField.frame = self.OGPasswordPosition
                self.passResetLabel.isHidden = false
                self.userNameTextField.isHidden = false
                self.passwordTextField.isHidden = true
                self.confirmEmailTextField.isHidden = true
                self.confirmPasswordTextField.isHidden = true
                self.uNameTextField.isHidden = true
                self.signInButton.setTitle("Send Password Reset", for: .normal)
                self.forgotPasswordButton.setTitle("Back", for: .normal)
            })
            
            
        }
    }
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var firstImageView: UIImageView!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var uNameTextField: UITextField!
    
    @IBOutlet weak var secondImageView: UIImageView!
    
    var isListening = false
    var OGEmailPosition = CGRect()
    var OGPasswordPosition = CGRect()
    var OGUNamePosition = CGRect()
    var images = [UIImage]()
    var currentImageindex = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        signInButton.isEnabled = false
        userNameTextField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 30,height: self.userNameTextField.frame.height))
        userNameTextField.leftViewMode = UITextFieldViewMode.always
        
        passwordTextField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 30,height: self.passwordTextField.frame.height))
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        
        uNameTextField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 30,height: self.uNameTextField.frame.height))
        uNameTextField.leftViewMode = UITextFieldViewMode.always
        
        confirmEmailTextField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 30,height: self.confirmEmailTextField.frame.height))
        confirmEmailTextField.leftViewMode = UITextFieldViewMode.always
        
        confirmPasswordTextField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 30,height: self.confirmPasswordTextField.frame.height))
        confirmPasswordTextField.leftViewMode = UITextFieldViewMode.always
        
        firstNameTextField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 30,height: self.firstNameTextField.frame.height))
        firstNameTextField.leftViewMode = UITextFieldViewMode.always
        
        lastNameTextField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 30,height: self.lastNameTextField.frame.height))
        lastNameTextField.leftViewMode = UITextFieldViewMode.always
        
        
        
        signInButton.layer.cornerRadius = 6
        signInButton.layer.masksToBounds = false
        profPicImageView.layer.cornerRadius = profPicImageView.frame.width/2
        picker.delegate = self
        profPicLabel.layer.cornerRadius = profPicLabel.layer.frame.width/2
        confirmPasswordTextField.delegate = self
        confirmEmailTextField.delegate = self
        uNameTextField.delegate = self
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        var userBool = false
        OGEmailPosition = userNameTextField.frame
        OGUNamePosition = uNameTextField.frame
        OGPasswordPosition = passwordTextField.frame
        ogFirstNamePos = firstNameTextField.frame
        ogLastNamePos = lastNameTextField.frame
        ogForgotLabelPos = forgotLabel.frame
        ogForgotButtonPos = forgotPasswordButton.frame
        ogSignInPos = signInButton.frame
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.groupTableViewBackground.cgColor
        border.frame = CGRect(x: 0, y: userNameTextField.frame.size.height - width, width: userNameTextField.frame.size.width, height: userNameTextField.frame.size.height)
        
        border.borderWidth = width
        userNameTextField.layer.addSublayer(border)
        
        userNameTextField.layer.masksToBounds = true
        
        //tf2
        let border2 = CALayer()
        let width2 = CGFloat(1.0)
        border2.borderColor = UIColor.groupTableViewBackground.cgColor
        border2.frame = CGRect(x: 0, y: passwordTextField.frame.size.height - width2, width: passwordTextField.frame.size.width, height: passwordTextField.frame.size.height)
        
        border2.borderWidth = width2
        passwordTextField.layer.addSublayer(border2)
        
        passwordTextField.layer.masksToBounds = true
        
        //tf3
        let border3 = CALayer()
        let width3 = CGFloat(1.0)
        border3.borderColor = UIColor.groupTableViewBackground.cgColor
        border3.frame = CGRect(x: 0, y: confirmEmailTextField.frame.size.height - width3, width: confirmEmailTextField.frame.size.width, height: confirmEmailTextField.frame.size.height)
        
        border3.borderWidth = width3
        confirmEmailTextField.layer.addSublayer(border3)
        
        confirmEmailTextField.layer.masksToBounds = true
        
        //tf4
        let border4 = CALayer()
        let width4 = CGFloat(1.0)
        border4.borderColor = UIColor.groupTableViewBackground.cgColor
        border4.frame = CGRect(x: 0, y: confirmPasswordTextField.frame.size.height - width4, width: confirmPasswordTextField.frame.size.width, height: confirmPasswordTextField.frame.size.height)
        
        border4.borderWidth = width4
        confirmPasswordTextField.layer.addSublayer(border4)
        
        confirmPasswordTextField.layer.masksToBounds = true
        
        //tf5
         let border5 = CALayer()
         let width5 = CGFloat(1.0)
         border5.borderColor = UIColor.groupTableViewBackground.cgColor
         border5.frame = CGRect(x: 0, y: firstNameTextField.frame.size.height - width5, width: firstNameTextField.frame.size.width, height: firstNameTextField.frame.size.height)
         
         border5.borderWidth = width5
         firstNameTextField.layer.addSublayer(border5)
         
         firstNameTextField.layer.masksToBounds = true
        
        let border6 = CALayer()
        let width6 = CGFloat(1.0)
        border6.borderColor = UIColor.groupTableViewBackground.cgColor
        border6.frame = CGRect(x: 0, y: lastNameTextField.frame.size.height - width6, width: lastNameTextField.frame.size.width, height: lastNameTextField.frame.size.height)
        
        border6.borderWidth = width6
        lastNameTextField.layer.addSublayer(border6)
        
        lastNameTextField.layer.masksToBounds = true
        
        
        var isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if(isRegisteredForRemoteNotifications == false){
            print("registeredForRemote = false")
            if #available(iOS 10, *) {
                UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
                UIApplication.shared.registerForRemoteNotifications()
            }
                // iOS 9 support
            else if #available(iOS 9, *) {
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
                UIApplication.shared.registerForRemoteNotifications()
            }
                // iOS 8 support
            else if #available(iOS 8, *) {
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
                UIApplication.shared.registerForRemoteNotifications()
            }
                // iOS 7 support
            else {
                print("registeringForRemote")
                UIApplication.shared.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
            }
            
            
            
        } else {
            isListening = true
            print("in some else")
            handle = Auth.auth().addStateDidChangeListener { auth, user in
                if let user = user {
                    self.authUser = user.uid
                    Messaging.messaging().delegate = self
                    self.authUser = user.uid
                    Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            for snap in snapshots{
                                if snap.key == Auth.auth().currentUser?.uid{
                                    userBool = true
                                }
                            }
                        }
                        
                        if userBool{
                            /*Auth.auth().currentUser?.delete(completion: { (error) in
                             if error != nil {
                             print("Error unable to delete user")
                             
                             }
                             })*/
                            
                        } else {
                           // self.performSegue(withIdentifier: "LoginToFeed", sender: self)
                        }
                    })
                    
                } else {
                    // No user is signed in.
                    //Auth.auth().removeStateDidChangeListener(<#T##listenerHandle: AuthStateDidChangeListenerHandle##AuthStateDidChangeListenerHandle#>)
                }
            }
            
            
        }
        
        //images.append(UIImage(named: "pexels-photo-241456.png")!)
        
        //firstImageView.image = images[0]
        print("hereee")
        UIView.animate(withDuration: 1.0, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat], animations: {
            //self.firstImageView.image = self.images[self.currentImageindex]
            // self.currentImageindex = (self.currentImageindex + 1) % self.images.count
            
        }, completion: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /*firstImageView.frame = view.frame
         secondImageView.frame = view.frame*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Auth: \(Auth.auth().currentUser?.uid)")

        if Auth.auth().currentUser != nil {
            // User is signed in.
            // ...
            //SwiftOverlays.showBlockingWaitOverlayWithText("Loading Feed")
            self.performSegue(withIdentifier: "LoginToFeed", sender: self)
            //print(Auth.auth().currentUser!.uid)
            //try! Auth.auth().signOut()
            //print("dfgdfg")
            //print(Auth.auth().currentUser!.uid)
            
            
        } else {
            // No user is signed in.
            // ...
             animateImageViews()
        }
        
       
    }
    
    func animateImageViews() {
        
        
    }
    
    
    
    
    
    
    
    //userNameTextField.color
    // Do any additional setup after loading the view.
    var gmRed = UIColor(red: 237/255, green: 28/255, blue: 39/255, alpha: 1.0)
    override func viewWillAppear(_ animated: Bool) {
        //self.signInButton.layer.borderColor = (UIColor.lightGray.withAlphaComponent(0.6)).cgColor
        
        //self.signInButton.layer.borderWidth = 2
    }
    var authUser = String()
    override func viewWillDisappear(_ animated: Bool) {
        if isListening == true{
            Auth.auth().removeStateDidChangeListener(handle!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        print("didBegin")
        signInButton.setTitleColor(UIColor.lightGray, for: .normal)
        if userNameTextField.hasText && passwordTextField.hasText{
            signInButton.isEnabled = true
            signInButton.setTitleColor(gmRed, for: .normal)
            print("bothHaveText")
        } else {
            print("missingtext")
            signInButton.isEnabled = true
            signInButton.setTitleColor(UIColor.lightGray, for: .normal)
        }
    }
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        
        return false
    }
    //public func textFieldDid
    
    @IBAction func emailTFEditing(_ sender: Any) {
        
    }
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        /*if textField == passwordTextField{
         if userNameTextField.hasText {
         signInButton.setTitleColor(gmRed, for: .normal)
         } else {
         signInButton.setTitleColor(UIColor.lightGray, for: .normal)
         }
         } else {
         if passwordTextField.hasText {
         signInButton.setTitleColor(gmRed, for: .normal)
         } else {
         signInButton.setTitleColor(UIColor.lightGray, for: .normal)
         }
         }*/
    }
    
    /*func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
     print("Firebase registration token: \(fcmToken)")
     var tokenDict = [String: Any]()
     
     
     tokenDict["deviceToken"] = [fcmToken: true] as [String: Any]?
     Database.database().reference().child("users").child(self.authUser).updateChildValues(tokenDict)
     
     // TODO: If necessary send token to application server.
     // Note: This callback is fired at each app startup and whenever a new token is generated.
     }*/
    
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginToFeed"{
            if let vc = segue.destination as? HomeFeedViewController {
                
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    
    
    @IBOutlet weak var selectProfPicButton: UIButton!
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("hey thereee")
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            print("si: \(selectedImage)")
            profPicImageView.image = selectedImage
            self.profPicked = true
            //selectProfPicButton.setImage(selectedImage, for: .normal)
            //userPic.isHidden = true
            //selectProfilePic.setBackgroundImage(selectedImage, for: .normal)
            
            //profileImageViewButton.set
            // profileImageView.image = selectedImage
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        var tokenDict = [String: Any]()
        
        
        tokenDict["deviceToken"] = [fcmToken: true] as [String: Any]?
        Database.database().reference().child("users").child(self.authUser).updateChildValues(tokenDict)
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    
    
    
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    /*
     override func textRect(forBounds bounds: CGRect) -> CGRect {
     
     return bounds.insetBy(dx: 10, dy: 10)
     }*/
    // placeholder position
    
    
    
    
}
