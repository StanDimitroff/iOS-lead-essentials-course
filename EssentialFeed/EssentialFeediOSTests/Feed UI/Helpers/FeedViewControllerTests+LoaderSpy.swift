//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Stanislav Dimitrov on 7.09.23.
//

import EssentialFeed
import EssentialFeediOS

extension FeedViewControllerIntergrationTests {

  class LoaderSpy: FeedLoader, FeedImageDataLoader  {

    // MARK: - FeedLoader

    private(set) var feedRequests = [(FeedLoader.Result) -> Void]()

    var loadFeedCallCount: Int {
      feedRequests.count
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      feedRequests.append(completion)
    }

    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
      feedRequests[index](.success(feed))
    }

    func completeFeedLoadingWithError(at index: Int) {
      let error = NSError(domain: "some error", code: 0)
      feedRequests[index](.failure(error))
    }

    // MARK: - FeedImageDataLoader

    private struct TaskSpy: FeedImageDataLoaderTask {
      let cancelCallback: () -> Void
      func cancel() {
        cancelCallback()
      }
    }

    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

    var loadedImageURLs: [URL] {
      imageRequests.map { $0.url }
    }

    private(set) var cancelledImageURLs = [URL]()

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
      imageRequests.append((url: url, completion: completion))

      return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
    }

    func completeImageLoading(with imageData: Data = .init(), at index: Int = 0) {
      imageRequests[index].completion(.success(imageData))
    }

    func completeImageLoadingWithError(at index: Int = 0) {
      imageRequests[index].completion(.failure(NSError(domain: "Image loader error", code: 0)))
    }
  }
}
