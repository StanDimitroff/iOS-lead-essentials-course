//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 18.03.23.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {

  private let store: FeedStore
  private let currentDate: () -> Date

  init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }

  func save(_ items: [FeedItem]) {
    store.deleteCachedFeed { [unowned self] error in
      if error == nil {
        store.insert(items, timestamp: currentDate())
      }
    }
  }
}

class FeedStore {

  typealias DeletionCompletion = (Error?) -> Void

  private(set) var deleteCacheCallCount: Int = 0
  private(set) var insertCacheCallCount: Int = 0

  private(set) var insertions = [(items: [FeedItem], timestamp: Date)]()

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

  func insert(_ items: [FeedItem], timestamp: Date) {
    insertCacheCallCount += 1
    insertions.append((items: items, timestamp: timestamp))
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

  func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let (sut, store) = makeSUT(currentDate: { timestamp })
    let items = [uniqueItem(), uniqueItem()]

    sut.save(items)
    store.completeDeletionSuccessfully()

    XCTAssertEqual(store.insertions.count, 1)
    XCTAssertEqual(store.insertions.first?.items, items)
    XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
  }

  // MARK: - Helpers

  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)

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
