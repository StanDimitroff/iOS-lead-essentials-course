//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Stanislav Dimitrov on 7.09.23.
//

import UIKit
import EssentialFeediOS

extension FeedImageCell {
  func simulateRetryAction() {
    feedImageRetryButton.simulateTap()
  }

  var isShowingLocation: Bool {
    !locationContainer.isHidden
  }

  var isShowingImageLoadingIndicator: Bool {
    feedImageContainer.isShimmering
  }

  var isShowingRetryAction: Bool {
    !feedImageRetryButton.isHidden
  }

  var locationText: String? {
    locationLabel.text
  }

  var descriptionText: String? {
    descriptionLabel.text
  }

  var renderedImage: Data? {
    feedImageView.image?.pngData()
  }
}
