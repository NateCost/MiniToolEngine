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
  func test_start_withNoSegments_doesNotRouteToSegment() {
    let router = RouterSpy()
    let sut = Flow(segments: [], router: router)
    
    sut.start()
    
    XCTAssertTrue(router.routedSegments.isEmpty)
  }
  
  func test_start_withNoSegments_flowHasNoSegmentsLoaded() {
    let router = RouterSpy()
    let sut = Flow(segments: [], router: router)
    
    sut.start()
    
    XCTAssertTrue(sut.segments.isEmpty)
  }
  
  func test_start_withSegments_routeToFirstSegment() {
    let router = RouterSpy()
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    let sut = Flow(segments: segments, router: router)
    
    sut.start()
    
    XCTAssertEqual(router.routedSegment?.value, "one")
  }
  
  func test_start_withSegments_routeToFirstSegment_2() {
    let router = RouterSpy()
    let segments = [
      SegmentSpy(value: "two"),
      SegmentSpy(value: "tree")
    ]
    let sut = Flow(segments: segments, router: router)
    
    sut.start()
    
    XCTAssertEqual(router.routedSegment?.value, "two")
  }
  
  func test_start_withSegments_hasSegmentsLoaded() {
    let router = RouterSpy()
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    let sut = Flow(segments: segments, router: router)
    
    sut.start()
  
    XCTAssertEqual(sut.segments.count, 2)
  }
  
  func test_start_withSegments_routeToSegment() {
    let router = RouterSpy()
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    let sut = Flow(segments: segments, router: router)
    
    sut.start()
    
    XCTAssertEqual(router.routedSegments.count, 1)
  }
  
  func test_startAndGiveRightAnswerToFirst_withSegments_routesToSecond() {
    let router = RouterSpy()
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    let sut = Flow(segments: segments, router: router)
    sut.start()
    
    router.answerCallback("one")
    
    XCTAssertEqual(router.routedSegment!.value, "two")
  }
  
  func test_startAndGiveWrongAnswerToFirst_withSegments_routesToSecond() {
    let router = RouterSpy()
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    let sut = Flow(segments: segments, router: router)
    sut.start()
    
    router.answerCallback("two")
    
    XCTAssertEqual(router.routedSegment!.value, "one")
  }
  
  func test_startTwice_withSegments_routeToFirstSegmentTwice() {
    let router = RouterSpy()
    let segments = [
      SegmentSpy(value: "one"),
      SegmentSpy(value: "two")
    ]
    let sut = Flow(segments: segments, router: router)
    
    sut.start()
    sut.start()
     
    XCTAssertEqual(router.routedSegments.map { $0.value }, ["one", "one"])
  }
  
  class RouterSpy: Router {
    var passedSegmentsCount = 0
    var routedSegmentCount = 0
    var routedSegment: Segment?
    var routedSegments: [Segment] = []
    var answerCallback: ((String) -> Void) = { _ in }
    
    func handleSegment(
      _ segment: Segment,
      answerCallback: @escaping ((String) -> Void)
    ) {
      routedSegment = segment
      routedSegments.append(segment)
      self.answerCallback = answerCallback
    }
  }
  
  struct SegmentSpy: Segment {
    var value: String
  }
}
