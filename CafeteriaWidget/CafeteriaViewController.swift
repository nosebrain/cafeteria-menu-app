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
        self.listViewController.contents = self.arrayController.arrangedObjects as [AnyObject]
    }
    
    override var nibName: String? {
        return "CafeteriaViewController"
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInset: NSEdgeInsets) -> NSEdgeInsets {
        // Override the left margin so that the list view is flush with the edge.
        return NSEdgeInsets(top: 10, left: -100, bottom: 10, right: 0);
    }
    
    func widgetList(list: NCWidgetListViewController!, viewControllerForRow row: Int) -> NSViewController! {
        return FoodViewController();
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        let today = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitWeekday | .CalendarUnitYear | .CalendarUnitWeekOfYear, fromDate: today)
        let year = components.year
        var weekOfYear = components.weekOfYear
        let weekday = components.weekday
        
        var labelText = "Today"
        if (weekday == 1 || weekday == 7) {
            weekOfYear++
        }
        
        if (weekday == 1) {
            labelText = "Tomorrow"
        }
        
        if (weekday == 7) {
            labelText = "Monday"
        }
        
        self.dayLabel.stringValue = labelText;
        
        if let cafeteria = self.representedObject as? Cafeteria {
            let urlString = NSString(format: "http://localhost:9090/service/%@/%d/%d_%d", cafeteria.universityId!, cafeteria.id!, year, weekOfYear)
            
            println(urlString)
            
            let url = NSURL(string: urlString)
            
            let req = NSURLRequest(URL: url!)
            
            self.data = NSMutableData()
            
            let connection = NSURLConnection(request: req, delegate: self, startImmediately: true)
        }
    }
    

    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        let today = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitWeekday, fromDate: today)
        var weekday = components.weekday
        
        weekday-- // 0 = monday, …
        
        if (weekday < 0 || weekday > 4) {
            weekday = 0;
        }
        
        println("loaded")
        
        // TODO: update view
        
        var parseError: NSError?
        let info: AnyObject? = NSJSONSerialization.JSONObjectWithData(self.data!,
            options: NSJSONReadingOptions.AllowFragments,
            error:&parseError)
        
        let foods = NSMutableArray()
        
        // FIXME: handle error
        if let cafeteria = info as? NSDictionary {
            if let days = cafeteria["days"] as? NSArray {
                if let day = days[weekday] as? NSDictionary {
                    if let food = day["food"] as? NSArray {
                        for menuD in food {
                            if let menu = menuD as?  NSDictionary{
                                let foodO = Food();
                                foodO.desc = menu["description"] as? NSString
                                foods.addObject(foodO);
                            }
                        }
                    }
                }
            }
        }
        
        self.arrayController = NSArrayController(content: foods)
        self.listViewController.contents = self.arrayController.arrangedObjects as [AnyObject]
    }
    
    func connection(connection: NSURLConnection!, didReceiveData conData: NSData!) {
        self.data!.appendData(conData)
    }
}