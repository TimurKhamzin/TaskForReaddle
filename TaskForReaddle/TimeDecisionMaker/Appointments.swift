//
//  Appointments.swift
//  TimeDecisionMaker
//
//  Created by Timur Khamzin on 16.06.2019.
//

import Foundation

struct Appointment {
    
    
    var start: Date
    
    var end: Date
    
    var startInLocalTimeZone: Date {
        return start + TimeInterval(TimeZone.current.secondsFromGMT())
    }
    
    var endInLocalTimeZone: Date {
        return end + TimeInterval(TimeZone.current.secondsFromGMT())
    }
    
    var summary: String?
    
    enum Transparency: String {
        case OPAQUE
        case TRANSPARENT
    }
    
    var transparency: Transparency = Transparency.TRANSPARENT
    
    var isBusy: Bool {
        return transparency == Transparency.OPAQUE ? true : false
    }
}
