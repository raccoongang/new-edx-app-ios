//
//  CourseBlockModel.swift
//  Core
//
//  Created by  Stepanok Ivan on 14.03.2023.
//

import Foundation

public struct CourseStructure: Equatable, Sendable {
    public static func == (lhs: CourseStructure, rhs: CourseStructure) -> Bool {
        return lhs.id == rhs.id
    }

    public let id: String
    public let graded: Bool
    public let completion: Double
    public let viewYouTubeUrl: String
    public let encodedVideo: String
    public let displayName: String
    public let topicID: String?
    public var childs: [CourseChapter]
    public let media: CourseMedia
    public let certificate: Certificate?
    public let org: String
    public let isSelfPaced: Bool
    public let courseProgress: CourseProgress?
    
    public init(
        id: String,
        graded: Bool,
        completion: Double,
        viewYouTubeUrl: String,
        encodedVideo: String,
        displayName: String,
        topicID: String? = nil,
        childs: [CourseChapter],
        media: CourseMedia,
        certificate: Certificate?,
        org: String,
        isSelfPaced: Bool,
        courseProgress: CourseProgress?
    ) {
        self.id = id
        self.graded = graded
        self.completion = completion
        self.viewYouTubeUrl = viewYouTubeUrl
        self.encodedVideo = encodedVideo
        self.displayName = displayName
        self.topicID = topicID
        self.childs = childs
        self.media = media
        self.certificate = certificate
        self.org = org
        self.isSelfPaced = isSelfPaced
        self.courseProgress = courseProgress
    }

    public func totalVideosSizeInBytes(downloadQuality: DownloadQuality) -> Int {
        childs.flatMap {
            $0.childs.flatMap { $0.childs.flatMap { $0.childs.compactMap { $0 } } }
        }
        .filter { $0.isDownloadable }
        .compactMap { $0.encodedVideo?.video(downloadQuality: downloadQuality)?.fileSize }
        .reduce(.zero) { $0 + $1 }
    }

    public func totalVideosSizeInMb(downloadQuality: DownloadQuality) -> Double {
        Double(totalVideosSizeInBytes(downloadQuality: downloadQuality)) / 1024.0 / 1024.0
    }

    public func totalVideosSizeInGb(downloadQuality: DownloadQuality) -> Double {
        Double(totalVideosSizeInBytes(downloadQuality: downloadQuality)) / 1024.0 / 1024.0 / 1024.0
    }
    
    public func blockWithID(courseBlockId: String) -> CourseBlock? {
        let block = childs.flatMap {
            $0.childs.flatMap { $0.childs.flatMap { $0.childs.compactMap { $0 } } }
        }.filter { $0.id == courseBlockId }.first
        return block
    }
}

public struct CourseMedia: Decodable, Sendable, Equatable {
    public let image: CourseImage
    
    public init(image: CourseImage) {
        self.image = image
    }
}

public struct CourseImage: Decodable, Sendable, Equatable {
    public let raw: String
    public let small: String
    public let large: String
    
    public init(raw: String, small: String, large: String) {
        self.raw = raw
        self.small = small
        self.large = large
    }
}

public struct CourseProgress: Sendable {
    public let totalAssignmentsCount: Int?
    public let assignmentsCompleted: Int?
    
    public init(totalAssignmentsCount: Int, assignmentsCompleted: Int) {
        self.totalAssignmentsCount = totalAssignmentsCount
        self.assignmentsCompleted = assignmentsCompleted
    }
}

public struct CourseChapter: Identifiable, Sendable, Equatable {
    public static func == (lhs: CourseChapter, rhs: CourseChapter) -> Bool {
        lhs.id == rhs.id &&
        lhs.blockId == rhs.blockId
    }

    public let blockId: String
    public let id: String
    public let displayName: String
    public let type: BlockType
    public var childs: [CourseSequential]
    
    public init(
        blockId: String,
        id: String,
        displayName: String,
        type: BlockType,
        childs: [CourseSequential]
    ) {
        self.blockId = blockId
        self.id = id
        self.displayName = displayName
        self.type = type
        self.childs = childs
    }
}

public struct CourseSequential: Identifiable, Sendable, Equatable {
    public static func == (lhs: CourseSequential, rhs: CourseSequential) -> Bool {
        lhs.id == rhs.id &&
        lhs.blockId == rhs.blockId
    }

