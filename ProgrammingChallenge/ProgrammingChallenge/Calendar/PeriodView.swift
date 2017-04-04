//
//  PeriodView.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/16/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import UIKit

class PeriodView: ElementView {
    var date: Date {
        didSet {
            configureViews()
        }
    }
    var weeks: [WeekView]?
    private var numberOfWeeks: Int {
        return delegate?.configuration(withElement: self).periodType.weeksCount() ?? 0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.date = Date()
        super.init(coder: aDecoder)
    }
    
    init(date: Date, delegate: ElementViewDelegate) {
        self.date = date
        super.init(delegate: delegate)
        clipsToBounds = true
        configureViews()
    }
    
    func configureViews() {
        if let weekViews = weeks {
            for i in 1...numberOfWeeks {
                let weekDate = (date as NSDate).addingDays((i - 1) * 7)
                weekViews[i - 1].date = weekDate
            }
        } else {
            weeks = []
            for i in 1...numberOfWeeks {
                let weekDate = (date as NSDate).addingDays((i - 1) * 7)
                let weekView = WeekView(date: weekDate, delegate: delegate!)
                addSubview(weekView)
                weeks!.append(weekView)
            }
        }
        
        setIsSameMonth()
    }
    
    override func updateFrame() {
        guard let weeks = weeks else { return }
        for (index, week) in weeks.enumerated() {
            let lineHeight = delegate?.configuration(withElement: self).rowHeight ?? 0
            week.frame = CGRect(x: 0, y: CGFloat(index) * lineHeight, width: frame.size.width, height: lineHeight)
        }
    }
    
    func startingDate() -> Date? {
        guard let weeks = weeks,
            let last = weeks.last,
            let firstDay = last.days.first else { return nil }
        
        return firstDay.date
    }
    
    func endingDate() -> Date? {
        guard let weeks = weeks,
            let last = weeks.last,
            let lastDay = last.days.last else { return nil }
        
        return lastDay.date
    }
    
    func startingPeriodDate() -> Date? {
        guard let weeks = weeks else { return nil }
        
        let monthCount = Format.PeriodType.month.weeksCount()
        if weeks.count == monthCount {
            let middleDate = weeks[3].date
            return (middleDate as NSDate).atStartOfMonth()
        } else {
            return startingDate()
        }
    }
    
    func endingPeriodDate() -> Date? {
        guard let weeks = weeks else { return nil }
        
        let monthCount = Format.PeriodType.month.weeksCount()
        if weeks.count == monthCount {
            let middleDate = weeks[3].date
            return (middleDate as NSDate).atEndOfMonth()
        } else {
            return endingDate()
        }
    }
    
    func isDateInPeriod(_ date: Date) -> Bool {
        return (date as NSDate).isLaterThanOrEqualDate(startingPeriodDate()!) && (date as NSDate).isEarlierThanOrEqualDate(endingPeriodDate()!)
    }
    
    // MARK: Private APIs
    
    private func setIsSameMonth() {
        guard let weeks = weeks,
            delegate?.configuration(withElement: self).periodType == .month else { return }
        
        let monthDate = weeks[1].date
        for (index, week) in weeks.enumerated() {
            if index == 0 || index == 4 || index == 5 {
                for dayView in week.days {
                    dayView.isSameMonth = (dayView.date as NSDate).atStartOfMonth() == (monthDate as NSDate).atStartOfMonth()
                }
            }
        }
    }
    
}
