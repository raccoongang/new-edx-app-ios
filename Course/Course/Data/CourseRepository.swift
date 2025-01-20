//
//  CourseRepository.swift
//  Course
//
//  Created by  Stepanok Ivan on 26.09.2022.
//

import Foundation
import Core
import OEXFoundation

public protocol CourseRepositoryProtocol: Sendable {
    func getCourseBlocks(courseID: String) async throws -> CourseStructure
    func getLoadedCourseBlocks(courseID: String) async throws -> CourseStructure
    func blockCompletionRequest(courseID: String, blockID: String) async throws
    func getHandouts(courseID: String) async throws -> String?
    func getUpdates(courseID: String) async throws -> [CourseUpdate]
    func resumeBlock(courseID: String) async throws -> ResumeBlock
    func getSubtitles(url: String, selectedLanguage: String) async throws -> String
    func getCourseDates(courseID: String) async throws -> CourseDates
    func getCourseDatesOffline(courseID: String) async throws -> CourseDates
    func getCourseDeadlineInfo(courseID: String) async throws -> CourseDateBanner
    func shiftDueDates(courseID: String) async throws
}

public actor CourseRepository: CourseRepositoryProtocol {
    
    private let api: API
    private let coreStorage: CoreStorage
    private let config: ConfigProtocol
    private let persistence: CoursePersistenceProtocol
    
    public init(
        api: API,
        coreStorage: CoreStorage,
        config: ConfigProtocol,
        persistence: CoursePersistenceProtocol
    ) {
        self.api = api
        self.coreStorage = coreStorage
        self.config = config
        self.persistence = persistence
    }
    
    public func getCourseBlocks(courseID: String) async throws -> CourseStructure {
        let course = try await api.requestData(
            CourseEndpoint.getCourseBlocks(courseID: courseID, userName: coreStorage.user?.username ?? "")
        ).mapResponse(DataLayer.CourseStructure.self)
        await persistence.saveCourseStructure(structure: course)
        let parsedStructure = parseCourseStructure(course: course)
        return parsedStructure
    }
    
    public func getLoadedCourseBlocks(courseID: String) async throws -> CourseStructure {
        let localData = try await persistence.loadCourseStructure(courseID: courseID)
        return parseCourseStructure(course: localData)
    }
    
    public func blockCompletionRequest(courseID: String, blockID: String) async throws {
        try await api.requestData(CourseEndpoint.blockCompletionRequest(
            username: coreStorage.user?.username ?? "",
            courseID: courseID,
            blockID: blockID)
        )
    }
    
    public func shiftDueDates(courseID: String) async throws {
        try await api.requestData(CourseEndpoint.courseDatesReset(courseID: courseID))
    }
    
    public func getHandouts(courseID: String) async throws -> String? {
        return try await api.requestData(CourseEndpoint.getHandouts(courseID: courseID))
            .mapResponse(DataLayer.HandoutsResponse.self)
            .handoutsHtml
    }
    
    public func getUpdates(courseID: String) async throws -> [CourseUpdate] {
        return try await api.requestData(CourseEndpoint.getUpdates(courseID: courseID))
            .mapResponse(DataLayer.CourseUpdates.self).map { $0.domain }
    }
    
    public func resumeBlock(courseID: String) async throws -> ResumeBlock {
        return try await api.requestData(CourseEndpoint
            .resumeBlock(userName: coreStorage.user?.username ?? "", courseID: courseID))
        .mapResponse(DataLayer.ResumeBlock.self).domain
    }
    
    public func getSubtitles(url: String, selectedLanguage: String) async throws -> String {
        if let subtitlesOffline = await persistence.loadSubtitles(url: url + selectedLanguage) {
            return subtitlesOffline
        } else {
            let result = try await api.requestData(CourseEndpoint.getSubtitles(
                url: url,
                selectedLanguage: selectedLanguage
            ))
            let subtitles = String(data: result, encoding: .utf8) ?? ""
            await persistence.saveSubtitles(url: url + selectedLanguage, subtitlesString: subtitles)
            return subtitles
        }
    }
    
    public func getCourseDates(courseID: String) async throws -> CourseDates {
        let courseDates = try await api.requestData(
            CourseEndpoint.getCourseDates(courseID: courseID)
        ).mapResponse(DataLayer.CourseDates.self).domain(useRelativeDates: coreStorage.useRelativeDates)
        await persistence.saveCourseDates(courseID: courseID, courseDates: courseDates)
        return courseDates
    }
    
    public func getCourseDeadlineInfo(courseID: String) async throws -> CourseDateBanner {
        let courseDateBanner = try await api.requestData(
            CourseEndpoint.getCourseDeadlineInfo(courseID: courseID)
        ).mapResponse(DataLayer.CourseDateBanner.self).domain
        return courseDateBanner
    }
    
    public func getCourseDatesOffline(courseID: String) async throws -> CourseDates {
        return try await persistence.loadCourseDates(courseID: courseID)
    }
    
    private func parseCourseStructure(course: DataLayer.CourseStructure) -> CourseStructure {
        let blocks = Array(course.dict.values)
        let courseBlock = blocks.first(where: {$0.type == BlockType.course.rawValue })!
        let descendants = courseBlock.descendants ?? []
        var childs: [CourseChapter] = []
        for descend in descendants {
            let chapter = parseChapters(id: descend, courseId: course.id, blocks: blocks)
            childs.append(chapter)
        }
        
        return CourseStructure(
            id: course.id,
            graded: courseBlock.graded,
            completion: courseBlock.completion ?? 0,
            viewYouTubeUrl: courseBlock.userViewData?.encodedVideo?.youTube?.url ?? "",
            encodedVideo: courseBlock.userViewData?.encodedVideo?.fallback?.url ?? "",
            displayName: courseBlock.displayName,
            topicID: courseBlock.userViewData?.topicID,
            childs: childs,
            media: course.media.domain,
            certificate: course.certificate?.domain,
            org: course.org ?? "",
            isSelfPaced: course.isSelfPaced,
            courseProgress: course.courseProgress == nil ? nil : CourseProgress(
                totalAssignmentsCount: course.courseProgress?.totalAssignmentsCount ?? 0,
                assignmentsCompleted: course.courseProgress?.assignmentsCompleted ?? 0
            )
        )
    }
    
    private func parseChapters(id: String, courseId: String, blocks: [DataLayer.CourseBlock]) -> CourseChapter {
        let chapter = blocks.first(where: {$0.id == id })!
        let descendants = chapter.descendants ?? []
        var childs: [CourseSequential] = []
        for descend in descendants {
            let chapter = parseSequential(id: descend, courseId: courseId, blocks: blocks)
            childs.append(chapter)
        }
        return CourseChapter(blockId: chapter.blockId,
                             id: chapter.id,
                             displayName: chapter.displayName,
                             type: BlockType(rawValue: chapter.type) ?? .unknown,
                             childs: childs)
        
    }
    
    private func parseSequential(id: String, courseId: String, blocks: [DataLayer.CourseBlock]) -> CourseSequential {
        let sequential = blocks.first(where: {$0.id == id })!
        let descendants = sequential.descendants ?? []
        var childs: [CourseVertical] = []
        for descend in descendants {
            let vertical = parseVerticals(id: descend, courseId: courseId, blocks: blocks)
            childs.append(vertical)
        }
        return CourseSequential(
            blockId: sequential.blockId,
            id: sequential.id,
            displayName: sequential.displayName,
            type: BlockType(rawValue: sequential.type) ?? .unknown,
            completion: sequential.completion ?? 0,
            childs: childs,
            sequentialProgress: SequentialProgress(
                assignmentType: sequential.assignmentProgress?.assignmentType,
                numPointsEarned: Int(sequential.assignmentProgress?.numPointsEarned ?? 0),
                numPointsPossible: Int(sequential.assignmentProgress?.numPointsPossible ?? 0)
            ),
            due: sequential.due == nil ? nil : Date(iso8601: sequential.due!)
        )
    }
    
    private func parseVerticals(id: String, courseId: String, blocks: [DataLayer.CourseBlock]) -> CourseVertical {
        let sequential = blocks.first(where: {$0.id == id })!
        let descendants = sequential.descendants ?? []
        var childs: [CourseBlock] = []
        for descend in descendants {
            let block = parseBlock(id: descend, courseId: courseId, blocks: blocks)
            childs.append(block)
        }
        return CourseVertical(
            blockId: sequential.blockId,
            id: sequential.id,
            courseId: courseId,
            displayName: sequential.displayName,
            type: BlockType(rawValue: sequential.type) ?? .unknown,
            completion: sequential.completion ?? 0,
            childs: childs,
            webUrl: sequential.webUrl
        )
    }
    
    private func parseBlock(id: String, courseId: String, blocks: [DataLayer.CourseBlock]) -> CourseBlock {
        let block = blocks.first(where: {$0.id == id })!
        let subtitles = block.userViewData?.transcripts?.map {
            let url = $0.value
                .replacingOccurrences(of: config.baseURL.absoluteString, with: "")
                .replacingOccurrences(of: "?lang=\($0.key)", with: "")
            return SubtitleUrl(language: $0.key, url: url)
        }
        
        var offlineDownload: OfflineDownload?
        
        if let offlineData = block.offlineDownload,
           let fileUrl = offlineData.fileUrl,
           let lastModified = offlineData.lastModified,
           let fileSize = offlineData.fileSize {
            let fullUrl = fileUrl.starts(with: "http") ? fileUrl : config.baseURL.absoluteString + fileUrl
            offlineDownload = OfflineDownload(
                fileUrl: fullUrl,
                lastModified: lastModified,
                fileSize: fileSize
            )
        }
            
        return CourseBlock(
            blockId: block.blockId,
            id: block.id,
            courseId: courseId,
            topicId: block.userViewData?.topicID,
            graded: block.graded,
            due: block.due == nil ? nil : Date(iso8601: block.due!),
            completion: block.completion ?? 0,
            type: BlockType(rawValue: block.type) ?? .unknown,
            displayName: block.displayName,
            studentUrl: block.studentUrl,
            webUrl: block.webUrl,
            subtitles: subtitles,
            encodedVideo: .init(
                fallback: parseVideo(
                    encodedVideo: block.userViewData?.encodedVideo?.fallback,
                    type: .fallback
                ),
                youtube: parseVideo(
                    encodedVideo: block.userViewData?.encodedVideo?.youTube,
                    type: .youtube
                ),
                desktopMP4: parseVideo(
                    encodedVideo: block.userViewData?.encodedVideo?.desktopMP4,
                    type: .desktopMP4
                ),
                mobileHigh: parseVideo(
                    encodedVideo: block.userViewData?.encodedVideo?.mobileHigh,
                    type: .mobileHigh
                ),
                mobileLow: parseVideo(
                    encodedVideo: block.userViewData?.encodedVideo?.mobileLow,
                    type: .mobileLow
                ),
                hls: parseVideo(
                    encodedVideo: block.userViewData?.encodedVideo?.hls,
                    type: .hls
                )
            ),
            multiDevice: block.multiDevice,
            offlineDownload: offlineDownload
        )
    }
    
    private func parseVideo(
        encodedVideo: DataLayer.EncodedVideoData?,
        type: CourseBlockVideoEncoding
    ) -> CourseBlockVideo? {
        guard let encodedVideo, encodedVideo.url?.isEmpty == false else {
            return nil
        }
        return .init(
            url: encodedVideo.url,
            fileSize: encodedVideo.fileSize,
            streamPriority: encodedVideo.streamPriority,
            type: type
        )
    }
}

