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
  typealias AnswerCallback = (String) -> Void
  var routedSegment: Segment? { get }
  func handleSegment(
    _ segment: Segment,
    answerCallback: @escaping AnswerCallback
  )
  func routeTo(result: [String: String])
}

class Flow {
  private let router: Router
  private let segments: [Segment]
  private var result: [String: String] = [:]
  
  init(segments: [Segment], router: Router) {
    self.segments = segments
    self.router = router
  }
  
  func start() {
    if let firstSegment = segments.first {
      router.handleSegment(firstSegment, answerCallback: handleAnswer)
    } else {
      router.routeTo(result: result)
    }
  }
  
  private func handleAnswer(answer: String) {
    guard let currentSegment = router.routedSegment else { return }
    result[currentSegment.value] = answer
    
    if answerValidation(segment: currentSegment, answer: answer) {
      routeNext(from: currentSegment)
    } else {
      router.routeTo(result: result)
    }
  }
  
  private func answerValidation(segment: Segment, answer: String) -> Bool {
    segment.value == answer
  }
  
  private func routeNext(from segment: Segment) {
    if let currentSegmentIndex = self.segments
      .map({ $0.value })
      .firstIndex(of: segment.value) {
      let nextSegmentIndex = currentSegmentIndex + 1
      if self.segments.count > nextSegmentIndex {
        let nextSegment = self.segments[nextSegmentIndex]
        self.router.handleSegment(
          nextSegment,
          answerCallback: self.handleAnswer(answer:)
        )
      } else {
        router.routeTo(result: result)
      }      
    }
  }
}
