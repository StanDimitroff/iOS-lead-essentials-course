//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 22.05.25.
//

import XCTest
import EssentialFeed

final class CacheFeedImageDataUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertTrue(store.receivedMessages.isEmpty)
  }
  
  func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
    let (sut, store) = makeSUT()
    let url = anyURL()
    let data = anyData()
    
    sut.save(data, for: url) { _ in }
    
    XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
  }
  
  // MARK: - Helpers
  private func makeSUT(
    file: StaticString = #file,
    line: UInt = #line
  ) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
    let store = FeedImageDataStoreSpy()
    let sut = LocalFeedImageDataLoader(store: store)
    trackForMemoryLeaks(for: store, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)
    
    return (sut, store)
  }
}
