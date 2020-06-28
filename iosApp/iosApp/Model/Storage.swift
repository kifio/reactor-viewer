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
        self.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Save posts, and return index of next page for loading
    func savePage(page: Int32, tag: String, posts: [Post]) -> Int32 {
        savePosts(posts: posts)
        return getNextPageIndex(page: page, tag: tag)
    }

    /// Save all new posts, rewrite existed
    private func savePosts(posts: [Post]) {
        posts.forEach {
            let postEntity = PostEntity(context: context)
            postEntity.tags = $0.tags.componentsJoined(by: ",").lowercased()
            postEntity.url = $0.url
            postEntity.date = dateFormatter.date(from: $0.dateModified)
        }

        do {
            try context.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
    }

    /// Try to fetch last parsed page from coredata. If tag have no pages in storage, return
    private func getNextPageIndex(page: Int32, tag: String) -> Int32 {
        // First, check if current page exist in database.
        let fetchRequest: NSFetchRequest<PageEntity> = PageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tag == %@ AND page == %d", tag, page)
        do {
            let result = try self.context.fetch(fetchRequest)
            if (result.count != 0) {
                // Page exists.
                // That's mean we should find earliest page in storage, and continue fetching from it, for skipping already fetched pages.
                fetchRequest.predicate = NSPredicate(format: "tag == %@ AND page < %d", tag, page)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "page", ascending: true)]
                fetchRequest.fetchLimit = 1

                let pageEntities = try context.fetch(fetchRequest)

                if let earliestPage = pageEntities.first {
                    return earliestPage.page - 1
                } else {
                    return Int32(page - 1)
                }
            } else {
                // Page not exists.
                // That's mean we should save this page and fetch next page.
                let pageEntity = NSEntityDescription.insertNewObject(forEntityName: "PageEntity", into: context) as! PageEntity
                pageEntity.page = page
                pageEntity.tag = tag
                try context.save()
                return Int32(page - 1)
            }
        } catch {
            print(error.localizedDescription)
            return Int32(page - 1)
        }
    }

    /// Fetch posts for tag
    func fetchPosts(tag: String, completion: ([String]) -> Void) {
        let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tags CONTAINS %@", tag)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        var urls = [String]()

        do {
            let result = try self.context.fetch(fetchRequest)
            for postEntity in result {
                if let url = postEntity.url, let dateModified = postEntity.date {
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
