//
//  ContentView.swift
//  BookUIApp
//
//  Created by Yugo Sugiyama on 2024/03/28.
//

import SwiftUI
import Observation

struct BookView: View {
    let images = Array(0...10).map({ "image\($0.remainderReportingOverflow(dividingBy: 6).partialValue)" })

    @State private var currentLeftPageIndex = 3
    private var currentRightPageIndex: Int {
        currentLeftPageIndex + 1
    }
//    @State private var leftPageStack: [any BookPageViewProtocol] = []
//    @State private var rightPageStack: [any BookPageViewProtocol] = []
    @State private var leftPage: AnyView = AnyView(EmptyView())
    @State private var rightPage: AnyView = AnyView(EmptyView())
    @State private var pageSwipeStatus: PageSwipeStatus = .notSwipe
    @State private var pageSize: CGSize = .zero
    private var leftPageIndex: Double {
        return pageSwipeStatus == .right ? 1 : 0
    }
    private var rightPageIndex: Double {
        return pageSwipeStatus == .left ? 1 : 0
    }

    func image(fileName: String) -> some View {
        return Image(fileName)
            .resizable()
            .clipped()

    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
//                    pageStackView(
//                        pageStack: leftPageStack,
//                        pageZIndex: leftPageIndex,
//                        pageType: .left,
//                        pageSize: .init(width: geometry.size.width / 2, height: geometry.size.height)
//                    )
//                    pageStackView(
//                        pageStack: rightPageStack,
//                        pageZIndex: rightPageIndex,
//                        pageType: .right,
//                        pageSize: .init(width: geometry.size.width / 2, height: geometry.size.height)
//                    )
                    leftPage
                    rightPage
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
                            self.pageSwipeStatus = .right
                            let dragXAmount = min(
                                max(value.location.x - value.startLocation.x, 0),
                                geometry.size.width
                            )
                            let leftAnimationRatio = min(dragXAmount / geometry.size.width, 1)
                            adjustBothPages(
                                currentLeftPageIndex: currentLeftPageIndex,
                                leftAnimationRatio: leftAnimationRatio,
                                currentRightPageIndex: currentRightPageIndex,
                                rightAnimationRatio: leftAnimationRatio
                            )
                        } else {
                            self.pageSwipeStatus = .left
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
                            self.pageSwipeStatus = .left
                            let dragXAmount = min(
                                max(value.startLocation.x - value.location.x, 0),
                                geometry.size.width
                            )
                            let rightAnimationRatio = min(dragXAmount / geometry.size.width, 1)
                            adjustBothPages(
                                currentLeftPageIndex: currentLeftPageIndex,
                                leftAnimationRatio: rightAnimationRatio,
                                currentRightPageIndex: currentRightPageIndex,
                                rightAnimationRatio: rightAnimationRatio
                            )
                        } else {
                            self.pageSwipeStatus = .right
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
                pageSize = geometry.size
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

private extension BookView {

    @ViewBuilder
    func pageStackView(
        pageStack: [any BookPageViewProtocol],
        pageZIndex: Double,
        pageType: PageDirectionType,
        pageSize: CGSize
    ) -> some View {
        ZStack(alignment: .center) {
            ForEach(0..<pageStack.count) { index in
//                AnyView(pageStack[index])
            }
        }
        .frame(width: pageSize.width, height: pageSize.height)
        .scaledToFill()
        .zIndex(pageZIndex)
    }
}

private extension BookView {
    func adjustBothPages(currentLeftPageIndex: Int, leftAnimationRatio: CGFloat, currentRightPageIndex: Int, rightAnimationRatio: CGFloat) {
        adjustLeftPages(currentLeftPageIndex: currentLeftPageIndex, leftAnimationRatio: leftAnimationRatio)
        adjustRightPages(currentRightPageIndex: currentRightPageIndex, rightAnimationRatio: rightAnimationRatio)

    }

    func adjustLeftPages(currentLeftPageIndex: Int, leftAnimationRatio: CGFloat) {
//        leftPageStack = [
//            SecondContentView(
//                id: images[currentLeftPageIndex - 2],
//                pageType: .left,
//                animationRatio: leftAnimationRatio) {
//                image(fileName: images[currentLeftPageIndex - 2])
//            },
//            TopPageView(pageType: .left, animationRatio: leftAnimationRatio, front: {
//                image(fileName: images[currentLeftPageIndex])
//            }, back: {
//                image(fileName: images[currentLeftPageIndex - 1])
//            })
//        ]
        leftPage = AnyView(
            ZStack(alignment: .center) {
                if images.indices.contains(currentLeftPageIndex - 2) {
                    SecondContentView(
                        id: images[currentLeftPageIndex - 2],
                        pageIndex: currentLeftPageIndex - 2,
                        pageType: .left,
                        animationRatio: leftAnimationRatio) {
                        image(fileName: images[currentLeftPageIndex - 2])
                    }
                } else {
                    EmptyView()
                }
                if images.indices.contains(currentLeftPageIndex - 1) {
                    TopPageView(
                        pageIndex: currentLeftPageIndex,
                        pageType: .left,
                        pageSwipeStatus: pageSwipeStatus,
                        animationRatio: leftAnimationRatio,
                        isFrontPageExist: images.indices.contains(currentLeftPageIndex),
                        isBackPageExist: images.indices.contains(currentLeftPageIndex - 1),
                        front: {
                        image(fileName: images[currentLeftPageIndex])
                        }, back: {
                            image(fileName: images[currentLeftPageIndex - 1])
                        }
                    )
                } else {
                    EmptyView()
                }
            }
            .frame(width: pageSize.width / 2, height: pageSize.height)
            .scaledToFill()
            .zIndex(leftPageIndex)
        )
    }

    func adjustRightPages(currentRightPageIndex: Int, rightAnimationRatio: CGFloat) {
//        rightPageStack = [
//            SecondContentView(
//                id: images[currentRightPageIndex + 2],
//                pageType: .right,
//                animationRatio: rightAnimationRatio) {
//                image(fileName: images[currentRightPageIndex + 2])
//            },
//            TopPageView(pageType: .right, animationRatio: rightAnimationRatio, front: {
//                image(fileName: images[currentRightPageIndex])
//            }, back: {
//                image(fileName: images[currentRightPageIndex + 1])
//            })
//        ]
        rightPage = AnyView(
            ZStack(alignment: .center) {
                if images.indices.contains(currentRightPageIndex + 2) {
                    SecondContentView(
                        id: images[currentRightPageIndex + 2],
                        pageIndex: currentRightPageIndex + 2,
                        pageType: .right,
                        animationRatio: rightAnimationRatio) {
                        image(fileName: images[currentRightPageIndex + 2])
                    }
                } else {
                    EmptyView()
                }
                if images.indices.contains(currentRightPageIndex) {
                    TopPageView(
                        pageIndex: currentRightPageIndex,
                        pageType: .right,
                        pageSwipeStatus: pageSwipeStatus,
                        animationRatio: rightAnimationRatio,
                        isFrontPageExist: images.indices.contains(currentRightPageIndex),
                        isBackPageExist: images.indices.contains(currentRightPageIndex + 1),
                        front: {
                        image(fileName: images[currentRightPageIndex])
                        }, back: {
                            image(fileName: images[currentRightPageIndex + 1])
                        }
                    )
                } else {
                    EmptyView()
                }
            }
            .frame(width: pageSize.width / 2, height: pageSize.height)
            .scaledToFill()
            .zIndex(rightPageIndex)
        )
    }
}

#Preview {
    BookView()
}
