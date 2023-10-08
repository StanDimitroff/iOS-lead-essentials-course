//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 10.09.23.
//

import EssentialFeed

struct FeedImageViewModel<Image> {
  let description: String?
  let location: String?
  let image: Image?
  let isLoading: Bool
  let shouldRetry: Bool

  var hasLocation: Bool {
    return location != nil
  }
}
