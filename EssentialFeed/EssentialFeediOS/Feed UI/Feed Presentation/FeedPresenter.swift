//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 12.09.23.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
  let isLoading: Bool
}

protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
  let feed: [FeedImage]
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

struct FeedErrorViewModel {
  let message: String?
}

protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
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

  static var title: String {
    NSLocalizedString(
      "FEED_VIEW_TITLE",
      tableName: "Feed",
      bundle: .init(for: FeedPresenter.self),
      comment: "Title for the feed view")
  }

  private var feedLoadError: String {
    return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                             tableName: "Feed",
                             bundle: Bundle(for: FeedPresenter.self),
                             comment: "Error message displayed when we can't load the image feed from the server")
  }

  func didStartLoadingFeed() {
    errorView.display(FeedErrorViewModel(message: nil))
    loadingView.display(FeedLoadingViewModel(isLoading: true))
  }

  func didEndLoadingFeed(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }

  func didEndLoadingFeed(with error: Error) {
    errorView.display(FeedErrorViewModel(message: feedLoadError))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}
