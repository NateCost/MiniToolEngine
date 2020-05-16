//
//  Flow.swift
//  WY Mini Tool Engine
//
//  Created by Ilya Sakalou on 5/4/20.
//  Copyright © 2020 Nirma. All rights reserved.
//

import Foundation

public protocol Router {
  associatedtype Segment: Hashable
  typealias SelectionCallback = (Segment, Segment) -> Void
  
  func handleSegment(_ segment: Segment, selectionCallback: @escaping SelectionCallback)
  func routeTo(result: [Segment: Segment])
}

public class Flow<Segment, R: Router> where R.Segment == Segment {
  private let router: R
  private let segments: [Segment]
  private var result: [Segment: Segment] = [:]
  
  init(segments: [Segment], router: R) {
    self.segments = segments
    self.router = router
  }
  
  public func start() {
    if let firstSegment = segments.first {
      router.handleSegment(firstSegment, selectionCallback: handleSelection)
    } else {
      router.routeTo(result: result)
    }
  }
  
  private func handleSelection(selection: Segment, for segment: Segment) {
    result[segment] = selection
    
    if selectionValidation(segment: segment, selection: selection) {
      routeNext(from: segment)
    } else {
      router.routeTo(result: result)
    }
  }
  
  private func selectionValidation(segment: Segment, selection: Segment) -> Bool {
    segment == selection
  }
  
  private func routeNext(from segment: Segment) {
    if let currentSegmentIndex = segments.firstIndex(of: segment) {
      let nextSegmentIndex = currentSegmentIndex + 1
      if segments.count > nextSegmentIndex {
        let nextSegment = segments[nextSegmentIndex]
        router.handleSegment(
          nextSegment,
          selectionCallback: handleSelection
        )
      } else {
        router.routeTo(result: result)
      }      
    }
  }
}
