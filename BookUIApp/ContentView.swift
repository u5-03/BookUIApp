//
//  ContentView.swift
//  BookUIApp
//
//  Created by Yugo Sugiyama on 2024/03/28.
//

import SwiftUI

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
    case first(pageView: PageView)
    case second(image: Image)

    @ViewBuilder
    var view: some View {
        switch self {
        case .first(let pageView):
            pageView
        case .second(let image):
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
    ]

    @State private var currentLeftPageIndex = 4
    @State private var leftPageStack: [PageLayer] = []
    @State private var rightPageStack: [PageLayer] = []
    @State private var leftAnimationRatio: CGFloat = 0
    @State private var rightAnimationRatio: CGFloat = 0
    @State private var dragStartPoint: CGPoint = .zero
    @State private var dragXAmount: CGFloat?

    func image(fileName: String) -> AnyView {
        return AnyView(
            ZStack {
                Image(fileName)
                    .resizable()
                    .clipped()
            }
        )
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ZStack(alignment: .center) {
                    ForEach(leftPageStack.indices, id: \.self) { index in
                        leftPageStack[index].view
                    }
                }
                .frame(width: geometry.size.width / 2)
                .scaledToFit()
                ZStack(alignment: .center) {
//                    Color.blue
//                    ForEach(rightPageStack.indices, id: \.self) { index in
//                        rightPageStack[index].view
//                            .frame(width: geometry.size.width / 2)
//                    }
                }
            }
            .ignoresSafeArea()
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragStartPoint = value.startLocation
                        self.dragXAmount = dragXAmount
                        if dragStartPoint.x < geometry.size.width / 2 {
                            print("DragXAmount: \(dragXAmount), \(leftAnimationRatio)")
                            let dragXAmount = value.location.x - value.startLocation.x
                            leftAnimationRatio = min(dragXAmount / geometry.size.width, 1)
                        } else {
                            print("DragXAmount: \(dragXAmount), \(rightAnimationRatio)")
                            let dragXAmount = value.startLocation.x - value.location.x
                            rightAnimationRatio = min(dragXAmount / geometry.size.width, 1)
                        }
                    }
                    .onEnded { value in
                        dragStartPoint = .zero
                        dragXAmount = nil
                        if dragStartPoint.x < geometry.size.width / 2 {
                            leftAnimationRatio = leftAnimationRatio > 0.5 ? 1 : 0
                        } else {
                            rightAnimationRatio = rightAnimationRatio > 0.5 ? 1 : 0
                        }
                    }
            )
            .onAppear {
                leftPageStack = [
                    .first(pageView:
                            PageView(
                                pageType: .left,
                                front:  { image(fileName: images[0]) },
                                back: { image(fileName: images[1]) },
                                pageWidth: geometry.size.width / 2,
                                animationRatio: $leftAnimationRatio,
                                dragStartPoint: $dragStartPoint,
                                dragXAmount: $dragXAmount
                            )
                          ),
                    //                    PageView(
                    //                        pageType: dragStartPoint.x < geometry.size.width / 2 ? .left : .right,
                    //                        front:  { image(fileName: images[2], width: geometry.size.width) },
                    //                        back: { image(fileName: images[3], width: geometry.size.width) },
                    //                        pageWidth: geometry.size.width / 2,
                    //                        animationRatio: $animationRatio,
                    //                        dragStartPoint: $dragStartPoint,
                    //                        dragXAmount: $dragXAmount
                    //                    )
                ]
                rightPageStack = [
//                    .first(pageView:
//                            PageView(
//                                pageType: .right,
//                                front:  { image(fileName: images[4]) },
//                                back: { image(fileName: images[5]) },
//                                pageWidth: geometry.size.width / 2,
//                                animationRatio: $rightAnimationRatio,
//                                dragStartPoint: $dragStartPoint,
//                                dragXAmount: $dragXAmount
//                            )
//                    )
                ]
            }
        }
        //        .shadow(radius: dragAmount == .zero ? 0 : 10)
    }
}

struct PageView: View {
    let pageType: PageType
    @ViewBuilder let front: () -> AnyView
    @ViewBuilder let back: () -> AnyView
    let pageWidth: CGFloat
    @Binding var animationRatio: CGFloat
    @Binding var dragStartPoint: CGPoint
    @Binding var dragXAmount: CGFloat?

    var body: some View {
        ZStack(alignment: .center) {
            if (pageType.isLeft && animationRatio > 0.5) || (!pageType.isLeft && animationRatio < 0.5) {
                front()
            }
            else {
                back()
            }
        }
        .onChange(of: animationRatio, { oldValue, newValue in
        })
        .rotation3DEffect(
            Angle(degrees: min( animationRatio * pageType.maxAngle, pageType.maxAngle)),
            axis: (x: CGFloat(0), y: 0.61, z: CGFloat(0)),
            anchor: pageType.anchor
        )
        .animation(.easeInOut, value: animationRatio)
    }
}

#Preview {
    ContentView()
}
