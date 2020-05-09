//
//  Flow.swift
//  WY Mini Tool Engine
//
//  Created by Ilya Sakalou on 5/4/20.
//  Copyright © 2020 Nirma. All rights reserved.
//

import Foundation

public protocol Segment {
  var value: String { get }
}

public struct BreachSegment: Segment {
  public let value: String
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

public class Flow {
  private let router: Router
  private let segments: [Segment]
  private var result: [String: String] = [:]
  
  init(segments: [Segment], router: Router) {
    self.segments = segments
    self.router = router
  }
  
  public func start() {
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
    if let currentSegmentIndex = segments
      .map({ $0.value })
      .firstIndex(of: segment.value) {
      let nextSegmentIndex = currentSegmentIndex + 1
      if segments.count > nextSegmentIndex {
        let nextSegment = segments[nextSegmentIndex]
        router.handleSegment(
          nextSegment,
          answerCallback: handleAnswer(answer:)
        )
      } else {
        router.routeTo(result: result)
      }      
    }
  }
}
