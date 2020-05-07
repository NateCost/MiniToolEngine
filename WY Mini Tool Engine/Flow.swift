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
      router.handleSegment(firstSegment, answerCallback: handleAnswer)
    }
  }
  
  func handleAnswer(answer: String) {
    guard let currentSegment = router.routedSegment else { return }
    if answerValidation(segment: currentSegment, answer: answer) {
      routeNext(segment: currentSegment)
    }
  }
  
  func answerValidation(segment: Segment, answer: String) -> Bool {
    segment.value == answer
  }
  
  func routeNext(segment: Segment) {
    if let currentSegmentIndex = self.segments
      .map({ $0.value })
      .firstIndex(of: segment.value),
      self.segments.count > currentSegmentIndex + 1 {
      let nextSegment = self.segments[currentSegmentIndex + 1]
      self.router.handleSegment(nextSegment, answerCallback: self.handleAnswer(answer:))
    }
  }
}
