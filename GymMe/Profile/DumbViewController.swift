//
//  DumbViewController.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 4/30/19.
//  Copyright © 2019 Thomas Threlkeld. All rights reserved.
//

import UIKit

class DumbViewController: UIViewController {

    var curUID = String()
    var curName = String()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        performSegue(withIdentifier: "DumbViewToProf", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("heymanc")
        

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? ProfileViewController{
            vc.curUID = self.curUID
            vc.curName = self.curName
        }
    }
    

}
