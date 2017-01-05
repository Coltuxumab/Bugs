//
//  CoreBugs+CoreDataProperties.swift
//  Bugs
//
//  Created by Cole Denkensohn on 12/8/16.
//  Copyright © 2016 Cole Denkensohn. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension CoreBugsData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreBugs> {
        return NSFetchRequest<CoreBugs>(entityName: "CoreBugsData");
    }

    @NSManaged public var name: String?

}
