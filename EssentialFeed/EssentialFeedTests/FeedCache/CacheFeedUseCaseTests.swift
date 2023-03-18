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
    store.deleteCachedFeed { [unowned self] error in
      if error == nil {
        store.insert(items)
      }
    }
  }
}

class FeedStore {

  typealias DeletionCompletion = (Error?) -> Void

  private(set) var deleteCacheCallCount: Int = 0
  private(set) var insertCacheCallCount: Int = 0

  private var deletionCompletions = [DeletionCompletion]()

  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deleteCacheCallCount += 1
    deletionCompletions.append(completion)
  }

  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }

  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }

  func insert(_ items: [FeedItem]) {
    insertCacheCallCount += 1
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

  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]

    let deletionError = anyNSError()

    sut.save(items)
    store.completeDeletion(with: deletionError)

    XCTAssertEqual(store.insertCacheCallCount, 0)
  }

  func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]

    sut.save(items)
    store.completeDeletionSuccessfully()

    XCTAssertEqual(store.insertCacheCallCount, 1)
  }

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)

    trackForMemoryLeaks(for: store, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return (sut, store)
  }

  private func uniqueItem() -> FeedItem {
    FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }

  private func anyURL() -> URL {
    URL(string: "http://test-url.com")!
  }

  private func anyNSError() -> NSError {
    NSError(domain: "Any error", code: 0)
  }
}
