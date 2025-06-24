//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Stanislav Dimitrov on 24.06.25.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedLoaderWithFallbackComposite: FeedLoader {
  private let primary: FeedLoader
  private let fallback: FeedLoader

  init(primary: FeedLoader, fallback: FeedLoader) {
    self.primary = primary
    self.fallback = fallback
  }

  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    primary.load { [weak self] result in
      switch result {
      case .success:
        completion(result)
      case .failure:
        self?.fallback.load(completion: completion)
      }
    }
  }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {

  func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
    let primaryFeed = uniqueFeed()
    let fallbackFeed = uniqueFeed()
    let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))

    expect(sut, toCompleteWith: .success(primaryFeed))
  }

  func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
    let fallbackFeed = uniqueFeed()
    let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))

    expect(sut, toCompleteWith: .success(fallbackFeed))
  }

  private func makeSUT(
    primaryResult: FeedLoader.Result,
    fallbackResult: FeedLoader.Result,
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> FeedLoader {
    let primaryLoader = LoaderStub(result: primaryResult)
    let fallbackLoader = LoaderStub(result: fallbackResult)
    let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
    trackForMemoryLeaks(for: primaryLoader, file: file, line: line)
    trackForMemoryLeaks(for: fallbackLoader, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return sut
  }

  private func expect(
    _ sut: FeedLoader,
    toCompleteWith expectedResult: FeedLoader.Result,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let exp = expectation(description: "Wait for load completion")

    sut.load { receivedResult in
      switch (receivedResult, expectedResult) {
      case (.success(let receivedFeed), .success(let expectedFeed)):
        XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
      case (.failure, .failure):
        break
      default:
        XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }

  private func trackForMemoryLeaks(for instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Expected instance to be deallocated, but it was not.", file: file, line: line)
    }
  }

  private func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
  }

  private func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
  }

  private class LoaderStub: FeedLoader {
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
      self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      completion(result)
    }
  }
}
