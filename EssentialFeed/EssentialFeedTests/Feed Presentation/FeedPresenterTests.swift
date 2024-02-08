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

  static func error(message: String) -> FeedErrorViewModel {
    FeedErrorViewModel(message: message)
  }
}

final class FeedPresenter {

  private let loadingView: FeedLoadingView
  private let feedView: FeedView
  private let errorView: FeedErrorView

  private var feedLoadError: String {
    return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                             tableName: "Feed",
                             bundle: Bundle(for: FeedPresenter.self),
                             comment: "Error message displayed when we can't load the image feed from the server")
  }

  init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
    self.loadingView = loadingView
    self.feedView = feedView
    self.errorView = errorView
  }

  static var title: String {
    NSLocalizedString(
      "FEED_VIEW_TITLE",
      tableName: "Feed",
      bundle: .init(for: FeedPresenter.self),
      comment: "Title for the feed view")
  }

  func didStartLoadingFeed() {
    errorView.display(.noError)
    loadingView.display(FeedLoadingViewModel(isLoading: true))
  }

  func didEndLoadingFeed(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }

  func didEndLoadingFeed(with error: Error) {
    errorView.display(.error(message: feedLoadError))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}

final class FeedPresenterTests: XCTestCase {

  func test_title_isLocalized() {
    XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
  }

  func test_init_doesNotSendMessagesToView() {
    let (_, view) = makeSUT()

    XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
  }

  func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
    let (sut, view) = makeSUT()
    
    sut.didStartLoadingFeed()

    XCTAssertEqual(view.messages, [.display(errorMessage: nil), .display(isLoading: true)])
  }

  func test_didEndLoadingFeed_displaysFeedAndStopsLoading() {
    let (sut, view) = makeSUT()
    let feed = uniqueImageFeed().models

    sut.didEndLoadingFeed(with: feed)

    XCTAssertEqual(view.messages, [.display(feed: feed), .display(isLoading: false)])
  }

  func test_didEndLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
    let (sut, view) = makeSUT()

    sut.didEndLoadingFeed(with: anyNSError())

    XCTAssertEqual(
      view.messages,
      [.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")), .display(isLoading: false)]
    )
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(loadingView: view, feedView: view, errorView: view)
    trackForMemoryLeaks(for: view, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)
    return (sut, view)
  }

  private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
    let table = "Feed"
    let bundle = Bundle(for: FeedPresenter.self)
    let value = bundle.localizedString(forKey: key, value: nil, table: table)
    if value == key {
      XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
    }
    return value
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
