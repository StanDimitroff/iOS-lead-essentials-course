//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Stanislav Dimitrov on 11.08.23.
//

import XCTest

final class FeedViewController: UIViewController {

  private var loader: FeedViewControllerTests.LoaderSpy?
  convenience init(loader: FeedViewControllerTests.LoaderSpy) {
    self.init()
    self.loader = loader
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    loader?.load()
  }
}

final class FeedViewControllerTests: XCTestCase {

  func test_init_doesNotLoadFeed() {
    let loader = LoaderSpy()
    _ = FeedViewController(loader: loader)

    XCTAssertEqual(loader.loadCallCount, 0)
  }

  func test_viewDidLoad_loadsFeed() {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)

    sut.loadViewIfNeeded()

    XCTAssertEqual(loader.loadCallCount, 1)
  }

  class LoaderSpy {
    private(set) var loadCallCount = 0

    func load() {
      loadCallCount += 1
    }
  }
}

