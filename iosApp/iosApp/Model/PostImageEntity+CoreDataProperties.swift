//
//  PostImageEntity+CoreDataProperties.swift
//  iosApp
//
//  Created by Ivan Murashov on 29.06.20.
//
//

import Foundation
import CoreData


extension PostImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostImageEntity> {
        return NSFetchRequest<PostImageEntity>(entityName: "PostImageEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var url: String?
}
