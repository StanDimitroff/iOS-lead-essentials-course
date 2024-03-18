//
//  RemoteFeedDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 18.03.24.
//

import XCTest
import EssentialFeed

class RemoteFeedDataLoader {
  private let client: HTTPClient

  init(client: HTTPClient) {
    self.client = client
  }

  func loadImageData(
    from url: URL,
    completion: @escaping (FeedImageDataLoader.Result) -> Void
  ) {
    client.get(from: url) { result in
      switch result {
      case let .failure(error):
        completion(.failure(error))
      default:
        break
      }
    }
  }
}

final class RemoteFeedDataLoaderTests: XCTestCase {

  func test_init_doesNotRequestDataFromURL() {
    let (_, client) = makeSUT()

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_loadImageDataFromURL_requestsDataFromURL() {
    let url = URL(string: "https://a-url.com")!
    let (sut, client) = makeSUT()

    sut.loadImageData(from: url) { _ in }

    XCTAssertEqual(client.requestedURLs, [url])
  }

  func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
    let url = URL(string: "https://a-url.com")!
    let (sut, client) = makeSUT()

    sut.loadImageData(from: url) { _ in }
    sut.loadImageData(from: url) { _ in }

    XCTAssertEqual(client.requestedURLs, [url, url])
  }

  func test_loadImageDataFromURL_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    let clientError = NSError(domain: "Client error", code: 0)

    expect(sut, toCompleteWith: .failure(clientError), when: {
      client.complete(with: clientError)
    })
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedDataLoader(client: client)
    trackForMemoryLeaks(for: sut, file: file, line: line)
    trackForMemoryLeaks(for: client, file: file, line: line)

    return (sut, client)
  }

  func expect(_ sut: RemoteFeedDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")

    sut.loadImageData(from: anyURL()) { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedData), .success(expectedData)):
        XCTAssertEqual(receivedData, expectedData, file: file, line: line)

      case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)

      default:
        XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }

      exp.fulfill()
    }

    action()

    wait(for: [exp], timeout: 1.0)
  }

  private class HTTPClientSpy: HTTPClient {
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()

    var requestedURLs: [URL] {
      return messages.map { $0.url }
    }

    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
      messages.append((url, completion))
    }

    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(.failure(error))
    }
  }
}
