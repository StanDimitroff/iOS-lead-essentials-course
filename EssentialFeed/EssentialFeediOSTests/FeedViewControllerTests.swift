//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Stanislav Dimitrov on 11.08.23.
//

import XCTest
import EssentialFeed

final class FeedViewController: UIViewController {

  private var loader: FeedLoader?

  convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    loader?.load { _ in }
  }
}

final class FeedViewControllerTests: XCTestCase {

  func test_init_doesNotLoadFeed() {
    let (_, loader) = makeSUT()

    XCTAssertEqual(loader.loadCallCount, 0)
  }

  func test_viewDidLoad_loadsFeed() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()

    XCTAssertEqual(loader.loadCallCount, 1)
  }

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)

    trackForMemoryLeaks(for: sut, file: file, line: line)
    trackForMemoryLeaks(for: loader, file: file, line: line)

    return (sut, loader)
  }

  class LoaderSpy: FeedLoader {

    private(set) var loadCallCount = 0

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      loadCallCount += 1
    }
  }
}
