//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 7.09.23.
//

import Foundation

public protocol FeedImageDataLoaderTask {
  func cancel()
}

public protocol FeedImageDataLoader {
  typealias Result = Swift.Result<Data, Error>
  func loadFeedImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
