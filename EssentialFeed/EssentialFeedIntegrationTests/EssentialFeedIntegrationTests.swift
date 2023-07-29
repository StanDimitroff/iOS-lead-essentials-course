//
//  EssentialFeedIntegrationTests.swift
//  EssentialFeedIntegrationTests
//
//  Created by Stanislav Dimitrov on 29.07.23.
//

import XCTest
import EssentialFeed

final class EssentialFeedIntegrationTests: XCTestCase {


  func test_load_deliliversNoIntemsOnEmptyCache() {
    let sut = makeSUT()

    let exp = expectation(description: "Wait for load completion")

    sut.load { result in
      switch result {
      case let .success(imageFeed):
        XCTAssertEqual(imageFeed, [])
      case let .failure(error):
        XCTFail("Expected successuful feed result, got \(error) instead")
      }

      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    let sut = LocalFeedLoader(store: store, currentDate: Date.init)

    trackForMemoryLeaks(for: store, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return sut
  }

  private func testSpecificStoreURL() -> URL {
    cachesDirectory().appending(path: "\(type(of: self)).store")
  }

  private func cachesDirectory() -> URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }

}
