//
//  Created by Ilya Sakalou on 5/4/20.
//  Copyright © 2020 Nirma. All rights reserved.
//

import Foundation
import XCTest
@testable import WY_Mini_Tool_Engine

class FlowTests: XCTestCase {
  let router = RouterSpy()
  let segment1 = SegmentSpy(value: "one")
  let segment2 = SegmentSpy(value: "two")
  
  func test_start_withNoSegments_doesNotRouteToSegment() {
    makeSUT(segments: []).start()
    XCTAssertNil(router.routedSegment)
  }
  
  func test_start_withSegments_routeToFirstSegment() {
    makeSUT(segments: [segment1]).start()
    XCTAssertEqual(router.routedSegment, segment1)
  }
  
  func test_startAndSelectUndefinedSegment_withTwoSegmentToBreach_finishFlow() {
    let segments = [segment1, segment2]
    makeSUT(segments: segments).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), segment1)
    
    XCTAssertTrue(router.finished)
  }
  
  func test_startAndChooseSameSegment_withSegments_routesToNextSegment() {
    let segmentToSelect = SegmentSpy(value: "one")
    makeSUT(segments: [segment1, segment2], segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, segment1)
    
    XCTAssertEqual(router.routedSegment, segment2)
  }
  
  func test_startTwice_withSegments_routeToFirstSegmentTwice() {
    let sut = makeSUT(segments: [segment1, segment2])
    
    sut.start()
    sut.start()
     
    XCTAssertEqual(router.routedSegment, segment1)
  }
  
  func test_start_withNoSegments_routeToResult() {
    makeSUT(segments: []).start()
    XCTAssertTrue(router.finished)
  }
  
  func test_start_withOneSegments_doesNotFinished() {
    makeSUT(segments: [segment1]).start()
    XCTAssertFalse(router.finished)
  }
  
  func test_startAndGiveRightAnswer_withOneSegment_finishesFlow() {
    makeSUT(segments: [segment1]).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), segment1)
    
    XCTAssertTrue(router.finished)
  }
  
  func test_startAndGiveWrongAnswer_withOneSegment_doesNotfinishFlow() {
    let segmentToSelect = SegmentSpy(value: "two")
    makeSUT(segments: [segment1], segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, segment1)
    
    XCTAssertFalse(router.finished)
  }
  
  func test_startAndGiveRightAnswer_withTwoSegments_finishesFlow() {
    makeSUT(segments: [segment1, segment2]).start()
    
    router.selectionCallback(SegmentSpy(value: "one"), segment1)
    router.selectionCallback(SegmentSpy(value: "two"), segment2)
    
    XCTAssertTrue(router.finished)
  }
  
  func test_startAndGiveOneRightAnswer_withTwoSegments_doesNotFinishFlow() {
    let segmentToSelect = SegmentSpy(value: "one")
    makeSUT(segments: [segment1, segment2], segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, segment1)
    
    XCTAssertFalse(router.finished)
  }
  
  func test_startAndGiveWrongAnswer_withTwoSegments_doesNotRouteToSecond() {
    let segmentToSelect = SegmentSpy(value: "oone")
    makeSUT(segments: [segment1, segment2], segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, segment1)
    
    XCTAssertEqual(router.routedSegment, segment1)
  }
  
  // MARK: - States
  func test_start_withTwoSegment_segmentsHaveProperStates() {
    makeSUT(segments: [segment1, segment2]).start()
    
    XCTAssertEqual(segment1.state, .selected)
    XCTAssertEqual(router.updatedSegments, [segment1])
    XCTAssertEqual(segment2.state, .none)
  }
  
  func test_startAndAnswerFirst_withOneSegment_selectedSegmentHasProperState() {
    let segmentToSelect = SegmentSpy(value: "one")
    makeSUT(segments: [segment1], segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, segment1)
    
    XCTAssertEqual(segmentToSelect.state, .selected)
    XCTAssertEqual(router.updatedSegments, [segment1, segmentToSelect, segment1])
  }
  
  func test_startAndAnswerRightFirst_withOneSegment_makesSegmentPassed() {
    let segmentToSelect = SegmentSpy(value: "one")
    makeSUT(segments: [segment1], segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, segment1)
    
    XCTAssertEqual(segment1.state, .passed)
    XCTAssertEqual(router.updatedSegments, [segment1, segmentToSelect, segment1])
  }
  
  func test_startAndAnswerWrongFirst_withOneSegment_makesSegmentFailed() {
    let segmentToSelect = SegmentSpy(value: "two")
    makeSUT(segments: [segment1], segmentsToSelect: [segmentToSelect]).start()
    
    router.selectionCallback(segmentToSelect, segment1)
    
    XCTAssertEqual(segment1.state, .failed)
    XCTAssertEqual(router.updatedSegments, [segment1, segmentToSelect, segment1])
  }
  
  func test_startAndAnswerTwoSegments_passFirstSegmentAndNavigateToSecondOne_deselectsAllSegments() {
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
  
  func test_deselection_startWithSegmentAndSelections_selectTwoWrongSegments_deselectsFirstWrongSegment() {
    let segmentToSelect1 = SegmentSpy(value: "one")
    let segmentToSelect2 = SegmentSpy(value: "two")
    let segmentToSelect3 = SegmentSpy(value: "three")
    makeSUT(
      segments: [segment1, segment2],
      segmentsToSelect: [segmentToSelect1, segmentToSelect2, segmentToSelect3]
    ).start()
    
    router.selectionCallback(segmentToSelect2, segment1)
    router.selectionCallback(segmentToSelect3, segment1)
    
    XCTAssertEqual(segmentToSelect2.state, .none)
    XCTAssertEqual(segmentToSelect3.state, .selected)
  }
  
  func test_deselection_startWithSegmentAndSelections_selectRightSegment_selectNextSegmentToBreach() {
    let segmentToSelect1 = SegmentSpy(value: "one")
    makeSUT(segments: [segment1, segment2], segmentsToSelect: [segmentToSelect1]).start()
    
    router.selectionCallback(segmentToSelect1, segment1)
    
    XCTAssertEqual(segment2.state, .selected)
    XCTAssertEqual(router.updatedSegments, [segment1, segmentToSelect1, segment1, segmentToSelect1, segment2])
  }
  
  // MARK: - Helpers
  func makeSUT(segments: [SegmentSpy], segmentsToSelect: [SegmentSpy] = []) -> Flow<SegmentSpy, RouterSpy> {
    Flow(segments: segments, segmentsToSelect: segmentsToSelect, router: router)
  }
  
  class RouterSpy: Router {
    var routedSegment: SegmentSpy?
    var finished = false
    var selectionCallback: (SegmentSpy, SegmentSpy) -> Void = { _, _ in }
    var updatedSegments: [SegmentSpy] = []
    
    func handleSegment(
      _ segment: SegmentSpy,
      selectionCallback: @escaping (SegmentSpy, SegmentSpy) -> Void
    ) {
      routedSegment = segment
      self.selectionCallback = selectionCallback
    }
    
    func segmentUpdated(_ segment: SegmentSpy) {
      updatedSegments.append(segment)
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
