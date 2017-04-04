//
//  WeekLabelsView.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/12/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import UIKit

class WeekLabelsView: ElementView {
    private var weekLabels = [UILabel]()
    lazy private var formatter = DateFormatter()
    
    private var weekDayText: [String] {
        var text = [String]()
        var dayIndex = 0
        
        for index in 1...7 {
            let configuration = (delegate?.configuration(withElement: self))! as Format
            switch configuration.startDayType {
            case .monday:
                dayIndex = index % 7
            case .sunday:
                dayIndex = index - 1
            }
            
            let day = formatter.weekdaySymbols[dayIndex]
            if let lettersInWeekDay = delegate?.configuration(withElement: self).lettersInWeekDayLabel.rawValue {
                text.append(day.substring(to: lettersInWeekDay).uppercased())
            }
        }
        
        return text
    }
    
    override init(delegate: ElementViewDelegate) {
        super.init(delegate: delegate)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func updateView() {
        for (index, weekLabel) in weekLabels.enumerated() {
            weekLabel.font = delegate?.configuration(withElement: self).weekLabelFont
            weekLabel.textColor = delegate?.configuration(withElement: self).weekLabelTextColor
            weekLabel.text = weekDayText[index]
        }
    }
    
    override func updateFrame() {
        for (index, weekLabel) in weekLabels.enumerated() {
            let labelWidth: CGFloat = frame.size.width / 7
            weekLabel.frame = CGRect(x: CGFloat(index) * labelWidth, y: 0, width: labelWidth, height: frame.size.height)
        }
    }
    
    // MARK: Private APIs
    
    private func setUpView() {
        for index in 0...6 {
            let label = UILabel()
            label.font = delegate?.configuration(withElement: self).weekLabelFont
            label.textColor = delegate?.configuration(withElement: self).weekLabelTextColor
            label.text = weekDayText[index]
            label.textAlignment = .center
            addSubview(label)
            weekLabels.append(label)
        }
    }
    
}
