//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 8.02.23.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
  func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
  func resume()
}

class URLSessionHTTPCLient {
  private let session: HTTPSession

  init(session: HTTPSession) {
    self.session = session
  }

  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url, completionHandler: {_ , _, error in
      if let error {
        completion(.failure(error))
      }
    }).resume()
  }
}

final class URLSessionHTTPClientTests: XCTestCase {

  func test_getFromURL_resumesDataTaskWithURL() {
    let url = URL(string: "http://test-url.com")!
    let session = HTTPSessionSpy()
    let task = URLSessionDataTaskSpy()
    session.stub(url: url, task: task)

    let sut = URLSessionHTTPCLient(session: session)

    sut.get(from: url) { _ in }

    XCTAssertEqual(task.resumeCallCount, 1)
  }

  // MARK: - Sad path

  func test_getFromURL_failsOnRequestError() {
    let url = URL(string: "http://test-url.com")!
    let session = HTTPSessionSpy()
    let task = URLSessionDataTaskSpy()

    let error = NSError(domain: "Some error", code: 1)
    session.stub(url: url, error: error)

    let sut = URLSessionHTTPCLient(session: session)

    let expectation = expectation(description: "Wait for completion")

    sut.get(from: url) { result in
      switch result {
        case let .failure(receivedError as NSError):
          XCTAssertEqual(receivedError, error)
        default:
          XCTFail("Expected failure with \(error), got \(result) instead")
      }

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
  }

  // MARK - Helpers

  private class HTTPSessionSpy: HTTPSession {
    private var stubs = [URL: Stub]()

    private struct Stub {
      let task: HTTPSessionTask
      let error: Error?
    }

    func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
      stubs[url] = Stub(task: task, error: error)
    }

    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
      guard let stub = stubs[url] else {
        fatalError("Could'n find stub for \(url)")
      }
      completionHandler(nil, nil, stub.error)
      return stub.task
    }
  }

  private class FakeURLSessionDataTask: HTTPSessionTask {
    func resume() {

    }
  }
  private class URLSessionDataTaskSpy: HTTPSessionTask {
    var resumeCallCount: Int = 0

    func resume() {
      resumeCallCount += 1
    }
  }
}
