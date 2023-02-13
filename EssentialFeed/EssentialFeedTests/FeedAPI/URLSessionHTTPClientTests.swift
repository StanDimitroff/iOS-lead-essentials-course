//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 8.02.23.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
  private let session: URLSession

  init(session: URLSession = .shared) {
    self.session = session
  }

  struct UnexpectedValuesRepresentation: Error { }

  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url, completionHandler: { _, _, error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.failure(UnexpectedValuesRepresentation()))
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
    let url = testURL()
    let expectation = expectation(description: "Wait for request")

    URLProtocolStub.observeRequests { request in
      XCTAssertEqual(request.url, url)
      XCTAssertEqual(request.httpMethod, "GET")

      expectation.fulfill()
    }

    makeSUT().get(from: url, completion: { _ in })
    wait(for: [expectation], timeout: 1.0)
  }

  // MARK: - Sad path

  func test_getFromURL_failsOnRequestError() {
    let requestError = NSError(domain: "Some error", code: 1)
    let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError

    XCTAssertEqual(receivedError?.domain, requestError.domain)
    XCTAssertEqual(receivedError?.code, requestError.code)
  }

  func test_getFromURL_failsOnAllInvalidCases() {
    let anyData = Data("Any data".utf8)
    let anyError = NSError(domain: "Any error", code: 0)
    let nonHTTPURLResponse = URLResponse(
      url: testURL(),
      mimeType: nil,
      expectedContentLength: 0,
      textEncodingName: nil)
    let anyHTTPURLResponse = HTTPURLResponse(url: testURL(), statusCode: 200, httpVersion: nil, headerFields: nil)

    XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
    XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: nil))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: nil))
  }

  // MARK - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
    let sut = URLSessionHTTPClient()
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return sut
  }

  private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
    URLProtocolStub.stub(data: data, response: response, error: error)

    let sut = makeSUT(file: file, line: line)
    let expectation = expectation(description: "Wait for completion")
    var receivedError: Error?

    sut.get(from: testURL()) { result in
      switch result {
        case let .failure(error):
          receivedError = error
        default:
          XCTFail("Expected failure, got \(result) instead", file: file, line: line)
      }

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
    return receivedError
  }

  private func testURL() -> URL {
    URL(string: "http://test-url.com")!
  }

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
