//
//  CalendarView.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/16/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import UIKit

protocol CalendarViewDelegate: NSObjectProtocol {
    func calendar(_ calendarView: CalendarView, didChangePeriod periodDate: Date, bySwipe: Bool)
    func calendar(_ calendarView: CalendarView, didSelectDate date: Date)
    func calendar(_ calendarView: CalendarView, backgroundForDate date: Date) -> UIColor?
    func calendar(_ calendarView: CalendarView, textColorForDate date: Date) -> UIColor?
}

class CalendarView: UIView {
    var configuration: Format
    private var periods = [PeriodView]()
    private var currentFrame = CGRect.zero
    fileprivate var currentDate: Date
    fileprivate var visiblePeriodDate = Date()
    fileprivate var isAnimating = false
    fileprivate var currentPage = 0
    
    weak var calendarDelegate: CalendarViewDelegate?
    
    lazy private var periodsContainerView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    lazy private var weekLabelsView: WeekLabelsView = {
        let labelsView = WeekLabelsView(delegate: self)
        return labelsView
    }()
    
    override init(frame: CGRect) {
        self.configuration = Format.getDefault()
        self.currentDate = NSDate().atStartOfDay()
        super.init(frame: frame)
        self.visiblePeriodDate = self.startDate(self.currentDate, withOtherMonth: false)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.configuration = Format.getDefault()
        self.currentDate = NSDate().atStartOfDay()
        super.init(coder: aDecoder)
        self.visiblePeriodDate = self.startDate(self.currentDate, withOtherMonth: false)
        configureViews()
    }
    
    override func layoutSubviews() {
        if !currentFrame.equalTo(frame) && !isAnimating {
            currentFrame = frame
            
            let weekLabelsViewHeight = configuration.weekLabelHeight
            periodsContainerView.frame = CGRect(x: 0, y: weekLabelsViewHeight, width: frame.width, height: frame.height - weekLabelsViewHeight)
            
            setPeriodFrames()
        }
    }
    
    func selectDate(_ date: Date) {
        let validatedDate = dateInRange(date)
        if !isDateAlreadyShown(validatedDate) {
            let periodDate = startDate(validatedDate, withOtherMonth: false)
            visiblePeriodDate = validatedDate.timeIntervalSince1970 < date.timeIntervalSince1970
                ? retroPeriodDate(periodDate) : periodDate
            calendarDelegate?.calendar(self, didChangePeriod: periodDate, bySwipe: false)
        }
        self.currentDate = validatedDate
        setPeriodViews()
    }
    
    func periodDateFromPage(_ page: Int) -> Date? {
        return periods[page].startingPeriodDate()
    }
    
    func reloadView() {
        visiblePeriodDate = recalculatedVisibleDate(false)
        clearView()
        setPeriodViews()
        setPeriodFrames()
        weekLabelsView.updateView()
    }
    
    func animateToPeriodType(_ periodType: Format.PeriodType, duration: TimeInterval, animations: @escaping (_ calendarHeight: CGFloat) -> Void, completion: ((Bool) -> Void)?) {
        let previousVisibleDate = visiblePeriodDate
        let previousPeriodType = configuration.periodType
        
        configuration.periodType = periodType
        let yDelta = periodYDelta(periodType, previousVisibleDate: previousVisibleDate)
        
        if periodType.weeksCount() > previousPeriodType.weeksCount() {
            reloadView()
            layoutIfNeeded()
            let currentPeriodViewFrame = currentPeriod().frame
            currentPeriod().frame = CGRect(x: currentPeriodViewFrame.origin.x, y: currentPeriodViewFrame.origin.y, width: currentPeriodViewFrame.width, height: periodHeight(previousPeriodType) - yDelta)
            
            performAnimation(true, periodType: periodType, yDelta: yDelta, duration: duration, animations: animations, completion: completion)
        } else {
            performAnimation(false, periodType: periodType, yDelta: yDelta, duration: duration, animations: animations, completion: completion)
        }
    }
    
