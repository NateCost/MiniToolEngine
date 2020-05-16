//
//  Segment.swift
//  WY Mini Tool Engine
//
//  Created by Ilya Sakalou on 5/15/20.
//  Copyright © 2020 Nirma. All rights reserved.
//

import Foundation

public protocol Valuable {
  var value: String { get }
}

public struct BreachSegment: Valuable {
  public let value: String
}
