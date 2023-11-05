//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 5.11.23.
//

import Foundation
import EssentialFeed

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
  private let feedLoader: FeedLoader
  var presenter: FeedPresenter?

  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }

  func didRequestFeedRefresh() {
    presenter?.didStartLoadingFeed()

    feedLoader.load { [weak self] result in
      switch result {
      case let .success(feed):
        self?.presenter?.didEndLoadingFeed(with: feed)

      case let .failure(error):
        self?.presenter?.didEndLoadingFeed(with: error)
      }
    }
  }
}
