//
//  LiveTableViewCell.swift
//  ZWA
//
//  Created by mac on 2017/3/26.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class LiveTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
