//
//  WeekView.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/16/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import UIKit

class WeekView: ElementView {
    var date: Date {
        didSet {
            configureViews()
        }
    }
    var days = [DayView]()
    
    required public init?(coder aDecoder: NSCoder) {
        self.date = Date()
        super.init(coder: aDecoder)
    }
    
    init(date: Date, delegate: ElementViewDelegate) {
        self.date = date
        super.init(delegate: delegate)
        configureViews()
    }
    
    override func updateFrame() {
        for (index, day) in days.enumerated() {
            let dayWidth = frame.size.width / 7
            day.frame = CGRect(x: CGFloat(index) * dayWidth, y: 0, width: dayWidth, height: frame.size.height)
        }
    }
    
    // MARK: Private APIs
    
    private func configureViews() {
        if days.count > 0 {
            for i in 1...7 {
                let dayDate = (date as NSDate).addingDays(i - 1)
                days[i - 1].date = dayDate
            }
        } else {
            for i in 1...7 {
                let dayDate = (date as NSDate).addingDays(i - 1)
                let dayView = DayView(date: dayDate, delegate: delegate!)
                addSubview(dayView)
                days.append(dayView)
            }
        }
    }
    
}
