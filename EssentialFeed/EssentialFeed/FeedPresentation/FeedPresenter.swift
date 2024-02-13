//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 13.02.24.
//

import Foundation

public protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

public protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
}
public struct FeedErrorViewModel {
  public let message: String?

  static var noError: FeedErrorViewModel {
    FeedErrorViewModel(message: nil)
  }

  static func error(message: String) -> FeedErrorViewModel {
    FeedErrorViewModel(message: message)
  }
}

public final class FeedPresenter {

  private let loadingView: FeedLoadingView
  private let feedView: FeedView
  private let errorView: FeedErrorView

  private var feedLoadError: String {
    return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                             tableName: "Feed",
                             bundle: Bundle(for: FeedPresenter.self),
                             comment: "Error message displayed when we can't load the image feed from the server")
  }

  public init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
    self.loadingView = loadingView
    self.feedView = feedView
    self.errorView = errorView
  }

  public static var title: String {
    NSLocalizedString(
      "FEED_VIEW_TITLE",
      tableName: "Feed",
      bundle: .init(for: FeedPresenter.self),
      comment: "Title for the feed view")
  }

  public func didStartLoadingFeed() {
    errorView.display(.noError)
    loadingView.display(FeedLoadingViewModel(isLoading: true))
  }

  public func didEndLoadingFeed(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }

  public func didEndLoadingFeed(with error: Error) {
    errorView.display(.error(message: feedLoadError))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}
