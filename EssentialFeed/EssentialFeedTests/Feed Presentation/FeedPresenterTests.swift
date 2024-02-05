//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 5.02.24.
//

import XCTest

final class FeedPresenter {
  init(view: Any) {

  }
}

final class FeedPresenterTests: XCTestCase {
  
  func test_init_doesNotSendMessagesToView() {
    let (_, view) = makeSUT()

    XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(view: view)
    trackForMemoryLeaks(for: view, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)
    return (sut, view)
  }

  private class ViewSpy {
    let messages = [Any]()
  }
}
