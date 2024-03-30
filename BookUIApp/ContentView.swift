//
//  ContentView.swift
//  BookUIApp
//
//  Created by Yugo Sugiyama on 2024/03/28.
//

import SwiftUI
import Observation

enum PageSwipeStatus {
    case left
    case right
    case notSwipe
}

enum PageType {
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
            return PageType.initialPageAngle
        case .right:
            return -PageType.initialPageAngle
        }
    }

    var moveMaxAngle: CGFloat {
        switch self {
        case .left:
            return PageType.maxAngle - defaultAngle * 2
        case .right:
            return -PageType.maxAngle + -defaultAngle * 2
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

enum PageLayer {
    case top(pageView: PageView, animationRatio: CGFloat)
    case second(view: AnyView, animationRatio: CGFloat)
    case empty

    @ViewBuilder
    var view: some View {
        switch self {
        case .top(let pageView, _):
            pageView
        case .second(let image, _):
            image
        case .empty:
            EmptyView()
        }
    }
}

struct ContentView: View {
    let images = [
        "image0",
        "image1",
        "image2",
        "image3",
        "image4",
        "image5",
        "image0",
        "image1",
        "image2",
        "image3",
        "image4",
        "image5",
        "image0",
        "image1",
        "image2",
        "image3",
        "image4",
        "image5",
        "image0",
        "image1",
        "image2",
        "image3",
        "image4",
        "image5",
        "image0",
        "image1",
        "image2",
        "image3",
        "image4",
        "image5",
    ]

    @State private var currentLeftPageIndex = 10
    private var currentRightPageIndex: Int {
        currentLeftPageIndex + 1
    }
    @State private var leftPageStack: [PageLayer] = []
    @State private var rightPageStack: [PageLayer] = []
    @State private var pageSwipeStatus: PageSwipeStatus = .notSwipe
    private var leftPageIndex: Double {
        return pageSwipeStatus == .left ? 1 : 0
    }
    private var rightPageIndex: Double {
        return pageSwipeStatus == .right ? 1 : 0
    }

    func image(fileName: String) -> AnyView {
        return AnyView(
            Image(fileName)
                .resizable()
                .clipped()
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    pageStackView(
                        pageStack: leftPageStack,
                        pageZIndex: leftPageIndex,
                        pageType: .left,
                        pageSize: .init(width: geometry.size.width / 2, height: geometry.size.height)
                    )
                    pageStackView(
                        pageStack: rightPageStack,
                        pageZIndex: rightPageIndex,
                        pageType: .right,
                        pageSize: .init(width: geometry.size.width / 2, height: geometry.size.height)
                    )
                }
            }
            .ignoresSafeArea()
            .rotation3DEffect(
                Angle(degrees: 20),
                axis: (x: CGFloat(6), y: 0, z: CGFloat(0)),
                anchor: .center,
                perspective: 1
            )
            // Left page
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let dragStartPoint = value.startLocation
                        let isLeftPageSwipe = dragStartPoint.x < geometry.size.width / 2
                        if isLeftPageSwipe {
                            self.pageSwipeStatus = .left
                            let dragXAmount = min(
                                max(value.location.x - value.startLocation.x, 0),
                                geometry.size.width
                            )
                            let leftAnimationRatio = min(dragXAmount / geometry.size.width, 1)
                            adjustLeftPages(
                                currentLeftPageIndex: currentLeftPageIndex,
                                leftAnimationRatio: leftAnimationRatio
                            )
                        }
                    }
                    .onEnded { value in
                        let dragStartPoint = value.startLocation
                        let isLeftPageSwipe = dragStartPoint.x < geometry.size.width / 2
                        if isLeftPageSwipe {
                            let isInLeftPage = value.location.x < geometry.size.width / 2
                            withAnimation {
                                adjustLeftPages(
                                    currentLeftPageIndex: currentLeftPageIndex,
                                    leftAnimationRatio: isInLeftPage ? 0 : 1
                                )
                            } completion: {
                                if !isInLeftPage {
                                    currentLeftPageIndex -= 2
                                }
                                pageSwipeStatus = .notSwipe
                                adjustBothPages(
                                    currentLeftPageIndex: currentLeftPageIndex,
                                    leftAnimationRatio: 0,
                                    currentRightPageIndex: currentRightPageIndex,
                                    rightAnimationRatio: 0
                                )
                            }
                        }
                    }
            )
            // Right page
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        let dragStartPoint = value.startLocation
                        let isRightPageSwipe = dragStartPoint.x > geometry.size.width / 2
                        if isRightPageSwipe {
                            self.pageSwipeStatus = .right
                            let dragXAmount = min(
                                max(value.startLocation.x - value.location.x, 0),
                                geometry.size.width
                            )
                            let rightAnimationRatio = min(dragXAmount / geometry.size.width, 1)
                            adjustRightPages(
                                currentRightPageIndex: currentRightPageIndex,
                                rightAnimationRatio: rightAnimationRatio
                            )
                        }
                    }
                    .onEnded { value in
                        let dragStartPoint = value.startLocation
                        let isRightPageSwipe = dragStartPoint.x > geometry.size.width / 2
                        if isRightPageSwipe {
                            let isInRightPage = value.location.x > geometry.size.width / 2
                            withAnimation {
                                adjustRightPages(
                                    currentRightPageIndex: currentRightPageIndex,
                                    rightAnimationRatio: isInRightPage ? 0 : 1
                                )

                            } completion: {
                                if !isInRightPage {
                                    currentLeftPageIndex += 2
                                }
                                pageSwipeStatus = .notSwipe
                                adjustBothPages(
                                    currentLeftPageIndex: currentLeftPageIndex,
                                    leftAnimationRatio: 0,
                                    currentRightPageIndex: currentRightPageIndex,
                                    rightAnimationRatio: 0
                                )
                            }
                        }
                    }
            )
            .onAppear {
                adjustBothPages(
                    currentLeftPageIndex: currentLeftPageIndex,
                    leftAnimationRatio: 0,
                    currentRightPageIndex: currentRightPageIndex,
                    rightAnimationRatio: 0
                )
            }
        }
        .padding(.all, 30)
        .padding(.horizontal, 80)
    }
}

