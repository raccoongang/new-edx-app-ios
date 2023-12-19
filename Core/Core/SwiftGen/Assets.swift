// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum CoreAssets {
  public static let appleButtonColor = ColorAsset(name: "AppleButtonColor")
  public static let facebookButtonColor = ColorAsset(name: "FacebookButtonColor")
  public static let googleButtonColor = ColorAsset(name: "GoogleButtonColor")
  public static let microsoftButtonColor = ColorAsset(name: "MicrosoftButtonColor")
  public static let bookCircle = ImageAsset(name: "book.circle")
  public static let bubbleLeftCircle = ImageAsset(name: "bubble.left.circle")
  public static let docCircle = ImageAsset(name: "doc.circle")
  public static let videoCircle = ImageAsset(name: "video.circle")
  public static let dashboardEmptyPage = ImageAsset(name: "DashboardEmptyPage")
  public static let addComment = ImageAsset(name: "addComment")
  public static let allPosts = ImageAsset(name: "allPosts")
  public static let chapter = ImageAsset(name: "chapter")
  public static let discussion = ImageAsset(name: "discussion")
  public static let discussionIcon = ImageAsset(name: "discussionIcon")
  public static let extra = ImageAsset(name: "extra")
  public static let filter = ImageAsset(name: "filter")
  public static let finished = ImageAsset(name: "finished")
  public static let followed = ImageAsset(name: "followed")
  public static let pen = ImageAsset(name: "pen")
  public static let question = ImageAsset(name: "question")
  public static let report = ImageAsset(name: "report")
  public static let reported = ImageAsset(name: "reported")
  public static let responses = ImageAsset(name: "responses")
  public static let send = ImageAsset(name: "send")
  public static let sendDisabled = ImageAsset(name: "sendDisabled")
  public static let sort = ImageAsset(name: "sort")
  public static let unread = ImageAsset(name: "unread")
  public static let video = ImageAsset(name: "video")
  public static let vote = ImageAsset(name: "vote")
  public static let voted = ImageAsset(name: "voted")
  public static let deleteDownloading = ImageAsset(name: "deleteDownloading")
  public static let startDownloading = ImageAsset(name: "startDownloading")
  public static let stopDownloading = ImageAsset(name: "stopDownloading")
  public static let announcements = ImageAsset(name: "announcements")
  public static let handouts = ImageAsset(name: "handouts")
  public static let dashboard = ImageAsset(name: "dashboard")
  public static let discovery = ImageAsset(name: "discovery")
  public static let profile = ImageAsset(name: "profile")
  public static let programs = ImageAsset(name: "programs")
  public static let addPhoto = ImageAsset(name: "addPhoto")
  public static let bgDelete = ImageAsset(name: "bg_delete")
  public static let checkmark = ImageAsset(name: "checkmark")
  public static let deleteChar = ImageAsset(name: "delete_char")
  public static let deleteEyes = ImageAsset(name: "delete_eyes")
  public static let done = ImageAsset(name: "done")
  public static let gallery = ImageAsset(name: "gallery")
  public static let leaveProfile = ImageAsset(name: "leaveProfile")
  public static let logOut = ImageAsset(name: "logOut")
  public static let noAvatar = ImageAsset(name: "noAvatar")
  public static let removePhoto = ImageAsset(name: "removePhoto")
  public static let iconApple = ImageAsset(name: "icon_apple")
  public static let iconFacebookWhite = ImageAsset(name: "icon_facebook_white")
  public static let iconGoogleWhite = ImageAsset(name: "icon_google_white")
  public static let iconMicrosoftWhite = ImageAsset(name: "icon_microsoft_white")
  public static let rotateDevice = ImageAsset(name: "rotateDevice")
  public static let sub = ImageAsset(name: "sub")
  public static let alarm = ImageAsset(name: "alarm")
  public static let appLogo = ImageAsset(name: "appLogo")
  public static let arrowLeft = ImageAsset(name: "arrowLeft")
  public static let arrowRight16 = ImageAsset(name: "arrowRight16")
  public static let certificate = ImageAsset(name: "certificate")
  public static let check = ImageAsset(name: "check")
  public static let checkEmail = ImageAsset(name: "checkEmail")
  public static let clearInput = ImageAsset(name: "clearInput")
  public static let edit = ImageAsset(name: "edit")
  public static let favorite = ImageAsset(name: "favorite")
  public static let goodWork = ImageAsset(name: "goodWork")
  public static let airmail = ImageAsset(name: "airmail")
  public static let defaultMail = ImageAsset(name: "defaultMail")
  public static let fastmail = ImageAsset(name: "fastmail")
  public static let googlegmail = ImageAsset(name: "googlegmail")
  public static let msOutlook = ImageAsset(name: "ms-outlook")
  public static let proton = ImageAsset(name: "proton")
  public static let readdleSpark = ImageAsset(name: "readdle-spark")
  public static let ymail = ImageAsset(name: "ymail")
  public static let noCourseImage = ImageAsset(name: "noCourseImage")
  public static let notAvaliable = ImageAsset(name: "notAvaliable")
  public static let playVideo = ImageAsset(name: "playVideo")
  public static let star = ImageAsset(name: "star")
  public static let starOutline = ImageAsset(name: "star_outline")
  public static let warningFilled = ImageAsset(name: "warning_filled")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ColorAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  public func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct ImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  public var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

public extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
