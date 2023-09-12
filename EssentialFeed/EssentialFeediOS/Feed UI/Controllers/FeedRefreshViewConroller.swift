//
//  FeedRefreshViewConroller.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 7.09.23.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {

  private(set) lazy var view: UIRefreshControl = loadView()

  private let presenter: FeedPresenter

  init(presenter: FeedPresenter) {
    self.presenter = presenter
  }

  func display(isLoading: Bool) {
    if isLoading {
      view.beginRefreshing()
    } else {
      view.endRefreshing()
    }
  }

  @objc func refresh() {
    presenter.loadFeed()
  }

  private func loadView() -> UIRefreshControl {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)

    return view
  }
}
