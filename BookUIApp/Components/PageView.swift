//
//  PageView.swift
//  BookUIApp
//
//  Created by Yugo Sugiyama on 2024/03/30.
//

import SwiftUI

protocol BookPageViewProtocol: View, Identifiable where Body: View, Body: View {
    var animationRatio: CGFloat { get }
    var pageLayerType: PageLayerType { get }
    @ViewBuilder var body: Self.Body { get }
}

struct TopPageView<FrontContent: View, BackContent: View>:View, BookPageViewProtocol {
    var id: String {
        return pageLayerType.hashValue.description
        + pageType.isLeft.description
        + animationRatio.description
    }

    let pageLayerType: PageLayerType = .top
    let pageType: PageDirectionType
    let pageSwipeStatus: PageSwipeStatus
    let animationRatio: CGFloat
    let front: () -> FrontContent
    let back: () -> BackContent

    private var isPageTurning: Bool {
        switch pageSwipeStatus {
        case .left:
            return pageType == .right
        case .right:
            return pageType == .left
        case .notSwipe:
            return false
        }
    }

    private var opacity: CGFloat {
        if isPageTurning {
            return 0
        } else if animationRatio < 0.5 {
            return 0
        } else {
            return (animationRatio - 0.5) * 2 * 0.5
        }
    }

    private var angleDegrees: CGFloat {
        if isPageTurning {
            return pageType.defaultAngle + animationRatio * pageType.moveMaxAngle
        } else {
            return pageType.defaultAngle
        }
    }

    var body: some View {
        ZStack(alignment: .center) {
            if !isPageTurning || animationRatio < 0.5 {
                front()
            }
            else {
                back()
                    .rotation3DEffect(
                        Angle(degrees: 180),
                        axis: (x: CGFloat(0), y: 0.61, z: CGFloat(0)),
                        perspective: 0.5
                    )
            }
        }
        .overlay(.black.opacity(opacity))
        .rotation3DEffect(
            Angle(degrees: angleDegrees),
            axis: (x: CGFloat(0), y: 0.61, z: CGFloat(0)),
            anchor: pageType.anchor,
            perspective: 0.3
        )
    }
}

struct SecondContentView<Content: View>: View, BookPageViewProtocol {
    let pageLayerType: PageLayerType = .second
    let id: String
    let pageType: PageDirectionType
    let animationRatio: CGFloat
    let content: () -> Content

    var body: some View {
        content()
            .overlay(.black.opacity((1 - animationRatio) * 0.5))
            .rotation3DEffect(
                Angle(degrees: pageType.defaultAngle * animationRatio),
                axis: (x: CGFloat(0), y: 0.61, z: CGFloat(0)),
                anchor: pageType.anchor,
                perspective: 0.3
            )
    }
}
