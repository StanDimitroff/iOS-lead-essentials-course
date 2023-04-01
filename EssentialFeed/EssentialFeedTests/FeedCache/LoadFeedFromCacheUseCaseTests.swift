//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 1.04.23.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {

  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }

  // MARK: - Helpers

  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)

    trackForMemoryLeaks(for: store, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return (sut, store)
  }

  private class FeedStoreSpy: FeedStore {

    enum ReceivedMesssage: Equatable {
      case deleteCachedFeed
      case insert([LocalFeedImage], Date)
    }

    private(set) var receivedMessages = [ReceivedMesssage]()
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
      deletionCompletions.append(completion)
      receivedMessages.append(.deleteCachedFeed)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
      deletionCompletions[index](error)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
      insertionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
      deletionCompletions[index](nil)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
      insertionCompletions[index](nil)
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
      insertionCompletions.append(completion)
      receivedMessages.append(.insert(feed, timestamp ))
    }
  }
  
}
