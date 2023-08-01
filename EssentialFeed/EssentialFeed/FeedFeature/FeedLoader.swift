//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 21.01.23.
//

import Foundation

public typealias LoadFeedResult = Swift.Result<[FeedImage], Error>

public protocol FeedLoader {
  func load(completion: @escaping (LoadFeedResult) -> Void)
}
