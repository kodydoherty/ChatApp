//
//  resultsCell.swift
//  ChatApp
//
//  Created by Samuel Doherty on 8/27/15.
//  Copyright (c) 2015 ColombiaIOS. All rights reserved.
//

import UIKit

class resultsCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        let theWidth = UIScreen.mainScreen().bounds.width
        
        contentView.frame = CGRectMake(0, 0, theWidth, 120)
        profileImg.center = CGPointMake(60, 60)
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        profileImg.clipsToBounds = true
        profileNameLbl.center = CGPointMake(230, 55)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
