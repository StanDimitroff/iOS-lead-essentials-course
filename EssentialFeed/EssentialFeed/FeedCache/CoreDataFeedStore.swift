//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 28.05.23.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {

  public init() { }


  public func retrieve(completion: @escaping RetrievalCompletion) {
    completion(.empty)
  }

  public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

  }

  public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

  }
}