    // MARK: Private APIs
    
    private func configureViews() {
        addSubview(weekLabelsView)
        addSubview(periodsContainerView)
        
        setPeriodViews()
    }
    
    fileprivate func setPeriodViews() {
        let visibleDate = visiblePeriodDate
        let previousDate = previousPeriodDate(visibleDate, withOtherMonth: true)
        let currentDate = startDate(visibleDate, withOtherMonth: true)
        let nextDate = nextPeriodDate(visibleDate, withOtherMonth: true)
        
        if periods.count > 0 {
            if shouldChangePeriodsRange() {
                if periods.count == 3 {
                    periods[0].date = previousDate
                    periods[1].date = currentDate
                    periods[2].date = nextDate
                    
                    currentPage = 1
                    setPeriodFrames()
                } else {
                    createPeriodsViews(previousDate, currentDate: currentDate, nextDate: nextDate)
                    setPeriodFrames()
                }
            } else {
                for periodView in periods {
                    periodView.configureViews()
                }
            }
        } else {
            createPeriodsViews(previousDate, currentDate: currentDate, nextDate: nextDate)
        }
    }
    
    private func createPeriodsViews(_ previousDate: Date, currentDate: Date, nextDate: Date) {
        clearView()
        let previosPeriodView = PeriodView(date: previousDate, delegate: self)
        if let endingPeriodDate = previosPeriodView.endingPeriodDate(),
            !isDateEarlierThanMin(endingPeriodDate) {
            periodsContainerView.addSubview(previosPeriodView)
            periods.append(previosPeriodView)
        }
        
        let currentPeriodView = PeriodView(date: currentDate, delegate: self)
        periodsContainerView.addSubview(currentPeriodView)
        periods.append(currentPeriodView)
        
        let nextPeriodView = PeriodView(date: nextDate, delegate: self)
        if let startingPeriodDate = nextPeriodView.startingPeriodDate(),
            !isDateLaterThanMax(startingPeriodDate) {
            periodsContainerView.addSubview(nextPeriodView)
            periods.append(nextPeriodView)
        }
        
        currentPage = periods.index(of: currentPeriodView)!
    }
    
    private func shouldChangePeriodsRange() -> Bool {
        let startDateOfPeriod = visiblePeriodDate
        let endDateOfPeriod = nextPeriodDate(visiblePeriodDate, withOtherMonth: false)
        return !(isDateEarlierThanMin(startDateOfPeriod) || isDateLaterThanMax(endDateOfPeriod))
    }
    
    fileprivate func isDateEarlierThanMin(_ date: Date) -> Bool {
        guard let minDate = configuration.minDate else { return false }
        
        let startDate = (minDate as NSDate).atStartOfDay()
        if (date as NSDate).isEarlierThanDate(startDate) {
            return true
        }
        
        return false
    }
    
    fileprivate func isDateLaterThanMax(_ date: Date) -> Bool {
        guard let maxDate = configuration.maxDate else { return false }
        
        let endDate = (maxDate as NSDate).atEndOfDay()
        if (date as NSDate).isLaterThanDate(endDate) {
            return true
        }
        
        return false
    }
    
    private func setPeriodFrames() {
        let mod7 = frame.width.truncatingRemainder(dividingBy: 7)
        let width = frame.width - mod7
        let x = ceil(mod7 / 2)
        
        weekLabelsView.frame = CGRect(x: x, y: 0, width: width, height: configuration.weekLabelHeight)
        
        for (index, period) in (periods).enumerated() {
            period.frame = CGRect(x: CGFloat(index) * frame.width + x,y: 0,width: width, height: periodHeight(configuration.periodType))
        }
        
        periodsContainerView.contentSize = CGSize(width: frame.width * CGFloat(periods.count), height: frame.height - configuration.weekLabelHeight)
        periodsContainerView.contentOffset.x = frame.width * CGFloat(currentPage)
    }
    