    public let blockId: String
    public let id: String
    public let displayName: String
    public let type: BlockType
    public let completion: Double
    public var childs: [CourseVertical]
    public let sequentialProgress: SequentialProgress?
    public let due: Date?

    public var isDownloadable: Bool {
        return childs.first(where: { $0.isDownloadable }) != nil
    }
    
    public var totalSize: Int {
        childs.flatMap { $0.childs.filter({ $0.isDownloadable }) }.reduce(0) { $0 + ($1.fileSize ?? 0) }
    }
    
    public init(
        blockId: String,
        id: String,
        displayName: String,
        type: BlockType,
        completion: Double,
        childs: [CourseVertical],
        sequentialProgress: SequentialProgress?,
        due: Date?
    ) {
        self.blockId = blockId
        self.id = id
        self.displayName = displayName
        self.type = type
        self.completion = completion
        self.childs = childs
        self.sequentialProgress = sequentialProgress
        self.due = due
    }
}

public struct CourseVertical: Identifiable, Hashable, Sendable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public let blockId: String
    public let id: String
    public let courseId: String
    public let displayName: String
    public let type: BlockType
    public let completion: Double
    public var childs: [CourseBlock]
    public var webUrl: String
    
    public var isDownloadable: Bool {
        return childs.first(where: { $0.isDownloadable }) != nil
    }

    public init(
        blockId: String,
        id: String,
        courseId: String,
        displayName: String,
        type: BlockType,
        completion: Double,
        childs: [CourseBlock],
        webUrl: String
    ) {
        self.blockId = blockId
        self.id = id
        self.courseId = courseId
        self.displayName = displayName
        self.type = type
        self.completion = completion
        self.childs = childs
        self.webUrl = webUrl
    }
}

public struct SubtitleUrl: Equatable, Sendable {
    public let language: String
    public let url: String
    
    public init(language: String, url: String) {
        self.language = language
        self.url = url
    }
}

public struct SequentialProgress: Sendable {
    public let assignmentType: String?
    public let numPointsEarned: Int?
    public let numPointsPossible: Int?
    
    public init(assignmentType: String?, numPointsEarned: Int?, numPointsPossible: Int?) {
        self.assignmentType = assignmentType
        self.numPointsEarned = numPointsEarned
        self.numPointsPossible = numPointsPossible
    }
}

public struct CourseBlock: Hashable, Identifiable, Sendable, Equatable {
    public static func == (lhs: CourseBlock, rhs: CourseBlock) -> Bool {
        lhs.id == rhs.id &&
        lhs.blockId == rhs.blockId &&
        lhs.completion == rhs.completion
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public let blockId: String
    public let id: String
    public let courseId: String
    public let topicId: String?
    public let graded: Bool
    public let due: Date?
    public var completion: Double
    public let type: BlockType
    public let displayName: String
    public let studentUrl: String
    public let webUrl: String
    public let subtitles: [SubtitleUrl]?
    public let encodedVideo: CourseBlockEncodedVideo?
    public let multiDevice: Bool?
    public var offlineDownload: OfflineDownload?
    public var actualFileSize: Int?

    public var isDownloadable: Bool {
        encodedVideo?.isDownloadable ?? false || offlineDownload?.isDownloadable ?? false
    }
    
    public var fileSize: Int? {
        if let actualFileSize {
            return actualFileSize
        } else if let fileSize = encodedVideo?.desktopMP4?.fileSize {
            return fileSize
        } else if let fileSize = encodedVideo?.fallback?.fileSize {
            return fileSize
        } else if let fileSize = encodedVideo?.hls?.fileSize {
            return fileSize
        } else if let fileSize = encodedVideo?.mobileHigh?.fileSize {
            return fileSize
        } else if let fileSize = encodedVideo?.mobileLow?.fileSize {
            return fileSize
        } else if let fileSize = offlineDownload?.fileSize {
            return fileSize
        } else {
            return nil
        }
    }

    public init(
        blockId: String,
        id: String,
        courseId: String,
        topicId: String? = nil,
        graded: Bool,
        due: Date?,
        completion: Double,
        type: BlockType,
        displayName: String,
        studentUrl: String,
        webUrl: String,
        subtitles: [SubtitleUrl]? = nil,
        encodedVideo: CourseBlockEncodedVideo?,
        multiDevice: Bool?,
        offlineDownload: OfflineDownload?
    ) {
        self.blockId = blockId
        self.id = id
        self.courseId = courseId
        self.topicId = topicId
        self.graded = graded
        self.due = due
        self.completion = completion
        self.type = type
        self.displayName = displayName
        self.studentUrl = studentUrl
        self.webUrl = webUrl
        self.subtitles = subtitles
        self.encodedVideo = encodedVideo
        self.multiDevice = multiDevice
        self.offlineDownload = offlineDownload
    }
}

public struct OfflineDownload: Sendable {
    public let fileUrl: String
    public var lastModified: String
    public let fileSize: Int
    
