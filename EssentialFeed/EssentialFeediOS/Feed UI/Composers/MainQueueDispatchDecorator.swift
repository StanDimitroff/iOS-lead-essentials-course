//
//  MainQueueDisoatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Stanislav Dimitrov on 5.11.23.
//

import Foundation
import EssentialFeed

final class MainQueueDispatchDecorator<T> {
  private let decoratee: T

  init(decoratee: T) {
    self.decoratee = decoratee
  }

  func dispatch(completion: @escaping () -> Void) {
    guard Thread.isMainThread else {
      return DispatchQueue.main.async { completion() }
    }
    completion()
  }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    decoratee.load { [weak self] result in
      self?.dispatch{ completion(result) }
    }
  }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
  func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
    decoratee.loadImageData(from: url) { [weak self] result in
      self?.dispatch{ completion(result) }
    }
  }
}
