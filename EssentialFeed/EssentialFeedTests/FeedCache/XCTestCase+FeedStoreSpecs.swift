//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 21.05.23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {

  @discardableResult
  func insert(cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache insertion")
    var insertionError: Error?
    sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
      insertionError = receivedInsertionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)

    return insertionError
  }

  @discardableResult
  func deleteCache(from sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache deletion")
    var deletionError: Error?
    sut.deleteCachedFeed { receivedDeletionError in
      deletionError = receivedDeletionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return deletionError
  }

  func expect(_ sut: FeedStore, toRetrieve expectedResult:
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

  func expect(_ sut: FeedStore, toRetrieveTwice expectedResult:
                      RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
}
