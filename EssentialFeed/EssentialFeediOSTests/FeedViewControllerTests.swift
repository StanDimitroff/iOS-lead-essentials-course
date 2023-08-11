//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Stanislav Dimitrov on 11.08.23.
//

import XCTest

final class FeedViewController {
  init(loader: LoaderSpy) {

  }
}

final class FeedViewControllerTests: XCTestCase {

  func test_init_doesNotLoadFeed() {
    let loader = LoaderSpy()
    _ = FeedViewController(loader: loader)

    XCTAssertEqual(loader.loadCallCount, 0)
  }
}

class LoaderSpy {
  private(set) var loadCallCount = 0
}