    private func periodHeight(_ periodType: Format.PeriodType) -> CGFloat {
        return CGFloat(periodType.weeksCount()) * configuration.rowHeight
    }
    
    private func startDate(_ date: Date, withOtherMonth: Bool) -> Date {
        if configuration.periodType == .month {
            let beginningOfMonth = (date as NSDate).atStartOfMonth()
            if withOtherMonth {
                return startWeekDay(beginningOfMonth)
            } else {
                return beginningOfMonth
            }
        } else {
            return startWeekDay(date)
        }
    }
    
    private func startWeekDay(_ date: Date) -> Date {
        let delta = configuration.startDayType == .monday ? 2 : 1
        var daysToSubstract = (date as NSDate).weekday - delta
        if daysToSubstract < 0 {
            daysToSubstract += 7
        }
        return (date as NSDate).subtractingDays(daysToSubstract)
    }
    
    private func nextPeriodDate(_ date: Date, withOtherMonth: Bool) -> Date {
        return periodDate(date, isNext: true, withOtherMonth: withOtherMonth)
    }
    
    private func previousPeriodDate(_ date: Date, withOtherMonth: Bool) -> Date {
        return periodDate(date, isNext: false, withOtherMonth: withOtherMonth)
    }
    
    private func periodDate(_ date: Date, isNext: Bool, withOtherMonth: Bool) -> Date {
        let isNextFactor = isNext ? 1 : -1
        switch configuration.periodType {
        case .month:
            let otherMonthDate = (date as NSDate).addingMonths(1 * isNextFactor)
            return startDate(otherMonthDate, withOtherMonth: withOtherMonth)
        case .twoWeeks: return (date as NSDate).addingDays((2 * isNextFactor) * 7)
        }
    }
    
    private func selectNewPeriod(_ date: Date) {
        let validatedDate = dateInRange(date)
        if !isDateAlreadyShown(validatedDate) {
            let periodDate = startDate(validatedDate, withOtherMonth: false)
            visiblePeriodDate = periodDate
            calendarDelegate?.calendar(self, didChangePeriod: periodDate, bySwipe: false)
        }
        self.currentDate = validatedDate
        setPeriodViews()
    }
    
    private func dateInRange(_ date: Date) -> Date {
        if let minDate = configuration.minDate,
            isDateEarlierThanMin(date) {
            return (minDate as NSDate).atStartOfDay()
        } else {
            return date
        }
    }
    
    private func retroPeriodDate(_ periodDate: Date) -> Date {
        switch configuration.periodType {
        case .month: return periodDate
        case .twoWeeks: return (periodDate as NSDate).addingDays(-7)
        }
    }
    
    private func currentPeriod() -> PeriodView {
        return periods[currentPage]
    }
    
    private func isDateAlreadyShown(_ date: Date) -> Bool {
        if configuration.periodType == .month {
            return (date as NSDate).atStartOfMonth() == (visiblePeriodDate as NSDate).atStartOfMonth()
        } else {
            return date.timeIntervalSince1970 >= (currentPeriod().startingDate()?.timeIntervalSince1970)!
                && date.timeIntervalSince1970 <= (currentPeriod().endingDate()?.timeIntervalSince1970)!
        }
    }
    
    private func clearView() {
        for period in periods {
            period.removeFromSuperview()
        }
        
        periods.removeAll()
        currentFrame = .zero
    }
    
    private func recalculatedVisibleDate(_ withOtherMonth: Bool) -> Date {
        let visibleDate = currentPeriod().isDateInPeriod(currentDate) ? currentDate : visiblePeriodDate
        let startDate = self.startDate(visibleDate, withOtherMonth: withOtherMonth)
        if configuration.periodType == .month {
            return startDate
        } else {
            let weekIndex = weekIndexByStartDate(startDate) + 1
            let weekCount = configuration.periodType.weeksCount()
            let visibleIndex = weekIndex - weekCount > 0 ? weekIndex - weekCount : 0
            return currentPeriod().weeks?[visibleIndex].date ?? Date()
        }
    }
    
