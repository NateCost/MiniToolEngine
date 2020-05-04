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
    
    XCTAssertEqual(router.routedSegmentCount, 0)
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
    
    XCTAssertEqual(router.routedSegmentCount, 1)
  }
  
  class RouterSpy: Router {
    var passedSegmentsCount = 0
    var routedSegmentCount = 0
    var routedSegment: Segment?
    
    func handleSegment(_ segment: Segment) {
      routedSegmentCount += 1
      routedSegment = segment
    }
  }
  
  struct SegmentSpy: Segment {
    var value: String
  }
}
