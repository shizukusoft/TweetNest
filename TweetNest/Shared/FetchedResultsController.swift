//
//  FetchedResultsController.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2022/03/19.
//

import SwiftUI
import CoreData

class FetchedResultsController<FetchedResultsController, ResultType>: NSObject, NSFetchedResultsControllerDelegate where ResultType: NSFetchRequestResult, FetchedResultsController: NSFetchedResultsController<ResultType> {
    private let nsFetchedResultsController: FetchedResultsController

    private var fetchedObjects: [ResultType] {
        nsFetchedResultsController.fetchedObjects ?? []
    }

    convenience init(_ nsFetchedResultsController: FetchedResultsController) throws {
        try self.init(nsFetchedResultsController: nsFetchedResultsController)
    }

    init(nsFetchedResultsController: FetchedResultsController) throws {
        self.nsFetchedResultsController = nsFetchedResultsController

        try nsFetchedResultsController.performFetch()
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
}

extension FetchedResultsController: RandomAccessCollection {
    typealias Index = Int
    typealias Element = ResultType

    var startIndex: Index { fetchedObjects.startIndex }
    var endIndex: Index { fetchedObjects.endIndex }

    subscript(position: Index) -> Element {
        get {
            fetchedObjects[position]
        }
    }

    func index(after i: Index) -> Index {
        fetchedObjects.index(after: i)
    }
}

extension FetchedResultsController: ObservableObject { }
