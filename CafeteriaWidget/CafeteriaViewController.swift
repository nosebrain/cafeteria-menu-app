//
//  CafeteriaViewController.swift
//  Cafeteria
//
//  Created by Daniel Zoller on 25.01.15.
//  Copyright (c) 2015 nosebrain. All rights reserved.
//

import Cocoa
import NotificationCenter

class CafeteriaViewController : NSViewController, NCWidgetListViewDelegate {
    
    @IBOutlet var listViewController: NCWidgetListViewController!
    @IBOutlet var dayLabel : NSTextField!
    
    var arrayController : NSArrayController!
    var data : NSMutableData?
    
    var minimumVisibleRowCount: Int {
        return 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.arrayController = NSArrayController(content: NSArray())
        self.listViewController.contents = self.arrayController.arrangedObjects as! [AnyObject]
    }
    
    override var nibName: String? {
        return "CafeteriaViewController"
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInset: NSEdgeInsets) -> NSEdgeInsets {
        // Override the left margin so that the list view is flush with the edge.
        return NSEdgeInsets(top: 10, left: -100, bottom: 10, right: 0);
    }
    
    @IBAction func openCafeteriaPage(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(self.getCafeteria().url!)
    }
    
    func widgetList(list: NCWidgetListViewController!, viewControllerForRow row: Int) -> NSViewController! {
        if (self.getCafeteria().closed) {
            return InfoViewController();
        }
        return FoodViewController();
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        let today = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Weekday, .Year, .WeekOfYear], fromDate: today)
        let year = components.year
        var weekOfYear = components.weekOfYear
        let weekday = components.weekday
        
        
        if (weekday == 1 || weekday == 7) {
            weekOfYear++
        }
        
        let cafeteria = self.getCafeteria();
        let urlString = String(format: "https://nosebrain.myqnapcloud.com/service/%@/%d/%d_%d.json", cafeteria.universityId!, cafeteria.id!, year, weekOfYear)
        
        print(urlString)
        
        let url = NSURL(string: urlString as String)
        
        let req = NSURLRequest(URL: url!)
        
        self.data = NSMutableData()
        
        // make the request
        let connection = NSURLConnection(request: req, delegate: self, startImmediately: true)
    }
    
    func getCafeteria() -> Cafeteria {
        return self.representedObject as! Cafeteria
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        let today = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Weekday, .Hour], fromDate: today)
        var weekday = components.weekday
        let hour = components.hour
        
        weekday -= 2 // 0 = monday, …
        
        if (weekday < 0 || weekday > 4) {
            weekday = 0;
        }
        
        let cafeteria = self.getCafeteria()
        cafeteria.closed = false;
        
        // TODO: update view
        do {
            let info = try NSJSONSerialization.JSONObjectWithData(self.data!, options: NSJSONReadingOptions.AllowFragments)
            let foods = NSMutableArray()
            
            if let jsonCafeteria = info as? NSDictionary {
                if let closed = jsonCafeteria["closed"] as? Bool {
                    if (closed) {
                        cafeteria.closed = true
                        self.arrayController = NSArrayController()
                        self.listViewController.contents = self.arrayController.arrangedObjects as! [AnyObject]
                    }
                } else {
                    if let days = jsonCafeteria["days"] as? NSArray {
                        if let day = days[weekday] as? NSDictionary {
                            
                            if let holidayJson = day["holiday"] as? Bool {
                                if (holidayJson) {
                                    cafeteria.closed = true
                                }
                            }
                            
                            if let food = day["food"] as? NSArray {
                                for menuD in food {
                                    if let menu = menuD as?  NSDictionary{
                                        let foodO = Food();
                                        foodO.desc = menu["description"] as? String
                                        foods.addObject(foodO);
                                    }
                                }
                            }
                        }
                    }
                    self.arrayController = NSArrayController(content: foods)
                    self.listViewController.contents = self.arrayController.arrangedObjects as! [AnyObject]
                }
            }
        } catch let error as NSError {
            // FIXME: handle error
        }
        
        var labelText = "Closed"
        
        if (!cafeteria.closed) {
            labelText = "Today"
            // weekday = Sunday => we will show Monday
            if (weekday == 1) {
                labelText = "Tomorrow"
            }
            
            if (weekday == 7) {
                labelText = "Monday"
            }
            
            // if cafeteria is closed show the menu for tomorrow
            if (hour > 16 && weekday != 7) {
                weekday++;
                labelText = "Tomorrow"
            }
        }
        
        self.dayLabel.stringValue = labelText;
    }
    
    func connection(connection: NSURLConnection!, didReceiveData conData: NSData!) {
        self.data!.appendData(conData)
    }
}