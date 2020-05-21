//
//  FlowTests.swift
//  WY Mini Tool EngineTests
//
//  Created by Ilya Sakalou on 5/4/20.
//  Copyright © 2020 Nirma. All rights reserved.
//

import Foundation
import XCTest
@testable import WY_Mini_Tool_Engine

class FlowTests: XCTestCase {
  let router = RouterSpy()
  
  func test_start_withNoSegments_doesNotRouteToSegment() {
    makeSUT(segments: []).start()
    
    XCTAssertNil(router.routedSegment)
  }
  
  func test_start_withSegments_routeToFirstSegment() {
    let segment = SegmentSpy(value: "one")
    makeSUT(segments: [segment]).start()
    
    XCTAssertEqual(router.routedSegment, segment)
  }
  
  func test_startAndChooseSameSegment_withSegments_routesToNextSegment() {
    let firstSegment = SegmentSpy(value: "one")
    let secondSegment = SegmentSpy(value: "two")
    let segments = [firstSegment, secondSegment]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), firstSegment)
    
    XCTAssertEqual(router.routedSegment, secondSegment)
  }
  
  func test_startTwice_withSegments_routeToFirstSegmentTwice() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    let sut = makeSUT(segments: segments)
    
    sut.start()
    sut.start()
     
    XCTAssertEqual(router.routedSegment?.value, SegmentSpy(value: "one").value)
  }
  
  func test_startAndGiveRightAnswerToFirst_withOneSegment_doesNotRoute() {
    let segment = SegmentSpy(value: "one")
    makeSUT(segments: [segment]).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), SegmentSpy(value: "one"))
    
    XCTAssertEqual(router.routedSegment, segment)
  }
  
  func test_start_withNoSegments_routeToResult() {
    makeSUT(segments: []).start()
    
    XCTAssertTrue(router.finished)
  }
  
  func test_start_withOneSegments_doesNotRouteToResult() {
    makeSUT(segments: [SegmentSpy(value: "one")]).start()
    
    XCTAssertFalse(router.finished)
  }
  
  func test_startAndGiveRightAnswer_withOneSegment_finishesFlow() {
    let segment = SegmentSpy(value: "one")
    makeSUT(segments: [segment]).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), segment)
    
    XCTAssertTrue(router.finished)
  }
  
  func test_startAndGiveRightAnswer_withTwoSegments_finishesFlow() {
    let firstSegment = SegmentSpy(value: "one")
    let secondSegment = SegmentSpy(value: "two")
    let segments = [firstSegment, secondSegment]
    
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), firstSegment)
    router.selectionCallback(SegmentSpy(value: "two"), secondSegment)
    
    XCTAssertTrue(router.finished)
  }
  
  func test_startAndGiveOneRightAnswer_withTwoSegments_doesNotFinishFlow() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), SegmentSpy(value: "one"))
    
    XCTAssertFalse(router.finished)
  }
  
  func test_startAndGiveWrongAnswer_withTwoSegments_doesNotRouteToSecond() {
    let segment = SegmentSpy(value: "one")
    let segments = [segment, SegmentSpy(value: "two")]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "oone"), SegmentSpy(value: "one"))
    
    XCTAssertEqual(router.routedSegment, segment)
  }
  
  func test_startAndGiveWrongAnswer_triggersFailedAttempt() {
    let segment = SegmentSpy(value: "one")
    let segments = [segment, SegmentSpy(value: "two")]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "oone"), segment)
    
    XCTAssertEqual(router.failedSegment, segment)
  }
  
  func test_startAndGiveFirstRightAndSecondWrongAnswers_twoSegments_triggersFailedAttempt() {
    let segment1 = SegmentSpy(value: "one")
    let segment2 = SegmentSpy(value: "two")
    let segments = [segment1, segment2]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(segment1, segment1)
    router.selectionCallback(SegmentSpy(value: "wrong"), segment2)
    
    XCTAssertEqual(router.failedSegment, segment2)
  }
  
  // MARK: - Helpers
  func makeSUT(segments: [SegmentSpy]) -> Flow<SegmentSpy, RouterSpy> {
    Flow(segments: segments, router: router)
  }
  
  class RouterSpy: Router {
    var routedSegment: SegmentSpy?
    var failedSegment: SegmentSpy?
    var finished = false
    var selectionCallback: (SegmentSpy, SegmentSpy) -> Void = { _, _ in }
    
    func handleSegment(
      _ segment: SegmentSpy,
      selectionCallback: @escaping (SegmentSpy, SegmentSpy) -> Void
    ) {
      routedSegment = segment
      self.selectionCallback = selectionCallback
    }
    
    func finish() {
      finished = true
    }
    
    func failedAttempt(for segment: SegmentSpy) {
      failedSegment = segment
    }
  }
  
  class SegmentSpy: Hashable, Valuable {
    var value: String = ""
    
    init(value: String) {
      self.value = value
    }
  }
}
