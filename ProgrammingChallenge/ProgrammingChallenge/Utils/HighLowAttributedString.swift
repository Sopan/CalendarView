//
//  HighLowAttributedString.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/19/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import Foundation
import UIKit

func highLowAttributedString(high: Int, low: Int, size: CGFloat = 15) -> NSAttributedString {
    let font = UIFont.systemFont(ofSize: size, weight: UIFontWeightLight)
    let attributedString = NSMutableAttributedString(
        string: String(format: "%zi°", high),
        attributes: [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.black
        ])
    attributedString.append(NSAttributedString(
        string: String(format: "/ %zi°", low),
        attributes: [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.black
        ]))
    return attributedString
}
