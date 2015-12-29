//
//  TodayViewController.swift
//  CafeteriaWidget
//
//  Created by Daniel Zoller on 25.01.15.
//  Copyright (c) 2015 nosebrain. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding, NCWidgetListViewDelegate {

    @IBOutlet var listViewController: NCWidgetListViewController!
    var arrayController : NSArrayController!
    var cafeteriaControllers : NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let caf = Cafeteria()
        caf.university = "Universität Würzburg"
        caf.universityId = "uni-wue"
        caf.id = 1
        caf.url = NSURL(string: "http://www.studentenwerk-wuerzburg.de/essen-trinken/speiseplaene/plan/show/frankenstube-wuerzburg.html")
        caf.name = "Frankenstube"
        
        let caf2 = Cafeteria()
        caf2.university = "Universität Würzburg"
        caf2.universityId = "uni-wue"
        caf2.id = 2
        caf2.url = NSURL(string: "http://www.studentenwerk-wuerzburg.de/essen-trinken/speiseplaene/plan/show/mensa-am-hubland-wuerzburg.html")
        caf2.name = "Mensa am Hubland"
        
        let caf3 = Cafeteria()
        caf3.university = "Universität Würzburg"
        caf3.universityId = "uni-wue"
        caf3.id = 6
        caf3.url = NSURL(string: "http://www.studentenwerk-wuerzburg.de/essen-trinken/speiseplaene/plan/show/mensateria-campus-nord.html")
        caf3.name = "Mensateria Campus Nord"
        
        self.arrayController = NSArrayController(content: NSArray(array: [caf, caf2, caf3] ))
        self.listViewController.contents = self.arrayController.arrangedObjects as! [AnyObject]
    }
    
    override var nibName: String? {
        return "TodayViewController"
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInset: NSEdgeInsets) -> NSEdgeInsets {
        // Override the left margin so that the list view is flush with the edge.
        return NSEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        
        for controller in self.cafeteriaControllers {
            controller.widgetPerformUpdateWithCompletionHandler(completionHandler);
        }
        
        completionHandler(.NoData)
    }
    
    func widgetList(list: NCWidgetListViewController!, viewControllerForRow row: Int) -> NSViewController! {
        let controller = CafeteriaViewController()
        
        self.cafeteriaControllers.addObject(controller)
        
        return controller
    }
}
