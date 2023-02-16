//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 8.02.23.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClientTests: XCTestCase {

  override func setUp() {
    super.setUp()

    URLProtocolStub.startInterceptingRequests()
  }

  override func tearDown() {
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
    let requestError = anyNSError()
    let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError

    XCTAssertEqual(receivedError?.domain, requestError.domain)
    XCTAssertEqual(receivedError?.code, requestError.code)
  }

  func test_getFromURL_failsOnAllInvalidCases() {
    XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
    XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
    XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
    XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
    XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
    XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
  }

  // MARK: Happy path

  func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
    let data = anyData()
    let response = anyHTTPURLResponse()

    let receivedValues = resultValuesFor(data: data, response: response, error: nil)

    XCTAssertEqual(receivedValues?.data, data)
    XCTAssertEqual(receivedValues?.response.url, response.url)
    XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
  }

  func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
    let response = anyHTTPURLResponse()

    let receivedValues = resultValuesFor(data: nil, response: response, error: nil)

    let emptyData = Data()
    XCTAssertEqual(receivedValues?.data, emptyData)
    XCTAssertEqual(receivedValues?.response.url, response.url)
    XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
  }

  // MARK - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
    let sut = URLSessionHTTPClient()
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return sut
  }

  private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
    let result = resultFor(data: data, response: response, error: error, file: file, line: line)

    switch result {
      case let .failure(error):
        return error
      default:
        XCTFail("Expected failure, got \(result) instead", file: file, line: line)
        return nil
    }
  }

  private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
    let result = resultFor(data: data, response: response, error: error, file: file, line: line)

    switch result {
      case let .success(data, response):
        return (data, response)
      default:
        XCTFail("Expected success, got \(result) instead", file: file, line: line)
        return nil
    }
  }

  private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
    URLProtocolStub.stub(data: data, response: response, error: error)

    let sut = makeSUT(file: file, line: line)
    let expectation = expectation(description: "Wait for completion")
    var receivedResult: HTTPClientResult!

    sut.get(from: testURL()) { result in
      receivedResult = result

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
    return receivedResult
  }

  private func testURL() -> URL {
    URL(string: "http://test-url.com")!
  }

  private func anyData() -> Data {
    Data("Any data".utf8)
  }

  private func anyNSError() -> NSError {
    NSError(domain: "Any error", code: 0)
  }

  private func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: testURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
  }

  private func nonHTTPURLResponse() -> URLResponse {
   URLResponse(
      url: testURL(),
      mimeType: nil,
      expectedContentLength: 0,
      textEncodingName: nil)
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
