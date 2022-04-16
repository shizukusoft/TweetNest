//
//  FetchedResultsController.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/03/19.
//

import SwiftUI
import CoreData
import OrderedCollections
import UnifiedLogging

class FetchedResultsController<Element>: NSObject, NSFetchedResultsControllerDelegate where Element: NSManagedObject {
    private lazy var fetchedResultsController: NSFetchedResultsController<Element> = newFetchedResultsController()

    private let errorHandler: (@Sendable (Error) -> Void)?

    let managedObjectContext: NSManagedObjectContext
    var fetchRequest: NSFetchRequest<Element> {
        didSet {
            fetchedResultsController = newFetchedResultsController()
        }
    }
    var cacheName: String? {
        didSet {
            fetchedResultsController = newFetchedResultsController()
        }
    }

    var fetchedObjects: OrderedSet<Element> {
        if fetchedResultsController.fetchedObjects == nil {
            managedObjectContext.performAndWait {
                guard fetchedResultsController.fetchedObjects == nil else { return }

                do {
                    self.objectWillChange.send()
                    try fetchedResultsController.performFetch()
                } catch {
                    Logger().error("Error occured on FetchedResultsController:\n\(error as NSError)")
                    self.errorHandler?(error)
                }
            }
        }

        return OrderedSet<Element>(fetchedResultsController.fetchedObjects ?? [])
    }

    init(fetchRequest: NSFetchRequest<Element>, managedObjectContext: NSManagedObjectContext, cacheName: String? = nil, onError errorHandler: (@Sendable (Error) -> Void)? = nil) {
        self.fetchRequest = fetchRequest
        self.managedObjectContext = managedObjectContext
        self.cacheName = cacheName
        self.errorHandler = errorHandler
    }

    convenience init(sortDescriptors: [SortDescriptor<Element>], predicate: NSPredicate? = nil, managedObjectContext: NSManagedObjectContext, cacheName: String? = nil, onError errorHandler: (@Sendable (Error) -> Void)? = nil) {
        self.init(
            fetchRequest: {
                let fetchRequest = NSFetchRequest<Element>()
                fetchRequest.entity = Element.entity()
                fetchRequest.sortDescriptors = sortDescriptors.map { NSSortDescriptor($0) }
                fetchRequest.predicate = predicate

                return fetchRequest
            }(),
            managedObjectContext: managedObjectContext,
            cacheName: cacheName,
            onError: errorHandler
        )
    }

    private func newFetchedResultsController() -> NSFetchedResultsController<Element> {
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: cacheName
        )
        fetchedResultsController.delegate = self

        Task.detached(priority: .utility) {
            await self.managedObjectContext.perform(schedule: .enqueued) {
                do {
                    if fetchedResultsController === self.fetchedResultsController {
                        self.objectWillChange.send()
                    }

                    try fetchedResultsController.performFetch()
                } catch {
                    Logger().error("Error occured on FetchedResultsController:\n\(error as NSError)")
                    self.errorHandler?(error)
                }
            }
        }

        return fetchedResultsController
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard controller === self.fetchedResultsController else { return }

        objectWillChange.send()
    }
}

extension FetchedResultsController: ObservableObject { }
