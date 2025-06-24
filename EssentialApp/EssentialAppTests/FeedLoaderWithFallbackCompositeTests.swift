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

  init(primary: FeedLoader, fallback: FeedLoader) {
    self.primary = primary
  }

  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    primary.load(completion: completion)
  }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {

  func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
    let primaryFeed = uniqueFeed()
    let fallbackFeed = uniqueFeed()
    let primaryLoader = LoaderStub(result: .success(primaryFeed))
    let fallbackLoader = LoaderStub(result: .success(fallbackFeed))
    let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

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

  private func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
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
