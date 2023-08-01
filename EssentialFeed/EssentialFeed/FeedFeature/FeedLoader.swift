//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 21.01.23.
//

import Foundation

public protocol FeedLoader {
  typealias Result = Swift.Result<[FeedImage], Error>

  func load(completion: @escaping (Result) -> Void)
}
