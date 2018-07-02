//
//  PopCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 6/28/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit

class PopCell: UICollectionViewCell {

    var player: Player?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.player = Player()
        self.addSubview((self.player?.view)!)
    }

}
