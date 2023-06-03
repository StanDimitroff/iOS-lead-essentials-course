//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Stanislav Dimitrov on 17.05.23.
//

import Foundation

public final class CodableFeedStore: FeedStore {

  private struct Cache: Codable {
    let feed: [CodableFeedImage]
    let timestamp: Date

    var localFeed: [LocalFeedImage] {
      feed.map({ $0.local })
    }
  }

  private struct CodableFeedImage: Codable {
    private let id: UUID
    private let description: String?
    private let location: String?
    private let url: URL

    init(_ image: LocalFeedImage) {
      self.id = image.id
      self.description = image.description
      self.location = image.location
      self.url = image.url
    }

    var local: LocalFeedImage {
      .init(id: id, description: description, location: location, url: url)
    }
  }

  private let storeURL: URL

  private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)

  public init(storeURL: URL) {
    self.storeURL = storeURL
  }

  public func retrieve(completion: @escaping RetrievalCompletion) {
    let storeURL = self.storeURL
    queue.async {
      guard let data = try? Data(contentsOf: storeURL) else {
        return completion(.empty)
      }

      let decoder = JSONDecoder()
      do {
        let cache = try decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
      } catch {
        completion(.failure(error))
      }
    }
  }

  public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    let storeURL = self.storeURL
    queue.async(flags: .barrier) {
      let encoder = JSONEncoder()
      let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
      let encoded = try! encoder.encode(cache)

      do {
        try encoded.write(to: storeURL)
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }

  public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    let storeURL = self.storeURL
    queue.async(flags: .barrier) {
      guard FileManager.default.fileExists(atPath: storeURL.path) else {
        return completion(nil)
      }
      
      do {
        try FileManager.default.removeItem(at: storeURL)
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }
}
