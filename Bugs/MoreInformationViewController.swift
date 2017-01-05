//
//  SecondViewController.swift
//  Bugs
//
//  Created by Cole Denkensohn on 12/7/16.
//  Copyright © 2016 Cole Denkensohn. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController {

    
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var webVersionLabel: UILabel!
    
    @IBOutlet var updateBugsButton: UIButton!
    @IBAction func updateBugsButton(_ sender: UIButton) {
        self.versionLabel.text = "x.x.x" // Set temporary version label
        
        if self.versionLabel.text == self.webVersionLabel.text {
            // Do a second check of the version just in case. Update button should be disabled if versions are the same, so this should never happen.
            //print("Nothing to update (second catch)")
        } else{
            //print("Versions different, updating CoreData to reflect new data")
            
            // Get bug details from CSV
            let bugDetailsFromWeb = BugsManager.sharedInstance.getArrayDetails(header: "Name", file: "https://docs.google.com/spreadsheets/d/1xE_39C3oGA4D3IPGPuSU0ajuBZ1l1nLAzXX2lKG-Ie0/pub?gid=0&single=true&output=csv")
            var bugNames:[String] = []
            var bugDetails:[[String:String]] = []
            
            // Split CSV data to be stored properly
            for object in bugDetailsFromWeb as! [[String : String]] {
                // Get object names
                bugNames.append(object["Name"]!)
                // Get all non-name details
                bugDetails.append(object)
            }
            
            updateBugsButton.isEnabled = false // Disable the update button
            self.versionLabel.text = "Updating"
            

            // Delete CoreBugsData
            BugsManager.sharedInstance.deleteAllBugs()
            
            // Add new bugs from web
            /* The difficulty here is that Dictionary Arrays are not ordered, but we need to get the data columns in the same order as the Admin inputs them (i.e. General should come before Treatment). The solution was to store the column headers as soon as they come in in the correct order and then loop through the dictionary adding it as a nested array to maintain the order. */
            var orderedHeaders:[String] = []
            for (name, details) in zip(bugNames, bugDetails) {
                var detailsR = details
                detailsR.removeValue(forKey: "Name") // No need to store bug name in details
                var checkname = name
                var finalOrderedDictionary:[[String:String]] = []
                if checkname == String(0) {
                    checkname = "order"
                    
                    let orderedDetailsR = detailsR.sorted{ $0.1 < $1.1 }
                    
                    for (key,_) in orderedDetailsR {
                        orderedHeaders.append(key)
                    }
                } else{
                    checkname = name
                }
                for key in orderedHeaders{
                    if detailsR[key] != nil {
                        finalOrderedDictionary.append([key:detailsR[key]!])
                    }
                    
                }
                if checkname == "order"{ continue }
                //addBug(newBugName: checkname, newBugDetails: finalOrderedDictionary)
                BugsManager.sharedInstance.addBug(newBugName: name, newBugDetails: finalOrderedDictionary)
            }
            
            // Clean up version numbers
            BugsManager.sharedInstance.deleteAllSettings() // Delete current CoreData version
            BugsManager.sharedInstance.setVersionNumber(newVersionNumber: self.webVersionLabel.text!) // Set CoreData version to web version
            self.versionLabel.text = self.webVersionLabel.text // Set versions the same
            
            // Notify user of updated data
            let alert = UIAlertController(title: "Data Updated", message: "You now have the most current data available for use offline.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Get app data version number from CoreData
        self.versionLabel.text = BugsManager.sharedInstance.getVersionNumber()
        
        if Reachability.isConnectedToNetwork() == true { // Ensure user has internet
            // Get web version number from CSV
            self.webVersionLabel.text = BugsManager.sharedInstance.getArrayItemsAtHeader(header: "version", file: "https://docs.google.com/spreadsheets/d/1xE_39C3oGA4D3IPGPuSU0ajuBZ1l1nLAzXX2lKG-Ie0/pub?gid=639913403&single=true&output=csv")[0]
            if self.versionLabel.text == self.webVersionLabel.text {
                // App version is the same as web version
            } else{
                // App version is different from web version (allow update by enabling update button)
                updateBugsButton.isEnabled = true
            }
        } else { // Do not allow update if internet is unavailable
            print("Internet Connection not Available!")
            self.webVersionLabel.text = "Offline"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

