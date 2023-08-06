//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 28.05.23.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
  func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    let insertionError = insert(cache: (uniqueImageFeed().local, Date()), to: sut)

    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
  }

  func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    insert(cache: (uniqueImageFeed().local, Date()), to: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }
}
