//
//  ContentView.swift
//  BookUIApp
//
//  Created by Yugo Sugiyama on 2024/03/28.
//

import SwiftUI
import Observation

extension Color {
    static var random: Color {
        // 0.0から1.0の範囲でランダムな値を生成
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)

        // 生成したランダムな値でColorを作成
        return Color(red: red, green: green, blue: blue)
    }
}

enum PageSwipeStatus {
    case left
    case right
    case notSwipe
}

enum PageType {
    case left
    case right

    var isLeft: Bool {
        return self == .left
    }

    var defaultAngle: CGFloat {
        switch self {
        case .left:
            return 0
        case .right:
            return 0
        }
    }

    var maxAngle: CGFloat {
        switch self {
        case .left:
            return 180
        case .right:
            return -180
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
    case top(pageView: PageView)
    case second(view: AnyView, id: String)

    @ViewBuilder
    var view: some View {
        switch self {
        case .top(let pageView):
            pageView
        case .second(let image, _):
            image
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
            ZStack {
                Image(fileName)
                    .resizable()
                    .clipped()
            }
                .id(fileName)
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    ZStack(alignment: .center) {
                        ForEach(leftPageStack.indices, id: \.self) { index in
                            leftPageStack[index].view
                        }
                    }
                    .frame(width: geometry.size.width / 2, height: geometry.size.height)
                    .scaledToFit()
                    .zIndex(leftPageIndex)
                    ZStack(alignment: .center) {
                        ForEach(rightPageStack.indices, id: \.self) { index in
                            rightPageStack[index].view
                        }
                    }
                    .frame(width: geometry.size.width / 2, height: geometry.size.height)
                    .scaledToFit()
                    .zIndex(rightPageIndex)
                }
            }
            .ignoresSafeArea()
            // Left page
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let dragStartPoint = value.startLocation
                        let isLeftPageSwipe = dragStartPoint.x < geometry.size.width / 2
                        if isLeftPageSwipe {
                            self.pageSwipeStatus = .left
                            let dragXAmount = min(
                                abs(value.location.x - value.startLocation.x),
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
                            let endedLeftAnimationRatio = min(
                                abs(value.location.x - value.startLocation.x),
                                geometry.size.width
                            )
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
                                abs(value.location.x - value.startLocation.x),
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
                            let endedRightAnimationRatio =  min(
                                abs(value.location.x - value.startLocation.x),
                                geometry.size.width
                            )
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
        .padding()
    }
}

private extension ContentView {
    func adjustBothPages(currentLeftPageIndex: Int, leftAnimationRatio: CGFloat, currentRightPageIndex: Int, rightAnimationRatio: CGFloat) {
        adjustLeftPages(currentLeftPageIndex: currentLeftPageIndex, leftAnimationRatio: leftAnimationRatio)
        adjustRightPages(currentRightPageIndex: currentRightPageIndex, rightAnimationRatio: rightAnimationRatio)

    }
    func adjustLeftPages(currentLeftPageIndex: Int, leftAnimationRatio: CGFloat) {
        leftPageStack = [
            .second(view: AnyView(image(fileName: images[currentLeftPageIndex - 2])), id: UUID().uuidString),
            .top(
                pageView: PageView(
                    pageType: .left,
                    animationRatio: leftAnimationRatio,
                    front: AnyView(image(fileName: images[currentLeftPageIndex])),
                    back:  AnyView(image(fileName: images[currentLeftPageIndex - 1]))
                )
            ),
        ]
    }

    func adjustRightPages(currentRightPageIndex: Int, rightAnimationRatio: CGFloat) {
        rightPageStack = [
            .second(view: AnyView(image(fileName: images[currentRightPageIndex + 2])), id: UUID().uuidString),
            .top(
                pageView: PageView(
                    pageType: .right,
                    animationRatio: rightAnimationRatio,
                    front: AnyView(image(fileName: images[currentRightPageIndex])),
                    back: AnyView(image(fileName: images[currentRightPageIndex + 1]))
                )
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
        let _ = print(animationRatio)
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
        .rotation3DEffect(
            Angle(degrees: animationRatio * pageType.maxAngle),
            axis: (x: CGFloat(0), y: 0.61, z: CGFloat(0)),
            anchor: pageType.anchor,
            perspective: 0.5
        )
    }
}

#Preview {
    ContentView()
}
