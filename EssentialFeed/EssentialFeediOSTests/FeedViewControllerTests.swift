//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Stanislav Dimitrov on 11.08.23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {

  func test_loadFeedActions_requestFeedFromLoader() {
    let (sut, loader) = makeSUT()
    XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")

    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected loading request once view is loaded")

    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a load")

    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected third loading request once user initiates another load")
  }

  func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

    loader.completeFeedLoading(at: 0)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed successfully")

    sut.simulateUserInitiatedFeedReload()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

    loader.completeFeedLoadingWithError(at: 1)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed with error")
  }

  func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
    let image0 = makeImage(description: "a description", location: "a location")
    let image1 = makeImage(description: nil, location: "a location")
    let image2 = makeImage(description: "a description", location: nil)
    let image3 = makeImage(description: nil, location: nil)

    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    assertThat(sut, isRendering: [])

    loader.completeFeedLoading(with: [image0], at: 0)
    assertThat(sut, isRendering: [image0])

    sut.simulateUserInitiatedFeedReload()
    loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
    assertThat(sut, isRendering: [image0, image1, image2, image3])
  }

  func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
    let image0 = makeImage()

    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [image0], at: 0)
    assertThat(sut, isRendering: [image0])

    sut.simulateUserInitiatedFeedReload()
    loader.completeFeedLoadingWithError(at: 1)
    assertThat(sut, isRendering: [image0])
  }

  func test_feedImageView_loadsImageURLWhenVisible() {
    let image0 = makeImage(url: .init(string: "http://url-0.com")!)
    let image1 = makeImage(url: .init(string: "http://url-1.com")!)

    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [image0, image1], at: 0)
    XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until view become visible")

    sut.simulateFeedImageViewBecomeVisible(at: 0)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")

    sut.simulateFeedImageViewBecomeVisible(at: 1)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second view becomes visible")
  }

  func test_feedImageView_cancelsImageLoadingWhenViewNotVisibleAnymore() {
    let image0 = makeImage(url: .init(string: "http://url-0.com")!)
    let image1 = makeImage(url: .init(string: "http://url-1.com")!)

    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [image0, image1], at: 0)
    XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")

    sut.simulateFeedImageViewNotVisible(at: 0)
    XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")

    sut.simulateFeedImageViewNotVisible(at: 1)
    XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
  }

  func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [makeImage(), makeImage()])

    let view0 = sut.simulateFeedImageViewBecomeVisible(at: 0)
    let view1 = sut.simulateFeedImageViewBecomeVisible(at: 1)

    XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
    XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")

    loader.completeImageLoading(at: 0)
    XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
    XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")

    loader.completeImageLoadingWithError(at: 1)
    XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false , "Expected no loading indicator state change for first view once second image loading completes with error")
    XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
  }

  func test_feedImageView_rendersImageLoadedFromURL() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [makeImage(), makeImage()])

    let view0 = sut.simulateFeedImageViewBecomeVisible(at: 0)
    let view1 = sut.simulateFeedImageViewBecomeVisible(at: 1)
    XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
    XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")

    let imageData0 = UIImage.make(withColor: .red).pngData()!
    loader.completeImageLoading(with: imageData0, at: 0)
    XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
    XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")

    let imageData1 = UIImage.make(withColor: .blue).pngData()!
    loader.completeImageLoading(with: imageData1, at: 1)
    XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
    XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
  }

  func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [makeImage(), makeImage()])

    let view0 = sut.simulateFeedImageViewBecomeVisible(at: 0)
    let view1 = sut.simulateFeedImageViewBecomeVisible(at: 1)
    XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
    XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")

    let imageData = UIImage.make(withColor: .red).pngData()!
    loader.completeImageLoading(with: imageData, at: 0)
    XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
    XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")

    loader.completeImageLoadingWithError(at: 1)
    XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
    XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = FeedViewController(feedLoader: loader, imageLoader: loader)

    trackForMemoryLeaks(for: sut, file: file, line: line)
    trackForMemoryLeaks(for: loader, file: file, line: line)

    return (sut, loader)
  }

  private func makeImage(description: String? = nil, location: String? = nil, url: URL = .init(string: "http://any-url.com")!) -> FeedImage {
    FeedImage(id: UUID(), description: description, location: location, url: url)
  }

  private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
    guard sut.numberOfRenderedFeedImageViews() == feed.count else {
      return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
    }

    feed.enumerated().forEach { index, image in
      assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
    }
  }

  private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
    let view = sut.feedImageView(at: index)

    guard let cell = view as? FeedImageCell else {
      return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
    }

    let shouldLocationBeVisible = (image.location != nil)
    XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)

    XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image  view at index (\(index))", file: file, line: line)

    XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)
  }

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

    func loadFeedImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
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

private extension FeedViewController {
  func simulateUserInitiatedFeedReload() {
    refreshControl?.simulatePullToRefresh()
  }

  @discardableResult
  func simulateFeedImageViewBecomeVisible(at index: Int) -> FeedImageCell? {
    feedImageView(at: index) as? FeedImageCell
  }

  func simulateFeedImageViewNotVisible(at row: Int) {
    let view = feedImageView(at: row)

    let delegate = tableView.delegate
    let indexPath = IndexPath(row: row, section: feedImageSection)
    delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
  }

  var isShowingLoadingIndicator: Bool {
    refreshControl?.isRefreshing == true
  }

  func numberOfRenderedFeedImageViews() -> Int {
    tableView.numberOfRows(inSection: feedImageSection)
  }

  func feedImageView(at row: Int) -> UITableViewCell? {
    let dataSource = tableView.dataSource
    let indexPath = IndexPath(row: row, section: feedImageSection)

    return dataSource?.tableView(tableView, cellForRowAt: indexPath)
  }

  private var feedImageSection: Int {
    0
  }
}

private extension FeedImageCell {
  var isShowingLocation: Bool {
    !locationContainer.isHidden
  }

  var isShowingImageLoadingIndicator: Bool {
    feedImageContainer.isShimmering
  }

  var isShowingRetryAction: Bool {
    !feedImageRetryButton.isHidden
  }

  var locationText: String? {
    locationLabel.text
  }

  var descriptionText: String? {
    descriptionLabel.text
  }

  var renderedImage: Data? {
    feedImageView.image?.pngData()
  }
}

private extension UIRefreshControl {
  func simulatePullToRefresh() {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }
  }
}

extension UIImage {
  static func make(withColor color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1

    return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
      color.setFill()
      rendererContext.fill(rect)
    }
  }
}
