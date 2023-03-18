//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 18.03.23.
//

import XCTest

class LocalFeedLoader {

  init(store: FeedStore) {

  }
}

class FeedStore {
  var deleteCacheCallCount: Int = 0
}


final class CacheFeedUseCaseTests: XCTestCase {

  func test_init_doesNotDeleteCacheUponCreation () {
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)
    XCTAssertEqual(store.deleteCacheCallCount, 0)
  }
}
