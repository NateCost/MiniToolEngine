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
  
  func test_startAndSelectUndefinedSegment_withTwoSegmentToBreach_finishFlow() {
    let firstSegment = SegmentSpy(value: "one")
    let secondSegment = SegmentSpy(value: "two")
    let segments = [firstSegment, secondSegment]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), firstSegment)
    
    XCTAssertTrue(router.finished)
  }
  
  func test_startAndChooseSameSegment_withSegments_routesToNextSegment() {
    let firstSegment = SegmentSpy(value: "one")
    let secondSegment = SegmentSpy(value: "two")
    let segmentToSelect = SegmentSpy(value: "one")
    makeSUT(segments: [firstSegment, secondSegment], segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, firstSegment)
    
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
  
  func test_start_withNoSegments_routeToResult() {
    makeSUT(segments: []).start()
    
    XCTAssertTrue(router.finished)
  }
  
  func test_start_withOneSegments_doesNotFinished() {
    makeSUT(segments: [SegmentSpy(value: "one")]).start()
    
    XCTAssertFalse(router.finished)
  }
  
  func test_startAndGiveRightAnswer_withOneSegment_finishesFlow() {
    let segment = SegmentSpy(value: "one")
    makeSUT(segments: [segment]).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), segment)
    
    XCTAssertTrue(router.finished)
  }
  
  func test_startAndGiveWrongAnswer_withOneSegment_doesNotfinishFlow() {
    let segment = SegmentSpy(value: "one")
    let segmentToSelect = SegmentSpy(value: "two")
    makeSUT(segments: [segment], segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, segment)
    
    XCTAssertFalse(router.finished)
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
    let firstSegment = SegmentSpy(value: "one")
    let secondSegment = SegmentSpy(value: "two")
    let segments = [firstSegment, secondSegment]
    let segmentToSelect = SegmentSpy(value: "one")
    makeSUT(segments: segments, segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, firstSegment)
    
    XCTAssertFalse(router.finished)
  }
  
  func test_startAndGiveWrongAnswer_withTwoSegments_doesNotRouteToSecond() {
    let segment = SegmentSpy(value: "one")
    let segments = [segment, SegmentSpy(value: "two")]
    let segmentToSelect = SegmentSpy(value: "oone")
    makeSUT(segments: segments, segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, segment)
    
    XCTAssertEqual(router.routedSegment, segment)
  }
  
  // MARK: - States
  func test_start_withTwoSegment_segmentsHaveProperStates() {
    let segment1 = SegmentSpy(value: "one")
    let segment2 = SegmentSpy(value: "two")
    makeSUT(segments: [segment1, segment2]).start()
    
    XCTAssertEqual(segment1.state, .selected)
    XCTAssertEqual(segment2.state, .none)
  }
  
  func test_startAndAnswerFirst_withOneSegment_selectedSegmentHasProperState() {
    let segment = SegmentSpy(value: "one")
    let segmentToSelect = SegmentSpy(value: "one")
    makeSUT(segments: [segment], segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, segment)
    
    XCTAssertEqual(segmentToSelect.state, .selected)
  }
  
  func test_startAndAnswerRightFirst_withOneSegment_makesSegmentPassed() {
    let segment = SegmentSpy(value: "one")
    let segmentToSelect = SegmentSpy(value: "one")
    makeSUT(segments: [segment], segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, segment)
    
    XCTAssertEqual(segment.state, .passed)
  }
  
  func test_startAndAnswerWrongFirst_withOneSegment_makesSegmentFailed() {
    let segment = SegmentSpy(value: "one")
    let segmentToSelect = SegmentSpy(value: "two")
    makeSUT(segments: [segment], segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, segment)
    
    XCTAssertEqual(segment.state, .failed)
  }
  
  func test_startAndAnswerTwoSegments_withTwoSegments_makesFirstSelectedSegmentDeselected() {
    let segment1 = SegmentSpy(value: "one")
    let segment2 = SegmentSpy(value: "two")
    let segmentToSelect1 = SegmentSpy(value: "one")
    let segmentToSelect2 = SegmentSpy(value: "two")
    makeSUT(
      segments: [segment1, segment2],
      segmentsToSelect: [segmentToSelect1, segmentToSelect2]
    ).start()
    
    router.selectionCallback(segmentToSelect1, segment1)
    router.selectionCallback(segmentToSelect2, segment2)
    
    XCTAssertEqual(segmentToSelect1.state, .none)
  }
  
  // MARK: - Helpers
  func makeSUT(segments: [SegmentSpy], segmentsToSelect: [SegmentSpy] = []) -> Flow<SegmentSpy, RouterSpy> {
    Flow(segments: segments, segmentsToSelect: segmentsToSelect, router: router)
  }
  
  class RouterSpy: Router {
    var routedSegment: SegmentSpy?
    var finished = false
    var selectionCallback: (SegmentSpy, SegmentSpy) -> Void = { _, _ in }
    
    func handleSegment(
      _ segment: SegmentSpy,
      selectionCallback: @escaping (SegmentSpy, SegmentSpy) -> Void
    ) {
      routedSegment = segment
      self.selectionCallback = selectionCallback
    }
    
    func updateSegment(_ segment: SegmentSpy, with state: SegmentState) {
      segment.setState(state)
    }
    
    func finish() {
      finished = true
      routedSegment = nil
    }
  }
  
  class SegmentSpy: Hashable, Valuable, Statable {
    var value: String = ""
    var state: SegmentState = .none
    
    init(value: String) {
      self.value = value
    }
    
    func setState(_ state: SegmentState) {
      self.state = state
    }
  }
}
