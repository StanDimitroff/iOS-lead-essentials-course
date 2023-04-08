//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 8.04.23.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {

  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }

  func test_validateCache_deletesCacheOnRetrievalError() {
    let (sut, store) = makeSUT()
    let retrievalError = anyNSError()

    sut.validateCache()
    store.completeRetrieval(with: retrievalError)

    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }

  private func anyNSError() -> NSError {
    NSError(domain: "Any error", code: 0)
  }

  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)

    trackForMemoryLeaks(for: store, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return (sut, store)
  }
}
