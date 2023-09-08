//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 8.09.23.
//

import EssentialFeed

public final class FeedUIComposer {
  private init() { }
  
  public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
    let feedController = FeedViewController(refreshController: refreshController)
    refreshController.onRefresh = { [weak feedController] feed in
      feedController?.tableModel = feed.map({ model in
        FeedImageCellConroller(model: model, imageLoader: imageLoader)
      })
    }
    return feedController
  }
}

