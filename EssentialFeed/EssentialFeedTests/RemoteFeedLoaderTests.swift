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

    // Act
    expect(sut, toCompleteWithError: .connectivity, when: {
      let clientError = NSError(domain: "Test", code: 0)
      client.complete(with: clientError)
    })
  }

  func test_load_deliversErrorOnNon200HTTPResponse() {
    // Arrange
    let (sut, client) = makeSUT()

    // Act
    let samples = [199, 201, 300, 400, 500]
    samples.enumerated().forEach { index, code in
      expect(sut, toCompleteWithError: .invalidData, when: {
        client.complete(with: code, at: index)
      })
    }
  }

  func test_load_deliversError200HTTPResponseWithInvalidJSON() {
    // Arrange
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWithError: .invalidData, when: {
      let invalidJSON = Data("invalid JSON".utf8)
       client.complete(with: 200, data: invalidJSON)
    })
  }

  func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
    let (sut, client) = makeSUT()

    var capturedResults = [RemoteFeedLoader.Result]()
    sut.load { capturedResults.append($0)}

    let emptyJSON = Data("{\"items\": []}".utf8)
    client.complete(with: 200, data: emptyJSON)

    XCTAssertEqual(capturedResults, [.success([])])
  }

  // MARK: - Helpers
  private func makeSUT(url: URL = URL(string: "https://test.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    return (sut: sut, client: client)
  }

  private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line ) {
    var capturedResults: [RemoteFeedLoader.Result] = []
    sut.load { capturedResults.append($0) }

    action()

    XCTAssertEqual(capturedResults, [.failure(error)], file: file, line: line)
  }

  private class HTTPClientSpy: HTTPClient {
    private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

    var requestedURLs: [URL] {
      messages.map { $0.url }
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
      messages.append((url, completion))
    }

    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(.failure(error))
    }

    func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
      )!
      messages[index].completion(.success(data, response))
    }
  }
}
