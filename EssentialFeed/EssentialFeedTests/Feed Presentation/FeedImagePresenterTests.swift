//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Stanislav Dimitrov on 13.02.24.
//

import XCTest
import EssentialFeed

protocol FeedImageView {
  func display(_ model: FeedImageViewModel)
}

struct FeedImageViewModel {
  let description: String?
  let location: String?
  let image: Any?
  let isLoading: Bool
  let shouldRetry: Bool

  var hasLocation: Bool {
    return location != nil
  }
}

final class FeedImagePresenter {
  private let view: FeedImageView

  init(view: FeedImageView) {
    self.view = view
  }

  func didStartLoadingImageData(for model: FeedImage) {
    view.display(FeedImageViewModel(
      description: model.description,
      location: model.location,
      image: nil,
      isLoading: true,
      shouldRetry: false))
  }
}

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

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedImagePresenter(view: view)

    trackForMemoryLeaks(for: view, file: file, line: line)
    trackForMemoryLeaks(for: sut, file: file, line: line)

    return (sut, view)
  }

  private class ViewSpy: FeedImageView {
    private(set) var messages = [FeedImageViewModel]()

    func display(_ model: FeedImageViewModel) {
      messages.append(model)
    }
  }
}
