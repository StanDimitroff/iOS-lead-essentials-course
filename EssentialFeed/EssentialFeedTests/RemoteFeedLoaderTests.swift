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
    // Arrangeu
    let url = URL(string: "https://test.com")!
    let (sut, client) = makeSUT(url: url)

    // Act
    sut.load()
    sut.load()

    // Assert
    XCTAssertEqual(client.requestedURLs, [url, url])
  }

  // MARK: - Sad path
  
  func test_load_deliversErrorOnHTTPClientError() {
    let (sut, client) = makeSUT()

    var capturedErrors: [RemoteFeedLoader.Error] = []
    sut.load { capturedErrors.append($0) }

    let clientError = NSError(domain: "Test", code: 0)
    client.complete(with: clientError)

    XCTAssertEqual(capturedErrors, [.connectivity])
  }

//  func test_loadTwice_deliversErrorOnHTTPClientError() {
//    let (sut, client) = makeSUT()
//    client.error = NSError(domain: "Test", code: 0)
//    var capturedErrors: [RemoteFeedLoader.Error] = []
//    sut.load { capturedErrors.append($0) }
//    sut.load { capturedErrors.append($0) }
//
//    XCTAssertEqual(capturedErrors, [.connectivity, .connectivity])
//  }

  // MARK: - Helpers
  private func makeSUT(url: URL = URL(string: "https://test.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    return (sut: sut, client: client)
  }

  private class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] = []
    var completion: ((Error) -> Void)?

    func get(from url: URL, completion: @escaping (Error) -> Void) {
      self.completion = completion
      requestedURLs.append(url)
    }

    func complete(with error: Error) {
      completion?(error)
    }
  }
}
