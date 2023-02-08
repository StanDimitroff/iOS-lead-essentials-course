//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 8.02.23.
//

import XCTest

class URLSessionHTTPCLient {
  private let session: URLSession

  init(session: URLSession) {
    self.session = session
  }

  func get(from url: URL) {
    session.dataTask(with: url, completionHandler: {_ , _, _ in })
  }
}

final class URLSessionHTTPClientTests: XCTestCase {

  func test_getFromURLCreatesDataTaskWithURL() {
    let url = URL(string: "http://test-url.com")!
    let sesion = URLSessionSpy()

    let sut = URLSessionHTTPCLient(session: sesion)
    sut.get(from: url)
    XCTAssertEqual(sesion.receivedURLs, [url])
  }

  // MARK - Helpers
  
  private class URLSessionSpy: URLSession {
    var receivedURLs: [URL] = []

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      receivedURLs.append(url)

      return FakeURLSessionDataTask()
    }
  }

  private class FakeURLSessionDataTask: URLSessionDataTask { }

}
