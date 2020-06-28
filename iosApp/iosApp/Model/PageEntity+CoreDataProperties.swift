//
//  PageEntity+CoreDataProperties.swift
//  iosApp
//cd
//  Created by Ivan Murashov on 28.06.20.
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
