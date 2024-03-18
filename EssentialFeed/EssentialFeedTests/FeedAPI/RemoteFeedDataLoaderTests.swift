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

  func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
    client.get(from: url) { _ in }
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

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedDataLoader(client: client)
    trackForMemoryLeaks(for: sut, file: file, line: line)
    trackForMemoryLeaks(for: client, file: file, line: line)

    return (sut, client)
  }

  private class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] = []

    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
      requestedURLs.append(url)
    }
  }
}
