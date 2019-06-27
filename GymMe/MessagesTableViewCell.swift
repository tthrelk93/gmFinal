//
//  MessagesTableViewCell.swift
//  GymMe
//
//  Created by Thomas Threlkeld on 7/19/18.
//  Copyright © 2018 Thomas Threlkeld. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {
    @IBOutlet weak var receiverPic: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var receiverName: UILabel!
    var receiverUID: String?
    var messageKey = String()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
