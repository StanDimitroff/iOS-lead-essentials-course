//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 8.05.23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {

  private struct Cache: Codable {
    let feed: [CodableFeedImage]
    let timestamp: Date

    var localFeed: [LocalFeedImage] {
      feed.map({ $0.local })
    }
  }

  private struct CodableFeedImage: Codable {
    private let id: UUID
    private let description: String?
    private let location: String?
    private let url: URL

    init(_ image: LocalFeedImage) {
      self.id = image.id
      self.description = image.description
      self.location = image.location
      self.url = image.url
    }

    var local: LocalFeedImage {
      .init(id: id, description: description, location: location, url: url)
    }
  }

  private let storeURL: URL

  init(storeURL: URL) {
    self.storeURL = storeURL
  }

  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      return completion(.empty)
    }

    let decoder = JSONDecoder()
    let cache = try! decoder.decode(Cache.self, from: data)
    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
  }

  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
    let encoded = try! encoder.encode(cache)
    try! encoded.write(to: storeURL)
    completion(nil)
  }
}

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
    let exp = expectation(description: "Wait for retrieval")

    sut.retrieve { firstResult in
      sut.retrieve { secondResult in
        switch (firstResult, secondResult) {
          case (.empty, .empty):
            break

          default:
            XCTFail("Expected retrieving twice from empty cache to deriver same empty result, got \(firstResult) and \(secondResult) instead!")
        }

        exp.fulfill()
      }
    }

    wait(for: [exp], timeout: 1.0) 
  }

  func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    let exp = expectation(description: "Wait for retrieval")
    sut.insert(feed, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected feed to be inserted succefully.")
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)

    expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
  }

  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let exp = expectation(description: "Wait for retrieval")
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    sut.insert(feed, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected feed to be inserted succefully.")

      sut.retrieve { firstResult in
        sut.retrieve { secondResult in
          switch (firstResult, secondResult) {
            case let (.found(firstFoundFeed, firstTimestamp), .found(secondFoundFeed, secondTimestamp)):
              XCTAssertEqual(firstFoundFeed, feed)
              XCTAssertEqual(firstTimestamp, timestamp)

              XCTAssertEqual(secondFoundFeed, feed)
              XCTAssertEqual(secondTimestamp, timestamp)

            default:
              XCTFail ("Expected retrieving twice from non empty cache to deliver same found result with feed \(feed) and timestamp \(timestamp), got \(firstResult) and \(secondResult) instead")
          }

          exp.fulfill()
        }
      }
    }

    wait(for: [exp], timeout: 1.0)
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
    let sut = CodableFeedStore(storeURL: testSpecificStoreURL())

    trackForMemoryLeaks(for: sut, file: file, line: line)

    return sut
  }

  private func expect (_ sut: CodableFeedStore, toRetrieve expectedResult:
                       RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retrieval")
    sut.retrieve { retrievedResult in
      switch (expectedResult, retrievedResult) {
        case (.empty, .empty):
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

  private func testSpecificStoreURL() -> URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
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
