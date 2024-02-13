//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 13.02.24.
//

import XCTest

final class FeedImagePresenter {
  init(view: Any) {

  }
}

final class FeedImagePresenterTests: XCTestCase {
  
  func test_init_doesNotSendMessageToView() {
    let view = ViewSpy()

    _ = FeedImagePresenter(view: view)

    XCTAssertEqual(view.messages.count, 0)
  }

  // MARK: - Helpers

  private class ViewSpy {
    var messages = [Any]()
  }
}