// Mark - For testing and SwiftUI preview
// swiftlint:disable all
#if DEBUG
@MainActor
class CourseRepositoryMock: CourseRepositoryProtocol {
    func getCourseDatesOffline(courseID: String) async throws -> CourseDates {
        throw NoCachedDataError()
    }
    
    func resumeBlock(courseID: String) async throws -> ResumeBlock {
        ResumeBlock(blockID: "123")
    }
    
    func getHandouts(courseID: String) async throws -> String? {
        return "Test Handouts"
    }
    
    func getUpdates(courseID: String) async throws -> [CourseUpdate] {
        return [CourseUpdate(id: 1, date: "Date", content: "content", status: "status")]
    }
    
    func getCourseDates(courseID: String) async throws -> CourseDates {
        do {
            let courseDates = try
            CourseRepository.courseDatesJSON.data(using: .utf8)!.mapResponse(DataLayer.CourseDates.self)
            return courseDates.domain(useRelativeDates: true)
        } catch {
            throw error
        }
    }
    
    func getCourseDeadlineInfo(courseID: String) async throws -> CourseDateBanner {
        let courseDates = try
        await getCourseDates(courseID: courseID)
        return CourseDateBanner(
            datesBannerInfo: courseDates.datesBannerInfo,
            hasEnded: courseDates.hasEnded
        )
    }
    
