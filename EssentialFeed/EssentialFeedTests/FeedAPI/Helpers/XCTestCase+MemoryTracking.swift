//
//  XCTestCase+MemoryTracking.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 12.02.23.
//

import XCTest

extension XCTestCase {
  func trackForMemoryLeaks(for instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
    }
  }
}
