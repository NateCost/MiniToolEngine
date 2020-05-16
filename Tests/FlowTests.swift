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
    
    XCTAssertEqual(router.routedSegment?.value, segment.value)
  }
  
  func test_startAndChooseSameSegment_withSegments_routesToNextSegment() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    makeSUT(segments: segments).start()
    
    router.answerCallback("one")
    
    XCTAssertEqual(router.routedSegment?.value, SegmentSpy(value: "two").value)
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
    
    router.answerCallback("one")
    
    XCTAssertEqual(router.routedSegment?.value, segment.value)
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
    
    router.answerCallback("one")
    
    XCTAssertEqual(router.routedResult, ["one": "one"])
  }
  
  func test_startAndGiveRightAnswer_withTwoSegments_routesToResult() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    makeSUT(segments: segments).start()
    
    router.answerCallback("one")
    router.answerCallback("two")
    
    XCTAssertEqual(router.routedResult, ["one": "one", "two": "two"])
  }
  
  func test_startAndGiveOneRightAnswer_withTwoSegments_doesNotRouteToResult() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    makeSUT(segments: segments).start()
    
    router.answerCallback("one")
    
    XCTAssertNil(router.routedResult)
  }
  
  func test_startAndGiveWrongAnswer_withSegment_routesToResult() {
    let segments = [
      SegmentSpy(value: "one")
    ]
    makeSUT(segments: segments).start()
    
    router.answerCallback("oone")
    
    XCTAssertEqual(router.routedResult, ["one": "oone"])
  }
  
  func test_startAndGiveSecondWrongAnswer_withTwoSegments_routesToResult() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    makeSUT(segments: segments).start()
    
    router.answerCallback("one")
    router.answerCallback("oone")
    
    XCTAssertEqual(router.routedResult, ["one": "one", "two": "oone"])
  }
  
  func test_startAndGiveWrongAnswer_withTwoSegments_doesNotRouteToSecond() {
    let segment = SegmentSpy(value: "one")
    let segments = [segment, SegmentSpy(value: "two")]
    makeSUT(segments: segments).start()
    
    router.answerCallback("oone")
    
    XCTAssertEqual(router.routedSegment?.value, segment.value)
  }
  
  // MARK: - Helpers
  func makeSUT(segments: [Segment]) -> Flow {
    Flow(segments: segments, router: router)
  }
  
  class RouterSpy: Router {
    var routedSegment: Segment?
    var routedResult: [String: String]?
    var answerCallback: Router.AnswerCallback = { _ in }
    
    func handleSegment(
      _ segment: Segment,
      answerCallback: @escaping Router.AnswerCallback
    ) {
      routedSegment = segment
      self.answerCallback = answerCallback
    }
    
    func routeTo(result: [String: String]) {
      routedResult = result
    }
  }
  
  struct SegmentSpy: Segment {
    var value: String
  }
}
