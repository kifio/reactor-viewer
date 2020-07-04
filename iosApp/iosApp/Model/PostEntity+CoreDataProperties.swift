//
//  PostEntity+CoreDataProperties.swift
//  iosApp
//
//  Created by Ivan Murashov on 29.06.20.
//
//

import Foundation
import CoreData


extension PostEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostEntity> {
        return NSFetchRequest<PostEntity>(entityName: "PostEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: String?
    @NSManaged public var tags: String?
    @NSManaged public var url: String?

}
