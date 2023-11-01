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

final class FeedPresenter {

  private let loadingView: FeedLoadingView
  private let feedView: FeedView

  init(loadingView: FeedLoadingView, feedView: FeedView) {
    self.loadingView = loadingView
    self.feedView = feedView
  }

  static var title: String {
    "My Feed"
  }

  func didStartLoadingFeed() {
    loadingView.display(FeedLoadingViewModel(isLoading: true))
  }

  func didEndLoadingFeed(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }

  func didEndLoadingFeed(with error: Error) {
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}
