//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 21.01.23.
//

import Foundation

public enum LoadFeedResult {
  case success([FeedItem])
  case failure(Error)
}

protocol FeedLoader {
  func load(completion: @escaping (LoadFeedResult) -> Void)
}
