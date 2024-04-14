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

    @State private var currentLeftPageIndex = 1
    private var currentRightPageIndex: Int {
        currentLeftPageIndex + 1
    }
    @State private var leftPageKindStack: [LeftBookPageKind] = []
    @State private var rightPageKindStack: [RightBookPageKind] = []

    @State private var animationRatio: CGFloat = 0

    @State private var pageSwipeStatus: PageSwipeStatus = .notSwipe
    @State private var pageSize: CGSize = .zero
    private var leftPageIndex: Double {
        return pageSwipeStatus == .right ? 1 : 0
    }
    private var rightPageIndex: Double {
        return pageSwipeStatus == .left ? 1 : 0
    }
    private let animationDuration: CGFloat = 0.5
    private let animationBounce: CGFloat = 0.3

    func image(fileName: String) -> some View {
        return Image(fileName)
            .resizable()
            .clipped()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    leftPageStackView(
                        pageKindStack: leftPageKindStack,
                        pageZIndex: leftPageIndex,
                        pageType: .left,
                        animationRatio: animationRatio,
                        pageSize: pageSize
                    )
                    rightPageStackView(
                        pageKindStack: rightPageKindStack,
                        pageZIndex: rightPageIndex,
                        pageType: .right,
                        animationRatio: animationRatio,
                        pageSize: pageSize
                    )
                }
            }
            .ignoresSafeArea()
            //            .rotation3DEffect(
            //                Angle(degrees: 20),
            //                axis: (x: CGFloat(6), y: 0, z: CGFloat(0)),
            //                anchor: .center,
            //                perspective: 1
            //            )
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
                            animationRatio = leftAnimationRatio
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
                            withAnimation(.spring(duration: animationDuration, bounce: animationBounce)) {
                                adjustLeftPages(
                                    currentLeftPageIndex: currentLeftPageIndex,
                                    leftAnimationRatio: isInLeftPage ? 0 : 1
                                )
                                self.animationRatio = isInLeftPage ? 0 : 1
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
                                animationRatio = 0
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
                            animationRatio = rightAnimationRatio
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
                            withAnimation(.spring(duration: animationDuration, bounce: animationBounce)) {
                                adjustRightPages(
                                    currentRightPageIndex: currentRightPageIndex,
                                    rightAnimationRatio: isInRightPage ? 0 : 1
                                )
                                animationRatio = isInRightPage ? 0 : 1

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
                                animationRatio = 0

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
    func leftPageStackView(
        pageKindStack: [LeftBookPageKind],
        pageZIndex: Double,
        pageType: PageDirectionType,
        animationRatio: CGFloat,
        pageSize: CGSize
    ) -> some View {
        ZStack(alignment: .center) {
            if pageKindStack.isEmpty {
                Spacer()
                    .frame(width: pageSize.width / 2)
            } else {
                ForEach(pageKindStack, id: \.id) { kind in
                    switch kind {
                    case .leftTopPage(let backFileName, let frontFileName, let frontPageIndex):
                        TopPageView(
                            pageIndex: currentLeftPageIndex,
                            pageType: .left,
                            pageSwipeStatus: pageSwipeStatus,
                            animationRatio: animationRatio,
                            isFrontPageExist: images.indices.contains(frontPageIndex),
                            isBackPageExist: images.indices.contains(frontPageIndex - 1),
                            pageSize: pageSize,
                            front: {
                                if let frontFileName = frontFileName {
                                    image(fileName: frontFileName)
                                } else {
                                    Spacer()
                                        .frame(width: pageSize.width / 2)
                                }
                            }, back: {
                                image(fileName: backFileName)
                            }
                        )
                    case .leftSecondPage(let fileName, let pageIndex):
                        SecondContentView(
                            id: images[currentLeftPageIndex - 2],
                            pageIndex: pageIndex,
                            pageSwipeStatus: pageSwipeStatus,
                            pageType: .left,
                            animationRatio: animationRatio,
                            pageSize: pageSize) {
                                image(fileName: fileName)
                            }
                            .frame(width: pageSize.width / 2, height: pageSize.height)
                    case .leftThirdPage(let fileName, let pageIndex):
                        ThirdContentView(
                            id: images[currentLeftPageIndex - 2],
                            pageIndex: pageIndex,
                            pageType: .left,
                            pageSize: pageSize) {
                                image(fileName: fileName)
                            }
                            .frame(width: pageSize.width / 2, height: pageSize.height)
                    }
                }
            }
        }
        .scaledToFill()
        .zIndex(pageZIndex)
    }

    @ViewBuilder
    func rightPageStackView(
        pageKindStack: [RightBookPageKind],
        pageZIndex: Double,
        pageType: PageDirectionType,
        animationRatio: CGFloat,
        pageSize: CGSize
    ) -> some View {
        ZStack(alignment: .center) {
            ForEach(pageKindStack, id: \.id) { kind in
                switch kind {
                case .rightTopPage(let frontFileName, let backFileName, let frontPageIndex):
                    TopPageView(
                        pageIndex: currentRightPageIndex,
                        pageType: .right,
                        pageSwipeStatus: pageSwipeStatus,
                        animationRatio: animationRatio,
                        isFrontPageExist: images.indices.contains(frontPageIndex),
                        isBackPageExist: images.indices.contains(frontPageIndex + 1),
                        pageSize: pageSize,
                        front: {
                            image(fileName: frontFileName)
                        }, back: {
                            if let backFileName = backFileName {
                                image(fileName: backFileName)
                            } else  {
                                Spacer()
                                    .frame(width: pageSize.width / 2)
                            }
                        }
                    )
                case .rightSecondPage(let fileName, let pageIndex):
                    if let fileName = fileName {
                        SecondContentView(
                            id: images[pageIndex],
                            pageIndex: pageIndex,
                            pageSwipeStatus: pageSwipeStatus,
                            pageType: .right,
                            animationRatio: animationRatio,
                            pageSize: pageSize) {
                                image(fileName: fileName)
                            }
                            .frame(width: pageSize.width / 2, height: pageSize.height)
                    } else {
                        Spacer()
                            .frame(width: pageSize.width / 2)
                    }
                case .rightThirdPage(let fileName, let pageIndex):
                    if let fileName = fileName {
                        ThirdContentView(
                            id: images[pageIndex],
                            pageIndex: pageIndex,
                            pageType: .right,
                            pageSize: pageSize) {
                                image(fileName: fileName)
                            }
                            .frame(width: pageSize.width / 2, height: pageSize.height)
                    } else {
                        Spacer()
                            .frame(width: pageSize.width / 2)
                    }
                }
            }
        }
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
        var leftPageKindStack: [LeftBookPageKind] = []
        let thirdPageIndex = currentLeftPageIndex - 4
        if images.indices.contains(thirdPageIndex) {
            leftPageKindStack.append(
                .leftThirdPage(
                    fileName: images[thirdPageIndex],
                    pageIndex: thirdPageIndex
                )
            )
        }
        let secondPageIndex = currentLeftPageIndex - 2
        if images.indices.contains(secondPageIndex) {
            leftPageKindStack.append(
                .leftSecondPage(
                    fileName: images[secondPageIndex],
                    pageIndex: secondPageIndex
                )
            )
        }
        let topBackPageIndex = currentLeftPageIndex - 1
        if images.indices.contains(topBackPageIndex) {
            leftPageKindStack.append(
                .leftTopPage(
                    backFileName: images[topBackPageIndex],
                    frontFileName: images.indices.contains(currentLeftPageIndex) ? images[currentLeftPageIndex] : nil,
                    frontPageIndex: currentLeftPageIndex
                )
            )
        }
        //        if leftPageKindStack.count < PageLayerType.allCases.count {
        //            leftPageKindStack.insert(.leftFrontPage(pageIndex: 0), at: 0)
        //        }
        //        if currentLeftPageIndex == images.count - 1 {
        //            leftPageKindStack.append(.leftBackPage(pageIndex: images.count))
        //        }
        self.leftPageKindStack = leftPageKindStack
    }

    func adjustRightPages(currentRightPageIndex: Int, rightAnimationRatio: CGFloat) {
        var rightPageKindStack: [RightBookPageKind] = []
        let thirdPageIndex = currentRightPageIndex + 4
        if images.indices.contains(thirdPageIndex) {
            rightPageKindStack.append(
                .rightThirdPage(
                    fileName: images[thirdPageIndex],
                    pageIndex: thirdPageIndex
                )
            )
        }
        let secondPageIndex = currentRightPageIndex + 2
        if images.indices.contains(secondPageIndex) {
            rightPageKindStack.append(
                .rightSecondPage(
                    fileName: images[secondPageIndex],
                    pageIndex: secondPageIndex
                )
            )
        }
        let topBackPageIndex = currentRightPageIndex + 1
        if images.indices.contains(currentRightPageIndex) {
            rightPageKindStack.append(
                .rightTopPage(
                    frontFileName: images[currentRightPageIndex],
                    backFileName: images.indices.contains(topBackPageIndex) ? images[topBackPageIndex] : nil,
                    frontPageIndex: currentRightPageIndex
                )
            )
        }
        self.rightPageKindStack = rightPageKindStack
    }
}

// PageView
enum LeftBookPageKind: Identifiable {
    case leftTopPage(backFileName: String, frontFileName: String?, frontPageIndex: Int)
    case leftSecondPage(fileName: String, pageIndex: Int)
    case leftThirdPage(fileName: String, pageIndex: Int)

    var id: String {
        return pageIndex.description
    }

    var pageIndex: Int {
        switch self {
        case .leftTopPage(_, _, let pageIndex):
            return pageIndex
        case .leftSecondPage(_, let pageIndex):
            return pageIndex
        case .leftThirdPage(_, let pageIndex):
            return pageIndex
        }
    }
}

enum RightBookPageKind: Identifiable {

    case rightTopPage(frontFileName: String, backFileName: String?, frontPageIndex: Int)
    case rightSecondPage(fileName: String?, pageIndex: Int)
    case rightThirdPage(fileName: String?, pageIndex: Int)

    var id: String {
        return pageIndex.description
    }

    var pageIndex: Int {
        switch self {
        case .rightTopPage(_, _, let pageIndex):
            return pageIndex
        case .rightSecondPage(_, let pageIndex):
            return pageIndex
        case .rightThirdPage(_, let pageIndex):
            return pageIndex
        }
    }
}

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

    let pageIndex: Int
    let pageLayerType: PageLayerType = .top
    let pageType: PageDirectionType
    let pageSwipeStatus: PageSwipeStatus
    let animationRatio: CGFloat
    let isFrontPageExist: Bool
    let isBackPageExist: Bool
    let pageSize: CGSize
    @ViewBuilder let front: () -> FrontContent
    @ViewBuilder let back: () -> BackContent

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
            return pageType.defaultAngle * (1 - animationRatio)
        }
    }

    private var backPageIndex: Int {
        switch pageType {
        case .left:
            return pageIndex - 1
        case .right:
            return pageIndex + 1
        }
    }

    private var viewWidth: CGFloat {
        let pagingRatioToHalfRatio: CGFloat
        switch pageType {
        case .left:
            pagingRatioToHalfRatio = abs(angleDegrees - 90) / 90
        case .right:
            pagingRatioToHalfRatio = abs(angleDegrees + 90) / 90
        }
        let minRatio = 0.5
        // 0.5~1.0の幅に調整
        let adjustedRatio = minRatio + (1 - minRatio) * pagingRatioToHalfRatio
        return pageSize.width / 2 * (adjustedRatio)
    }

    private var leftTopPageLeftMargin: CGFloat {
        if pageType == .left {
            return pageSize.width / 2 - viewWidth
        } else {
            return 0
        }
    }

    private var rightTopPageRightMargin: CGFloat {
        if pageType == .left {
            return 0
        } else {
            return pageSize.width / 2 - viewWidth
        }
    }

    var body: some View {
        HStack {
            Spacer()
                .frame(width: leftTopPageLeftMargin)
            ZStack(alignment: .center) {
                if !isPageTurning || animationRatio < 0.5 {
                    ZStack(alignment: pageType == .left ? .bottomLeading : .bottomTrailing) {
                        if isFrontPageExist {
                            front()
                        } else {
                            Color.white
                                .stroke(color: Color.black, width: 1)
                        }
                        PageTextView(pageIndex: pageIndex)
                    }
                }
                else {
                    ZStack(alignment: pageType == .left ? .bottomLeading : .bottomTrailing) {
                        if isBackPageExist {
                            back()
                                .rotation3DEffect(
                                    Angle(degrees: 180),
                                    axis: (x: CGFloat(0), y: 0.61, z: CGFloat(0)),
                                    perspective: 0.5
                                )
                        } else {
                            Color.white
                                .stroke(color: Color.black, width: 1)
                        }
                        PageTextView(pageIndex: backPageIndex)
                            .rotation3DEffect(
                                Angle(degrees: 180),
                                axis: (x: CGFloat(0), y: 0.61, z: CGFloat(0)),
                                perspective: 0.5
                            )
                    }
                }
            }
            .overlay(.black.opacity(opacity))
            .rotation3DEffect(
                Angle(degrees: angleDegrees),
                axis: (x: CGFloat(0), y: 0.61, z: CGFloat(0)),
                anchor: pageType.anchor,
                perspective: 0.3
            )
            .frame(width: viewWidth, height: pageSize.height)
            Spacer()
                .frame(width: rightTopPageRightMargin)
        }
    }
}

