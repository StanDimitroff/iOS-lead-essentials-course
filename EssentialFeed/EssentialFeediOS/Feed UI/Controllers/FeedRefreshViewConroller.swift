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

  @IBOutlet private var view: UIRefreshControl?

  var delegate: FeedRefreshViewConrollerDelegate?

  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view?.beginRefreshing()
    } else {
      view?.endRefreshing()
    }
  }

  @IBAction func refresh() {
    delegate?.didRequestFeedRefresh()
  }
}
