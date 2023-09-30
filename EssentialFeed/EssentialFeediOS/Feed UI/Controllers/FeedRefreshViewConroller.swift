//
//  FeedRefreshViewConroller.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 7.09.23.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {

  private(set) lazy var view: UIRefreshControl = loadView()

  private var loadFeed: () -> Void

  init(loadFeed: @escaping () -> Void) {
    self.loadFeed = loadFeed
  }

  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view.beginRefreshing()
    } else {
      view.endRefreshing()
    }
  }

  @objc func refresh() {
    loadFeed()
  }

  private func loadView() -> UIRefreshControl {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)

    return view
  }
}
