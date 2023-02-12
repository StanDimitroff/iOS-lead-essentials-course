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

  init(session: URLSession = .shared) {
    self.session = session
  }

  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url, completionHandler: { _, _, error in
      if let error {
        completion(.failure(error))
      }
    }).resume()
  }
}

final class URLSessionHTTPClientTests: XCTestCase {

  override func setUp() {
    super.setUp()

    URLProtocolStub.startInterceptingRequests()
  }

  override class func tearDown() {
    super.tearDown()

    URLProtocolStub.stopInterceptingRequests()
  }

  func test_getFromURL_performsGETRequestWithURL() {
    let url = URL(string: "http://test-url.com")!
    let expectation = expectation(description: "Wait for request")

    URLProtocolStub.observeRequests { request in
      XCTAssertEqual(request.url, url)
      XCTAssertEqual(request.httpMethod, "GET")

      expectation.fulfill()
    }

    URLSessionHTTPCLient().get(from: url, completion: { _ in })
    wait(for: [expectation], timeout: 1.0)
  }

  // MARK: - Sad path

  func test_getFromURL_failsOnRequestError() {
    let url = URL(string: "http://test-url.com")!
    let error = NSError(domain: "Some error", code: 1)
    URLProtocolStub.stub(data: nil, response: nil, error: error)

    let sut = URLSessionHTTPCLient()

    let expectation = expectation(description: "Wait for completion")

    sut.get(from: url) { result in
      switch result {
        case let .failure(receivedError as NSError):
          XCTAssertEqual(receivedError.domain, error.domain)
          XCTAssertEqual(receivedError.code, error.code)
        default:
          XCTFail("Expected failure with \(error), got \(result) instead")
      }

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
  }

  // MARK - Helpers

  private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?

    private struct Stub {
      let data: Data?
      let response: URLResponse?
      let error: Error?
    }

    static func stub(data: Data?, response: URLResponse?, error: Error?) {
      stub = Stub(data: data, response: response, error: error)
    }

    static func startInterceptingRequests() {
      URLProtocol.registerClass(URLProtocolStub.self)
    }

    static func stopInterceptingRequests() {
      URLProtocol.unregisterClass(URLProtocolStub.self)
      stub = nil
      requestObserver = nil
    }

    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
      requestObserver = observer
    }

    override class func canInit(with request: URLRequest) -> Bool {
      requestObserver?(request)
      return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      request
    }

    override func startLoading() {
      if let data = URLProtocolStub.stub?.data {
        client?.urlProtocol(self, didLoad: data)
      }

      if let response = URLProtocolStub.stub?.response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }

      if let error = URLProtocolStub.stub?.error {
        client?.urlProtocol(self, didFailWithError: error)
      }

      client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
  }
}
