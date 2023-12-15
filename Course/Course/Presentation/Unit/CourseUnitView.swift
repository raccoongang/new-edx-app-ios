//
//  LessonView.swift
//  CourseDetails
//
//  Created by  Stepanok Ivan on 05.10.2022.
//

import Foundation
import SwiftUI
import Core
import Discussion
import Combine
import Theme

public extension NSNotification {
    static let blockChanged = Notification.Name.init("block_changed")
}

public struct CourseUnitView: View {
    
    @ObservedObject private var viewModel: CourseUnitViewModel
    @State private var showAlert: Bool = false
    @State var alertMessage: String? {
        didSet {
            withAnimation {
                showAlert = alertMessage != nil
            }
        }
    }
    @State var offsetView: CGFloat = 0
    @State var showDiscussion: Bool = false
    @Environment(\.isPresented) private var isPresented
    @Environment(\.isHorizontal) private var isHorizontal
    private let sectionName: String
    public let playerStateSubject = CurrentValueSubject<VideoPlayerState?, Never>(nil)
    
    //Dropdown parameters
    @State var showDropdown: Bool = false
    private let portraitTopSpacing: CGFloat = 60
    private let landscapeTopSpacing: CGFloat = 75
    
    let isDropdownActive: Bool
    
    var sequenceTitle: String {
        let chapter = viewModel.chapters[viewModel.chapterIndex]
        let sequence = chapter.childs[viewModel.sequentialIndex]
        return sequence.displayName
    }
    
    var unitTitle: String {
        let chapter = viewModel.chapters[viewModel.chapterIndex]
        let sequence = chapter.childs[viewModel.sequentialIndex]
        let unit = sequence.childs[viewModel.verticalIndex]
        return unit.displayName
    }
    
    var isDropdownAvailable: Bool {
        viewModel.verticals.count > 1
    }
    
    public init(
        viewModel: CourseUnitViewModel,
        sectionName: String,
        isDropdownActive: Bool = false
    ) {
        self.viewModel = viewModel
        self.sectionName = sectionName
        self.isDropdownActive = isDropdownActive
        viewModel.loadIndex()
        viewModel.nextTitles()
    }
            
