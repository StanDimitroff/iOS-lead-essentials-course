//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 18.03.24.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
  private let client: HTTPClient

  init(client: HTTPClient) {
    self.client = client
  }

  public enum Error: Swift.Error {
    case invalidData
  }

  func loadImageData(
    from url: URL,
    completion: @escaping (FeedImageDataLoader.Result) -> Void
  ) {
    client.get(from: url) { [weak self] result in
      guard self != nil else { return }
      
      switch result {
      case let .success((data, response)):
        guard response.statusCode == 200, !data.isEmpty else {
          completion(.failure(Error.invalidData))
          return
        }
        completion(.success(data))

      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {

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

  // MARK: - Sad path

  func test_loadImageDataFromURL_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    let clientError = NSError(domain: "Client error", code: 0)

    expect(sut, toCompleteWith: .failure(clientError), when: {
      client.complete(with: clientError)
    })
  }

  func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()

    let samples = [199, 201, 300, 400, 500]
    samples.enumerated().forEach { index, code in
      expect(sut, toCompleteWith: failure(.invalidData), when: {
        client.complete(withStatusCode: code, data: anyData(), at: index)
      })
    }
  }

  func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWith: failure(.invalidData), when: {
      let emptyData = Data()
      client.complete(withStatusCode: 200, data: emptyData)
    })
  }

  // MARK: - Happy path

  func test_loadImageDataFromURL_deliversReceivedDataOn200HTTPResponse() {
    let (sut, client) = makeSUT()
    let data = anyData()

    expect(sut, toCompleteWith: .success(data), when: {
      client.complete(withStatusCode: 200, data: data)
    })
  }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)

        var capturedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL()) { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: anyData())

        XCTAssertTrue(capturedResults.isEmpty)
    }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedImageDataLoader(client: client)
    trackForMemoryLeaks(for: sut, file: file, line: line)
    trackForMemoryLeaks(for: client, file: file, line: line)

    return (sut, client)
  }

  private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
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

  private func anyData() -> Data {
    Data("Any data".utf8)
  }

  private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
    .failure(error)
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

    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: code,
        httpVersion: nil,
        headerFields: nil
      )!
      messages[index].completion(.success((data, response)))
    }
  }
}