    func getLoadedCourseBlocks(courseID: String) throws -> CourseStructure {
        let decoder = JSONDecoder()
        let jsonData = Data(CourseRepository.courseStructureJson.utf8)
        let courseBlocks = try decoder.decode(DataLayer.CourseStructure.self, from: jsonData)
        return parseCourseStructure(course: courseBlocks)
    }
        
    public  func getCourseBlocks(courseID: String) async throws -> CourseStructure {
        do {
            let courseBlocks = try
            CourseRepository.courseStructureJson.data(using: .utf8)!.mapResponse(DataLayer.CourseStructure.self)
            return parseCourseStructure(course: courseBlocks)
        } catch {
            throw error
        }
    }
    
    public  func blockCompletionRequest(courseID: String, blockID: String) {
        
    }
    
    func shiftDueDates(courseID: String) async throws {
        
    }
    
    public func getSubtitles(url: String, selectedLanguage: String) async throws -> String {
        return """
0
00:00:00,350 --> 00:00:05,230
GREGORY NAGY: In hour zero, where I try to introduce Homeric poetry to
1
00:00:05,230 --> 00:00:11,060
people who may never have been exposed to the Iliad and the Odyssey even in
2
00:00:11,060 --> 00:00:20,290
translation, my idea was to get a sense of the medium, which is not a
3
00:00:20,290 --> 00:00:25,690
readable medium because Homeric poetry, in its historical context, was
4
00:00:25,690 --> 00:00:30,210
meant to be heard, not read.
5
00:00:30,210 --> 00:00:34,760
And there are various ways of describing it-- call it oral poetry or
"""
    }
    
