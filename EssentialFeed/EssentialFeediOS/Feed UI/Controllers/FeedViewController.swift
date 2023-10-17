//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 26.08.23.
//

import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {

  private var refreshController: FeedRefreshViewController?
  var tableModel = [FeedImageCellController]() {
    didSet {
      tableView.reloadData()
    }
  }

  init?(coder: NSCoder, refreshController: FeedRefreshViewController) {
    self.refreshController = refreshController
    super.init(coder: coder)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    refreshControl = refreshController?.view
    tableView.prefetchDataSource = self
    refreshController?.refresh()
  }

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    tableModel.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cellController(forRowAt: indexPath).view()
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
