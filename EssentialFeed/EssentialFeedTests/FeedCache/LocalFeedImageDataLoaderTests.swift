//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 20.05.25.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
  func retrieve(dataForURL url: URL)
}

final class LocalFeedImageDataLoader {

  private let store: FeedImageDataStore

  init(store: FeedImageDataStore) {
    self.store = store
  }

  func loadImageData(from url: URL, completion: (FeedImageDataLoader.Result) -> Void) {
    store.retrieve(dataForURL: url)
  }
}

final class LocalFeedImageDataLoaderTests: XCTestCase {

  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertTrue(store.receivedMessages.isEmpty)
  }

  func test_loadImageDataFromURL_requestsStoredDataForURL() {
    let (sut, store) = makeSUT()
    let url = anyURL()

    sut.loadImageData(from: url) { _ in }

    XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
  }

  // MARK: - Helpers
  private func makeSUT(
    file: StaticString = #file,
    line: UInt = #line
  ) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
    let store = StoreSpy()
    let sut = LocalFeedImageDataLoader(store: store)
    trackForMemoryLeaks(for: store, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return (sut, store)
  }

  private class StoreSpy: FeedImageDataStore {

    enum Message: Equatable {
      case retrieve(dataFor: URL)
    }

    private(set) var receivedMessages = [Message]()

    func retrieve(dataForURL url: URL) {
      receivedMessages.append(.retrieve(dataFor: url))
    }
  }
}
