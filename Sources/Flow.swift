//
//  Created by Ilya Sakalou on 5/4/20.
//  Copyright © 2020 Nirma. All rights reserved.
//

import Foundation

public protocol Router {
  associatedtype Segment: Hashable, Valuable, Statable
  typealias SelectionCallback = (Segment, Segment) -> Void
  
  func handleSegment(_ segment: Segment, selectionCallback: @escaping SelectionCallback)
  func segmentUpdated(_ segment: Segment)
  func finish()
}

public class Flow<Segment, R: Router> where R.Segment == Segment {
  private let router: R
  private let segments: [Segment]
  private let segmentsToSelect: [Segment]
  
  public init(segments: [Segment], segmentsToSelect: [Segment], router: R) {
    self.segments = segments
    self.segmentsToSelect = segmentsToSelect
    self.router = router
  }
  
  public func start() {
    if let firstSegment = segments.first {
      firstSegment.setState(.selected)
      router.segmentUpdated(firstSegment)
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
    
    deselectAllSelections()
    selection.setState(.selected)
    router.segmentUpdated(selection)
    
    if selectionValidation(segment: segment, selection: selection) {
      segment.setState(.passed)
      router.segmentUpdated(segment)
      routeNext(from: segment)
    } else {
      segment.setState(.failed)
      router.segmentUpdated(segment)
    }
  }
  
  private func selectionValidation(segment: Segment, selection: Segment) -> Bool {
    segment.value == selection.value
  }
  
  private func routeNext(from segment: Segment) {
    if let currentSegmentIndex = segments.firstIndex(of: segment) {
      let nextSegmentIndex = currentSegmentIndex + 1
      if segments.count > nextSegmentIndex {
        let nextSegment = segments[nextSegmentIndex]
        deselectAllSelections()
        nextSegment.setState(.selected)
        router.segmentUpdated(nextSegment)
        router.handleSegment(nextSegment, selectionCallback: handleSelection)
      } else {
        router.finish()
      }      
    }
  }
  
  private func deselectAllSelections() {
    for segment in segmentsToSelect where segment.state != .none {
      segment.setState(.none)
      router.segmentUpdated(segment)
    }
  }
}