    private func weekIndexByStartDate(_ startDate: Date) -> Int {
        guard let weeks = currentPeriod().weeks else { return 0 }
        
        for (index, week) in weeks.enumerated() {
            if week.date == startDate {
                return index
            }
        }
        
        return 0
    }
    
    private func periodYDelta(_ periodType: Format.PeriodType, previousVisibleDate: Date) -> CGFloat {
        let visiblePeriodDatePreview = recalculatedVisibleDate(true)
        let deltaVisiblePeriod = visiblePeriodDatePreview.timeIntervalSince1970 - previousVisibleDate.timeIntervalSince1970
        let weekIndexDelta = ceil(deltaVisiblePeriod / (3600 * 24 * 7))
        return CGFloat(weekIndexDelta) * configuration.rowHeight
    }
    
    // Perform animation to contract/expand calender view
    private func performAnimation(_ animateToBiggerSize: Bool, periodType: Format.PeriodType, yDelta: CGFloat, duration: TimeInterval, animations: @escaping (_ calendarHeight: CGFloat) -> Void, completion: ((Bool) -> Void)?) {
        isAnimating = true
        UIView.animate(withDuration: duration, animations: { () -> Void in
            animations(self.periodHeight(periodType) + self.configuration.weekLabelHeight)
            let currentPeriodViewFrame = self.currentPeriod().frame
            if animateToBiggerSize {
                self.currentPeriod().frame = CGRect(x: currentPeriodViewFrame.origin.x, y: 0, width: currentPeriodViewFrame.width, height: self.periodHeight(periodType))
            } else {
                self.currentPeriod().frame = CGRect(x: currentPeriodViewFrame.origin.x, y: currentPeriodViewFrame.origin.y - yDelta, width: currentPeriodViewFrame.width, height: self.periodHeight(periodType) + yDelta)
            }
            
        }) { (completed) -> Void in
            self.isAnimating = false
            if !animateToBiggerSize {
                self.reloadView()
                self.setPeriodFrames()
            }
            self.calendarDelegate?.calendar(self, didChangePeriod: self.visiblePeriodDate, bySwipe: false)
            
            if let completionBlock = completion {
                completionBlock(completed)
            }
        }
    }
    
}

extension CalendarView: ElementViewDelegate {
    
    func elementView(_ elementView: ElementView, isDateSelected date: Date) -> Bool {
        return (currentDate as NSDate).isEqual(toDateIgnoringTime: date)
    }
    
    func configuration(withElement elementView: ElementView) -> Format {
        return configuration
    }
    
    func elementView(_ elementView: ElementView, didSelectDate date: Date) {
        selectDate(date)
        calendarDelegate?.calendar(self, didSelectDate: date)
    }
    
    func isBeingAnimated(withElement elementView: ElementView) -> Bool {
        return isAnimating
    }
    
    func elementView(_ elementView: ElementView, backgroundColorForDate date: Date) -> UIColor? {
        return calendarDelegate?.calendar(self, backgroundForDate: date)
    }
    
    func elementView(_ elementView: ElementView, textColorForDate date: Date) -> UIColor? {
        return calendarDelegate?.calendar(self, textColorForDate: date)
    }
    
    func isDateOutOfRange(_ elementView: ElementView, date: Date) -> Bool {
        return isDateLaterThanMax(date) || isDateEarlierThanMin(date)
    }
    
}

extension CalendarView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let ratio = scrollView.contentOffset.x / pageWidth
        let page = Int(ratio)
        
        if let periodDate = periodDateFromPage(page),
            visiblePeriodDate != periodDate {
            currentPage = page
            visiblePeriodDate = periodDate
            calendarDelegate?.calendar(self, didChangePeriod: periodDate, bySwipe: true)
            if configuration.selectDayOnPeriodChange {
                selectDate(periodDate)
            } else {
                setPeriodViews()
            }
        }
    }
    
}
