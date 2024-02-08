//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 5.02.24.
//

import XCTest

protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
}

struct FeedErrorViewModel {
  let message: String?

  static var noError: FeedErrorViewModel {
    FeedErrorViewModel(message: nil)
  }
}

final class FeedPresenter {

  private let errorView: FeedErrorView

  init(errorView: FeedErrorView) {
    self.errorView = errorView
  }

  func didStartLoadingFeed() {
    errorView.display(.noError)
  }
}

final class FeedPresenterTests: XCTestCase {
  	
  func test_init_doesNotSendMessagesToView() {
    let (_, view) = makeSUT()

    XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
  }

  func test_didStartLoadingFeed_displaysNoErrorMessage() {
    let (sut, view) = makeSUT()
    
    sut.didStartLoadingFeed()

    XCTAssertEqual(view.messages, [.display(errorMessage: nil)])
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(errorView: view)
    trackForMemoryLeaks(for: view, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)
    return (sut, view)
  }

  private class ViewSpy: FeedErrorView {
    enum Message: Equatable {
      case display(errorMessage: String?)
    }

    private(set) var messages = [Message]()

    func display(_ viewModel: FeedErrorViewModel) {
      messages.append(.display(errorMessage: viewModel.message))
    }
  }
}
