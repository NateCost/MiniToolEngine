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
    
    XCTAssertTrue(router.routedSegments.isEmpty)
  }
  
  func test_start_withSegments_routeToFirstSegment() {
    makeSUT(segments: [SegmentSpy(value: "one")]).start()
    
    XCTAssertEqual(router.routedSegment?.value, "one")
  }
  
  func test_start_withSegments_routeToFirstSegment_2() {
    makeSUT(segments: [SegmentSpy(value: "two")]).start()
    
    XCTAssertEqual(router.routedSegment?.value, "two")
  }
  
  func test_start_withSegments_routeToSegment() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    makeSUT(segments: segments).start()
    
    XCTAssertEqual(router.routedSegments.count, 1)
  }
  
  func test_startAndGiveRightAnswerToFirstAndSecond_withSegments_routesToSecondAndThird() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two"),
      SegmentSpy(value: "three"),
    ]
    let sut = makeSUT(segments: segments)
    sut.start()
    
    router.answerCallback("one")
    router.answerCallback("two")
    
    XCTAssertEqual(router.routedSegments.map { $0.value }, ["one", "two", "three"])
  }
  
  func test_startAndGiveRightAnswerToFirstAndWrongForSecond_withSegments_routesToSecond() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two"),
      SegmentSpy(value: "three"),
    ]
    let sut = makeSUT(segments: segments)
    sut.start()
    
    router.answerCallback("one")
    router.answerCallback("one")
    
    XCTAssertEqual(router.routedSegments.map { $0.value }, ["one", "two"])
  }
  
  func test_startTwice_withSegments_routeToFirstSegmentTwice() {
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    let sut = makeSUT(segments: segments)
    
    sut.start()
    sut.start()
     
    XCTAssertEqual(router.routedSegments.map { $0.value }, ["one", "one"])
  }
  
  func test_startAndGiveRightAnswerToFirst_withOneSegment_doesNotRoute() {
    let sut = makeSUT(segments: [SegmentSpy(value: "one")])
    sut.start()
    
    router.answerCallback("one")
    
    XCTAssertEqual(router.routedSegments.map { $0.value }, ["one"])
  }
  
  func test_start_withNoSegments_routeToResult() {
    makeSUT(segments: []).start()
    
    XCTAssertEqual(router.routedResult, [:])
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
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    makeSUT(segments: segments).start()
    
    router.answerCallback("oone")
    
    XCTAssertEqual(router.routedSegments.map { $0.value }, ["one"])
  }
  
  // MARK: - Helpers
  func makeSUT(segments: [Segment]) -> Flow {
    Flow(segments: segments, router: router)
  }
  
  class RouterSpy: Router {
    var passedSegmentsCount = 0
    var routedSegmentCount = 0
    var routedSegment: Segment?
    var routedSegments: [Segment] = []
    var routedResult: [String: String]?
    var answerCallback: Router.AnswerCallback = { _ in }
    
    func handleSegment(
      _ segment: Segment,
      answerCallback: @escaping Router.AnswerCallback
    ) {
      routedSegment = segment
      routedSegments.append(segment)
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
