//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 17.12.23.
//

import UIKit

extension UIRefreshControl {
  func update(isRefreshing: Bool) {
    isRefreshing ? beginRefreshing() : endRefreshing()
  }
}
