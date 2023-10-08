//
//  FeedRefreshViewConroller.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 7.09.23.
//

import UIKit

protocol FeedRefreshViewConrollerDelegate {
  func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {

  private(set) lazy var view: UIRefreshControl = loadView()

  private var delegate: FeedRefreshViewConrollerDelegate

  init(delegate: FeedRefreshViewConrollerDelegate) {
    self.delegate = delegate
  }

  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view.beginRefreshing()
    } else {
      view.endRefreshing()
    }
  }

  @objc func refresh() {
    delegate.didRequestFeedRefresh()
  }

  private func loadView() -> UIRefreshControl {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)

    return view
  }
}
