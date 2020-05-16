//
//  Segment.swift
//  WY Mini Tool Engine
//
//  Created by Ilya Sakalou on 5/15/20.
//  Copyright © 2020 Nirma. All rights reserved.
//

import Foundation

public protocol Segment {
  var value: String { get }
}

public struct BreachSegment: Segment {
  public let value: String
}