private extension ContentView {
    func pageStackView(pageStack: [PageLayer], pageZIndex: Double, pageType: PageType,  pageSize: CGSize) -> some View {
        return ZStack(alignment: .center) {
            ForEach(pageStack.indices, id: \.self) { index in
                switch pageStack[index] {
                case .top(let pageView, let animationRatio):
                    pageView
                        .rotation3DEffect(
                            Angle(degrees: pageType.defaultAngle + animationRatio * pageType.moveMaxAngle),
                            axis: (x: CGFloat(0), y: 0.61, z: CGFloat(0)),
                            anchor: pageType.anchor,
                            perspective: 0.3
                        )
                case .second(let view, let animationRatio):
                    view
                        .rotation3DEffect(
                            Angle(degrees: pageType.defaultAngle * animationRatio),
                            axis: (x: CGFloat(0), y: 0.61, z: CGFloat(0)),
                            anchor: pageType.anchor,
                            perspective: 0.3
                        )
                case .empty:
                    EmptyView()
                }
            }
        }
        .frame(width: pageSize.width, height: pageSize.height)
        .scaledToFill()
        .zIndex(pageZIndex)
    }
}

private extension ContentView {
    func adjustBothPages(currentLeftPageIndex: Int, leftAnimationRatio: CGFloat, currentRightPageIndex: Int, rightAnimationRatio: CGFloat) {
        adjustLeftPages(currentLeftPageIndex: currentLeftPageIndex, leftAnimationRatio: leftAnimationRatio)
        adjustRightPages(currentRightPageIndex: currentRightPageIndex, rightAnimationRatio: rightAnimationRatio)

    }

    func adjustLeftPages(currentLeftPageIndex: Int, leftAnimationRatio: CGFloat) {
        leftPageStack = [
            .second(
                view: AnyView(image(fileName: images[currentLeftPageIndex - 2])),
                animationRatio: leftAnimationRatio
            ),
            .top(
                pageView: PageView(
                    pageType: .left,
                    animationRatio: leftAnimationRatio,
                    front: AnyView(image(fileName: images[currentLeftPageIndex])),
                    back:  AnyView(image(fileName: images[currentLeftPageIndex - 1]))
                ),
                animationRatio: leftAnimationRatio
            ),
        ]
    }

    func adjustRightPages(currentRightPageIndex: Int, rightAnimationRatio: CGFloat) {
        rightPageStack = [
            .second(
                view: AnyView(image(fileName: images[currentRightPageIndex + 2])),
                animationRatio: rightAnimationRatio
            ),
            .top(
                pageView: PageView(
                    pageType: .right,
                    animationRatio: rightAnimationRatio,
                    front: AnyView(image(fileName: images[currentRightPageIndex])),
                    back: AnyView(image(fileName: images[currentRightPageIndex + 1]))
                ),
                animationRatio: rightAnimationRatio
            ),
        ]
    }
}

struct PageView: View {
    let pageType: PageType
    let animationRatio: CGFloat
    let front: AnyView
    let back: AnyView

    var body: some View {
        ZStack(alignment: .center) {
            if animationRatio < 0.5 {
                front
            }
            else {
                back
                    .rotation3DEffect(
                        Angle(degrees: 180),
                        axis: (x: CGFloat(0), y: 0.61, z: CGFloat(0)),
                        perspective: 0.5
                    )
            }
        }
    }
}

#Preview {
    ContentView()
}
