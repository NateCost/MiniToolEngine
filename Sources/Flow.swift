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
  func updateSegment(_ segment: Segment, with state: SegmentState)
  func finish()
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
      router.updateSegment(firstSegment, with: .selected)
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
    
    router.updateSegment(selection, with: .selected)
    
    if selectionValidation(segment: segment, selection: selection) {
      router.updateSegment(segment, with: .passed)
      routeNext(from: segment)
    } else {
      router.updateSegment(segment, with: .failed)
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
    segmentsToSelect.forEach { router.updateSegment($0, with: .none) }
  }
}