    public var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Page Body
            ZStack(alignment: .bottom) {
                GeometryReader { reader in
                    VStack(spacing: 0) {
                        topInset(reader: reader)
                        content(reader: reader)
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    // MARK: Progress Dots
                    if !viewModel.courseUnitProgressEnabled {
                        LessonProgressView(viewModel: viewModel)
                    }
                }
                // MARK: - Alert
                if showAlert {
                    ZStack(alignment: .bottomLeading) {
                        Spacer()
                        HStack(spacing: 6) {
                            CoreAssets.rotateDevice.swiftUIImage.renderingMode(.template)
                                .onAppear {
                                    alertMessage = CourseLocalization.Alert.rotateDevice
                                }
                            Text(alertMessage ?? "")
                        }.shadowCardStyle(bgColor: Theme.Colors.accentColor,
                                          textColor: Theme.Colors.white)
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            doAfter(Theme.Timeout.snackbarMessageLongTimeout) {
                                alertMessage = nil
                                showAlert = false
                            }
                        }
                    }
                }
                courseNavigation
            }
            .onDisappear {
                if !isPresented {
                    playerStateSubject.send(VideoPlayerState.kill)
                }
            }
            if isDropdownActive && showDropdown {
                CourseUnitVerticalsDropdownView(
                    verticals: viewModel.verticals,
                    currentIndex: viewModel.verticalIndex,
                    offsetY: isHorizontal ? landscapeTopSpacing : portraitTopSpacing,
                    showDropdown: $showDropdown
                ) { [weak viewModel] vertical in
                    viewModel?.route(to: vertical)
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onRightSwipeGesture {
            playerStateSubject.send(VideoPlayerState.kill)
            viewModel.router.back()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showDiscussion = viewModel.selectedLesson().type == .discussion
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
        .background(
            Theme.Colors.background
                .ignoresSafeArea()
        )
        .dropdownAnimation(isActive: isDropdownActive, value: showDropdown)
    }

    // MARK: - Content

    private func topInset(reader: GeometryProxy) -> some View {
        VStack { Theme.Colors.background }
            .frame(
                width: reader.size.width,
                height: isHorizontal ?
                (viewModel.courseUnitProgressEnabled ? 85 : 75) :
                (viewModel.courseUnitProgressEnabled ? 60 : 50)
            )
    }

    // swiftlint:disable function_body_length
    private func content(reader: GeometryProxy) -> some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            let data = Array(viewModel.verticals[viewModel.verticalIndex].childs.enumerated())
            ForEach(data, id: \.offset) { index, block in
                VStack(spacing: 0) {
                    if isDropdownActive {
                        dropdown(block: block)
                    }
                    switch LessonType.from(block) {
                        // MARK: YouTube
                    case let .youtube(url, blockID):
                        if index >= viewModel.index - 1 && index <= viewModel.index + 1 {
                            if viewModel.connectivity.isInternetAvaliable {
                                YouTubeView(
                                    name: block.displayName,
                                    url: url,
                                    courseID: viewModel.courseID,
                                    blockID: blockID,
                                    playerStateSubject: playerStateSubject,
                                    languages: block.subtitles ?? [],
                                    isOnScreen: index == viewModel.index
                                )
                                .frameLimit()
                                if !isHorizontal {
                                    Spacer(minLength: 150)
                                }
                            } else {
                                NoInternetView(playerStateSubject: playerStateSubject)
                            }
                        } else {
                            EmptyView()
                        }
                        // MARK: Encoded Video
                    case let .video(encodedUrl, blockID):
                        if index == viewModel.index {
                            let url = viewModel.urlForVideoFileOrFallback(
                                blockId: blockID,
                                url: encodedUrl
                            )
                            if viewModel.connectivity.isInternetAvaliable || url?.isFileURL == true {
                                EncodedVideoView(
                                    name: block.displayName,
                                    url: url,
                                    courseID: viewModel.courseID,
                                    blockID: blockID,
                                    playerStateSubject: playerStateSubject,
                                    languages: block.subtitles ?? [],
                                    isOnScreen: index == viewModel.index
                                )
                                .padding(.top, 5)
                                .frameLimit()
                                if !isHorizontal {
                                    Spacer(minLength: 150)
                                }
                            } else {
                                NoInternetView(playerStateSubject: playerStateSubject)
                            }
                        }
                        // MARK: Web
                    case .web(let url):
                        if index >= viewModel.index - 1 && index <= viewModel.index + 1 {
                            if viewModel.connectivity.isInternetAvaliable {
                                WebView(
                                    url: url,
                                    viewModel: viewModel,
                                    roundedBackgroundEnabled: !viewModel.courseUnitProgressEnabled
                                )
                            } else {
                                NoInternetView(playerStateSubject: playerStateSubject)
                            }
                        } else {
                            EmptyView()
                        }
                        // MARK: Unknown
                    case .unknown(let url):
                        if index >= viewModel.index - 1 && index <= viewModel.index + 1 {
                            if viewModel.connectivity.isInternetAvaliable {
                                UnknownView(url: url, viewModel: viewModel)
                                Spacer()
                            } else {
                                NoInternetView(playerStateSubject: playerStateSubject)
                            }
                        } else {
                            EmptyView()
                        }
                        // MARK: Discussion
                    case let .discussion(blockID, blockKey, title):
                        if index >= viewModel.index - 1 && index <= viewModel.index + 1 {
                            if viewModel.connectivity.isInternetAvaliable {
                                VStack {
                                    if showDiscussion {
                                        DiscussionView(
                                            id: viewModel.courseID,
                                            blockID: blockID,
                                            blockKey: blockKey,
                                            title: title,
                                            viewModel: viewModel
                                        )
                                        Spacer(minLength: 100)
                                    } else {
                                        VStack {
                                            Color.clear
                                        }
                                    }
                                }.frameLimit()
                            } else {
                                NoInternetView(playerStateSubject: playerStateSubject)
                            }
                        } else {
                            EmptyView()
                        }
                    }

                }
                .frame(
                    width: isHorizontal ? reader.size.width - 16 : reader.size.width,
                    height: reader.size.height
                )
                .id(index)
            }
        }
        .offset(y: offsetView)
        .clipped()
        .onAppear {
            offsetView = -(reader.size.height * CGFloat(viewModel.index))
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                                   object: nil, queue: .main) { _ in
                offsetView = -(reader.size.height * CGFloat(viewModel.index))
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification,
                                                   object: nil, queue: .main) { _ in
                offsetView = -(reader.size.height * CGFloat(viewModel.index))
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification,
                                                   object: nil, queue: .main) { _ in
                offsetView = -(reader.size.height * CGFloat(viewModel.index))
            }
        }
        .onChange(of: UIDevice.current.orientation, perform: { _ in
            offsetView = -(reader.size.height * CGFloat(viewModel.index))
        })
        .onChange(of: viewModel.verticalIndex, perform: { index in
            DispatchQueue.main.async {
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    offsetView = -(reader.size.height * CGFloat(index))
                }
            }

        })
        .onChange(of: viewModel.index, perform: { index in
            DispatchQueue.main.async {
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    offsetView = -(reader.size.height * CGFloat(index))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showDiscussion = viewModel.selectedLesson().type == .discussion
                    }
                }
            }

        })
        .onReceive(
            NotificationCenter.default.publisher(
                for: NSNotification.blockCompletion
            )
        ) { _ in
            let blockID = viewModel.selectedLesson().id
            Task {
                await viewModel.blockCompletionRequest(blockID: blockID)
            }
        }
    }
    // swiftlint:enable function_body_length

    private func dropdown(block: CourseBlock) -> some View {
        HStack {
            if block.type == .video {
                let title = block.displayName
                Text(title)
                    .lineLimit(1)
                    .font(Theme.Fonts.titleLarge)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                Spacer()
            }
        }
    }

    // MARK: - Course Navigation

    private var courseNavigation: some View {
        VStack(spacing: 0) {
            ZStack {
                if !isDropdownActive {
                    GeometryReader { reader in
                        VStack {
                            HStack {
                                let currentBlock = viewModel.verticals[viewModel.verticalIndex]
                                    .childs[viewModel.index]
                                if currentBlock.type == .video {
                                    let title = currentBlock.displayName
                                    Text(title)
                                        .lineLimit(1)
                                        .font(Theme.Fonts.titleLarge)
                                        .foregroundStyle(Theme.Colors.textPrimary)
                                        .padding(.leading, isHorizontal ? 30 : 42)
                                        .padding(.top, isHorizontal ? 14 : 2)
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: isHorizontal ? reader.size.width * 0.5 : nil)
                            Spacer()
                        }
                    }
                }
                navigationBar
                courseNavigationView
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var navigationBar: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                NavigationBar(
                    title: isDropdownActive ? sequenceTitle : "",
                    leftButtonAction: {
                        if viewModel.blockChanged {
                            NotificationCenter.default.post(
                                name: NSNotification.blockChanged,
                                object: nil
                            )
                        }
                        viewModel.router.back()
                        playerStateSubject.send(VideoPlayerState.kill)
                    }
                )
                .padding(.top, isHorizontal ? 10 : 0)
                .padding(.leading, isHorizontal ? -16 : 0)

                if isDropdownActive {
                    CourseUnitDropDownTitle(
                        title: unitTitle,
                        isAvailable: isDropdownAvailable,
                        showDropdown: $showDropdown
                    )
                    .padding(.bottom, 0)
                }
            }
            .background(Theme.Colors.background)

            if viewModel.courseUnitProgressEnabled {
                LessonLineProgressView(viewModel: viewModel)
            }
            Spacer()
        }
    }

    private var courseNavigationView: some View {
        HStack(alignment: .center) {
            if isHorizontal {
                Spacer()
            }
            VStack {
                if !isHorizontal {
                    Spacer()
                }
                CourseNavigationView(
                    sectionName: sectionName,
                    viewModel: viewModel,
                    playerStateSubject: playerStateSubject
                )
                if isHorizontal {
                    Spacer()
                }
            }//.frame(height: isHorizontal ? nil : 44)

            .padding(.bottom, isHorizontal ? 0 : 50)
            .padding(.top, isHorizontal ? 12 : 0)
        }
        .frameLimit(sizePortrait: 420)
    }
}

