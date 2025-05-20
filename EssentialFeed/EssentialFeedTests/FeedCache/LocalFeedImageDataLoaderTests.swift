//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 20.05.25.
//

import XCTest

final class LocalFeedImageDataLoader {

  init(store: Any) {

  }
}

final class LocalFeedImageDataLoaderTests: XCTestCase {

  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertTrue(store.receivedMessages.isEmpty)
  }

  // MARK: - Helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedImageDataLoader(store: store)
    trackForMemoryLeaks(for: store, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return (sut, store)
  }

  private class FeedStoreSpy {
    let receivedMessages = [Any]()
  }
}
