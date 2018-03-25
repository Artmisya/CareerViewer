//
//  ContactCell.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    
    @IBOutlet var clickableView: UIView!
    @IBOutlet var contactLbl: UILabel!
    @IBOutlet var contactImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
