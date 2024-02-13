//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 13.02.24.
//

import Foundation

public struct FeedErrorViewModel {
  public let message: String?

  static var noError: FeedErrorViewModel {
    FeedErrorViewModel(message: nil)
  }

  static func error(message: String) -> FeedErrorViewModel {
    FeedErrorViewModel(message: message)
  }
}
