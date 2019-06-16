//
//  TableViewController.swift
//  TimeDecisionMaker
//
//  Created by Sasha Myshkina on 5/30/19.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TimeDecisionConfigurator {
    
    
    var freeSlots: [DateInterval] = []
    var decisionMaker = RDTimeDecisionMaker()
    var a = Bundle.main.path(forResource: "A", ofType: "ics")
    var b = Bundle.main.path(forResource: "B", ofType: "ics")
    
    var day: DateInterval?
    var duration: TimeInterval = 3600
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        updateTimeSlots()
        
    }
    
    func updateTimeSlots() {
        
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            if let day = self.day {
                freeSlots = decisionMaker.suggestAppointments(icsFilePath: a!, duration: self.duration, dayInterval: day)
            } else {
                freeSlots = decisionMaker.suggestAppointments(icsFilePath: a!, duration: self.duration)
            }
        case 1:
            if let day = self.day {
                freeSlots = decisionMaker.suggestAppointments(icsFilePath: b!, duration: self.duration, dayInterval: day)
            } else {
                freeSlots = decisionMaker.suggestAppointments(icsFilePath: b!, duration: self.duration)
            }
        default:
            if let day = self.day {
                freeSlots = decisionMaker.suggestAppointments(organizerICS: a!, attendeeICS: b!, duration: self.duration, dayInterval: day)
            } else {
                freeSlots = decisionMaker.suggestAppointments(organizerICS: a!, attendeeICS: b!, duration:
                    self.duration)
            }
        }
        
        tableView.reloadData()
    }
    
    
    
    @IBAction func tappedToChangePerson(_ sender: Any) {
        updateTimeSlots()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return freeSlots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCell
        
        let formatter = DateFormatter()
        
        
        formatter.dateFormat = "dd"
        
        cell.dayLabel?.text = formatter.string(from: freeSlots[indexPath.row].start)
        cell.dayTwoLabel?.text = formatter.string(from: freeSlots[indexPath.row].end)
        
        
        
        formatter.dateFormat = "MMMM"
        
        cell.monthLabel?.text = formatter.string(from: freeSlots[indexPath.row].start)
        cell.monthTwoLabel?.text = formatter.string(from: freeSlots[indexPath.row].end)
        
        
        formatter.dateFormat = "HH:mm"
        
        cell.endInterval?.text = formatter.string(from: freeSlots[indexPath.row].end)
        cell.startInterval?.text = formatter.string(from: freeSlots[indexPath.row].start)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90.0
    }
}


protocol TimeDecisionConfigurator {
    
    var duration: TimeInterval { get set }
    var day: DateInterval? { get set }
}



class CustomCell: UITableViewCell {
    
    @IBOutlet weak var startInterval: UILabel!
    @IBOutlet weak var endInterval: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayTwoLabel: UILabel!
    @IBOutlet weak var monthTwoLabel: UILabel!
}

