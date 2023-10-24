//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Stanislav Dimitrov on 7.09.23.
//

import UIKit
import EssentialFeediOS

extension FeedViewController {
  func simulateUserInitiatedFeedReload() {
    refreshControl?.simulatePullToRefresh()
  }

  @discardableResult
  func simulateFeedImageViewBecomeVisible(at index: Int) -> FeedImageCell? {
    feedImageView(at: index) as? FeedImageCell
  }

  @discardableResult
  func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell?  {
    let view = simulateFeedImageViewBecomeVisible(at: row)

    let delegate = tableView.delegate
    let indexPath = IndexPath(row: row, section: feedImageSection)
    delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)

    return view
  }

  func simulateFeedImageViewNearVisible(at row: Int) {
    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImageSection)
    ds?.tableView(tableView, prefetchRowsAt: [index])
  }

  func simulateFeedImageViewNotNearVisible(at row: Int) {
    simulateFeedImageViewNearVisible(at: row)

    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImageSection)
    ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
  }

  var isShowingLoadingIndicator: Bool {
    refreshControl?.isRefreshing == true
  }

  func numberOfRenderedFeedImageViews() -> Int {
    tableView.numberOfRows(inSection: feedImageSection)
  }

  func feedImageView(at row: Int) -> UITableViewCell? {
    let dataSource = tableView.dataSource
    let indexPath = IndexPath(row: row, section: feedImageSection)

    return dataSource?.tableView(tableView, cellForRowAt: indexPath)
  }

  private var feedImageSection: Int {
    0
  }
}