    private func parseCourseStructure(course: DataLayer.CourseStructure) -> CourseStructure {
        let blocks = Array(course.dict.values)
        let courseBlock = blocks.first(where: {$0.type == BlockType.course.rawValue })!
        let descendants = courseBlock.descendants ?? []
        var childs: [CourseChapter] = []
        for descend in descendants {
            let chapter = parseChapters(id: descend, courseId: course.id, blocks: blocks)
            childs.append(chapter)
        }
        
        return CourseStructure(
            id: course.id,
            graded: courseBlock.graded,
            completion: courseBlock.completion ?? 0,
            viewYouTubeUrl: courseBlock.userViewData?.encodedVideo?.youTube?.url ?? "",
            encodedVideo: courseBlock.userViewData?.encodedVideo?.fallback?.url ?? "",
            displayName: courseBlock.displayName,
            topicID: courseBlock.userViewData?.topicID,
            childs: childs,
            media: course.media.domain,
            certificate: course.certificate?.domain,
            org: course.org ?? "",
            isSelfPaced: course.isSelfPaced, 
            courseProgress: course.courseProgress == nil ? nil : CourseProgress(
                totalAssignmentsCount: course.courseProgress?.totalAssignmentsCount ?? 0,
                assignmentsCompleted: course.courseProgress?.assignmentsCompleted ?? 0
            )
        )
    }
    
    private func parseChapters(id: String, courseId: String, blocks: [DataLayer.CourseBlock]) -> CourseChapter {
        let chapter = blocks.first(where: {$0.id == id })!
        let descendants = chapter.descendants ?? []
        var childs: [CourseSequential] = []
        for descend in descendants {
            let chapter = parseSequential(id: descend, courseId: courseId, blocks: blocks)
            childs.append(chapter)
        }
        return CourseChapter(
            blockId: chapter.blockId,
            id: chapter.id,
            displayName: chapter.displayName,
            type: BlockType(rawValue: chapter.type) ?? .unknown,
            childs: childs
        )
    }
    
