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

    let exp = expectation(description: "Wait for load completion")

    sut.load { result in
      switch result {
      case .success(let receivedFeed):
        XCTAssertEqual(receivedFeed, primaryFeed)
      case .failure:
        XCTFail("Expected successful feed result, got failure instead.")
      }

      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }

  func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
    let fallbackFeed = uniqueFeed()
    let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))

    let exp = expectation(description: "Wait for load completion")

    sut.load { result in
      switch result {
      case .success(let receivedFeed):
        XCTAssertEqual(receivedFeed, fallbackFeed)
      case .failure:
        XCTFail("Expected successful feed result, got failure instead.")
      }

      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }

  private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result) -> FeedLoader {
    let primaryLoader = LoaderStub(result: primaryResult)
    let fallbackLoader = LoaderStub(result: fallbackResult)
    let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

    return sut
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
