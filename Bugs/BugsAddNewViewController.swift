//
//  BugsAddNewViewController.swift
//  Bugs
//
//  Created by Cole Denkensohn on 12/21/16.
//  Copyright © 2016 Cole Denkensohn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BugsAddNewViewController: UIViewController {

    @IBOutlet weak var NewBugName: UITextField!
    
    // Save button pressed
    @IBAction func SaveButton(_ sender: Any) {
        
        // Save new bug
        let SaveNewBugName: String = NewBugName.text!
        BugsManager.sharedInstance.addBug(newBugName: SaveNewBugName)
        print("Save new bug \(SaveNewBugName)")
        
        // Dismiss view
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CancelButton(_ sender: Any) {
        // Dismiss view
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
