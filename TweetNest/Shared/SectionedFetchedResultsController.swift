//
//  SectionedFetchedResultsController.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/03/19.
//

import SwiftUI
import CoreData
import UnifiedLogging

class SectionedFetchedResultsController<Result>: NSObject, NSFetchedResultsControllerDelegate where Result: NSManagedObject {
    struct Section {
        private var fetchedResultsSectionInfo: NSFetchedResultsSectionInfo

        init(fetchedResultsSectionInfo: NSFetchedResultsSectionInfo) {
            self.fetchedResultsSectionInfo = fetchedResultsSectionInfo
        }
    }

    private lazy var fetchedResultsController: NSFetchedResultsController<Result> = newFetchedResultsController() {
        didSet {
            managedObjectContext.perform(fetch)
        }
    }

    private let errorHandler: ((Error) -> Void)?

    let managedObjectContext: NSManagedObjectContext
    var fetchRequest: NSFetchRequest<Result> {
        didSet {
            fetchedResultsController = newFetchedResultsController()
        }
    }
    var sectionNameKeyPath: KeyPath<Result, String> {
        didSet {
            fetchedResultsController = newFetchedResultsController()
        }
    }
    var cacheName: String? {
        didSet {
            fetchedResultsController = newFetchedResultsController()
        }
    }

    var sections: [Section]? {
        if fetchedResultsController.fetchedObjects == nil {
            managedObjectContext.performAndWait {
                guard fetchedResultsController.fetchedObjects == nil else { return }

                fetch()
            }
        }

        return fetchedResultsController.sections.flatMap {
            $0.map {
                Section(fetchedResultsSectionInfo: $0)
            }
        }
    }

    init(
        fetchRequest: NSFetchRequest<Result>,
        managedObjectContext: NSManagedObjectContext,
        sectionNameKeyPath: KeyPath<Result, String>,
        cacheName: String? = nil,
        onError errorHandler: ((Error) -> Void)? = nil
    ) {
        self.fetchRequest = fetchRequest
        self.managedObjectContext = managedObjectContext
        self.sectionNameKeyPath = sectionNameKeyPath
        self.cacheName = cacheName
        self.errorHandler = errorHandler
    }

    convenience init(
        sortDescriptors: [SortDescriptor<Result>], predicate: NSPredicate? = nil,
        managedObjectContext: NSManagedObjectContext,
        sectionNameKeyPath: KeyPath<Result, String>,
        cacheName: String? = nil,
        onError errorHandler: ((Error) -> Void)? = nil
    ) {
        self.init(
            fetchRequest: {
                let fetchRequest = NSFetchRequest<Result>()
                fetchRequest.entity = Result.entity()
                fetchRequest.sortDescriptors = sortDescriptors.map { NSSortDescriptor($0) }
                fetchRequest.predicate = predicate

                return fetchRequest
            }(),
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: cacheName,
            onError: errorHandler
        )
    }

    private func newFetchedResultsController() -> NSFetchedResultsController<Result> {
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: sectionNameKeyPath._kvcKeyPathString,
            cacheName: cacheName
        )

        fetchedResultsController.delegate = self

        return fetchedResultsController
    }

    private func fetch() {
        do {
            self.objectWillChange.send()
            try fetchedResultsController.performFetch()
        } catch {
            Logger().error("Error occured on FetchedResultsController:\n\(error as NSError)")
            self.errorHandler?(error)
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
}

extension SectionedFetchedResultsController: ObservableObject { }
