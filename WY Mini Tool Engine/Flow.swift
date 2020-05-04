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
  func handleSegment(_ segment: Segment)
}

class Flow {
  let router: Router
  let segments: [Segment]
  
  init(segments: [Segment], router: Router) {
    self.segments = segments
    self.router = router
  }
  
  func start() {
    guard !segments.isEmpty else { return }
    router.handleSegment(BreachSegment(value: ""))
  }
}
