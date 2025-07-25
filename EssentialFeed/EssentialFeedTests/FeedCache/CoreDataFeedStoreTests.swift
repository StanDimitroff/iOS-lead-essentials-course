//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 28.05.23.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {

  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()

    assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
  }

  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()

    assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
  }

  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    let sut = makeSUT()

    assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
  }

  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()

    assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
  }

  func test_insert_overridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()

    assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
  }

  func test_insert_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()

    assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
  }

  func test_insert_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()

    assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
  }

  func test_delete_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()
    
    assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
  }

  func test_delete_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()

    assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
  }

  func test_delete_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()

    assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
  }

  func test_delete_emptiesPreviouslyInsertedCache() {
    let sut = makeSUT()

    assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
  }

  func test_storeSideEffects_runSerially() {
    let sut = makeSUT()
    
    assertThatSideEffectsRunSerially(on: sut)
  }

  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
    let storeURL = URL(fileURLWithPath: "/dev/null")
    let sut = try! CoreDataFeedStore(storeURL: storeURL)
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return sut
  }
}
