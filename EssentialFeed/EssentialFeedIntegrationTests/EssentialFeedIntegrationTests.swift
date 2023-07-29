//
//  EssentialFeedIntegrationTests.swift
//  EssentialFeedIntegrationTests
//
//  Created by Stanislav Dimitrov on 29.07.23.
//

import XCTest
import EssentialFeed

final class EssentialFeedIntegrationTests: XCTestCase {

  override func setUp() {
    super.setUp()

    setupEmptyStoreState()
  }

  override func tearDown() {
    super.tearDown()
    undoStoreSideEffects()
  }

  func test_load_deliliversNoIntemsOnEmptyCache() {
    let sut = makeSUT()

    expect(sut, toLoad: [])
  }

  func test_load_deliversItemsOnNonEmptyCache() {
    let sutToPerformSave = makeSUT()
    let sutToPerformLoad = makeSUT()
    let feed = uniqueImageFeed().models

    let saveExp = expectation(description: "Wait for save completion")
    sutToPerformSave.save(feed) { saveError in
      XCTAssertNil(saveError, "Expected to save feed successfully")
      saveExp.fulfill()
    }
    wait(for: [saveExp])

    expect(sutToPerformLoad, toLoad: feed)
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    let sut = LocalFeedLoader(store: store, currentDate: Date.init)

    trackForMemoryLeaks(for: store, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return sut
  }

  private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")

    sut.load { result in
      switch result {
      case let .success(loadedFeed):
        XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
      case let .failure(error):
        XCTFail("Expected successuful feed result, got \(error) instead", file: file, line: line)
      }

      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }

  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }

  private func undoStoreSideEffects()  {
    deleteStoreArtifacts()
  }

  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }

  private func testSpecificStoreURL() -> URL {
    cachesDirectory().appending(path: "\(type(of: self)).store")
  }

  private func cachesDirectory() -> URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }

}
