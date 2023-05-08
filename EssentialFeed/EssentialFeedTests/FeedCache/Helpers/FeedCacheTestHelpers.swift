//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 9.04.23.
//

import Foundation
import EssentialFeed

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
  let models = [uniqueItem(), uniqueItem()]
  let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }

  return (models, local)
}

func uniqueItem() -> FeedImage {
  FeedImage(id: UUID(), description:  "any", location: "any", url: anyURL())
}

extension Date {
  func minusFeedCacheMaxAge() -> Date {
    adding(days: -feedCahceMaxAgeInDays)
  }

  private var feedCahceMaxAgeInDays: Int { 7 }
  
  private func adding(days: Int) -> Date {
    Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }
}

extension Date {
  func adding(seconds: TimeInterval) -> Date {
    self + seconds
  }
}
