//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 18.03.23.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {

  func test_init_doesNotMessageStoreUponCreation () {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }

  func test_save_requestsCacheDeletion() {
    let (sut, store) = makeSUT()

    sut.save(uniqueImageFeed().models) { _ in }

    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }

  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()

    let deletionError = anyNSError()

    sut.save(uniqueImageFeed().models) { _ in }
    store.completeDeletion(with: deletionError)

    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }

  func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let (sut, store) = makeSUT(currentDate: { timestamp })
    let feed = uniqueImageFeed()

    sut.save(feed.models) { _ in }
    store.completeDeletionSuccessfully()

    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timestamp)])
  }

  func test_save_failsOnDeletionError() {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()

    expect(sut: sut, toCompleteWith: deletionError, when: {
      store.completeDeletion(with: deletionError)
    })
  }

  func test_save_failsOnInsertionError() {
    let (sut, store) = makeSUT()
    let insertionError = anyNSError()

    expect(sut: sut, toCompleteWith: insertionError, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertion(with: insertionError)
    })
  }

  func test_save_succeedsOnSuccessfulCacheInsertion() {
    let (sut, store) = makeSUT()

    expect(sut: sut, toCompleteWith: nil, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertionSuccessfully()
    })
  }

  func test_save_doesNotDeliverDelitionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init )

    var receivedResults = [LocalFeedLoader.SaveResult]()
    sut?.save([uniqueItem()]) {
      receivedResults.append($0)
    }

    sut = nil
    store.completeDeletion(with: anyNSError())

    XCTAssertTrue(receivedResults.isEmpty)
  }

  func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init )

    var receivedResults = [LocalFeedLoader.SaveResult]()
    sut?.save([uniqueItem()]) {
      receivedResults.append($0)
    }

    store.completeDeletionSuccessfully()
    sut = nil
    store.completeInsertion(with: anyNSError())

    XCTAssertTrue(receivedResults.isEmpty)
  }

  // MARK: - Helpers

  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)

    trackForMemoryLeaks(for: store, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return (sut, store)
  }

  private func expect(sut: LocalFeedLoader, toCompleteWith expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "Wait for save completion")

    var receivedError: Error?
    sut.save([uniqueItem()]) { error in
      receivedError = error
      exp.fulfill()
    }

    action()
    wait(for: [exp], timeout: 1.0)

    XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
  }

  private func uniqueItem() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
  }

  private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueItem(), uniqueItem()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }

    return (models, local)
  }

  private func anyURL() -> URL {
    URL(string: "http://test-url.com")!
  }

  private func anyNSError() -> NSError {
    NSError(domain: "Any error", code: 0)
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
