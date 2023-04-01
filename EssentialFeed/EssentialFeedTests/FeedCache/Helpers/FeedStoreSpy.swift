//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 1.04.23.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {

  enum ReceivedMesssage: Equatable {
    case deleteCachedFeed
    case insert([LocalFeedImage], Date)
  }

  private(set) var receivedMessages = [ReceivedMesssage]()
  private var deletionCompletions = [DeletionCompletion]()
  private var insertionCompletions = [InsertionCompletion]()

  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCachedFeed)
  }

  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }

  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](error)
  }

  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }

  func completeInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](nil)
  }

  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(feed, timestamp ))
  }
}
