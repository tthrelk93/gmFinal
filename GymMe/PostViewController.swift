//
//  PostViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 6/23/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class PostViewController: UIViewController, UITabBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var postText: UIView!
    @IBOutlet weak var postPic: UIView!
    
    @IBOutlet weak var picVidButton: UIButton!
    @IBOutlet weak var picVidSmallFrame: UIView!
    @IBOutlet weak var addPicButton: UIButton!
    @IBAction func addPicTouched(_ sender: AnyObject) {
        currentPicker = "photo"
        imagePicker.allowsEditing = true
        //imagePicker.mediaTypes = ["kUTTypeImage"] //[.kUTTypeImage as String]
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    var extended = false
    @IBOutlet weak var picButtonPositionOut: UIView!
    @IBAction func picVidPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            if self.extended == false {
            self.addPicButton.frame = self.picButtonPositionOut.frame
            self.addVidButton.frame = self.vidButtonPositionOut.frame
            self.picVidButton.frame = self.picVidSmallFrame.frame
                self.extended = true
            } else {
                self.addPicButton.frame = self.ogPicPosit
                self.addVidButton.frame = self.ogVidPosit
                self.picVidButton.frame = self.ogPicVidPosit
                self.extended = false
            }
            
        })
    }
    var ogVidPosit = CGRect()
    var ogPicPosit = CGRect()
    var ogPicVidPosit = CGRect()
    var currentPicker = String()
    let picker = UIImagePickerController()
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var addVidButton: UIButton!
    
    @IBOutlet weak var vidButtonPositionOut: UIView!
    @IBAction func chooseVidFromPhoneSelected(_ sender: AnyObject) {
        currentPicker = "vid"
        picker.mediaTypes = ["public.movie"]
        
        present(picker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        imagePicker.delegate = self
        ogVidPosit = addVidButton.frame
        ogPicPosit = addPicButton.frame
        ogPicVidPosit = picVidButton.frame
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?[2]
        postPic.layer.cornerRadius = 15
        postText.layer.cornerRadius = 15

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items![0]{
            performSegue(withIdentifier: "PostToFeed", sender: self)
        } else if item == tabBar.items![1]{
            performSegue(withIdentifier: "PostToSearch", sender: self)
        } else if item == tabBar.items![2]{
            //performSegue(withIdentifier: "", sender: self)
        } else if item == tabBar.items![3]{
            //performSegue(withIdentifier: "FeedToNote", sender: self)
        } else {
            performSegue(withIdentifier: "PostToProfile", sender: self)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if currentPicker == "photo"{
            print("imagePickerSelected")
            var selectedImageFromPicker: UIImage?
            if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
                selectedImageFromPicker = editedImage
            } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                selectedImageFromPicker = originalImage
            }
            
            self.dismiss(animated: true, completion: nil)
            
        } else {
            //if senderView == "main"{
            print("vidPickerSelected")
            if let movieURL = info[UIImagePickerControllerMediaURL] as? NSURL{
                print("MOVURL: \(movieURL)")
                //print("MOVPath: \(moviePath)")
                if let data = NSData(contentsOf: movieURL as! URL){
                    //self.addedVidDataArray.append(data as Data)
                    
                }
                //movieURLFromPicker = movieURL
                dismiss(animated: true, completion: nil)
                var tempArray1 = [String]()
                /*if totalVidArray.count != 0{
                    self.currentCollectID = "vidFromPhone"
                    //self.isYoutubeCell = false
                    self.totalVidArray.append(movieURL)
                    self.vidFromPhoneCollectionView.performBatchUpdates({
                        let insertionIndexPath = IndexPath(row: self.totalVidArray.count - 1, section: 0)
                        self.vidFromPhoneCollectionView.insertItems(at: [insertionIndexPath])}, completion: nil)
                }else{
                    self.currentCollectID = "vidFromPhone"
                    self.totalVidArray.insert(movieURL, at: 0)
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                    self.vidFromPhoneCollectionView.dataSource = self
                    self.vidFromPhoneCollectionView.delegate = self
                }*/
            }
        }
        
    }
    
    
    
    
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
