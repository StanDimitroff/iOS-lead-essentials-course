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
    expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.connectivity), when: {
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
      expect(sut, toCompleteWith: failure(.invalidData), when: {
        let json = makeItemsJSON([])
        client.complete(withStatusCode: code, data: json, at: index)
      })
    }
  }

  func test_load_deliversError200HTTPResponseWithInvalidJSON() {
    // Arrange
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWith: failure(.invalidData), when: {
      let invalidJSON = Data("invalid JSON".utf8)
      client.complete(withStatusCode: 200, data: invalidJSON)
    })
  }

  func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWith: .success([]), when: {
      let emptyJSON = makeItemsJSON([])
      client.complete(withStatusCode: 200, data: emptyJSON)
    })
  }

  func test_load_deliversItemsOn200HTTPResponseWithJSONItemsList() {
    let (sut, client) = makeSUT()

    let item1 = makeItem(imageURL: URL(string: "http://url1.com")!)

    let item2 = makeItem(
      description: "item2 description",
      location: "item2 location",
      imageURL: URL(string: "http://url2.com")!)

    let items = [item1.model, item2.model]

    expect(sut, toCompleteWith: .success(items), when: {
      let json = makeItemsJSON([item1.json, item2.json])
      client.complete(withStatusCode: 200, data: json)
    })
  }

  func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
    // Arrange
    let url = URL(string: "http://any-url.com")!
    let client = HTTPClientSpy()
    var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

    var capturedResults: [RemoteFeedLoader.Result] = []
    sut?.load { capturedResults.append($0) }

    // Act
    sut = nil
    client.complete(withStatusCode: 200, data: makeItemsJSON([]))

    XCTAssertTrue(capturedResults.isEmpty)
  }

  // MARK: - Helpers
  private func makeSUT(url: URL = URL(string: "https://test.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)

    trackForMemoryLeak(for: sut, file: file, line: line)
    trackForMemoryLeak(for: client, file: file, line: line)

    return (sut: sut, client: client)
  }

  private func trackForMemoryLeak(for instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
    }
  }

  private func makeItem(description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
    let item = FeedItem(
      id: UUID(),
      description: description,
      location: location,
      imageURL: imageURL)

    let json = [
      "id": item.id.uuidString,
      "description": item.description,
      "location": item.location,
      "image": item.imageURL.absoluteString
    ]

    return (item, json.compactMapValues { $0 })
  }

  private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return  try! JSONSerialization.data(withJSONObject: json)
  }

  private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line ) {
    let exp = expectation(description: "Wait to load completion")
    sut.load { receivedResult in
      switch (receivedResult, expectedResult) {
        case let (.success(receivedItems), .success(expectedItems)):
          XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
        case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
          XCTAssertEqual(receivedError, expectedError, file: file, line: line)

        default:
          XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }

      exp.fulfill()
    }

    action()

    wait(for: [exp], timeout: 1.0)
  }

  private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
    .failure(error)
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

    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: code,
        httpVersion: nil,
        headerFields: nil
      )!
      messages[index].completion(.success(data, response))
    }
  }
}
