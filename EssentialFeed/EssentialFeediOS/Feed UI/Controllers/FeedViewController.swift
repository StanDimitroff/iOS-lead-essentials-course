//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 26.08.23.
//

import UIKit

protocol FeedViewControllerDelegate {
  func didRequestFeedRefresh()
}

public final class ErrorView: UIView {
  public var message: String?
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView {

  var delegate: FeedViewControllerDelegate?
  @IBOutlet private(set) public var errorView: ErrorView?

  var tableModel = [FeedImageCellController]() {
    didSet {
      tableView.reloadData()
    }
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    refresh()
  }

  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      refreshControl?.beginRefreshing()
    } else {
      refreshControl?.endRefreshing()
    }
  }

  func display(_ viewModel: FeedErrorViewModel) {
    errorView?.message = viewModel.message
  }

  @IBAction private func refresh() {
    delegate?.didRequestFeedRefresh()
  }

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    tableModel.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cellController(forRowAt: indexPath).view(in: tableView)
  }

  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cancelCellControllerLoad(forRowAt: indexPath)
  }

  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      cellController(forRowAt: indexPath).preload()
    }
  }

  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(cancelCellControllerLoad)
  }

  private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
    tableModel[indexPath.row]
  }

  private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
    cellController(forRowAt: indexPath).cancelLoad()
  }
}
