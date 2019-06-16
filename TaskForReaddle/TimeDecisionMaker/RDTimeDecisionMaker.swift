//
//  RDTimeDecisionMaker.swift
//  TimeDecisionMaker
//
//  Created by Mikhail on 4/24/19.
//

import Foundation

class RDTimeDecisionMaker: NSObject {
    /// Main method to perform date interval calculation
    ///
    /// - Parameters:
    ///   - organizerICSPath: path to personA file with events
    ///   - attendeeICSPath: path to personB file with events
    ///   - duration: desired duration of appointment
    /// - Returns: array of available time slots, empty array if none found
    func suggestAppointments(organizerICS: String,
                             attendeeICS: String,
                             duration: TimeInterval) -> [DateInterval] {
        
        let organizerIntervals: [DateInterval] = suggestAppointments(icsFilePath: organizerICS, duration: duration)
        let attendeeIntervals: [DateInterval] = suggestAppointments(icsFilePath: attendeeICS, duration: duration)
        
        
        var freeIntervals: [DateInterval] = []
        
        for orgInterval in organizerIntervals {
            for attInterval in attendeeIntervals {
                if let intersection = orgInterval.intersection(with: attInterval) {
                    freeIntervals.append(intersection)
                }
            }
        }
        
        return freeIntervals.filter({ (interval) -> Bool in
            return interval.duration >= duration
        })
    }
    
    func suggestAppointments(icsFilePath: String, duration: TimeInterval) -> [DateInterval] {
        let parser = NewParser()
        let personalAppointments: [Appointment] = parser.returnEventfromPath(fromFilePath: icsFilePath)
        
        let busyAppointments = personalAppointments.filter { (event) -> Bool in
            return event.isBusy
        }
        
        let sortedEvents = busyAppointments.sorted { (first, second) -> Bool in
            return first.start < second.start
        }
        
        var freeIntervals: [DateInterval] = []
        
        for i in 0..<sortedEvents.count {
            
            if i == 0 {
                let interval = DateInterval(start: sortedEvents[i].startInLocalTimeZone.dayStart, end: sortedEvents[i].start)
                freeIntervals.append(interval)
                
                if sortedEvents.count > 1 {
                    let interval = DateInterval(start: sortedEvents[i].end, end: sortedEvents[i + 1].start)
                    freeIntervals.append(interval)
                }
                
            } else if i == sortedEvents.count - 1 {
                let interval = DateInterval(start: sortedEvents[i].end, end: sortedEvents[i].endInLocalTimeZone.dayEnd)
                
                freeIntervals.append(interval)
            } else {
                let interval = DateInterval(start: sortedEvents[i].end, end: sortedEvents[i + 1].start)
                freeIntervals.append(interval)
            }
        }
        
        
        return freeIntervals.filter({ (interval) -> Bool in
            return interval.duration >= duration
        })
    }
    
    
    func suggestAppointments(icsFilePath: String, duration: TimeInterval, dayInterval: DateInterval) -> [DateInterval] {
        let freeIntervals  = suggestAppointments(icsFilePath: icsFilePath, duration: duration)
        
        var oneDayIntervals = freeIntervals.filter { (interval) -> Bool in
            return dayInterval.intersects(interval)
        }
        
        for i in 0..<oneDayIntervals.count {
            if i == 0 {
                if oneDayIntervals[0].start < dayInterval.start {
                    oneDayIntervals[0] = DateInterval(start: dayInterval.start, end: oneDayIntervals[0].end)
                }
            }
            if i == oneDayIntervals.count - 1 {
                if oneDayIntervals[oneDayIntervals.count - 1].end > dayInterval.end {
                    oneDayIntervals[oneDayIntervals.count - 1] = DateInterval(start: oneDayIntervals[oneDayIntervals.count - 1].start, end: dayInterval.end)
                }
            }
        }
        
        return oneDayIntervals.filter({ (interval) -> Bool in
            return interval.duration >= duration
        })
    }
    
    func suggestAppointments(organizerICS: String, attendeeICS: String, duration: TimeInterval, dayInterval: DateInterval) -> [DateInterval] {
        let freeIntervals = suggestAppointments(organizerICS: organizerICS, attendeeICS: attendeeICS, duration: duration)
        
        var oneDayIntervals = freeIntervals.filter { (freeInterval) -> Bool in
            return dayInterval.intersects(freeInterval)
        }
        
        for i in 0..<oneDayIntervals.count {
            if i == 0 {
                if oneDayIntervals[0].start < dayInterval.start {
                    oneDayIntervals[0] = DateInterval(start: dayInterval.start, end: oneDayIntervals[0].end)
                }
            }
            
            if i == oneDayIntervals.count - 1 {
                if oneDayIntervals[oneDayIntervals.count - 1].end > dayInterval.end {
                    oneDayIntervals[oneDayIntervals.count - 1] = DateInterval(start: oneDayIntervals[oneDayIntervals.count - 1].start, end: dayInterval.end)
                }
            }
        }
        
        return oneDayIntervals.filter({ (interval) -> Bool in
            return interval.duration >= duration
        })
    }
}

extension Date {
    
    var dayInterval: DateInterval? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: self)
        let dayStartString = dateString + "T000000Z"
        let dayEndString = dateString + "T235959Z"
        formatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
        
        
        if let dayStartDate = formatter.date(from: dayStartString), let dayEndDate = formatter.date(from: dayEndString) {
            return DateInterval(start: dayStartDate, end: dayEndDate)
        } else {
            return nil
        }
    }
    
    var dayStart: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: self)
        let dayStartString = dateString + "T000000Z"
        formatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
        return formatter.date(from: dayStartString)! - TimeInterval(TimeZone.current.secondsFromGMT())
    }
    
    var dayEnd: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: self)
        let dayEndString = dateString + "T235959Z"
        formatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
        return formatter.date(from: dayEndString)! - TimeInterval(TimeZone.current.secondsFromGMT())
    }
    
}
