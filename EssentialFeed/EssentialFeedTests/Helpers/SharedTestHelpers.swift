//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 9.04.23.
//

import Foundation

func anyNSError() -> NSError {
  NSError(domain: "Any error", code: 0)
}

func anyURL() -> URL {
  URL(string: "http://test-url.com")!
}
