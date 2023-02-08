//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 8.02.23.
//

import XCTest
import EssentialFeed

class URLSessionHTTPCLient {
  private let session: URLSession

  init(session: URLSession) {
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
    let session = URLSessionSpy()
    let task = URLSessionDataTaskSpy()
    session.stub(url: url, task: task)

    let sut = URLSessionHTTPCLient(session: session)

    sut.get(from: url) { _ in }

    XCTAssertEqual(task.resumeCallCount, 1)
  }

  // MARK: - Sad path

  func test_getFromURL_failsOnRequestError() {
    let url = URL(string: "http://test-url.com")!
    let session = URLSessionSpy()
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

  private class URLSessionSpy: URLSession {
    private var stubs = [URL: Stub]()

    private struct Stub {
      let task: URLSessionDataTask
      let error: Error?
    }

    func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
      stubs[url] = Stub(task: task, error: error)
    }

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      guard let stub = stubs[url] else {
        fatalError("Could'n find stub for \(url)")
      }
      completionHandler(nil, nil, stub.error)
      return stub.task
    }
  }

  private class FakeURLSessionDataTask: URLSessionDataTask {
    override func resume() {

    }
  }
  private class URLSessionDataTaskSpy: URLSessionDataTask {
    var resumeCallCount: Int = 0

    override func resume() {
      resumeCallCount += 1
    }
  }
}
