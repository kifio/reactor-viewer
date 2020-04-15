//
//  Storage.swift
//  iosApp
//
//  Created by Ivan Murashov on 15.04.20.
//

import CoreData
import app

class Storage {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Save page, and return index of next page for loading
    func savePage(page: Int, posts: [Post]) -> Int {
        let pageEntity = NSEntityDescription.entity(forEntityName: "PageEntity", in: context)
        let pageObject = NSManagedObject(entity: pageEntity!, insertInto: context)
//        pageObject.setValue(session.id, forKey: "id")

        do {
            try pageObject.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }

        let pointsEntity = NSEntityDescription.entity(forEntityName: "PostEntity", in: context)

        return 0
    }

    /// Fetch posts for tag
    func fetchPosts(tag: String, completion: ([Post]) -> Void) {
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PostEntity")
    }
}
