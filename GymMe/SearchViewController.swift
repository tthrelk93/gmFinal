//
//  SearchViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 6/21/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit
var gmRed = UIColor(red: 180/255, green: 29/255, blue: 2/255, alpha: 1.0)
class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var categoriesCollect: UICollectionView!
    @IBAction func topBarSearchPressed(_ sender: Any) {
    }
    @IBOutlet weak var topBarSearchButton: UIButton!
    
    @IBOutlet weak var topBarCat: UIButton!
    
    @IBAction func topBarCatPressed(_ sender: Any) {
        topBarCat.setTitleColor(gmRed, for: .normal)
        topBarPop.setTitleColor(UIColor.black, for: .normal)
        topBarNearby.setTitleColor(UIColor.black, for: .normal)
        categoriesCollect.isHidden = false
        
        border1.isHidden = false
        border2.isHidden = true
        border3.isHidden = true
        popCollect.isHidden = true
    }
    
    @IBOutlet weak var topBarPop: UIButton!
    
    @IBAction func topBarPopPressed(_ sender: Any) {
        topBarCat.setTitleColor(UIColor.black, for: .normal)
        topBarPop.setTitleColor(gmRed, for: .normal)
        topBarNearby.setTitleColor(UIColor.black, for: .normal)
        categoriesCollect.isHidden = true
        border1.isHidden = true
        border2.isHidden = false
        border3.isHidden = true
        popCollect.isHidden = false
        
        
    }
    
    @IBOutlet weak var topBarNearby: UIButton!
    
    @IBAction func topBarNearbyPressed(_ sender: Any) {
        topBarCat.setTitleColor(UIColor.black, for: .normal)
        topBarPop.setTitleColor(UIColor.black, for: .normal)
        topBarNearby.setTitleColor(gmRed, for: .normal)
        categoriesCollect.isHidden = true
        border1.isHidden = true
        border2.isHidden = true
        border3.isHidden = false
        popCollect.isHidden = true
    }
    var catCollectPics = ["bodybuilding-motivation-tips-part-2","dd3c303d81d5301e3c427f897bf5bd2e","thumb-1920-426586","bodybuilding-motivation-tips-part-2", "images-1", "images","thumb-1920-426586","bodybuilding-motivation-tips-part-2"]
    var catCollectData = ["Arms","Chest","Abs","Legs","Back", "Shoulders","Other"]
     //let border = CALayer()
     //let border2 = CALayer()
     //let border3 = CALayer()
    @IBOutlet weak var border3: UIView!
    
    @IBOutlet weak var border2: UIView!
    
    @IBOutlet weak var popCollect: UICollectionView!
    @IBOutlet weak var border1: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        self.popCollect.register(UINib(nibName: "PopCell", bundle: nil), forCellWithReuseIdentifier: "PopCell")
       
        border1.isHidden = false
        border2.isHidden = true
        border3.isHidden = true
        
        tabBar.delegate = self
        categoriesCollect.delegate = self
        categoriesCollect.dataSource = self
        
        popCollect.delegate = self
        popCollect.dataSource = self
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        layout.itemSize = CGSize(width: screenWidth/2.035, height: screenWidth/2.035)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 1
        categoriesCollect!.collectionViewLayout = layout
        
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout2.sectionInset = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        layout2.itemSize = CGSize(width: screenWidth/3.045, height: screenWidth/3.045)
        layout2.minimumInteritemSpacing = 0
        layout2.minimumLineSpacing = 1
        popCollect!.collectionViewLayout = layout2
        popCollect.isHidden = true
        
        tabBar.selectedItem = tabBar.items?[1]
        topBarCat.setTitleColor(gmRed, for: .normal)
        topBarPop.setTitleColor(UIColor.black, for: .normal)
        topBarNearby.setTitleColor(UIColor.black, for: .normal)
        categoriesCollect.isHidden = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items![0]{
            performSegue(withIdentifier: "SearchToFeed", sender: self)
        } else if item == tabBar.items![2]{
            performSegue(withIdentifier: "SearchToPost", sender: self)
        } else if item == tabBar.items![3]{
            //performSegue(withIdentifier: "SearchToNotifications", sender: self)
        } else if item == tabBar.items![4]{
            performSegue(withIdentifier: "SearchToProfile", sender: self)
        } else {
            //curScreen
        }
        
    }
    var popCollectData = [PopCell]()
    @IBOutlet weak var feedCollect: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollect{
            return catCollectData.count
        } else {
            return 24//popCollectData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("hey")
        if collectionView == categoriesCollect{
        
        let cell : UICollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "CatCell", for: indexPath) as! CatCell)
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        (cell as! CatCell).catCellLabel.text = catCollectData[indexPath.row]
        (cell as! CatCell).catCellImageView.image = UIImage(named: catCollectPics[indexPath.row])
        
        
            return cell
        } else {
            let cell : UICollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "PopCell", for: indexPath) as! PopCell)
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.cgColor
            //(cell as! PopCell).catCellLabel.text = catCollectData[indexPath.row]
            //(cell as! CatCell).catCellImageView.image = UIImage(named: catCollectPics[indexPath.row])
            return cell
            
        }
        
        
    }
    
    /*public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("here")
        let width = collectionView.frame.width/2.21006471
        let height = collectionView.frame.width/2.21006471
            
            return CGSize(width: width, height: height)
        
    }*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
