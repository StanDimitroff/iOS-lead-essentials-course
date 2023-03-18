//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 18.03.23.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {

  let store: FeedStore

  init(store: FeedStore) {
    self.store = store
  }

  func save(_ items: [FeedItem]) {
    store.deleteCachedFeed()
  }
}

class FeedStore {
  private(set) var deleteCacheCallCount: Int = 0

  func deleteCachedFeed() {
    deleteCacheCallCount += 1
  }
}


final class CacheFeedUseCaseTests: XCTestCase {

  func test_init_doesNotDeleteCacheUponCreation () {
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)
    XCTAssertEqual(store.deleteCacheCallCount, 0)
  }

  func test_save_requestsCacheDeletion() {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
    let items = [uniqueItem(), uniqueItem()]
    sut.save(items)
    XCTAssertEqual(store.deleteCacheCallCount, 1)
  }

  private func uniqueItem() -> FeedItem {
    FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }

  private func anyURL() -> URL {
    URL(string: "http://test-url.com")!
  }
}