struct SecondContentView<Content: View>: View, BookPageViewProtocol {
    let pageLayerType: PageLayerType = .second
    let id: String
    let pageIndex: Int
    let pageSwipeStatus: PageSwipeStatus
    let pageType: PageDirectionType
    let animationRatio: CGFloat
    let pageSize: CGSize
    @ViewBuilder let content: () -> Content

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

    private var angleDegrees: CGFloat {
        if isPageTurning {
            return pageType.defaultAngle * animationRatio
        } else {
            return pageType.defaultAngle * -animationRatio
        }
    }

    private var viewWidth: CGFloat {
        let pagingRatioToHalfRatio: CGFloat
        switch pageType {
        case .left:
            pagingRatioToHalfRatio = abs(angleDegrees - 90) / 90
        case .right:
            pagingRatioToHalfRatio = abs(angleDegrees + 90) / 90
        }
        let minRatio = 0.5
        let adjustedRatio = minRatio + (1 - minRatio) * pagingRatioToHalfRatio
        return pageSize.width / 2 * (adjustedRatio)
    }

    private var leftTopPageLeftMargin: CGFloat {
        if pageType == .left {
            return pageSize.width / 2 - viewWidth
        } else {
            return 0
        }
    }

    private var rightTopPageRightMargin: CGFloat {
        if pageType == .left {
            return 0
        } else {
            return pageSize.width / 2 - viewWidth
        }
    }

