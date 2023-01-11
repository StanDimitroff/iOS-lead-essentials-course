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
    sut.load { _ in }

    // Assert
    XCTAssertEqual(client.requestedURLs, [url])
  }

  func test_loadTwice_requestsDataFromURL() {
    // Arrangeu
    let url = URL(string: "https://test.com")!
    let (sut, client) = makeSUT(url: url)

    // Act
    sut.load { _ in }
    sut.load { _ in }

    // Assert
    XCTAssertEqual(client.requestedURLs, [url, url])
  }

  // MARK: - Sad path
  
  func test_load_deliversErrorOnHTTPClientError() {
    // Arrange
    let (sut, client) = makeSUT()
    var capturedErrors: [RemoteFeedLoader.Error] = []

    // Act
    sut.load { capturedErrors.append($0) }
    let clientError = NSError(domain: "Test", code: 0)
    client.complete(with: clientError)

    // Assert
    XCTAssertEqual(capturedErrors, [.connectivity])
  }

  func test_load_deliversErrorOnNon200HTTPResponse() {
    // Arrange
    let (sut, client) = makeSUT()
    var capturedErrors: [RemoteFeedLoader.Error] = []

    // Act
    sut.load { capturedErrors.append($0) }
    client.complete(with: 400)

    // Assert
    XCTAssertEqual(capturedErrors, [.invalidData])
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
    private var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()

    var requestedURLs: [URL] {
      messages.map { $0.url }
    }

    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
      messages.append((url, completion))
    }

    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(error, nil)
    }

    func complete(with statusCode: Int, at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
      )
      messages[index].completion(nil, response)
    }
  }
}
