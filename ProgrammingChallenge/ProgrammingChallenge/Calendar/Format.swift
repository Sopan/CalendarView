//
//  Format.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/20/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import Foundation
import UIKit

struct Format {
    enum PeriodType {
        case twoWeeks, month
        func weeksCount() -> Int {
            switch self {
            case .month: return 6
            case .twoWeeks: return 2
            }
        }
    }
    
    enum DayViewType {
        case square, circle
    }
    
    enum StartDayType {
        case monday, sunday
    }
    
    enum LettersInWeekDay: Int {
        case one = 1
        case two
        case three
    }
    
    enum SelectedDayType {
        case filled, border
    }
    
    var lettersInWeekDayLabel: LettersInWeekDay = .three
    
    var periodType: PeriodType = .month
    var dayViewType: DayViewType = .circle
    var startDayType: StartDayType = .monday
    var selectedDayType: SelectedDayType = .border
    
    var rowHeight: CGFloat = 30
    var dayViewSize = CGSize(width: 24, height: 24)
    var dayTextFont = UIFont.systemFont(ofSize: 12)
    
    var otherMonthBackgroundColor = UIColor.clear
    var otherMonthDayViewBackgroundColor = UIColor.clear
    var otherMonthTextColor = UIColor.clear
    
    var dayBackgroundColor = UIColor.clear
    var dayDayViewBackgroundColor = UIColor.clear
    var dayTextColor = UIColor.clear
    
    var selectedDayBackgroundColor = UIColor.clear
    var selectedDayTextColor = UIColor.clear
    var selectedBorderWidth: CGFloat = 1
    
    var weekLabelFont = UIFont.systemFont(ofSize: 12)
    var weekLabelTextColor = UIColor.clear
    var weekLabelHeight: CGFloat = 25
    
    var minDate: Date?
    var maxDate: Date?
    
    var outOfRangeDayBackgroundColor = UIColor.clear
    var outOfRangeDayTextColor = UIColor.clear
    
    var selectDayOnPeriodChange = true
    
    static func getDefault() -> Format {
        let calendarFormat = Format()
        return calendarFormat
    }
}
