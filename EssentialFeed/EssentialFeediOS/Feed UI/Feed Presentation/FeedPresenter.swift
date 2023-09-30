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

  var loadingView: FeedLoadingView?
  var feedView: FeedView?

  func didStartLoadingFeed() {
    loadingView?.display(FeedLoadingViewModel(isLoading: true))
  }

  func didEndLoadingFeed(with feed: [FeedImage]) {
    feedView?.display(FeedViewModel(feed: feed))
    loadingView?.display(FeedLoadingViewModel(isLoading: false))
  }

  func didEndLoadingFeed(with error: Error) {
    loadingView?.display(FeedLoadingViewModel(isLoading: false))
  }
}
