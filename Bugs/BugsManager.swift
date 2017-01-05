//
//  BugsManager.swift
//  Bugs
//
//  Created by Cole Denkensohn on 12/8/16.
//  Copyright © 2016 Cole Denkensohn. All rights reserved.
//

import UIKit
import CoreData

class BugsManager {
    // Singleton (only instance of this class)
    
    static let sharedInstance = BugsManager()
    
    //var managedObjectContext: NSManagedObjectContext
    
    var bugs = [String]()
    
    var count:Int {
        get  {
            return bugs.count
        }
    }
    
    /*func bugAtIndex (index:Int) -> Void {
        return bugs[index]
    }*/
    
    func fetchBugs(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreBugsData")
        request.returnsObjectsAsFaults = false // return as string, not object
        do {
            
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name:String = result.value(forKey: "name") as? String {
                        
                        //print("Name is \(name)")
                        if name != "order"{
                            // Add name to bugs list, as long as it isn't the order row
                            bugs.append(name)
                        }
                        
                    }
                }
            } else{ // No data in CoreBugsData
                
                // Get bug details from CSV
                let bugDetailsFromWeb = getArrayDetails(header: "Name", file: "InitialData", initialData: true)
                var bugNames:[String] = []
                var bugDetails:[[String:String]] = []
                print("Need to get data.")
                // Split CSV data to be stored properly
                for object in bugDetailsFromWeb as! [[String : String]] {
                    // Get object names
                    bugNames.append(object["Name"]!)
                    // Get all non-name details
                    bugDetails.append(object)
                }
                
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
                        //print(key)
                        if detailsR[key] != nil {
                            finalOrderedDictionary.append([key:detailsR[key]!])
                        }
                        
                    }
                    if checkname == "order"{ continue }
                    addBug(newBugName: checkname, newBugDetails: finalOrderedDictionary)
                }
            }
            
            
        } catch {
            fatalError("Failed to save new bug: \(error)")
        }
        
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func fetchBugDetails(forBugName:String)->[Dictionary<String, String>]{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreBugsData")
        request.returnsObjectsAsFaults = false // return as string, not object
        var returnDetails:[Dictionary<String, String>] = []
        do {
            
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name:String = result.value(forKey: "name") as? String {
                        // Add name to bugs list
                        bugs.append(name)
                        if name == forBugName{
                            //print(result.value(forKey: "attributes"))
                            let dictArray = result.value(forKey: "attributes") as! [Dictionary<String, String>]
                            for dict in dictArray {
                                //print(dict)
                                returnDetails.append(dict)
                            }
                            //print(returnDetails)
                            //returnDetails = (result.value(forKey: "attributes") as! NSDictionary) as! Dictionary<String, String>
                        }
                        //print(name)
                        
                    }
                }
            }
            
            
        } catch {
            fatalError("Failed to save new bug: \(error)")
        }
        return returnDetails
        
    }
    
    func addBug(newBugName:String, newBugDetails:[[String:String]]){

        // Get context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newBug = NSEntityDescription.insertNewObject(forEntityName: "CoreBugsData", into: context)
        newBug.setValue(newBugName, forKey: "name")
        newBug.setValue(newBugDetails, forKey: "attributes")
        
        do {
            
            try context.save()
            //print("Saved")
            
        } catch {
            fatalError("Failed to save new bug: \(error)")
        }
        
    }
    
    func deleteAllBugs() -> Void {
        
        // Get context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreBugsData")
        
        let result = try? context.fetch(fetchRequest)
        let resultData = result
        
        for object in resultData! {
            context.delete(object as! NSManagedObject)
        }
        
        do {
            try context.save()
            //print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }
    
    func getVersionNumber()->String{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        request.returnsObjectsAsFaults = false // return as string, not object
        var returnVersion = "1.0.x"
        do {
            
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let version:String = result.value(forKey: "version") as? String {
                        
                        returnVersion = version
                        //print("Version from DB: \(version)")
                        
                    }
                }
            } else{
                returnVersion = "update"
                //print("No version in database")
            }
            
            
        } catch {
            fatalError("Failed to save new bug: \(error)")
        }
        
        return returnVersion
        
    }
    func setVersionNumber(newVersionNumber:String){
        
        // Get context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newBug = NSEntityDescription.insertNewObject(forEntityName: "Settings", into: context)
        newBug.setValue(newVersionNumber, forKey: "version")
        
        do {
            
            try context.save()
            //print("Saved version number")
            
        } catch {
            fatalError("Failed to save new bug: \(error)")
        }
        
    }
    func deleteAllSettings() -> Void {
        
        // Get context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        
        let result = try? context.fetch(fetchRequest)
        let resultData = result
        
        for object in resultData! {
            context.delete(object as! NSManagedObject)
        }
        
        do {
            try context.save()
            //print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }
    
    //BEGIN: CSV Functions
    var  CSVdata:[[String:String]] = []
    var  CSVcolumnTitles:[String] = []
    
    func getArrayItemsAtHeader(header:String, file:String)->Array<String>{
        
        convertCSV(file: readDataFromFile(file: file), order: false)
        var bugItemsFromWeb:[String] = []
        for object in CSVdata {
            //print(object)
            if object[header]! == header {
                // Header row, ignore
            } else {
                bugItemsFromWeb.append(object[header]!)
            }
        }
        
        return bugItemsFromWeb
        
    }
    func getArrayDetails(header:String, file:String, initialData:Bool=false)->Array<Any>{
        
        if initialData == true{
            convertCSV(file: readInitialData(file: file))
        } else {
            convertCSV(file: readDataFromFile(file: file))
        }
        var bugDetailsFromWeb:[[String:String]] = []
        for object in CSVdata {
            var cleanObject = object
            if object[header]! == header {
                // Header row, ignore
            } else {
                for nullObject in object { // Look for empty keys (coming from CSV with empty value in row
                    if nullObject.value == ""{
                        //print("Possible null \(nullObject)")
                        cleanObject.removeValue(forKey: nullObject.key)
                    }
                }
                bugDetailsFromWeb.append(cleanObject)
            }
        }
        
        return bugDetailsFromWeb
        
    }
    func cleanRows(file:String)->String{
        //use a uniform \n for end of lines.
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
    
    func getStringFieldsForRow(row:String, delimiter:String)-> [String]{
        return row.components(separatedBy: delimiter)
    }
    
    func convertCSV(file:String, order:Bool=true){
        let rows = cleanRows(file: file).components(separatedBy: "\n")
        if rows.count > 0 {
            CSVdata = []
            CSVcolumnTitles = getStringFieldsForRow(row: rows.first!,delimiter:",")
            if order == true{
                // Add order of columns as first row
                var orderedHeaders:[String:String] = [:]
                var count:Int = 0
                for key in CSVcolumnTitles{
                    orderedHeaders.updateValue(String(count), forKey: key)
                    count += 1
                }
                CSVdata.append(orderedHeaders)
            }
            for row in rows{
                let fields = getStringFieldsForRow(row: row,delimiter: ",")
                if fields.count != CSVcolumnTitles.count {continue}
                var dataRow = [String:String]()
                for (index,field) in fields.enumerated(){
                    dataRow[CSVcolumnTitles[index]] = field
                }
                CSVdata += [dataRow]
            }
            //print(CSVdata)
        } else {
            print("No data in file")
        }
    }
    
    func readDataFromFile(file:String)-> String!{
        guard let url = URL(string: file)
            //guard let filepath = Bundle.main.path(forResource: file, ofType: "txt")
            else {
                return nil
        }
        do {
            let contents = try String(contentsOf: url)
            //let contents = try String(contentsOfFile: filepath, encoding: String.Encoding.utf8)
            return contents
        } catch {
            print ("File Read Error")
            return nil
        }
    }
    func readInitialData(file:String)-> String!{
        guard let filepath = Bundle.main.path(forResource: file, ofType: "csv")
            else {
                return nil
        }
        do {
            let contents = try String(contentsOfFile: filepath, encoding: String.Encoding.utf8)
            return contents
        } catch {
            print ("File Read Error")
            return nil
        }
    }
    //END: CSV Functions
    
    
    private init() {
        // Fetch bugs from CoreBugsData (or add initial data if empty)
        fetchBugs()
    }
}
