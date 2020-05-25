//
//  Flow.swift
//  WY Mini Tool Engine
//
//  Created by Ilya Sakalou on 5/4/20.
//  Copyright © 2020 Nirma. All rights reserved.
//

import Foundation

public protocol Router {
  associatedtype Segment: Hashable, Valuable, Statable
  typealias SelectionCallback = (Segment, Segment) -> Void
  
  func handleSegment(_ segment: Segment, selectionCallback: @escaping SelectionCallback)
  func finish()
  func failedAttempt(for segment: Segment)
}

public class Flow<Segment, R: Router> where R.Segment == Segment {
  private let router: R
  private let segments: [Segment]
  private let segmentsToSelect: [Segment]
  
  init(segments: [Segment], segmentsToSelect: [Segment], router: R) {
    self.segments = segments
    self.segmentsToSelect = segmentsToSelect
    self.router = router
  }
  
  public func start() {
    if let firstSegment = segments.first {
      firstSegment.setState(.selected)
      router.handleSegment(firstSegment, selectionCallback: handleSelection)
    } else {
      router.finish()
    }
  }
  
  private func handleSelection(selection: Segment, for segment: Segment) {
    guard segmentsToSelect.contains(selection) else {
      router.finish()
      return
    }
    
    selection.setState(.selected)
    
    if selectionValidation(segment: segment, selection: selection) {
      segment.setState(.passed)
      routeNext(from: segment)
    } else {
      segment.setState(.failed)
      router.failedAttempt(for: segment)
    }
  }
  
  private func selectionValidation(segment: Segment, selection: Segment) -> Bool {
    segment.value == selection.value
  }
  
  private func routeNext(from segment: Segment) {
    if let currentSegmentIndex = segments.firstIndex(of: segment) {
      let nextSegmentIndex = currentSegmentIndex + 1
      if segments.count > nextSegmentIndex {
        deselectAllSegments()
        router.handleSegment(segments[nextSegmentIndex], selectionCallback: handleSelection)
      } else {
        router.finish()
      }      
    }
  }
  
  private func deselectAllSegments() {
    segmentsToSelect.forEach { $0.setState(.none) }
  }
}
