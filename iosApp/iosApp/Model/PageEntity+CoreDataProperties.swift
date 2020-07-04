//
//  PageEntity+CoreDataProperties.swift
//  iosApp
//
//  Created by Ivan Murashov on 29.06.20.
//
//

import Foundation
import CoreData


extension PageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PageEntity> {
        return NSFetchRequest<PageEntity>(entityName: "PageEntity")
    }

    @NSManaged public var page: Int32
    @NSManaged public var tag: String?

}
