//
//  CalendarEventTableViewCell.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/17/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import UIKit

class CalendarEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var dateLabelView: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static func identifier() -> String {
        return "calendarEventTableViewCellIdentifier"
    }

}