#if DEBUG
//swiftlint:disable all
struct CourseUnitView_Previews: PreviewProvider {
    static var previews: some View {
        let blocks = [
            CourseBlock(
                blockId: "1",
                id: "1",
                courseId: "123",
                topicId: "1",
                graded: false,
                completion: 0,
                type: .video,
                displayName: "Lesson 1",
                studentUrl: "",
                videoUrl: nil,
                youTubeUrl: nil
            ),
            CourseBlock(
                blockId: "2",
                id: "2",
                courseId: "123",
                topicId: "2",
                graded: false,
                completion: 0,
                type: .video,
                displayName: "Lesson 2",
                studentUrl: "2",
                videoUrl: nil,
                youTubeUrl: nil
            ),
            CourseBlock(
                blockId: "3",
                id: "3",
                courseId: "123",
                topicId: "3",
                graded: false,
                completion: 0,
                type: .unknown,
                displayName: "Lesson 3",
                studentUrl: "3",
                videoUrl: nil,
                youTubeUrl: nil
            ),
            CourseBlock(
                blockId: "4",
                id: "4",
                courseId: "123",
                topicId: "4",
                graded: false,
                completion: 0,
                type: .unknown,
                displayName: "4",
                studentUrl: "4",
                videoUrl: nil,
                youTubeUrl: nil
            ),
        ]
        
        let chapters = [
            CourseChapter(
                blockId: "0",
                id: "0",
                displayName: "0",
                type: .chapter,
                childs: [
                    CourseSequential(
                        blockId: "5",
                        id: "5",
                        displayName: "5",
                        type: .sequential,
                        completion: 0,
                        childs: [
                            CourseVertical(
                                blockId: "6",
                                id: "6",
                                courseId: "123",
                                displayName: "6",
                                type: .vertical,
                                completion: 0,
                                childs: blocks
                            )
                        ]
                    )
                    
                ]),
            CourseChapter(
                blockId: "2",
                id: "2",
                displayName: "2",
                type: .chapter,
                childs: [
                    CourseSequential(
                        blockId: "3",
                        id: "3",
                        displayName: "3",
                        type: .sequential,
                        completion: 0,
                        childs: [
                            CourseVertical(
                                blockId: "4",
                                id: "4",
                                courseId: "1",
                                displayName: "4",
                                type: .vertical,
                                completion: 0,
                                childs: blocks
                            )
                        ]
                    )
                    
                ])
        ]
        
        return CourseUnitView(viewModel: CourseUnitViewModel(
            lessonID: "",
            courseID: "",
            courseName: "courseName",
            chapters: chapters,
            chapterIndex: 0,
            sequentialIndex: 0,
            verticalIndex: 0,
            interactor: CourseInteractor.mock,
            config: ConfigMock(),
            router: CourseRouterMock(),
            analytics: CourseAnalyticsMock(),
            connectivity: Connectivity(),
            manager: DownloadManagerMock()
        ), sectionName: "")
    }
}
//swiftlint:enable all
#endif

struct NoInternetView: View {
    
    let playerStateSubject: CurrentValueSubject<VideoPlayerState?, Never>
    
    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "wifi").resizable()
                .scaledToFit()
                .frame(width: 100)
            Text(CourseLocalization.Error.noInternet)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            UnitButtonView(type: .reload, action: {
                playerStateSubject.send(VideoPlayerState.kill)
            }).frame(width: 100)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
