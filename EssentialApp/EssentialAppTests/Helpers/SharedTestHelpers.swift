//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Stanislav Dimitrov on 10.07.25.
//

import Foundation

func anyURL() -> URL {
  URL(string: "http://test-url.com")!
}

func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
  Data("Any data".utf8)
}
