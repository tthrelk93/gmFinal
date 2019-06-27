//
//  MapViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 4/15/19.
//  Copyright © 2019 Thomas Threlkeld. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Nominatim

class MapViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, ToProfileDelegate {
    func shareCirclePressed(likedByUID: String, indexPath: IndexPath) {
        
    }
    
    func segueToProf(cellUID: String, name: String) {
        print("hereghghgh")
        self.cellUID = cellUID
        self.cellName = name
        performSegue(withIdentifier: "MapToProfile", sender: self)
    }
    //var locDel: CLLocationManagerDelegate?
    var cellUID = String()
    var cellName = String()
    var mapCollectData = [[String:Any]]()
    var mapType = String()
    var myGym = String()
    var myUName = String()
    var myName = String()
    var myPic = String()
    var myCity = String()
    var myCoord = [String:Any]()
    var followersArr = [String]()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mapCollectData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cell?")
        let cell : LikedByCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedByCollectionViewCell", for: indexPath) as! LikedByCollectionViewCell
        cell.toProfileButton.isHidden = false
        var thisData = ((self.mapCollectData[indexPath.row] ).first?.value) as! [String:Any]
        var thisKey = (self.mapCollectData[indexPath.row] ).first?.key as! String
        
            DispatchQueue.main.async{
                
                if (self.followersArr.contains(((self.mapCollectData[indexPath.row] ).first?.key)!)){
                    
                    cell.likedByFollowButton.setTitle("Unfollow", for: .normal)
                    
                    cell.likedByFollowButton.layer.borderWidth = 1
                    cell.likedByFollowButton.layer.borderColor = UIColor.red.cgColor
                    cell.likedByFollowButton.backgroundColor = UIColor.white
                    cell.likedByFollowButton.setTitleColor(UIColor.red, for: .normal)
                    
                } else {
                    cell.likedByFollowButton.layer.borderWidth = 1
                    cell.likedByFollowButton.layer.borderColor = UIColor.red.cgColor
                    cell.likedByFollowButton.backgroundColor = UIColor.red
                    cell.likedByFollowButton.setTitleColor(UIColor.white, for: .normal)
                }
                cell.delegate1 = self
                cell.likedByName.isHidden = false
                cell.likedByUName.isHidden = false
                cell.likedByFollowButton.isHidden = false
                cell.commentName.isHidden = true
                cell.commentTextView.isHidden = true
                cell.commentTimestamp.isHidden = true
                cell.likedByUName.text = (thisData["username"] as! String)
                //cell.layer.borderWidth = 1
                //cell.layer.borderColor = UIColor.red.cgColor
                //cell.likedByFollowButton.backgroundColor = UIColor.white
                //cell.likedByFollowButton.setTitleColor(UIColor.red, for: .normal)
                cell.likedByUID = thisKey
                
                cell.likedByName.text = thisData["realName"] as! String
                
                if thisData["profPic"] as! String == "profile-placeholder"{
                    DispatchQueue.main.async{
                        cell.likedByImage.image = UIImage(named: "profile-placeholder")
                    }
                } else {
                    if let messageImageUrl = URL(string: thisData["profPic"] as! String) {
                        
                        if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                            DispatchQueue.main.async{
                                cell.likedByImage.image = UIImage(data: imageData as Data)
                            }
                            
                        }
                        
                        //}
                    }
                }
        }
        return cell
    }
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var backPressed = false
    @IBAction func backButtonPressed(_ sender: Any) {
        if mapType == "feed"{
            performSegue(withIdentifier: "MapToFeed", sender: self)
        } else {
        backPressed = true
        self.cellUID = Auth.auth().currentUser!.uid
        self.cellName = ""
        
        performSegue(withIdentifier: "MapToProfile", sender: self)
        }
    }
    @IBOutlet weak var mapCollect: UICollectionView!
    
    @IBOutlet weak var ogFrame: UIView!
    @IBOutlet weak var showHideCollectButton: UIButton!
    var ogButtonFrame = CGRect()
    var ogCollectFrame = CGRect()
    @IBAction func showHideCollectButtonPressed(_ sender: Any) {
        if extended == false{
            UIView.animate(withDuration: 0.5, animations: {
                self.showHideCollectButton.frame = self.ogButtonFrame
                self.mapCollect.isHidden = false
                self.mapCollect.frame = self.ogCollectFrame
                self.extended = true
                
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.showHideCollectButton.frame = self.ogFrame.frame
                
                self.mapCollect.frame = self.ogFrame.frame
                
                self.mapCollect.isHidden = true
                self.extended = false
            })
        }
    }
    var coordFromFeed: [String:Any]?
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.ogButtonFrame = showHideCollectButton.frame
        self.ogCollectFrame = mapCollect.frame
        mapCollect.frame = ogFrame.frame
        showHideCollectButton.frame = ogFrame.frame
        
        print("mapType: \(mapType), \(self.myCity)")
        mapView.delegate = self
        //self.performGoogleSearch(for: self.myCity)
        let annotation = MKPointAnnotation()
        if mapType == "feed"{
            showHideCollectButton.isHidden = true
            annotation.title = self.myCity
            var tempLoc: CLLocation?
            var lat = CLLocationDegrees(exactly: coordFromFeed!["lat"] as! Double)
            var long = CLLocationDegrees(exactly: coordFromFeed!["long"] as! Double)
            var coord = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            annotation.coordinate = coord
            let viewRegion = MKCoordinateRegionMakeWithDistance(coord, 800, 800)
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(viewRegion, animated: false)
            
           
            
           /* self.getLocation(forPlaceCalled: self.myCity) { (location) in
                
                annotation.coordinate = location!.coordinate
                let viewRegion = MKCoordinateRegionMakeWithDistance(location!.coordinate, 800, 800)
                self.mapView.addAnnotation(annotation)
                self.mapView.setRegion(viewRegion, animated: false)
                print("tempLoc: \(location)")
            }*/
            
            
            
        } else if mapType == "gym"{
            annotation.title = self.myGym
        } else {
            annotation.title = self.myCity
        }
        
        //annotation.subtitle = ""
        
        if mapType == "feed"{
            
        } else {
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(floatLiteral: myCoord["lat"] as! Double), longitude: (myCoord["long"] as! Double))
        
        mapView.addAnnotation(annotation)
        let viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: CLLocationDegrees(floatLiteral: myCoord["lat"] as! Double), longitude: (myCoord["long"] as! Double)), 800, 800)
        mapView.setRegion(viewRegion, animated: false)
        
        if mapType == "gym"{
            Database.database().reference().child("users").observeSingleEvent(of: .value, with: {(snapshot) in
                print("here: \(snapshot.value)")
                //let snapshotss = snapshot.value as? [DataSnapshot]
                print("hereNow")
                for (key, val) in (snapshot.value as! [String:Any]){
                    var userDict = val as! [String:Any]
                    if userDict["homeGym"] != nil{
                        var gym = (userDict["homeGym"] as! [Any])[0] as! String
                        print("gym:\(gym)")
                        if gym == self.myGym && key != Auth.auth().currentUser!.uid{
                            var temp = [key:val]
                            self.mapCollectData.append(temp)
                            
                        }
                    }
                }
                if self.mapCollectData.count == 1{
                    self.showHideCollectButton.setTitle("You follow \(self.mapCollectData.count) person who trains here", for: .normal)
                } else {
                    self.showHideCollectButton.setTitle("You follow \(self.mapCollectData.count) people who train here", for: .normal)
                }
                
                self.showHideCollectButton.isHidden = false
                
                print("mapCollectData: \(self.mapCollectData.count), \(self.myGym)")
                self.mapCollect.delegate = self
                self.mapCollect.dataSource = self
               
                self.mapCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
                
            })
        
        } else {
            Database.database().reference().child("users").observeSingleEvent(of: .value, with: {(snapshot) in
                print("here: \(snapshot.value)")
                //let snapshotss = snapshot.value as? [DataSnapshot]
                print("hereNow")
                for (key, val) in (snapshot.value as! [String:Any]){
                    var userDict = val as! [String:Any]
                    if (userDict["city"] as? String) != nil{
                        print("userCity: \(userDict["city"]), myCity: \(self.myCity)")
                        let city = userDict["city"] as! String
                        if city == self.myCity && key != Auth.auth().currentUser!.uid{
                            let temp = [key:val]
                            self.mapCollectData.append(temp)
                            
                        }
                    }
                }
                if self.mapCollectData.count == 1{
                    self.showHideCollectButton.setTitle("You follow \(self.mapCollectData.count) person who lives here", for: .normal)
                } else {
                self.showHideCollectButton.setTitle("You follow \(self.mapCollectData.count) people who live here", for: .normal)
                }
                
                self.showHideCollectButton.isHidden = false
                self.mapCollect.delegate = self
                self.mapCollect.dataSource = self
                self.mapCollect.register(UINib(nibName: "LikedByCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikedByCollectionViewCell")
        })
        }
        }
        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    var prevID = String()
    var extended = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "MapToProfile"{
            if let vc = segue.destination as? ProfileViewController{
                if backPressed == true {
                    vc.curUID = self.prevID
                    
                    vc.prevScreen = "follow"
                    
                    vc.viewerIsCurAuth = true
                    
                    vc.curName = self.cellName
                } else {
                    vc.curUID = self.cellUID
                    
                    vc.prevScreen = "follow"
                    
                    vc.viewerIsCurAuth = false
                    
                    vc.curName = self.cellName
                }
                
            }
        }
    }
    func getLocation(forPlaceCalled name: String,
                     completion: @escaping(CLLocation?) -> Void) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(name) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                print("couldnt find location: \(name)")
                completion(nil)
                
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            guard let location = placemark.location else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            completion(location)
        }
    }
    func performGoogleSearch(for string: String) {
        var strings:String?
        //tableView.reloadData()
        
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/geocode/json")!
        let key = URLQueryItem(name: "key", value: "...") // use your key
        let address = URLQueryItem(name: "address", value: string)
        components.queryItems = [key, address]
        
        let task = URLSession.shared.dataTask(with: components.url!) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                print(String(describing: response))
                print(String(describing: error))
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                print("not JSON format expected")
                print(String(data: data, encoding: .utf8) ?? "Not string?!?")
                return
            }
            
            guard let results = json["results"] as? [[String: Any]],
                let status = json["status"] as? String,
                status == "OK" else {
                    print("no results")
                    print(String(describing: json))
                    return
            }
            
            DispatchQueue.main.async {
                // now do something with the results, e.g. grab `formatted_address`:
            
                let strings = results.compactMap { $0["formatted_address"] as? String }
                print("googleAddress: \(strings)")
                
            }
        }
        
        task.resume()
    }
    

}

