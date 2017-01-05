//
//  bugsTableViewController.swift
//  Bugs
//
//  Created by Cole Denkensohn on 12/7/16.
//  Copyright © 2016 Cole Denkensohn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BugsTableViewController: UIViewController, UITableViewDataSource, UITabBarDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchDisplayDelegate {
    
    
    @IBOutlet weak var BugsTable: UITableView!

    
    var bugsList = BugsManager.sharedInstance.bugs // Array of bugs from BugsManager
    var bugsSearchResults:[String] = [] // Array of bugs from search results
    var shouldShowSearchResults = false // Search was performed
    let searchController = UISearchController(searchResultsController: nil)
    
    
    // Table View Data Source Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults { // Search view
            return bugsSearchResults.count
        }
        return bugsList.count // Get number of bugs from BugsManager
    }
    
    // Provide a cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = BugsTable.dequeueReusableCell(withIdentifier: "BugsTableCell")!
        
        var bugName : String!
        if shouldShowSearchResults { // Search view
            bugName = bugsSearchResults[indexPath.row]
        } else { // No search was made
            bugName = bugsList[indexPath.row]
        }
        
        cell.textLabel?.text = bugName
        
        // Get bug type
        let bugDetails = BugsManager.sharedInstance.fetchBugDetails(forBugName: bugName)
        var bugType = "unknown"
        for item in bugDetails {
            for (key,value) in item{
                if key == "Type"{
                    bugType = value
                }
            }
        }
        
        // Choose which image to add
        if bugType == "Bacteria" {
            bugType = "Table Icon - Bacteria - 0"
        } else if bugType == "Virus"{
            bugType = "Table Icon - Virus - 0"
        } else if bugType == "Protozoa"{
            bugType = "Table Icon - Protozoa - 0"
        } else {
            bugType = "Table Icon - Unknown"
        }
        
        // Add left image based on type
        let image : UIImage = UIImage(named: bugType)!
        cell.imageView?.image = image
        
        return cell
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set bugs array to null, fetch new bugs from database, set the current array to the pulled bugs, and reload the data
        BugsManager.sharedInstance.bugs = [String]()
        BugsManager.sharedInstance.fetchBugs()
        bugsList = BugsManager.sharedInstance.bugs
        BugsTable.reloadData()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // Send data to detail view when someone taps a cell
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "bugDetailSegue" {

            if let indexPath = BugsTable.indexPathForSelectedRow {
                
                let DestViewController : BugDetailViewController = segue.destination as! BugDetailViewController
                
                if shouldShowSearchResults && searchController.searchBar.text != "" {
                    DestViewController.passedName = bugsSearchResults[indexPath.row]
                } else {
                    DestViewController.passedName = bugsList[indexPath.row]
                }
                
            }
        
        }

    }
    
    
    // BEGIN: Handle Search
    
    func updateSearchResults(for searchController: UISearchController){

        filterContent(searchText: self.searchController.searchBar.text!)
 
    }
    override func viewWillDisappear(_ animated: Bool) { // remove searchbar after segue
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    func filterContent(searchText:String) {
        
        bugsSearchResults = bugsList.filter { bugs in
            let username = bugs
            return(username.lowercased().contains(searchText.lowercased()))
        }
        if(bugsSearchResults.count == 0){
            shouldShowSearchResults = false
        } else {
            shouldShowSearchResults = true
        }
        BugsTable.reloadData()
    }
    
    // END: Handle Search
    
    // View LIFECYCLE BELOW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        BugsTable.tableHeaderView = searchController.searchBar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Get bug details from CSV
        let bugDetailsFromWeb = BugsManager.sharedInstance.getArrayDetails(header: "Name", file: "https://docs.google.com/spreadsheets/d/1xE_39C3oGA4D3IPGPuSU0ajuBZ1l1nLAzXX2lKG-Ie0/pub?gid=0&single=true&output=csv")
        //print(bugDetailsFromWeb)
        var bugNames:[String] = []
        var bugDetails:[[String:String]] = []
        
        // Split CSV data to be stored properly
        for object in bugDetailsFromWeb as! [[String : String]] {
            // Get object names
            bugNames.append(object["Name"]!)
            // Get all non-name details
            bugDetails.append(object)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

