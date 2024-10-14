//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 18.03.24.
//

import XCTest
import EssentialFeed

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

  func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
    let (sut, client) = makeSUT()
    let clientError = NSError(domain: "a client error", code: 0)

    expect(sut, toCompleteWith: failure(.connectivity), when: {
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

  func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
    let (sut, client) = makeSUT()
    let url = anyURL()

    let task = sut.loadImageData(from: url) { _ in }
    XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")

    task.cancel()
    XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
  }

  func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
    let (sut, client) = makeSUT()
    let nonEmptyData = Data("non-empty data".utf8)

    var received = [FeedImageDataLoader.Result]()
    let task = sut.loadImageData(from: anyURL()) { received.append($0) }
    task.cancel()

    client.complete(withStatusCode: 404, data: anyData())
    client.complete(withStatusCode: 200, data: nonEmptyData)
    client.complete(with: anyNSError())

    XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
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

  private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
    .failure(error)
  }
}
