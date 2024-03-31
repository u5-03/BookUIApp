//
//  PageDirectionType.swift
//  BookUIApp
//
//  Created by Yugo Sugiyama on 2024/03/30.
//

import SwiftUI

enum PageDirectionType {
    case left
    case right

    private static let maxAngle: CGFloat = 180
    private static let initialPageAngle: CGFloat = 10

    var isLeft: Bool {
        return self == .left
    }

    var defaultAngle: CGFloat {
        switch self {
        case .left:
            return PageDirectionType.initialPageAngle
        case .right:
            return -PageDirectionType.initialPageAngle
        }
    }

    var moveMaxAngle: CGFloat {
        switch self {
        case .left:
            return PageDirectionType.maxAngle - defaultAngle * 2
        case .right:
            return -PageDirectionType.maxAngle + -defaultAngle * 2
        }
    }

    var anchor: UnitPoint {
        switch self {
        case .left:
            return .trailing
        case .right:
            return .leading
        }
    }
}
