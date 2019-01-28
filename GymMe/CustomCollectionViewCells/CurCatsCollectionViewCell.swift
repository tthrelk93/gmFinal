//
//  CurCatsCollectionViewCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 1/28/19.
//  Copyright © 2019 Thomas Threlkeld. All rights reserved.
//

import UIKit

protocol RemoveCatDelegate {
    
    func removeCat(catLabel: String)
    
}

class CurCatsCollectionViewCell: UICollectionViewCell {

    @IBAction func removeCatPressed(_ sender: Any) {
        print("inremoveDel")
        delegate?.removeCat(catLabel: self.curCatLabel.text!)
    }
    var delegate: RemoveCatDelegate?
    @IBOutlet weak var curCatLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 8
    }

}