    var body: some View {
        HStack {
            Spacer()
                .frame(width: leftTopPageLeftMargin)
            ZStack(alignment: pageType == .left ? .bottomLeading : .bottomTrailing) {
                content()
                PageTextView(pageIndex: pageIndex)
            }
            .overlay(.black.opacity((1 - animationRatio) * 0.5))
            .rotation3DEffect(
                Angle(degrees: angleDegrees),
                axis: (x: CGFloat(0), y: 0.61, z: CGFloat(0)),
                anchor: pageType.anchor,
                perspective: 0.3
            )
            Spacer()
                .frame(width: rightTopPageRightMargin)
        }
    }
}

struct ThirdContentView<Content: View>: View {
    let pageLayerType: PageLayerType = .third
    let id: String
    let pageIndex: Int
    let pageType: PageDirectionType
    let pageSize: CGSize
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: pageType == .left ? .bottomLeading : .bottomTrailing) {
            content()
            PageTextView(pageIndex: pageIndex)
        }
        .overlay(.black.opacity(0.5))
        .frame(width: pageSize.width / 2, height: pageSize.height)
    }
}

private struct PageTextView: View {
    let pageIndex: Int

    var body: some View {
        Text((pageIndex + 1).description)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .stroke(color: .black, width: 1)
            .padding()
    }
}

#Preview {
    BookView()
}
