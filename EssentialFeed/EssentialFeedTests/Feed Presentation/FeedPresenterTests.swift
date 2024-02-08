//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 5.02.24.
//

import XCTest
import EssentialFeed

protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}
struct FeedLoadingViewModel {
  let isLoading: Bool
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}
struct FeedViewModel {
  let feed: [FeedImage]
}

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

  private let loadingView: FeedLoadingView
  private let feedView: FeedView
  private let errorView: FeedErrorView

  init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
    self.loadingView = loadingView
    self.feedView = feedView
    self.errorView = errorView
  }

  func didStartLoadingFeed() {
    errorView.display(.noError)
    loadingView.display(FeedLoadingViewModel(isLoading: true))
  }

  func didEndLoadingFeed(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}

final class FeedPresenterTests: XCTestCase {
  	
  func test_init_doesNotSendMessagesToView() {
    let (_, view) = makeSUT()

    XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
  }

  func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
    let (sut, view) = makeSUT()
    
    sut.didStartLoadingFeed()

    XCTAssertEqual(view.messages, [.display(errorMessage: nil), .display(isLoading: true)])
  }

  func test_didEndtLoadingFeed_displaysFeedAndStopsLoading() {
    let (sut, view) = makeSUT()
    let feed = uniqueImageFeed().models

    sut.didEndLoadingFeed(with: feed)

    XCTAssertEqual(view.messages, [.display(feed: feed), .display(isLoading: false)])
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(loadingView: view, feedView: view, errorView: view)
    trackForMemoryLeaks(for: view, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)
    return (sut, view)
  }

  private class ViewSpy: FeedLoadingView, FeedView, FeedErrorView {
    enum Message: Hashable {
      case display(errorMessage: String?)
      case display(isLoading: Bool)
      case display(feed: [FeedImage])
    }

    private(set) var messages = Set<Message>()

    func display(_ viewModel: FeedLoadingViewModel) {
      messages.insert(.display(isLoading: viewModel.isLoading))
    }

    func display(_ viewModel: FeedViewModel) {
      messages.insert(.display(feed: viewModel.feed))
    }

    func display(_ viewModel: FeedErrorViewModel) {
      messages.insert(.display(errorMessage: viewModel.message))
    }
  }
}
