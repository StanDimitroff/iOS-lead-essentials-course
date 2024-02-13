//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 13.02.24.
//

import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
  
  func test_init_doesNotSendMessageToView() {
    let (_, view) = makeSUT()

    XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
  }

  func test_didStartLoadingImageData_displaysLoadingImage() {
    let (sut, view) = makeSUT()
    let image = uniqueItem()

    sut.didStartLoadingImageData(for: image)

    let message = view.messages.first

    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.description, image.description)
    XCTAssertEqual(message?.location, image.location)
    XCTAssertEqual(message?.isLoading, true)
    XCTAssertEqual(message?.shouldRetry, false)
    XCTAssertNil(message?.image)
  }

  func test_didFinishLoadingImageData_displaysRetryOnImageTransformationFail() {
    let (sut, view) = makeSUT(imageTransformer: fail)
    let image = uniqueItem()

    sut.didFinishLoadingImageData(with: Data(), for: image)

    let message = view.messages.first

    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.description, image.description)
    XCTAssertEqual(message?.location, image.location)
    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.shouldRetry, true)
    XCTAssertNil(message?.image)
  }

  func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
    let image = uniqueItem()
    let transformedData = AnyImage()
    let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })

    sut.didFinishLoadingImageData(with: Data(), for: image)

    let message = view.messages.first

    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.description, image.description)
    XCTAssertEqual(message?.location, image.location)
    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.shouldRetry, false)
    XCTAssertNotNil(message?.image)
    XCTAssertEqual(message?.image, transformedData)
  }

  func test_didFinishLoadingImageDataWithError_displaysRetry() {
    let (sut, view) = makeSUT()
    let image = uniqueItem()

    sut.didFinishLoadingImageData(with: anyNSError(), for: image)
    
    let message = view.messages.first

    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.description, image.description)
    XCTAssertEqual(message?.location, image.location)
    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.shouldRetry, true)
    XCTAssertNil(message?.image)
  }

  // MARK: - Helpers

  private func makeSUT(
    imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)

    trackForMemoryLeaks(for: view, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return (sut, view)
  }

  private var fail: (Data) -> AnyImage? {
    { _ in nil }
  }

  private struct AnyImage: Equatable { }

  private class ViewSpy: FeedImageView {
    private(set) var messages = [FeedImageViewModel<AnyImage>]()

    func display(_ model: FeedImageViewModel<AnyImage>) {
      messages.append(model)
    }
  }
}
