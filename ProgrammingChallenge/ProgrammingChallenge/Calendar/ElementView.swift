//
//  ElementView.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/12/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import UIKit

protocol ElementViewDelegate: NSObjectProtocol {
    func configuration(withElement elementView: ElementView) -> Format
    func elementView(_ elementView: ElementView, isDateSelected date: Date) -> Bool
    func elementView(_ elementView: ElementView, didSelectDate date: Date)
    func isBeingAnimated(withElement elementView: ElementView) -> Bool
    func elementView(_ elementView: ElementView, backgroundColorForDate date: Date) -> UIColor?
    func elementView(_ elementView: ElementView, textColorForDate date: Date) -> UIColor?
    func isDateOutOfRange(_ elementView: ElementView, date: Date) -> Bool
}

class ElementView: UIView {
    weak var delegate: ElementViewDelegate?
    var currentFrame = CGRect.zero
    
    init(delegate: ElementViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        if !currentFrame.equalTo(frame) {
            currentFrame = frame
            updateFrame()
        }
    }
    
    func updateFrame() {
        fatalError("updateFrame has not been implemented")
    }

}
