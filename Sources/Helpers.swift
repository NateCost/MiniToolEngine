//
//  Helpers.swift
//  WY Mini Tool Engine
//
//  Created by Ilya Sakalou on 5/21/20.
//  Copyright © 2020 Nirma. All rights reserved.
//

import Foundation

extension Hashable where Self: AnyObject {
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}

extension Equatable where Self: AnyObject {
  static func == (lhs: Self, rhs: Self) -> Bool { lhs === rhs }
}
