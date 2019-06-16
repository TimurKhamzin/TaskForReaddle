

import Foundation

struct NewParser {
    
    var dateFormatter = DateFormatter()
    
    var timeZone: String? = nil
    var longDate = "yyyyMMdd'T'HHmmssZ"
    var shortDate = "yyyyMMdd"
    
    
    
    private func getKeyValue(line: String) -> (key: String, value: String) {
        if let index = line.firstIndex(of: ":") {
            let key = String(line[..<index])
            let value = String(line[index...].dropFirst())
            return (key,value)
        } else {
            return (line, "")
        }
    }
    
    
    
    
    //Парсер для таймзоны
    func parseTimeZone(content: String) -> TimeZone? {
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let key = getKeyValue(line: line).key
            let value = getKeyValue(line: line).value
            if key == "X-WR-TIMEZONE" {
                return TimeZone(identifier: value)
            }
        }
        return nil
    }
    
    
    
    
    
    
    //Парсер для ивента
    func parseEvent(content: String) -> Appointment? {
        
        var start: Date?
        var end: Date?
        var summary: String?
        var transparency: Appointment.Transparency?
        
        
        let lines = content.components(separatedBy: .newlines)
        for everyLine in lines {
            let key = getKeyValue(line: everyLine).key, value = getKeyValue(line: everyLine).value
            switch key {
            case "DTSTART", "DTSTART;VALUE=DATE":
                start = formatDate(dateString: value)
            case "DTEND", "DTEND;VALUE=DATE":
                end = formatDate(dateString: value)
            case "SUMMARY":
                summary = value
            case "TRANSP":
                transparency = Appointment.Transparency(rawValue: value)
                
            default: continue
            }
        }
        if let start = start, let end = end, let transparency = transparency {
            return Appointment(start: start, end: end, summary: summary, transparency: transparency)
        } else {
            return nil
        }
    }
    
    
    
    
    
    
    
    //Массив ивентов
    func returnEvents(icsContent: String) -> [Appointment]{
        
        var appointments: [Appointment] = []
        
        let veventsBlocks = icsContent.components(separatedBy: "BEGIN:VEVENT")
        
        for vevent in veventsBlocks {
            if let appointment = self.parseEvent(content: vevent) {
                appointments.append(appointment)
            }
        }
        
        return appointments
        
    }
    
    func returnEventfromPath(fromFilePath: String) -> [Appointment] {
        do {
            let content = try String(contentsOfFile: fromFilePath)
            return returnEvents(icsContent: content)
        } catch {
            return []
        }
    }
    
    
    
    
    
    
    //Преобразование строки в дату нужного формата
    
    func formatDate(dateString: String) -> Date?{
        self.dateFormatter.dateFormat = self.longDate
        if let date = self.dateFormatter.date(from: dateString) {
            return date
        } else {
            self.dateFormatter.dateFormat = self.shortDate
            
            if let date = self.dateFormatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
    
}
