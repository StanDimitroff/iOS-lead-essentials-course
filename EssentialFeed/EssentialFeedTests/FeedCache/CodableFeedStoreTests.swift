//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 8.05.23.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase {

  override func setUp() {
    super.setUp()

    setupEmptyStoreState()
  }

  override func tearDown() {
    super.tearDown()

    cleanStoreState()
  }

  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()

    expect(sut, toRetrieve: .empty)
  }

  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()

    expect(sut, toRetrieveTwice: .empty)
  }

  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    insert(cache: (feed: feed, timestamp: timestamp), to: sut)

    expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
  }

  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    insert(cache: (feed: feed, timestamp: timestamp), to: sut)

    expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
  }

  func test_retrieve_deliversFailureOnRetrievalError() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)

    try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

    expect(sut, toRetrieve: .failure(anyNSError()))
  }

  func test_retrieve_hasNoSideEffectsOnFailure() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)

    try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

    expect(sut, toRetrieveTwice: .failure(anyNSError()))
  }

  func test_insert_overridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()

    let firstInsertionError = insert(cache: (feed: uniqueImageFeed().local, timestamp: Date()), to: sut)
    XCTAssertNil(firstInsertionError)

    let latestFeed = uniqueImageFeed().local
    let latestTimestamp = Date()

    let secondInsertionError = insert(cache: (feed: latestFeed, timestamp: latestTimestamp), to: sut)
    XCTAssertNil(secondInsertionError)

    expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
  }

  func test_insert_deliversErrorOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")
    let sut = makeSUT(storeURL: invalidStoreURL)
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    let insertionError = insert(cache: (feed: feed, timestamp: timestamp), to: sut)

    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error due to invalid store URL")
  }

  func test_delete_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()

    let deletionError = deleteCache(from: sut)

    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    expect(sut, toRetrieve: .empty)
  }

  func test_delete_emptiesPreviouslyInsertedCache() {
    let sut = makeSUT()
    insert(cache: (feed: uniqueImageFeed().local, timestamp: Date()), to: sut)

    let deletionError = deleteCache(from: sut)

    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    expect(sut, toRetrieve: .empty)
  }

  func test_delete_deliversErrorOnDeletionError() {
    let noDeletePermissionURL = noDeletePermissionURL()
    let sut = makeSUT(storeURL: noDeletePermissionURL)

    let deletionError = deleteCache(from: sut)

    XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    expect(sut, toRetrieve: .empty)
  }

  func test_storeSideEffects_runSerially() {
    let sut = makeSUT()
    var completedOperationsInOrder = [XCTestExpectation]()

    let op1 = expectation(description: "Ooperation 1")
    sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
      completedOperationsInOrder.append(op1)
      op1.fulfill()
    }

    let op2 = expectation(description: "Operation 2")
    sut.deleteCachedFeed { _ in
      completedOperationsInOrder.append(op2)
      op2.fulfill()
    }

    let op3 = expectation(description: "Operation 3")
    sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
      completedOperationsInOrder.append(op3)
      op3.fulfill()
    }

    wait(for: [op1, op2, op3], timeout: 5.0)

    XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order")
  }

  // MARK: - Helpers

  private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
    let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())

    trackForMemoryLeaks(for: sut, file: file, line: line)

    return sut
  }

  @discardableResult
  private func insert(cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache insertion")
    var insertionError: Error?
    sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
      insertionError = receivedInsertionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)

    return insertionError
  }

  private func deleteCache(from sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache deletion")
    var deletionError: Error?
    sut.deleteCachedFeed { receivedDeletionError in
      deletionError = receivedDeletionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return deletionError
  }

  private func expect(_ sut: FeedStore, toRetrieve expectedResult:
                       RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retrieval")
    sut.retrieve { retrievedResult in
      switch (expectedResult, retrievedResult) {
        case (.empty, .empty),
          (.failure, .failure):
          break
        case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)) :
          XCTAssertEqual (retrievedFeed, expectedFeed, file: file, line: line)
          XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
        default:
          XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead",
                  file: file, line: line)
      }

      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }

  private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult:
                               RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }

  private func testSpecificStoreURL() -> URL {
    cachesDirectory().appendingPathComponent("\(type(of: self)).store")
  }

  private func cachesDirectory() -> URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }

  private func noDeletePermissionURL() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
  }

  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }

  private func cleanStoreState() {
    deleteStoreArtifacts()
  }

  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }
}
