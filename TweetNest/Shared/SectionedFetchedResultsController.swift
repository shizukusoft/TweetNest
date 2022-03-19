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
    class Section {
        private var fetchedResultsSectionInfo: NSFetchedResultsSectionInfo

        init(fetchedResultsSectionInfo: NSFetchedResultsSectionInfo) {
            self.fetchedResultsSectionInfo = fetchedResultsSectionInfo
        }
    }

    private lazy var fetchedResultsController: NSFetchedResultsController<Result> = newFetchedResultsController() {
        willSet {
            objectWillChange.send()
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
        fetchedResultsController.sections.flatMap {
            $0.map {
                Section(fetchedResultsSectionInfo: $0)
            }
        }
    }

    init(fetchRequest: NSFetchRequest<Result>, managedObjectContext: NSManagedObjectContext, sectionNameKeyPath: KeyPath<Result, String>, cacheName: String? = nil, onError errorHandler: ((Error) -> Void)? = nil) {
        self.fetchRequest = fetchRequest
        self.managedObjectContext = managedObjectContext
        self.sectionNameKeyPath = sectionNameKeyPath
        self.cacheName = cacheName
        self.errorHandler = errorHandler
    }

    convenience init(sortDescriptors: [SortDescriptor<Result>], predicate: NSPredicate? = nil, managedObjectContext: NSManagedObjectContext, sectionNameKeyPath: KeyPath<Result, String>, cacheName: String? = nil, onError errorHandler: ((Error) -> Void)? = nil) {
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

        do {
            if fetchedResultsController.fetchedObjects == nil {
                try fetchedResultsController.performFetch()
            }
        } catch {
            Logger().error("Error occured on FetchedResultsController:\n\(error as NSError)")
            self.errorHandler?(error)
        }

        return fetchedResultsController
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
}

extension SectionedFetchedResultsController: RandomAccessCollection {
    typealias Index = Int
    typealias Element = Section

    var startIndex: Index { (sections ?? []).startIndex }
    var endIndex: Index { (sections ?? []).endIndex }

    subscript(position: Index) -> Element {
        get {
            (sections ?? [])[position]
        }
    }

    func index(after i: Index) -> Index {
        (sections ?? []).index(after: i)
    }
}

extension SectionedFetchedResultsController.Section: RandomAccessCollection {
    typealias Index = Int
    typealias Element = Result

    var startIndex: Index { (fetchedResultsSectionInfo.objects as? [Result] ?? []).startIndex }
    var endIndex: Index { (fetchedResultsSectionInfo.objects as? [Result] ?? []).endIndex }

    subscript(position: Index) -> Element {
        get {
            (fetchedResultsSectionInfo.objects as? [Result] ?? [])[position]
        }
    }

    func index(after i: Index) -> Index {
        (fetchedResultsSectionInfo.objects as? [Result] ?? []).index(after: i)
    }

}

extension SectionedFetchedResultsController: ObservableObject { }

extension SectionedFetchedResultsController.Section: Identifiable {
    var id: String {
        fetchedResultsSectionInfo.name
    }
}
