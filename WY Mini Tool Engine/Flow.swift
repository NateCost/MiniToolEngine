//
//  Flow.swift
//  WY Mini Tool Engine
//
//  Created by Ilya Sakalou on 5/4/20.
//  Copyright © 2020 Nirma. All rights reserved.
//

import Foundation

protocol Segment {
  var value: String { get }
}

struct BreachSegment: Segment {
  let value: String
}

protocol Router {
  var routedSegment: Segment? { get }
  func handleSegment(
    _ segment: Segment,
    answerCallback: @escaping ((String) -> Void)
  )
}

class Flow {
  let router: Router
  let segments: [Segment]
  
  init(segments: [Segment], router: Router) {
    self.segments = segments
    self.router = router
  }
  
  func start() {
    if let firstSegment = segments.first {
      router.handleSegment(firstSegment) { [weak self] answer in
        guard let self = self, let routedSegment = self.router.routedSegment else { return }

        if routedSegment.value == answer {
          if let currentSegmentIndex = self.segments
            .map({ $0.value })
            .firstIndex(of: routedSegment.value),
            self.segments.count > currentSegmentIndex + 1 {
            let nextSegment = self.segments[currentSegmentIndex + 1]
            self.router.handleSegment(nextSegment, answerCallback: { _ in })
          }
        }
      }
    }
  }
}
