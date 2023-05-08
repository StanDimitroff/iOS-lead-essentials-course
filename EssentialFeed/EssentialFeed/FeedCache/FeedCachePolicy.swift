//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 22.04.23.
//

import Foundation

internal final class FeedCachePolicy {

  private init() { }

  internal static let calendar = Calendar(identifier: .gregorian)

  internal static var maxCacheAgeInDays: Int { 7 }

  internal static func isTimestampValid(_ timestamp: Date, against date: Date) -> Bool {
    guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
      return false
    }

    return date < maxCacheAge
  }
}
