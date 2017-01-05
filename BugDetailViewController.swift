//
//  BugDetailViewController.swift
//  Bugs
//
//  Created by Cole Denkensohn on 12/8/16.
//  Copyright © 2016 Cole Denkensohn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BugDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var DetailTable: UITableView!
    @IBOutlet var detailTitle: UINavigationItem!
    
    var passedName:String = "Default Name"
    
    var section:[String] = []
    var items:[[String]] = []
    
    // Get sections and items and split
    let myArray:[[String:String]] = [
        ["General": "Gram positive; Anaerobe", "Type": "Bacteria", "Name": "Acinetobacter", "Treatment": "Antibiotic 1; Antibiotic 2; Antibiotic 3"],
        ["General": "Icosahedral, Positive ssRNA", "Type": "Virus", "Name": "CMV", "Treatment": "Valgancyclovir"],
        ["General": "Gram positive; Aerobe", "Type": "Bacteria", "Name": "E. coli", "Treatment": "Antibiotic 1; Antibiotic 2; Antibiotic 3"]
    ]

    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Get Detail table sections and items from CoreBugsData
        var sectionFormatted:[String] = []
        var itemsFormatted:[[String]] = []
        
        // Get details from CoreBugsData for specific name passed from BugsTableViewController
        let dataArray = BugsManager.sharedInstance.fetchBugDetails(forBugName: passedName)
        let obj = dataArray as [Dictionary<String, String>]
        for item in obj {
            for (key, value) in item { // Loop through bug detail data setting key = column name, value = column detail
                sectionFormatted.append(key)
                itemsFormatted.append((value as AnyObject).components(separatedBy: "; ")) // Break out detail by semicolons, as formatted in CSV
            }
        }
        
        section = sectionFormatted
        items = itemsFormatted
        
    }

    // Set up tables
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section [section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath as IndexPath)
        cell.textLabel?.text = self.items[indexPath.section][indexPath.row]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.detailTitle.title = passedName
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
