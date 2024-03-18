//
//  RemoteFeedDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 18.03.24.
//

import XCTest
import EssentialFeed

class RemoteFeedDataLoader {
  init(client: Any) {

  }
}

final class RemoteFeedDataLoaderTests: XCTestCase {

  func test_init_doesNotRequestDataFromURL() {
    let (_, client) = makeSUT()

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedDataLoader(client: client)
    trackForMemoryLeaks(for: sut, file: file, line: line)
    trackForMemoryLeaks(for: client, file: file, line: line)

    return (sut, client)
  }

  private class HTTPClientSpy {
    var requestedURLs: [URL] = []
  }
}
