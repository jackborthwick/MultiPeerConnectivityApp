//
//  MessageTableViewCell.swift
//  MultiPeerConnectivityApp
//
//  Created by Jack Borthwick on 7/27/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
