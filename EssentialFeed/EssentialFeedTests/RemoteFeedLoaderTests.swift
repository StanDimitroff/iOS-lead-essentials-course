//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 7.01.23.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

  func test_init_doesNotRequestDataFromURL() {
    let url = URL(string: "https://test.com")!
    let (_, client) = makeSUT(url: url)

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_load_requestsDataFromURL() {
    // Arrange
    let url = URL(string: "https://test.com")!
    let (sut, client) = makeSUT(url: url)

    // Act
    sut.load()

    // Assert
    XCTAssertEqual(client.requestedURLs, [url])
  }

  func test_loadTwice_requestsDataFromURL() {
    // Arrange
    let url = URL(string: "https://test.com")!
    let (sut, client) = makeSUT(url: url)

    // Act
    sut.load()
    sut.load()

    // Assert
    XCTAssertEqual(client.requestedURLs, [url, url])
  }

  // MARK: - Helpers
  private func makeSUT(url: URL) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    return (sut: sut, client: client)
  }

  private class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] = []

    func get(from url: URL) {
      requestedURLs.append(url)
    }
  }
}