    public init(fileUrl: String, lastModified: String, fileSize: Int) {
        self.fileUrl = fileUrl
        self.lastModified = lastModified
        self.fileSize = fileSize
    }
    
    public var isDownloadable: Bool {
        [".zip"].contains(where: { fileUrl.contains($0) == true })
    }
}

public struct CourseBlockEncodedVideo: Sendable {

    public let fallback: CourseBlockVideo?
    public let desktopMP4: CourseBlockVideo?
    public let mobileHigh: CourseBlockVideo?
    public let mobileLow: CourseBlockVideo?
    public let hls: CourseBlockVideo?
    public let youtube: CourseBlockVideo?

    public init(
        fallback: CourseBlockVideo?,
        youtube: CourseBlockVideo?,
        desktopMP4: CourseBlockVideo?,
        mobileHigh: CourseBlockVideo?,
        mobileLow: CourseBlockVideo?,
        hls: CourseBlockVideo?
    ) {
        self.fallback = fallback
        self.youtube = youtube
        self.desktopMP4 = desktopMP4
        self.mobileHigh = mobileHigh
        self.mobileLow = mobileLow
        self.hls = hls
    }

    public var isDownloadable: Bool {
        [hls, desktopMP4, mobileHigh, mobileLow, fallback]
            .contains { $0?.isDownloadable == true }
    }

    public func video(downloadQuality: DownloadQuality) -> CourseBlockVideo? {
        switch downloadQuality {
        case .auto:
            [hls, mobileLow, mobileHigh, desktopMP4, fallback]
                .first(where: { $0?.isDownloadable == true })?
                .flatMap { $0 }
        case .high:
            [desktopMP4, mobileHigh, mobileLow, fallback, hls]
                .first(where: { $0?.isDownloadable == true })?
                .flatMap { $0 }
        case .medium:
            [mobileHigh, mobileLow, desktopMP4, fallback, hls]
                .first(where: { $0?.isDownloadable == true })?
                .flatMap { $0 }
        case .low:
            [mobileLow, mobileHigh, desktopMP4, fallback, hls]
                .first(where: { $0?.isDownloadable == true })?
                .flatMap { $0 }
        }
    }

    public func video(streamingQuality: StreamingQuality) -> CourseBlockVideo? {
        switch streamingQuality {
        case .auto:
            [hls, mobileLow, mobileHigh, desktopMP4, fallback, youtube]
                .compactMap { $0 }
                .sorted(by: { ($0?.streamPriority ?? 0) < ($1?.streamPriority ?? 0) })
                .first?
                .flatMap { $0 }
        case .high:
            [desktopMP4, mobileHigh, mobileLow, hls, youtube, fallback]
                .compactMap { $0 }
                .first?
                .flatMap { $0 }
        case .medium:
            [mobileHigh, mobileLow, desktopMP4, hls, youtube, fallback]
                .compactMap { $0 }
                .first?
                .flatMap { $0 }
        case .low:
            [mobileLow, mobileHigh, desktopMP4, hls, youtube, fallback]
                .compactMap { $0 }
                .first(where: { $0?.isDownloadable == true })?
                .flatMap { $0 }
        }
    }
}

public enum CourseBlockVideoEncoding: Sendable {
    case mobileLow, mobileHigh, desktopMP4, fallback, hls, youtube
}

public struct CourseBlockVideo: Equatable, Sendable {
    public let url: String?
    public let fileSize: Int?
    public let streamPriority: Int?
    public let type: CourseBlockVideoEncoding?

    public init(
        url: String?,
        fileSize: Int?,
        streamPriority: Int?,
        type: CourseBlockVideoEncoding?
    ) {
        self.url = url
        self.fileSize = fileSize
        self.streamPriority = streamPriority
        self.type = type
    }

    public var isVideoURL: Bool {
        [".mp4", ".m3u8"].contains(where: { url?.contains($0) == true })
    }

    public var isDownloadable: Bool {
        [".mp4"].contains(where: { url?.contains($0) == true })
    }
}
