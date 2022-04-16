//
//  FetchedResultsController.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/03/19.
//

import SwiftUI
import CoreData
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

    var fetchedObjects: [Element] {
        if fetchedResultsController.fetchedObjects == nil {
            managedObjectContext.performAndWait {
                guard self.fetchedResultsController.fetchedObjects == nil else { return }

                self.fetch(fetchedResultsController)
            }
        }

        return fetchedResultsController.fetchedObjects ?? []
    }

    init(fetchRequest: NSFetchRequest<Element>, managedObjectContext: NSManagedObjectContext, cacheName: String? = nil, onError errorHandler: (@Sendable (Error) -> Void)? = nil) {
        self.fetchRequest = fetchRequest
        self.managedObjectContext = managedObjectContext
        self.cacheName = cacheName
        self.errorHandler = errorHandler

        super.init()

        Task.detached(priority: .utility) {
            await MainActor.run {
                _ = self.fetchedResultsController
            }
        }
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

        Task.detached {
            await self.managedObjectContext.perform(schedule: .enqueued) {
                self.fetch(fetchedResultsController)
            }
        }

        return fetchedResultsController
    }

    private func fetch(_ fetchedResultsController: NSFetchedResultsController<Element>) {
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

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard controller === self.fetchedResultsController else { return }

        objectWillChange.send()
    }
}

extension FetchedResultsController: ObservableObject { }
