//
//  ViewController.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/8/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import UIKit
import CoreLocation

// Fake Agenda data structure for adding test events
struct Agenda {
    var startDate: Date
    var endDate: Date
    var textColor: UIColor
    var backgroundColor: UIColor
    var title: String
    var location: String?
    var participants: Array<Any>?
}

class CalenderViewController: UIViewController {
    
    fileprivate struct Constants {
        static let tableViewCellReuseIdentifier = "tableViewCellReuseIdentifier"
        // static agenda cells for total 4 years
        static let daysRange = 365 * 4
    }

    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var jumpToCurrentDateButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var isScrollingAnimation = false
    var agendaList = [Date: Agenda]()
    
    static fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    var colors: [UIColor] {
        return [
            UIColor.darkGray,
            UIColor.orange,
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setUpTestAgendaList()
        scrollTableViewToDate(Date())
        setUpCalendarConfiguration()
        setTitleWithDate(Date())
        jumpToCurrentDateButton.layer.cornerRadius = jumpToCurrentDateButton.frame.size.width/2
    }
    
    func setUpCalendarConfiguration() {
        calendarView.calendarDelegate = self
        calendarView.backgroundColor = UIColor.white
        
        // Set displayed period type. Available types: Month, TwoWeeks
        calendarView.configuration.periodType = .month
        
        // Set shape of day view. Available types: Circle, Square
        calendarView.configuration.dayViewType = .circle
        
        // Set selected day display type. Available types:
        // Border - Only border is colored with selected day color
        // Filled - Entire day view is filled with selected day color
        calendarView.configuration.selectedDayType = .filled
        
        // Set width of selected day border. Relevant only if selectedDayType = .Border
        calendarView.configuration.selectedBorderWidth = 1
        calendarView.configuration.dayTextColor = UIColor.darkGray
        calendarView.configuration.dayBackgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        calendarView.configuration.selectedDayTextColor = UIColor.white
        calendarView.configuration.selectedDayBackgroundColor = UIColor(red: 0.13, green: 0.51, blue: 0.85, alpha: 1)
        calendarView.configuration.otherMonthTextColor = UIColor.lightGray
        
        // Set other month background color. Relevant only if periodType = .Month
        calendarView.configuration.otherMonthBackgroundColor = UIColor.white
        
        // Set week text color
        calendarView.configuration.weekLabelTextColor = UIColor(red: 0.111, green: 0.120, blue: 0.124, alpha: 1)
        
        // Set start day. Available type: .Monday, Sunday
        calendarView.configuration.startDayType = .monday
        
        // Set number of letters presented in the week days label
        calendarView.configuration.lettersInWeekDayLabel = .one
        calendarView.configuration.dayTextFont = UIFont.systemFont(ofSize: 12)
        calendarView.configuration.weekLabelFont = UIFont.systemFont(ofSize: 12)
        calendarView.configuration.dayViewSize = CGSize(width: 24, height: 24)
        
        //Set height of row with week's days
        calendarView.configuration.rowHeight = 30
        
        // Set height of week's days names view
        calendarView.configuration.weekLabelHeight = 25
        
        // To commit all configuration changes execute reloadView method
        calendarView.reloadView()
    }
    
    // MARK: Private APIs
    
    @IBAction func jumpToCurrentDate(_ sender: Any) {
        scrollTableViewToDate(Date())
        calendarView.selectDate(Date())
        hideUnhideJumpToCurrentDate(fromDate: Date())
    }

    func setTitleWithDate(_ date: Date) {
        CalenderViewController.dateFormatter.dateFormat = "MMMM yyyy"
        navigationItem.title = CalenderViewController.dateFormatter.string(from: date)
    }
    
    func isDate(equalToDateInSection section: Int) -> Bool {
        let date = dateByIndex(section)
        return (date as NSDate).isEqual(toDateIgnoringTime: NSDate().atStartOfDay())
    }
    
    func dateByIndex(_ index: Int) -> Date {
        let startDay = ((Date() as NSDate).atStartOfDay() as NSDate).subtractingDays(Constants.daysRange / 2)
        let day = (startDay as NSDate).addingDays(index)
        return day
    }
    
    func scrollTableViewToDate(_ date: Date) {
        if let section = indexByDate(date) {
            let indexPath = IndexPath(row: 0, section: section)
            tableView.setContentOffset(tableView.contentOffset, animated: false)
            isScrollingAnimation = true
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func indexByDate(_ date: Date) -> Int? {
        let startDay = ((Date() as NSDate).atStartOfDay() as NSDate).subtractingDays(Constants.daysRange / 2)
        let index = (date as NSDate).days(after: startDay)
        if index >= 0 && index <= Constants.daysRange {
            return index
        } else {
            return nil
        }
    }
    
    func animateToPeriod(_ period: Format.PeriodType) {
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        
        calendarView.animateToPeriodType(period, duration: 0.2, animations: { [weak self] (calendarHeight) -> Void in
            guard let `self` = self else { return }
            self.calendarViewHeight.constant = calendarHeight
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func hideUnhideJumpToCurrentDate(fromDate date: Date) {
        let existingAlpha = jumpToCurrentDateButton.alpha
        var alpha = 0.0
        let isDateEqual = (date as NSDate).isEqual(toDateIgnoringTime: NSDate().atStartOfDay())
        if !isDateEqual {
            alpha = 0.5
        }
        
        if existingAlpha != CGFloat(alpha) {
            UIView.transition(with: view, duration: 0.5, options: .curveEaseInOut, animations: {() -> Void in
                self.jumpToCurrentDateButton.alpha = CGFloat(alpha)
            }, completion: { _ in })
        }
    }

}

extension CalenderViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.daysRange
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let date = dateByIndex(indexPath.section)
        if let agenda = agendaList[date] {
            let cell = tableView.dequeueReusableCell(withIdentifier: CalendarEventTableViewCell.identifier()) as! CalendarEventTableViewCell
            let duration = (agenda.endDate as NSDate).minutes(after: agenda.startDate) as Int
            cell.dateLabelView.text = agenda.title
            cell.durationLabel.text = "\(duration)" + "m"
            cell.startTimeLabel.text = getActualTime(fromDate: agenda.startDate)
            cell.colorView.backgroundColor = agenda.backgroundColor
            cell.colorView.clipsToBounds = true
            cell.colorView.layer.cornerRadius = cell.colorView.frame.size.width / 2
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewCellReuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: Constants.tableViewCellReuseIdentifier)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
            cell.textLabel?.textColor = UIColor.gray
            cell.textLabel?.text = "No Events"
            
            return cell
        }

    }
    
    // Mark: Helper methods
    
    func setUpTestAgendaList() {
        for i in 0...Constants.daysRange {
            let day = self.dateByIndex(i)
            if let randomColor = randomColor() {
                // Fake events
                let agenda = Agenda(startDate: day, endDate: day.addingTimeInterval(30 * 60), textColor: UIColor.white, backgroundColor: randomColor, title: "Code review meeting", location: nil, participants: nil)
                agendaList[day] = agenda
            } else {
                agendaList[day] = nil
            }
        }
    }
    
    func randomColor() -> UIColor? {
        if arc4random() % 10 == 0 {
            let colorIndex = Int(arc4random()) % colors.count
            let color = colors[colorIndex]
            return color
        }
        
        return nil
    }
    
    func getActualTime(fromDate date: Date) -> String {
        CalenderViewController.dateFormatter.dateFormat = "h:mm a"
        return CalenderViewController.dateFormatter.string(from: date)
    }
    
}

extension CalenderViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        if isDate(equalToDateInSection: section)  {
            header?.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
            header?.textLabel?.textColor = UIColor(red: 0.13, green: 0.51, blue: 0.85, alpha: 1)
        } else {
            header?.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
            header?.textLabel?.textColor = UIColor.gray
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = dateByIndex(section)
        CalenderViewController.dateFormatter.dateFormat = "EEEE, MMMM d"
        var dateString = CalenderViewController.dateFormatter.string(from: date)
        if isDate(equalToDateInSection: section) {
            dateString = String(format: "Today • %@", dateString)
        }
        
        return dateString.uppercased()
    }
    
}

extension CalenderViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Prevent changing selected day when non user scroll is triggered.
        if !isScrollingAnimation {
            // Get all visible cells from tableview
            if let visibleCells = tableView.indexPathsForVisibleRows {
                if let cellIndexPath = visibleCells.first {
                    // Get day by indexPath
                    let day = dateByIndex(cellIndexPath.section)
                    
                    //Select day according to first visible cell in tableview
                    calendarView.selectDate(day)
                }
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrollingAnimation = false
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if calendarView.configuration.periodType != .twoWeeks {
            animateToPeriod(.twoWeeks)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let visibleCells = tableView.indexPathsForVisibleRows {
            if let cellIndexPath = visibleCells.first {
                // Get day by indexPath
                let day = dateByIndex(cellIndexPath.section)
                hideUnhideJumpToCurrentDate(fromDate: day)
            }
        }
    }
    
}

extension CalenderViewController: CalendarViewDelegate {
    
    func calendar(_ calendarView: CalendarView, didChangePeriod periodDate: Date, bySwipe: Bool) {
        // Sets month name according to presented dates
        setTitleWithDate(periodDate)
        hideUnhideJumpToCurrentDate(fromDate: periodDate)
        
        // bySwipe diffrentiate changes made from swipes or select date method
        if bySwipe {
            // Scroll to relevant date in tableview
            scrollTableViewToDate(periodDate)
            if calendarView.configuration.periodType != .month {
                animateToPeriod(.month)
            }
        }
    }
    
    func calendar(_ calendarView: CalendarView, backgroundForDate date: Date) -> UIColor? {
        return agendaList[date]?.backgroundColor
    }
    
    func calendar(_ calendarView: CalendarView, textColorForDate date: Date) -> UIColor? {
        return agendaList[date]?.textColor
    }
    
    func calendar(_ calendarView: CalendarView, didSelectDate date: Date) {
        scrollTableViewToDate(date)
    }
    
}
