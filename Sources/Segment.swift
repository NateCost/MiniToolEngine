//
//  Segment.swift
//  WY Mini Tool Engine
//
//  Created by Ilya Sakalou on 5/15/20.
//  Copyright © 2020 Nirma. All rights reserved.
//

import Foundation

public protocol Statable {
  var state: SegmentState { get set }
}

public protocol Valuable {
  associatedtype Value: Equatable
  var value: Value { get set }
}

public enum SegmentState {
  case selected
  case passed
  case failed
  case none
}
