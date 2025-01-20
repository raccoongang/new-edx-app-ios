//
//  CourseContainerViewModelTests.swift
//  CourseTests
//
//  Created by  Stepanok Ivan on 20.01.2023.
//

import SwiftyMocky
import XCTest
@testable import Core
@testable import Course
import Alamofire
import SwiftUI
import Combine

@MainActor
final class CourseContainerViewModelTests: XCTestCase {
    
    func testGetCourseBlocksSuccess() async throws {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        
        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: DownloadManagerMock(), 
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        
        let block = CourseBlock(
            blockId: "",
            id: "",
            courseId: "123",
            topicId: "",
            graded: true, 
            due: Date(),
            completion: 0,
            type: .problem,
            displayName: "",
            studentUrl: "",
            webUrl: "",
            encodedVideo: nil,
            multiDevice: true, 
            offlineDownload: nil
        )
        let vertical = CourseVertical(
            blockId: "",
            id: "",
            courseId: "123",
            displayName: "",
            type: .vertical,
            completion: 0,
            childs: [block],
            webUrl: ""
        )
        let sequential = CourseSequential(
            blockId: "",
            id: "",
            displayName: "",
            type: .chapter,
            completion: 0,
            childs: [vertical], 
            sequentialProgress: nil,
            due: Date()
        )
        let chapter = CourseChapter(
            blockId: "",
            id: "",
            displayName: "",
            type: .chapter,
            childs: [sequential]
        )
        
        let childs = [chapter]
        
        let courseStructure = CourseStructure(
            id: "123",
            graded: true,
            completion: 0,
            viewYouTubeUrl: "",
            encodedVideo: "",
            displayName: "",
            topicID: nil,
            childs: childs,
            media: CourseMedia(
                image: CourseImage(
                    raw: "",
                    small: "",
                    large: ""
                )
            ),
            certificate: nil,
            org: "",
            isSelfPaced: true,
            courseProgress: nil
        )
        
        let resumeBlock = ResumeBlock(blockID: "123")
        
        Given(interactor, .getCourseBlocks(courseID: "123",
                                           willReturn: courseStructure))
        Given(interactor, .getCourseBlocks(courseID: "123",
                                           willReturn: courseStructure))
        Given(interactor, .resumeBlock(courseID: "123",
                                       willReturn: resumeBlock))
        Given(interactor, .getCourseVideoBlocks(fullStructure: .any,
                                                willReturn: courseStructure))
        
        await viewModel.getCourseBlocks(courseID: "123")
        
        Verify(interactor, .getCourseBlocks(courseID: .any))
        Verify(interactor, .getCourseVideoBlocks(fullStructure: .any))
        Verify(interactor, .resumeBlock(courseID: "123"))
        XCTAssertFalse(viewModel.isShowProgress)
        XCTAssertFalse(viewModel.showError)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.courseStructure, courseStructure)
    }
    
    func testGetCourseBlocksOfflineSuccess() async throws {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        
        Given(connectivity, .isInternetAvaliable(getter: false))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: DownloadManagerMock(), 
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        
        let courseStructure = CourseStructure(
            id: "123",
            graded: true,
            completion: 0,
            viewYouTubeUrl: "",
            encodedVideo: "",
            displayName: "",
            topicID: nil,
            childs: [],
            media: CourseMedia(
                image: CourseImage(
                    raw: "",
                    small: "",
                    large: ""
                )
            ),
            certificate: nil,
            org: "",
            isSelfPaced: true,
            courseProgress: nil
        )
        
        Given(interactor, .getLoadedCourseBlocks(courseID: .any, willReturn: courseStructure))
        Given(interactor, .getCourseVideoBlocks(fullStructure: .any,
                                                willReturn: courseStructure))
        
        await viewModel.getCourseBlocks(courseID: "123")
        
        Verify(interactor, .getLoadedCourseBlocks(courseID: .any))
        Verify(interactor, .getCourseVideoBlocks(fullStructure: .any))
        XCTAssertFalse(viewModel.isShowProgress)
        XCTAssertFalse(viewModel.showError)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.courseStructure, courseStructure)
    }
    
    func testGetCourseBlocksNoInternetError() async throws {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        
        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: DownloadManagerMock(), 
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        
        let noInternetError = AFError.sessionInvalidated(error: URLError(.notConnectedToInternet))
        
        
        Given(interactor, .getCourseBlocks(courseID: "123",
                                           willThrow: noInternetError))
        
        await viewModel.getCourseBlocks(courseID: "123")
        
        Verify(interactor, .getCourseBlocks(courseID: .any))
        XCTAssertFalse(viewModel.isShowProgress)
        XCTAssertNil(viewModel.courseStructure)
        XCTAssertNil(viewModel.courseVideosStructure)
    }
    
    func testGetCourseBlocksNoCacheError() async throws {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        
        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: DownloadManagerMock(),
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        
        Given(interactor, .getCourseBlocks(courseID: "123",
                                           willThrow: NoCachedDataError()))
        
        await viewModel.getCourseBlocks(courseID: "123")
        
        Verify(interactor, .getCourseBlocks(courseID: .any))
        XCTAssertFalse(viewModel.isShowProgress)
        XCTAssertNil(viewModel.courseStructure)
        XCTAssertNil(viewModel.courseVideosStructure)
    }
    
    func testGetCourseBlocksUnknownError() async throws {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        
        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: DownloadManagerMock(), 
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        
        Given(interactor, .getCourseBlocks(courseID: "123",
                                           willThrow: NSError()))
        
        await viewModel.getCourseBlocks(courseID: "123")
        
        Verify(interactor, .getCourseBlocks(courseID: .any))
        XCTAssertFalse(viewModel.isShowProgress)
        XCTAssertNil(viewModel.courseStructure)
        XCTAssertNil(viewModel.courseVideosStructure)
    }
    
    func testTabSelectedAnalytics() {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        
        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: DownloadManagerMock(), 
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        
        viewModel.trackSelectedTab(selection: .course, courseId: "1", courseName: "name")
        Verify(analytics, .courseOutlineCourseTabClicked(courseId: .value("1"), courseName: .value("name")))
        
        viewModel.trackSelectedTab(selection: .videos, courseId: "1", courseName: "name")
        Verify(analytics, .courseOutlineVideosTabClicked(courseId: .value("1"), courseName: .value("name")))
        
        viewModel.trackSelectedTab(selection: .discussion, courseId: "1", courseName: "name")
        Verify(analytics, .courseOutlineDiscussionTabClicked(courseId: .value("1"), courseName: .value("name")))
        
        viewModel.trackSelectedTab(selection: .handounds, courseId: "1", courseName: "name")
        Verify(analytics, .courseOutlineHandoutsTabClicked(courseId: .value("1"), courseName: .value("name")))
    }
    
    func testOnDownloadViewAvailableTap() async throws {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        let downloadManager = DownloadManagerProtocolMock()

        let blockId = "chapter:block:1"

        let block = CourseBlock(
            blockId: blockId,
            id: "1",
            courseId: "123",
            topicId: "",
            graded: false,
            due: Date(),
            completion: 0,
            type: .video,
            displayName: "",
            studentUrl: "",
            webUrl: "",
            encodedVideo: .init(
                fallback: nil,
                youtube: nil,
                desktopMP4: .init(url: "test.mp4", fileSize: 1000, streamPriority: 1, type: .desktopMP4),
                mobileHigh: nil,
                mobileLow: nil,
                hls: nil
            ),
            multiDevice: true,
            offlineDownload: nil
        )

        let vertical = CourseVertical(
            blockId: blockId,
            id: "vertical1",
            courseId: "123",
            displayName: "",
            type: .vertical,
            completion: 0,
            childs: [block],
            webUrl: ""
        )

        let sequential = CourseSequential(
            blockId: blockId,
            id: blockId,
            displayName: "",
            type: .chapter,
            completion: 0,
            childs: [vertical],
            sequentialProgress: nil,
            due: Date()
        )

        let chapter = CourseChapter(
            blockId: blockId,
            id: "1",
            displayName: "Chapter 1",
            type: .chapter,
            childs: [sequential]
        )

        let courseStructure = CourseStructure(
            id: "123",
            graded: true,
            completion: 0,
            viewYouTubeUrl: "",
            encodedVideo: "",
            displayName: "",
            topicID: nil,
            childs: [chapter],
            media: CourseMedia(
                image: CourseImage(
                    raw: "",
                    small: "",
                    large: ""
                )
            ),
            certificate: nil,
            org: "",
            isSelfPaced: true,
            courseProgress: nil
        )

        let downloadData = DownloadDataTask(
            id: "1",
            blockId: "1",
            courseId: "course123",
            userId: 1,
            url: "https://example.com/file.mp4",
            fileName: "file.mp4",
            displayName: "file.mp4",
            progress: 0,
            resumeData: nil,
            state: .inProgress,
            type: .video,
            fileSize: 1000,
            lastModified: ""
        )

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(connectivity, .isMobileData(getter: false))

        Given(downloadManager, .publisher(willReturn: Empty().eraseToAnyPublisher()))
        Given(downloadManager, .eventPublisher(willReturn: Just(.added).eraseToAnyPublisher()))
        Given(downloadManager, .getDownloadTasksForCourse(.any, willReturn: [downloadData]))
        Given(downloadManager, .updateUnzippedFileSize(for: .any, willReturn: [sequential]))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: downloadManager,
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        viewModel.courseStructure = courseStructure
        await viewModel.setDownloadsStates(courseStructure: courseStructure)

        await viewModel.download(
            state: .available,
            blocks: [block],
            sequentials: [sequential]
        )

        await Task.yield()

        XCTAssertEqual(viewModel.sequentialsDownloadState[blockId], .downloading)
    }

    
    func testOnDownloadViewDownloadingTap() async {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        let downloadManager = DownloadManagerProtocolMock()
        
        let blockId = "chapter:block:1"

        let block = CourseBlock(
            blockId: blockId,
            id: "1",
            courseId: "123",
            topicId: "",
            graded: false,
            due: Date(),
            completion: 0,
            type: .video,
            displayName: "",
            studentUrl: "",
            webUrl: "",
            encodedVideo: .init(
                fallback: nil,
                youtube: nil,
                desktopMP4: .init(url: "test.mp4", fileSize: 1000, streamPriority: 1, type: .desktopMP4),
                mobileHigh: nil,
                mobileLow: nil,
                hls: nil
            ),
            multiDevice: true,
            offlineDownload: nil
        )

        let vertical = CourseVertical(
            blockId: blockId,
            id: "vertical1",
            courseId: "123",
            displayName: "",
            type: .vertical,
            completion: 0,
            childs: [block],
            webUrl: ""
        )

        let sequential = CourseSequential(
            blockId: blockId,
            id: blockId,
            displayName: "",
            type: .chapter,
            completion: 0,
            childs: [vertical],
            sequentialProgress: nil,
            due: Date()
        )

        let chapter = CourseChapter(
            blockId: blockId,
            id: "1",
            displayName: "Chapter 1",
            type: .chapter,
            childs: [sequential]
        )

        let courseStructure = CourseStructure(
            id: "123",
            graded: true,
            completion: 0,
            viewYouTubeUrl: "",
            encodedVideo: "",
            displayName: "",
            topicID: nil,
            childs: [chapter],
            media: CourseMedia(
                image: CourseImage(
                    raw: "",
                    small: "",
                    large: ""
                )
            ),
            certificate: nil,
            org: "",
            isSelfPaced: true,
            courseProgress: nil
        )

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(connectivity, .isMobileData(getter: false))

        Given(downloadManager, .publisher(willReturn: Empty().eraseToAnyPublisher()))
        Given(downloadManager, .eventPublisher(willReturn: Just(.added).eraseToAnyPublisher()))
        Given(downloadManager, .getDownloadTasksForCourse(.any, willReturn: []))
        Given(downloadManager, .updateUnzippedFileSize(for: .any, willReturn: []))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: downloadManager,
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        viewModel.courseStructure = courseStructure
        await viewModel.setDownloadsStates(courseStructure: courseStructure)

        await viewModel.download(
            state: .available,
            blocks: [block],
            sequentials: [sequential]
        )

        await Task.yield()

        XCTAssertEqual(viewModel.sequentialsDownloadState[blockId], .available)
    }
    
    func testOnDownloadViewFinishedTap() async throws {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        let downloadManager = DownloadManagerProtocolMock()
        
        let blockId = "chapter:block:1"

        let block = CourseBlock(
            blockId: blockId,
            id: "1",
            courseId: "123",
            topicId: "",
            graded: false,
            due: Date(),
            completion: 0,
            type: .video,
            displayName: "",
            studentUrl: "",
            webUrl: "",
            encodedVideo: .init(
                fallback: nil,
                youtube: nil,
                desktopMP4: .init(url: "test.mp4", fileSize: 1000, streamPriority: 1, type: .desktopMP4),
                mobileHigh: nil,
                mobileLow: nil,
                hls: nil
            ),
            multiDevice: true,
            offlineDownload: nil
        )

        let vertical = CourseVertical(
            blockId: blockId,
            id: "vertical1",
            courseId: "123",
            displayName: "",
            type: .vertical,
            completion: 0,
            childs: [block],
            webUrl: ""
        )

        let sequential = CourseSequential(
            blockId: blockId,
            id: blockId,
            displayName: "",
            type: .chapter,
            completion: 0,
            childs: [vertical],
            sequentialProgress: nil,
            due: Date()
        )

        let chapter = CourseChapter(
            blockId: blockId,
            id: "1",
            displayName: "Chapter 1",
            type: .chapter,
            childs: [sequential]
        )

        let courseStructure = CourseStructure(
            id: "123",
            graded: true,
            completion: 0,
            viewYouTubeUrl: "",
            encodedVideo: "",
            displayName: "",
            topicID: nil,
            childs: [chapter],
            media: CourseMedia(
                image: CourseImage(
                    raw: "",
                    small: "",
                    large: ""
                )
            ),
            certificate: nil,
            org: "",
            isSelfPaced: true,
            courseProgress: nil
        )

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(connectivity, .isMobileData(getter: false))

        Given(downloadManager, .publisher(willReturn: Empty().eraseToAnyPublisher()))
        Given(downloadManager, .eventPublisher(willReturn: Just(.added).eraseToAnyPublisher()))
        Given(downloadManager, .getDownloadTasksForCourse(.any, willReturn: []))
        Given(downloadManager, .updateUnzippedFileSize(for: .any, willReturn: []))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: downloadManager,
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        viewModel.courseStructure = courseStructure
        await viewModel.setDownloadsStates(courseStructure: courseStructure)

        await viewModel.download(
            state: .available,
            blocks: [block],
            sequentials: [sequential]
        )

        await Task.yield()

        XCTAssertEqual(viewModel.sequentialsDownloadState[blockId], .available)

    }
    
    func testSetDownloadsStatesAvailable() async throws {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        let downloadManager = DownloadManagerProtocolMock()
        
        let blockId = "chapter:block:1"

        let block = CourseBlock(
            blockId: blockId,
            id: "1",
            courseId: "123",
            topicId: "",
            graded: false,
            due: Date(),
            completion: 0,
            type: .video,
            displayName: "",
            studentUrl: "",
            webUrl: "",
            encodedVideo: .init(
                fallback: nil,
                youtube: nil,
                desktopMP4: .init(url: "test.mp4", fileSize: 1000, streamPriority: 1, type:.desktopMP4),
                mobileHigh: nil,
                mobileLow: nil,
                hls: nil
            ),
            multiDevice: true,
            offlineDownload: nil
        )

        let vertical = CourseVertical(
            blockId: blockId,
            id: "vertical1",
            courseId: "123",
            displayName: "",
            type: .vertical,
            completion: 0,
            childs: [block],
            webUrl: ""
        )

        let sequential = CourseSequential(
            blockId: blockId,
            id: blockId,
            displayName: "",
            type: .chapter,
            completion: 0,
            childs: [vertical],
            sequentialProgress: nil,
            due: Date()
        )

        let chapter = CourseChapter(
            blockId: blockId,
            id: "1",
            displayName: "Chapter 1",
            type: .chapter,
            childs: [sequential]
        )

        let courseStructure = CourseStructure(
            id: "123",
            graded: true,
            completion: 0,
            viewYouTubeUrl: "",
            encodedVideo: "",
            displayName: "",
            topicID: nil,
            childs: [chapter],
            media: CourseMedia(
                image: CourseImage(
                    raw: "",
                    small: "",
                    large: ""
                )
            ),
            certificate: nil,
            org: "",
            isSelfPaced: true,
            courseProgress: nil
        )

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(connectivity, .isMobileData(getter: false))

        Given(downloadManager, .publisher(willReturn: Empty().eraseToAnyPublisher()))
        Given(downloadManager, .eventPublisher(willReturn: Just(.added).eraseToAnyPublisher()))
        Given(downloadManager, .getDownloadTasksForCourse(.any, willReturn: []))
        Given(downloadManager, .updateUnzippedFileSize(for: .any, willReturn: []))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: downloadManager,
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        viewModel.courseStructure = courseStructure
        await viewModel.setDownloadsStates(courseStructure: courseStructure)

        await Task.yield()

        XCTAssertEqual(viewModel.sequentialsDownloadState[sequential.id], .available)
    }
    
    func testSetDownloadsStatesDownloading() async throws {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        let downloadManager = DownloadManagerProtocolMock()

        let blockId = "chapter:block:1"

        let block = CourseBlock(
            blockId: blockId,
            id: "1",
            courseId: "123",
            topicId: "",
            graded: false,
            due: Date(),
            completion: 0,
            type: .video,
            displayName: "",
            studentUrl: "",
            webUrl: "",
            encodedVideo: .init(
                fallback: nil,
                youtube: nil,
                desktopMP4: .init(url: "test.mp4", fileSize: 1000, streamPriority: 1, type:.desktopMP4),
                mobileHigh: nil,
                mobileLow: nil,
                hls: nil
            ),
            multiDevice: true,
            offlineDownload: nil
        )

        let vertical = CourseVertical(
            blockId: blockId,
            id: "vertical1",
            courseId: "123",
            displayName: "",
            type: .vertical,
            completion: 0,
            childs: [block],
            webUrl: ""
        )

        let sequential = CourseSequential(
            blockId: blockId,
            id: blockId,
            displayName: "",
            type: .chapter,
            completion: 0,
            childs: [vertical],
            sequentialProgress: nil,
            due: Date()
        )

        let chapter = CourseChapter(
            blockId: blockId,
            id: "1",
            displayName: "Chapter 1",
            type: .chapter,
            childs: [sequential]
        )

        let courseStructure = CourseStructure(
            id: "123",
            graded: true,
            completion: 0,
            viewYouTubeUrl: "",
            encodedVideo: "",
            displayName: "",
            topicID: nil,
            childs: [chapter],
            media: CourseMedia(image: CourseImage(raw: "",
                                                  small: "",
                                                  large: "")),
            certificate: nil,
            org: "",
            isSelfPaced: true,
            courseProgress: nil
        )

        let downloadData = DownloadDataTask(
            id: "1",
            blockId: "1",
            courseId: "course123",
            userId: 1,
            url: "https://example.com/file.mp4",
            fileName: "file.mp4",
            displayName: "file.mp4",
            progress: 0,
            resumeData: nil,
            state: .inProgress,
            type: .video,
            fileSize: 1000,
            lastModified: ""
        )

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(connectivity, .isMobileData(getter: false))

        Given(downloadManager, .publisher(willReturn: Empty().eraseToAnyPublisher()))
        Given(downloadManager, .eventPublisher(willReturn: Just(.added).eraseToAnyPublisher()))
        Given(downloadManager, .getDownloadTasksForCourse(.any, willReturn: [downloadData]))
        Given(downloadManager, .updateUnzippedFileSize(for: .any, willReturn: [sequential]))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: downloadManager,
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        viewModel.courseStructure = courseStructure
        await viewModel.setDownloadsStates(courseStructure: courseStructure)

        await Task.yield()

        XCTAssertEqual(viewModel.sequentialsDownloadState[sequential.id], .downloading)
    }
    
    func testSetDownloadsStatesFinished() async throws {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        let downloadManager = DownloadManagerProtocolMock()

        let blockId = "chapter:block:1"

        let block = CourseBlock(
            blockId: blockId,
            id: "1",
            courseId: "123",
            topicId: "",
            graded: false,
            due: Date(),
            completion: 0,
            type: .video,
            displayName: "",
            studentUrl: "",
            webUrl: "",
            encodedVideo: .init(
                fallback: nil,
                youtube: nil,
                desktopMP4: .init(url: "test.mp4", fileSize: 1000, streamPriority: 1, type:.desktopMP4),
                mobileHigh: nil,
                mobileLow: nil,
                hls: nil
            ),
            multiDevice: true,
            offlineDownload: nil
        )

        let vertical = CourseVertical(
            blockId: blockId,
            id: "vertical1",
            courseId: "123",
            displayName: "",
            type: .vertical,
            completion: 0,
            childs: [block],
            webUrl: ""
        )

        let sequential = CourseSequential(
            blockId: blockId,
            id: blockId,
            displayName: "",
            type: .chapter,
            completion: 0,
            childs: [vertical],
            sequentialProgress: nil,
            due: Date()
        )

        let chapter = CourseChapter(
            blockId: blockId,
            id: "1",
            displayName: "Chapter 1",
            type: .chapter,
            childs: [sequential]
        )

        let courseStructure = CourseStructure(
            id: "123",
            graded: true,
            completion: 0,
            viewYouTubeUrl: "",
            encodedVideo: "",
            displayName: "",
            topicID: nil,
            childs: [chapter],
            media: CourseMedia(image: CourseImage(raw: "",
                                                  small: "",
                                                  large: "")),
            certificate: nil,
            org: "",
            isSelfPaced: true,
            courseProgress: nil
        )

        let downloadData = DownloadDataTask(
            id: "1",
            blockId: "1",
            courseId: "course123",
            userId: 1,
            url: "https://example.com/file.mp4",
            fileName: "file.mp4",
            displayName: "file.mp4",
            progress: 0,
            resumeData: nil,
            state: .finished,
            type: .video,
            fileSize: 1000,
            lastModified: ""
        )

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(connectivity, .isMobileData(getter: false))

        Given(downloadManager, .publisher(willReturn: Empty().eraseToAnyPublisher()))
        Given(downloadManager, .eventPublisher(willReturn: Just(.added).eraseToAnyPublisher()))
        Given(downloadManager, .getDownloadTasksForCourse(.any, willReturn: [downloadData]))
        Given(downloadManager, .updateUnzippedFileSize(for: .any, willReturn: [sequential]))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: downloadManager,
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        viewModel.courseStructure = courseStructure
        await viewModel.setDownloadsStates(courseStructure: courseStructure)

        await Task.yield()
        
        XCTAssertEqual(viewModel.sequentialsDownloadState[sequential.id], .finished)
    }
    
    func testSetDownloadsStatesPartiallyFinished() async throws {
        let interactor = CourseInteractorProtocolMock()
        let authInteractor = AuthInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let config = ConfigMock()
        let connectivity = ConnectivityProtocolMock()
        let downloadManager = DownloadManagerProtocolMock()

        let blockId = "chapter:block:1"

        let block = CourseBlock(
            blockId: blockId,
            id: "1",
            courseId: "123",
            topicId: "",
            graded: false,
            due: Date(),
            completion: 0,
            type: .video,
            displayName: "",
            studentUrl: "",
            webUrl: "",
            encodedVideo: .init(
                fallback: nil,
                youtube: nil,
                desktopMP4: .init(url: "test.mp4", fileSize: 1000, streamPriority: 1, type:.desktopMP4),
                mobileHigh: nil,
                mobileLow: nil,
                hls: nil
            ),
            multiDevice: true,
            offlineDownload: nil
        )
        let block2 = CourseBlock(
            blockId: "123",
            id: "1213",
            courseId: "123",
            topicId: "",
            graded: false,
            due: Date(),
            completion: 0,
            type: .video,
            displayName: "",
            studentUrl: "",
            webUrl: "",
            encodedVideo: .init(
                fallback: nil,
                youtube: nil,
                desktopMP4: .init(url: "test.mp4", fileSize: 1000, streamPriority: 1, type:.desktopMP4),
                mobileHigh: nil,
                mobileLow: nil,
                hls: nil
            ),
            multiDevice: true,
            offlineDownload: nil
        )

        let vertical = CourseVertical(
            blockId: blockId,
            id: "vertical1",
            courseId: "123",
            displayName: "",
            type: .vertical,
            completion: 0,
            childs: [block, block2],
            webUrl: ""
        )

        let sequential = CourseSequential(
            blockId: blockId,
            id: blockId,
            displayName: "",
            type: .chapter,
            completion: 0,
            childs: [vertical],
            sequentialProgress: nil,
            due: Date()
        )

        let chapter = CourseChapter(
            blockId: blockId,
            id: "1",
            displayName: "Chapter 1",
            type: .chapter,
            childs: [sequential]
        )

        let courseStructure = CourseStructure(
            id: "123",
            graded: true,
            completion: 0,
            viewYouTubeUrl: "",
            encodedVideo: "",
            displayName: "",
            topicID: nil,
            childs: [chapter],
            media: CourseMedia(
                image: CourseImage(
                    raw: "",
                    small: "",
                    large: ""
                )
            ),
            certificate: nil,
            org: "",
            isSelfPaced: true,
            courseProgress: nil
        )

        let downloadData = DownloadDataTask(
            id: "1",
            blockId: "1",
            courseId: "course123",
            userId: 1,
            url: "https://example.com/file.mp4",
            fileName: "file.mp4",
            displayName: "file.mp4",
            progress: 0,
            resumeData: nil,
            state: .finished,
            type: .video,
            fileSize: 1000,
            lastModified: ""
        )

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(connectivity, .isMobileData(getter: false))

        Given(downloadManager, .publisher(willReturn: Empty().eraseToAnyPublisher()))
        Given(downloadManager, .eventPublisher(willReturn: Just(.added).eraseToAnyPublisher()))
        Given(downloadManager, .getDownloadTasksForCourse(.any, willReturn: [downloadData]))
        Given(downloadManager, .updateUnzippedFileSize(for: .any, willReturn: [sequential]))

        let viewModel = CourseContainerViewModel(
            interactor: interactor,
            authInteractor: authInteractor,
            router: router,
            analytics: analytics,
            config: config,
            connectivity: connectivity,
            manager: downloadManager,
            storage: CourseStorageMock(),
            isActive: true,
            courseStart: Date(),
            courseEnd: nil,
            enrollmentStart: nil,
            enrollmentEnd: nil,
            lastVisitedBlockID: nil,
            coreAnalytics: CoreAnalyticsMock()
        )
        viewModel.courseStructure = courseStructure
        await viewModel.setDownloadsStates(courseStructure: courseStructure)

        await Task.yield()

        XCTAssertEqual(viewModel.sequentialsDownloadState[sequential.id], .available)
    }
}
