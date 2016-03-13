//
//  VideosModel.swift
//  Zype
//
//  Created by Pavel Pantus on 3/12/16.
//  Copyright © 2016 Pavel Pantus. All rights reserved.
//

import CoreData
import CocoaLumberjack

final class VideosModel {
    static let sharedInstance = VideosModel()
    private init() {}

    private let entityName = "Video"

    func addEntity(video: TVideo) {
        var cdVideo: Video

        if let existingVideo = videoBy(id: video.identifier) {
            cdVideo = existingVideo
        } else {
            let moc = DBConfigurator.sharedInstance.managedObjectContext
            let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: moc)!
            cdVideo = NSManagedObject(entity: entity, insertIntoManagedObjectContext: moc) as! Video
            cdVideo.identifier = video.identifier
        }

        update(cdVideo, withTVideo: video)
    }

    func videoBy(id id: String) -> Video? {
        let moc = DBConfigurator.sharedInstance.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "identifier == %@", id)
        fetchRequest.predicate = predicate

        do {
            let objects = try moc.executeFetchRequest(fetchRequest)
            return objects.count > 0 ? (objects[0] as! Video) : nil
        } catch let error as NSError {
            DDLogError("Videos model: Perform fetch failed with error: \(error)")
        }
        return nil
    }

    func count() -> Int {
        let moc = DBConfigurator.sharedInstance.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityName)
        return moc.countForFetchRequest(fetchRequest, error: nil)
    }

    func createFRC() -> NSFetchedResultsController {
        let moc = DBConfigurator.sharedInstance.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    }

    private func update(dbVideo: Video, withTVideo: TVideo) {
        if dbVideo.title != withTVideo.title {
            dbVideo.title = withTVideo.title
        }
        if dbVideo.thumbnail != withTVideo.thumbnailURI?.absoluteString {
            dbVideo.thumbnail = withTVideo.thumbnailURI?.absoluteString
        }
    }

    func videos() -> [Video]? {
        let moc = DBConfigurator.sharedInstance.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            let objects = try moc.executeFetchRequest(fetchRequest) as! [Video]
            return objects
        } catch let error as NSError {
            DDLogError("Videos model: Perform fetch failed with error: \(error)")
        }
        return nil
    }
}
