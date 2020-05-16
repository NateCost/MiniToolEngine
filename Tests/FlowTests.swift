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
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), SegmentSpy(value: "one"))
    
    XCTAssertEqual(router.routedSegment, SegmentSpy(value: "two"))
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
    
    XCTAssertEqual(router.routedSegment, SegmentSpy(value: "one"))
  }
  
  func test_start_withNoSegments_routeToResult() {
    makeSUT(segments: []).start()
    
    XCTAssertEqual(router.routedResult, [:])
  }
  
  func test_start_withOneSegments_doesNotRouteToResult() {
    makeSUT(segments: [SegmentSpy(value: "one")]).start()
    
    XCTAssertNil(router.routedResult)
  }
  
  func test_startAndGiveRightAnswer_withOneSegment_routesToResult() {
    makeSUT(segments: [SegmentSpy(value: "one")]).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), SegmentSpy(value: "one"))
    
    XCTAssertEqual(router.routedResult, [SegmentSpy(value: "one"): SegmentSpy(value: "one")])
  }
  
  func test_startAndGiveRightAnswer_withTwoSegments_routesToResult() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), SegmentSpy(value: "one"))
    router.selectionCallback(SegmentSpy(value: "two"), SegmentSpy(value: "two"))
    
    XCTAssertEqual(
      router.routedResult,
      [
        SegmentSpy(value: "one"): SegmentSpy(value: "one"),
        SegmentSpy(value: "two"): SegmentSpy(value: "two")
      ]
    )
  }
  
  func test_startAndGiveOneRightAnswer_withTwoSegments_doesNotRouteToResult() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), SegmentSpy(value: "one"))
    
    XCTAssertNil(router.routedResult)
  }
  
  func test_startAndGiveWrongAnswer_withSegment_routesToResult() {
    let segments = [
      SegmentSpy(value: "one")
    ]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "oone"), SegmentSpy(value: "one"))
    
    XCTAssertEqual(router.routedResult, [SegmentSpy(value: "one"): SegmentSpy(value: "oone")])
  }
  
  func test_startAndGiveSecondWrongAnswer_withTwoSegments_routesToResult() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), SegmentSpy(value: "one"))
    router.selectionCallback(SegmentSpy(value: "oone"), SegmentSpy(value: "two"))
    
    XCTAssertEqual(
      router.routedResult,
      [
        SegmentSpy(value: "one"): SegmentSpy(value: "one"),
        SegmentSpy(value: "two"): SegmentSpy(value: "oone")
      ]
    )
  }
  
  func test_startAndGiveWrongAnswer_withTwoSegments_doesNotRouteToSecond() {
    let segment = SegmentSpy(value: "one")
    let segments = [segment, SegmentSpy(value: "two")]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "oone"), SegmentSpy(value: "one"))
    
    XCTAssertEqual(router.routedSegment, segment)
  }
  
  // MARK: - Helpers
  func makeSUT(segments: [SegmentSpy]) -> Flow<SegmentSpy, RouterSpy> {
    Flow(segments: segments, router: router)
  }
  
  class RouterSpy: Router {
    var routedSegment: SegmentSpy?
    var routedResult: [SegmentSpy: SegmentSpy]?
    var selectionCallback: (SegmentSpy, SegmentSpy) -> Void = { _, _ in }
    
    func handleSegment(
      _ segment: SegmentSpy,
      selectionCallback: @escaping (SegmentSpy, SegmentSpy) -> Void
    ) {
      routedSegment = segment
      self.selectionCallback = selectionCallback
    }
    
    func routeTo(result: [SegmentSpy: SegmentSpy]) {
      routedResult = result
    }
  }
  
  struct SegmentSpy: Valuable, Hashable {
    var value: String
  }
}
