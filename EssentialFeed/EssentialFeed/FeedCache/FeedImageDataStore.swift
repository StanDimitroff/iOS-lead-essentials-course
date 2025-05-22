//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 22.05.25.
//

public protocol FeedImageDataStore {
  typealias Result = Swift.Result<Data?, Error>
  func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
