//
//  Storage.swift
//  iosApp
//
//  Created by Ivan Murashov on 15.04.20.
//

import CoreData
import UIKit
import common

class Storage {

    private let context: NSManagedObjectContext
    private let dateFormatter = ISO8601DateFormatter()

    init(context: NSManagedObjectContext) {
        self.context = context
        self.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Save posts, and return index of next page for loading
    func savePage(page: Int32, tag: String, posts: [Post]) -> Int32 {
        savePosts(tag: tag, posts: posts)
        return getNextPageIndex(page: page, tag: tag)
    }

    /// Save all new posts, rewrite existed
    private func savePosts(tag: String, posts: [Post]) {
        for post in posts {
            let entity = NSEntityDescription.entity(forEntityName: "PostEntity", in: context)!
            let postEntity = PostEntity(entity: entity, insertInto: context)

            postEntity.id = post.id
            postEntity.tags = tag
            postEntity.date = dateFormatter.date(from: post.dateModified)
            postEntity.url = post.url

            for url in post.urls {
                let entity = NSEntityDescription.entity(forEntityName: "PostImageEntity", in: context)!
                let postImage = PostImageEntity(entity: entity, insertInto: context)
                postImage.id = post.id
                postImage.url = url
            }

            do {
                   try context.save()
               } catch {
                   let saveError = error as NSError
                   print(saveError.localizedDescription)
               }
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
                let entity = NSEntityDescription.entity(forEntityName: "PageEntity", in: context)!
                let pageEntity = PageEntity(entity: entity, insertInto: context)
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
    func fetchPosts(tag: String, laterThen: Date?, completion: ([PostEntity]) -> Void) {
        let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        if let date = laterThen {
            fetchRequest.predicate = NSPredicate(format: "tags CONTAINS %@ AND date < %@", tag, date as NSDate)
        } else {
            fetchRequest.predicate = NSPredicate(format: "tags CONTAINS %@", tag)
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            let result = try self.context.fetch(fetchRequest)
            completion(result)
        } catch {
            let saveError = error as NSError
            print(saveError)
            completion([PostEntity]())
        }

    }

    /// Fetch all images from post
    func fetchImagesUrls(for postId: String, completion: ([String]) -> Void) {
        let fetchRequest: NSFetchRequest<PostImageEntity> = PostImageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", postId)

        var urls = [String]()

        do {
            let result = try self.context.fetch(fetchRequest)
            for postImageEntity in result {
                if let url = postImageEntity.url {
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
