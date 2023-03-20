//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 20.03.23.
//

import Foundation

public final  class LocalFeedLoader {

  private let store: FeedStore
  private let currentDate: () -> Date

  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }

  public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
    store.deleteCachedFeed { [weak self] error in
      guard let self = self else { return }

      if let cacheDeletionError = error {
        completion(cacheDeletionError)
      } else {
        self.cacheItems(items, with: completion)
      }
    }
  }

  private func cacheItems(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
    store.insert(items, timestamp: self.currentDate()) { [weak self] error in
      guard self != nil else { return }

      completion(error)
    }
  }
}
