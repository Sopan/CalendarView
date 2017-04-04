//
//  DayView.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/16/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import UIKit

class DayView: ElementView {
    var date: Date! {
        didSet {
            updateView()
        }
    }
    private var todayDate: Date!
    var isSameMonth = true {
        didSet {
            if isSameMonth != oldValue {
                updateView()
            }
        }
    }
    
    lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    
    lazy var borderView: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(date: Date, delegate: ElementViewDelegate) {
        self.date = date
        self.todayDate = (Date() as NSDate).atStartOfDay()
        super.init(delegate: delegate)
        setUpGesture()
        addSubviews()
        updateView()
    }
    
    override func updateFrame() {
        let labelSize = self.labelSize()
        let labelFrame = CGRect(x: (frame.size.width - labelSize.width) / 2,
                                y: (frame.size.height - labelSize.height) / 2, width: labelSize.width, height: labelSize.height)
        label.frame = labelFrame
        
        guard let dayViewSize = delegate?.configuration(withElement: self).dayViewSize else { return }
        let borderFrame = CGRect(x: (frame.size.width - dayViewSize.width) / 2,
                                 y: (frame.size.height - dayViewSize.height) / 2, width: dayViewSize.width, height: dayViewSize.height)
        borderView.frame = borderFrame
    }
    
    // MARK: Private APIs
    
    private func addSubviews() {
        addSubview(borderView)
        addSubview(label)
    }
    
    private func setUpGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func didTap() {
        if let isDateOutOfRange = delegate?.isDateOutOfRange(self, date: date),
            !isDateOutOfRange {
            delegate?.elementView(self, didSelectDate: date)
        }
    }
    
    private func labelSize() -> CGSize {
        guard let dayViewSize = delegate?.configuration(withElement: self).dayViewSize,
            let borderSize = delegate?.configuration(withElement: self).selectedBorderWidth else { return CGSize.zero}
        
        let labelSize = delegate?.configuration(withElement: self).selectedDayType == .filled
            ? dayViewSize
            : CGSize(width: dayViewSize.width - 2 * borderSize, height: dayViewSize.height - 2 * borderSize)
        return labelSize
    }
    
    func updateView() {
        setText()
        setShape()
        setBackgrounds()
        setTextColors()
        setViewBackgrounds()
        setBorder()
    }
    
    private func setText() {
        label.font = delegate?.configuration(withElement: self).dayTextFont
        let text = "\((date as NSDate).day)"
        label.text = text
        
        let isToday = (todayDate as NSDate).isEqual(toDateIgnoringTime: date)
        if isToday {
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleDouble.rawValue]
            label.attributedText = NSAttributedString(string: text, attributes: underlineAttribute)
        } else {
            label.attributedText = NSAttributedString(string: text)
        }
    }
    
    private func setShape() {
        let labelCornerRadius = delegate?.configuration(withElement: self).dayViewType == .circle ? labelSize().width / 2 : 0
        label.layer.cornerRadius = labelCornerRadius
        let dayViewSize = delegate?.configuration(withElement: self).dayViewSize
        var borderCornerRadius: CGFloat = 0
        if let width = dayViewSize?.width {
            borderCornerRadius = width / 2
        }
        borderView.layer.cornerRadius = borderCornerRadius
    }
    
    private func setViewBackgrounds() {
        if isSameMonth {
            if let isDateOutOfRange = delegate?.isDateOutOfRange(self, date: date),
                isDateOutOfRange {
                backgroundColor = delegate?.configuration(withElement: self).outOfRangeDayBackgroundColor
            } else {
                backgroundColor = delegate?.configuration(withElement: self).dayBackgroundColor
            }
        } else {
            backgroundColor = delegate?.configuration(withElement: self).otherMonthBackgroundColor
        }
    }
    
    private func setTextColors() {
        if let isDateSelected = delegate?.elementView(self, isDateSelected: date),
            isDateSelected,
            delegate?.configuration(withElement: self).selectedDayType == .filled {
            label.textColor = delegate?.configuration(withElement: self).selectedDayTextColor
        } else if isSameMonth {
            if let textColor = delegate?.elementView(self, textColorForDate: date) {
                label.textColor = textColor
            } else {
                if let isDateOutOfRange = delegate?.isDateOutOfRange(self, date: date),
                    isDateOutOfRange {
                    label.textColor = delegate?.configuration(withElement: self).outOfRangeDayTextColor
                } else {
                    label.textColor = delegate?.configuration(withElement: self).dayTextColor
                }
            }
        } else {
            label.textColor = delegate?.configuration(withElement: self).otherMonthTextColor
        }
    }
    
    private func setBackgrounds() {
        if let isDateSelected = delegate?.elementView(self, isDateSelected: date),
            isDateSelected,
            delegate?.configuration(withElement: self).selectedDayType == .filled {
            label.backgroundColor = delegate?.configuration(withElement: self).selectedDayBackgroundColor
        } else if isSameMonth {
            if let backgroundColor = delegate?.elementView(self, backgroundColorForDate: date) {
                label.backgroundColor = backgroundColor
            } else {
                if let isDateOutOfRange = delegate?.isDateOutOfRange(self, date: date),
                    isDateOutOfRange {
                    label.backgroundColor = delegate?.configuration(withElement: self).outOfRangeDayBackgroundColor
                } else {
                    label.backgroundColor = delegate?.configuration(withElement: self).dayBackgroundColor
                }
            }
        } else {
            label.backgroundColor = delegate?.configuration(withElement: self).otherMonthBackgroundColor
        }
    }
    
    private func setBorder() {
        borderView.backgroundColor = delegate?.configuration(withElement:self).selectedDayBackgroundColor
        let isDateSelected = delegate?.elementView(self, isDateSelected: date) ?? false
        borderView.isHidden = !(isDateSelected && isSameMonth)
    }
    
}
