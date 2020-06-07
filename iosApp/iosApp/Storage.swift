//
//  Storage.swift
//  iosApp
//
//  Created by Ivan Murashov on 15.04.20.
//

import CoreData
import UIKit
import app

class Storage {

    private let context: NSManagedObjectContext
    private let dateFormatter = ISO8601DateFormatter()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Save page, and return index of next page for loading
    func savePage(page: Int32, tag: String, posts: [Post]) -> Int32 {

        var nextPage: Int32 = -1
        let one: Int32 = 1

        // Try to fetch last parsed page from coredata
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PageEntity")
        fetchRequest.predicate = NSPredicate(format: "tag == %@ AND page < \(page)", tag)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "page", ascending: false)]

        do {
            let result = try self.context.fetch(fetchRequest)
            if (result.count == 0) {
                // Save page, return page - 1
                if let pageEntity = NSEntityDescription.entity(forEntityName: "PageEntity", in: context) {

                    let pageObject = NSManagedObject(entity: pageEntity, insertInto: context)
                    pageObject.setValue(page, forKey: "page")
                    pageObject.setValue(tag, forKey: "tag")

                    do {
                        try pageObject.managedObjectContext?.save()
                    } catch {
                        let saveError = error as NSError
                        print(saveError)
                    }
                }
                nextPage = page - one
            } else {
                if let managedObject = result.last,
                    let lastKnownPage = managedObject.value(forKey: "page") as? Int32 {
                    nextPage = lastKnownPage - one
                }
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }

        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PostEntity")

        if let postEntity = NSEntityDescription.entity(forEntityName: "PostEntity", in: context) {
            posts.forEach {
                fetchRequest.predicate = NSPredicate(format: "url == %@", $0.url)

                do {
                    let existedPosts = try self.context.fetch(fetchRequest)
                    if existedPosts.isEmpty {
                        let postObject = NSManagedObject(entity: postEntity, insertInto: context)
                        postObject.setValue($0.tags.componentsJoined(by: ",").lowercased()  , forKey: "tags")
                        postObject.setValue($0.url, forKey: "url")
                        let date = dateFormatter.date(from: $0.dateModified)
                        postObject.setValue(date, forKey: "date")

                        try postObject.managedObjectContext?.save()
                    }
                } catch {
                    let saveError = error as NSError
                    print(saveError)
                }
            }
        }


        return nextPage
    }

    /// Fetch posts for tag
    func fetchPosts(tag: String, completion: ([String]) -> Void) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PostEntity")
        fetchRequest.predicate = NSPredicate(format: "tags CONTAINS %@", tag)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        var urls = [String]()

        do {
            let result = try self.context.fetch(fetchRequest)
                for managedObject in result {
                if let url = managedObject.value(forKey: "url") as? String,
                    let dateModified = managedObject.value(forKey: "date") as? Date {
                    print("Append url \(url) with date \(dateModified)")
                    urls.append(url)
                }
            }
        } catch {
            let saveError = error as NSError
            print(saveError)
        }

        completion(urls)
    }
}
