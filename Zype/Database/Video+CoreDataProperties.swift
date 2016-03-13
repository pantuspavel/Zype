//
//  Video+CoreDataProperties.swift
//  Zype
//
//  Created by Pavel Pantus on 3/12/16.
//  Copyright © 2016 Pavel Pantus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Video {

    @NSManaged var identifier: String?
    @NSManaged var thumbnail: String?
    @NSManaged var title: String?

}
