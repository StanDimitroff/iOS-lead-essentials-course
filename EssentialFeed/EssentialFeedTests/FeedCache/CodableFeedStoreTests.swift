//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 8.05.23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    completion(.empty )
  }
}

final class CodableFeedStoreTests: XCTestCase {

  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = CodableFeedStore()
    let exp = expectation(description: "Wait for retrieval")

    sut.retrieve { result in

      switch result {
        case .empty:
          break

        default:
          XCTFail("Expected emty result, got \(result) instead.")
      }

      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }

}