    private func parseSequential(id: String, courseId: String, blocks: [DataLayer.CourseBlock]) -> CourseSequential {
        let sequential = blocks.first(where: {$0.id == id })!
        let descendants = sequential.descendants ?? []
        var childs: [CourseVertical] = []
        for descend in descendants {
            let vertical = parseVerticals(id: descend, courseId: courseId, blocks: blocks)
            childs.append(vertical)
        }
        return CourseSequential(
            blockId: sequential.blockId,
            id: sequential.id,
            displayName: sequential.displayName,
            type: BlockType(rawValue: sequential.type) ?? .unknown,
            completion: sequential.completion ?? 0,
            childs: childs, 
            sequentialProgress: SequentialProgress(
                assignmentType: sequential.assignmentProgress?.assignmentType,
                numPointsEarned: Int(sequential.assignmentProgress?.numPointsEarned ?? 0),
                numPointsPossible: Int(sequential.assignmentProgress?.numPointsPossible ?? 0)
            ),
            due: sequential.due == nil ? nil : Date(iso8601: sequential.due!)
        )
    }
    
    private func parseVerticals(id: String, courseId: String, blocks: [DataLayer.CourseBlock]) -> CourseVertical {
        let sequential = blocks.first(where: {$0.id == id })!
        let descendants = sequential.descendants ?? []
        var childs: [CourseBlock] = []
        for descend in descendants {
            let block = parseBlock(id: descend, courseId: courseId, blocks: blocks)
            childs.append(block)
        }
        return CourseVertical(
            blockId: sequential.blockId,
            id: sequential.id,
            courseId: courseId,
            displayName: sequential.displayName,
            type: BlockType(rawValue: sequential.type) ?? .unknown,
            completion: sequential.completion ?? 0,
            childs: childs,
            webUrl: sequential.webUrl
        )
    }
    
    private func parseBlock(id: String, courseId: String, blocks: [DataLayer.CourseBlock]) -> CourseBlock {
        let block = blocks.first(where: {$0.id == id })!
        let subtitles = block.userViewData?.transcripts?.map {
            let url = $0.value
            return SubtitleUrl(language: $0.key, url: url)
        }
        
        var offlineDownload: OfflineDownload?
        
        if let offlineData = block.offlineDownload,
           let fileUrl = offlineData.fileUrl,
           let lastModified = offlineData.lastModified,
           let fileSize = offlineData.fileSize {
            offlineDownload = OfflineDownload(
                fileUrl: fileUrl,
                lastModified: lastModified,
                fileSize: fileSize
            )
        }
            
        return CourseBlock(
            blockId: block.blockId,
            id: block.id,
            courseId: courseId,
            topicId: block.userViewData?.topicID,
            graded: block.graded,
            due: block.due == nil ? nil : Date(iso8601: block.due!),
            completion: block.completion ?? 0,
            type: BlockType(rawValue: block.type) ?? .unknown,
            displayName: block.displayName,
            studentUrl: block.studentUrl,
            webUrl: block.webUrl,
            subtitles: subtitles,
            encodedVideo: .init(
                fallback: parseVideo(
                    encodedVideo: block.userViewData?.encodedVideo?.fallback,
                    type: .fallback
                ),
                youtube: parseVideo(
                    encodedVideo: block.userViewData?.encodedVideo?.youTube,
                    type: .youtube
                ),
                desktopMP4: parseVideo(
                    encodedVideo: block.userViewData?.encodedVideo?.desktopMP4,
                    type: .desktopMP4
                ),
                mobileHigh: parseVideo(
                    encodedVideo: block.userViewData?.encodedVideo?.mobileHigh,
                    type: .mobileHigh
                ),
                mobileLow: parseVideo(
                    encodedVideo: block.userViewData?.encodedVideo?.mobileLow, type: .mobileLow),
                hls: parseVideo(
                    encodedVideo: block.userViewData?.encodedVideo?.hls,
                    type: .hls
                )
            ),
            multiDevice: block.multiDevice, 
            offlineDownload: offlineDownload
        )
    }

    private func parseVideo(
        encodedVideo: DataLayer.EncodedVideoData?,
        type: CourseBlockVideoEncoding
    ) -> CourseBlockVideo? {
        guard let encodedVideo else {
            return nil
        }
        return .init(
            url: encodedVideo.url,
            fileSize: encodedVideo.fileSize,
            streamPriority: encodedVideo.streamPriority,
            type: type
        )
    }
}
#endif
// swiftlint:enable all
