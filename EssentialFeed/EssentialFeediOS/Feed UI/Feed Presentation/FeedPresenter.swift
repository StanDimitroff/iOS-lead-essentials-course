//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 12.09.23.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
  func display(isLoading: Bool)
}

protocol FeedView {
  func display(feed: [FeedImage])
}

final class FeedPresenter {
  typealias Observer<T> = (T) -> Void

  private let feedLoader: FeedLoader

  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }

  var loadingView: FeedLoadingView?
  var feedView: FeedView?

  func loadFeed() {
    loadingView?.display(isLoading: true)
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.feedView?.display(feed: feed)
      }
      self?.loadingView?.display(isLoading: false)
    }
  }
}
