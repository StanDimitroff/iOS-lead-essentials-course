//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Stanislav Dimitrov on 25.06.25.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {

  init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {

  }

  private class Task: FeedImageDataLoaderTask {
    func cancel() {

    }
  }

  func loadImageData(
    from url: URL,
    completion: @escaping (FeedImageDataLoader.Result) -> Void
  ) -> any FeedImageDataLoaderTask {
    let task = Task()

    return task
  }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {

  func test_init_doesNotLoadImageData() {
    let (_, primaryLoader, fallbackLoader) = makeSUT()

    XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
    XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
  }

  // MARK: - Helpers

  private func makeSUT(
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> (FeedImageDataLoader, LoaderSpy, LoaderSpy) {
    let primaryLoader = LoaderSpy()
    let fallbackLoader = LoaderSpy()
    let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

    return (sut, primaryLoader, fallbackLoader)
  }

  private func anyURL() -> URL {
    URL(string: "http://test-url.com")!
  }

  private func anyData() -> Data {
    Data("Any data".utf8)
  }

  private class LoaderSpy: FeedImageDataLoader {
    private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

    var loadedURLs: [URL] {
      return messages.map { $0.url }
    }

    private struct Task: FeedImageDataLoaderTask {
      func cancel() {

      }
    }

    func loadImageData(
      from url: URL,
      completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> any FeedImageDataLoaderTask {
      messages.append((url, completion))

      return Task()
    }
  }
}
