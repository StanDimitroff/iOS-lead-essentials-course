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
    let (_, store) = makeSUT()
    XCTAssertEqual(store.deleteCacheCallCount, 0)
  }

  func test_save_requestsCacheDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    sut.save(items)
    XCTAssertEqual(store.deleteCacheCallCount, 1)
  }

  private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)

    return (sut, store)
  }

  private func uniqueItem() -> FeedItem {
    FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }

  private func anyURL() -> URL {
    URL(string: "http://test-url.com")!
  }
}
