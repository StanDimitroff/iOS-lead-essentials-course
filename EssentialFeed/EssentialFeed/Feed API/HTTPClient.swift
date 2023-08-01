//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 21.01.23.
//

import Foundation

public protocol HTTPClient {
  typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

  func get(from url: URL, completion: @escaping (Result) -> Void)
}
