// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum CourseLocalization {
  public enum Accessibility {
    /// Cancel download
    public static let cancelDownload = CourseLocalization.tr("Localizable", "ACCESSIBILITY.CANCEL_DOWNLOAD", fallback: "Cancel download")
    /// Delete download
    public static let deleteDownload = CourseLocalization.tr("Localizable", "ACCESSIBILITY.DELETE_DOWNLOAD", fallback: "Delete download")
    /// Download
    public static let download = CourseLocalization.tr("Localizable", "ACCESSIBILITY.DOWNLOAD", fallback: "Download")
  }
  public enum Alert {
    /// Accept
    public static let accept = CourseLocalization.tr("Localizable", "ALERT.ACCEPT", fallback: "Accept")
    /// Are you sure you want to delete all video(s) for
    public static let deleteAllVideos = CourseLocalization.tr("Localizable", "ALERT.DELETE_ALL_VIDEOS", fallback: "Are you sure you want to delete all video(s) for")
    /// Are you sure you want to delete video(s) for
    public static let deleteVideos = CourseLocalization.tr("Localizable", "ALERT.DELETE_VIDEOS", fallback: "Are you sure you want to delete video(s) for")
    /// Rotate your device to view this video in full screen.
    public static let rotateDevice = CourseLocalization.tr("Localizable", "ALERT.ROTATE_DEVICE", fallback: "Rotate your device to view this video in full screen.")
    /// Turning off the switch will stop downloading and delete all downloaded videos for
    public static let stopDownloading = CourseLocalization.tr("Localizable", "ALERT.STOP_DOWNLOADING", fallback: "Turning off the switch will stop downloading and delete all downloaded videos for")
  }
  public enum Courseware {
    /// Back to outline
    public static let backToOutline = CourseLocalization.tr("Localizable", "COURSEWARE.BACK_TO_OUTLINE", fallback: "Back to outline")
    /// Continue
    public static let `continue` = CourseLocalization.tr("Localizable", "COURSEWARE.CONTINUE", fallback: "Continue")
    /// Course content
    public static let courseContent = CourseLocalization.tr("Localizable", "COURSEWARE.COURSE_CONTENT", fallback: "Course content")
    /// Course units
    public static let courseUnits = CourseLocalization.tr("Localizable", "COURSEWARE.COURSE_UNITS", fallback: "Course units")
    /// Finish
    public static let finish = CourseLocalization.tr("Localizable", "COURSEWARE.FINISH", fallback: "Finish")
    /// Good Work!
    public static let goodWork = CourseLocalization.tr("Localizable", "COURSEWARE.GOOD_WORK", fallback: "Good Work!")
    /// “ is finished.
    public static let isFinished = CourseLocalization.tr("Localizable", "COURSEWARE.IS_FINISHED", fallback: "“ is finished.")
    /// Next
    public static let next = CourseLocalization.tr("Localizable", "COURSEWARE.NEXT", fallback: "Next")
    /// Prev
    public static let previous = CourseLocalization.tr("Localizable", "COURSEWARE.PREVIOUS", fallback: "Prev")
    /// Resume with:
    public static let resumeWith = CourseLocalization.tr("Localizable", "COURSEWARE.RESUME_WITH", fallback: "Resume with:")
    /// Section “
    public static let section = CourseLocalization.tr("Localizable", "COURSEWARE.SECTION", fallback: "Section “")
  }
  public enum CourseContainer {
    /// Course
    public static let course = CourseLocalization.tr("Localizable", "COURSE_CONTAINER.COURSE", fallback: "Course")
    /// Dates
    public static let dates = CourseLocalization.tr("Localizable", "COURSE_CONTAINER.DATES", fallback: "Dates")
    /// Discussions
    public static let discussions = CourseLocalization.tr("Localizable", "COURSE_CONTAINER.DISCUSSIONS", fallback: "Discussions")
    /// Handouts
    public static let handouts = CourseLocalization.tr("Localizable", "COURSE_CONTAINER.HANDOUTS", fallback: "Handouts")
    /// Handouts In developing
    public static let handoutsInDeveloping = CourseLocalization.tr("Localizable", "COURSE_CONTAINER.HANDOUTS_IN_DEVELOPING", fallback: "Handouts In developing")
    /// Videos
    public static let videos = CourseLocalization.tr("Localizable", "COURSE_CONTAINER.VIDEOS", fallback: "Videos")
  }
  public enum CourseDates {
    /// Completed
    public static let completed = CourseLocalization.tr("Localizable", "COURSE_DATES.COMPLETED", fallback: "Completed")
    /// Due next
    public static let dueNext = CourseLocalization.tr("Localizable", "COURSE_DATES.DUE_NEXT", fallback: "Due next")
    /// Item Hidden
    public static let itemHidden = CourseLocalization.tr("Localizable", "COURSE_DATES.ITEM_HIDDEN", fallback: "Item Hidden")
    /// Items Hidden
    public static let itemsHidden = CourseLocalization.tr("Localizable", "COURSE_DATES.ITEMS_HIDDEN", fallback: "Items Hidden")
    /// Past due
    public static let pastDue = CourseLocalization.tr("Localizable", "COURSE_DATES.PAST_DUE", fallback: "Past due")
    /// Your due dates have been successfully shifted to help you stay on track.
    public static let toastSuccessMessage = CourseLocalization.tr("Localizable", "COURSE_DATES.TOAST_SUCCESS_MESSAGE", fallback: "Your due dates have been successfully shifted to help you stay on track.")
    /// Due Dates Shifted
    public static let toastSuccessTitle = CourseLocalization.tr("Localizable", "COURSE_DATES.TOAST_SUCCESS_TITLE", fallback: "Due Dates Shifted")
    /// Today
    public static let today = CourseLocalization.tr("Localizable", "COURSE_DATES.TODAY", fallback: "Today")
    /// Unreleased
    public static let unreleased = CourseLocalization.tr("Localizable", "COURSE_DATES.UNRELEASED", fallback: "Unreleased")
    /// Verified Only
    public static let verifiedOnly = CourseLocalization.tr("Localizable", "COURSE_DATES.VERIFIED_ONLY", fallback: "Verified Only")
    /// View All Dates
    public static let viewAllDates = CourseLocalization.tr("Localizable", "COURSE_DATES.VIEW_ALL_DATES", fallback: "View All Dates")
    public enum ResetDate {
      /// Your dates could not be shifted. Please try again.
      public static let errorMessage = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.ERROR_MESSAGE", fallback: "Your dates could not be shifted. Please try again.")
      /// Your dates have been successfully shifted.
      public static let successMessage = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.SUCCESS_MESSAGE", fallback: "Your dates have been successfully shifted.")
      /// Course Dates
      public static let title = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.TITLE", fallback: "Course Dates")
      public enum ResetDateBanner {
        /// Don't worry - shift our suggested schedule to complete past due assignments without losing any progress.
        public static let body = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.RESET_DATE_BANNER.BODY", fallback: "Don't worry - shift our suggested schedule to complete past due assignments without losing any progress.")
        /// Shift due dates
        public static let button = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.RESET_DATE_BANNER.BUTTON", fallback: "Shift due dates")
        /// Missed some deadlines?
        public static let header = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.RESET_DATE_BANNER.HEADER", fallback: "Missed some deadlines?")
      }
      public enum TabInfoBanner {
        /// We built a suggested schedule to help you stay on track. But don’t worry – it’s flexible so you can learn at your own pace. If you happen to fall behind, you’ll be able to adjust the dates to keep yourself on track.
        public static let body = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.TAB_INFO_BANNER.BODY", fallback: "We built a suggested schedule to help you stay on track. But don’t worry – it’s flexible so you can learn at your own pace. If you happen to fall behind, you’ll be able to adjust the dates to keep yourself on track.")
        /// 
        public static let header = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.TAB_INFO_BANNER.HEADER", fallback: "")
      }
      public enum UpgradeToCompleteGradedBanner {
        /// To complete graded assignments as part of this course, you can upgrade today.
        public static let body = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.UPGRADE_TO_COMPLETE_GRADED_BANNER.BODY", fallback: "To complete graded assignments as part of this course, you can upgrade today.")
        /// 
        public static let button = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.UPGRADE_TO_COMPLETE_GRADED_BANNER.BUTTON", fallback: "")
        /// 
        public static let header = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.UPGRADE_TO_COMPLETE_GRADED_BANNER.HEADER", fallback: "")
      }
      public enum UpgradeToResetBanner {
        /// You are auditing this course, which means that you are unable to participate in graded assignments. It looks like you missed some important deadlines based on our suggested schedule. To complete graded assignments as part of this course and shift the past due assignments into the future, you can upgrade today.
        public static let body = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.UPGRADE_TO_RESET_BANNER.BODY", fallback: "You are auditing this course, which means that you are unable to participate in graded assignments. It looks like you missed some important deadlines based on our suggested schedule. To complete graded assignments as part of this course and shift the past due assignments into the future, you can upgrade today.")
        /// 
        public static let button = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.UPGRADE_TO_RESET_BANNER.BUTTON", fallback: "")
        /// 
        public static let header = CourseLocalization.tr("Localizable", "COURSE_DATES.RESET_DATE.UPGRADE_TO_RESET_BANNER.HEADER", fallback: "")
      }
    }
  }
  public enum Download {
    /// All videos downloaded
    public static let allVideosDownloaded = CourseLocalization.tr("Localizable", "DOWNLOAD.ALL_VIDEOS_DOWNLOADED", fallback: "All videos downloaded")
    /// You cannot change the download video quality when all videos are downloading
    public static let changeQualityAlert = CourseLocalization.tr("Localizable", "DOWNLOAD.CHANGE_QUALITY_ALERT", fallback: "You cannot change the download video quality when all videos are downloading")
    /// Download
    public static let download = CourseLocalization.tr("Localizable", "DOWNLOAD.DOWNLOAD", fallback: "Download")
    /// The videos you've selected are larger than 1 GB. Do you want to download these videos?
    public static let downloadLargeFileMessage = CourseLocalization.tr("Localizable", "DOWNLOAD.DOWNLOAD_LARGE_FILE_MESSAGE", fallback: "The videos you've selected are larger than 1 GB. Do you want to download these videos?")
    /// Download to device
    public static let downloadToDevice = CourseLocalization.tr("Localizable", "DOWNLOAD.DOWNLOAD_TO_DEVICE", fallback: "Download to device")
    /// Downloading videos...
    public static let downloadingVideos = CourseLocalization.tr("Localizable", "DOWNLOAD.DOWNLOADING_VIDEOS", fallback: "Downloading videos...")
    /// Downloads
    public static let downloads = CourseLocalization.tr("Localizable", "DOWNLOAD.DOWNLOADS", fallback: "Downloads")
    /// Your current download settings only allow downloads over Wi-Fi.
    /// Please connect to a Wi-Fi network or change your download settings.
    public static let noWifiMessage = CourseLocalization.tr("Localizable", "DOWNLOAD.NO_WIFI_MESSAGE", fallback: "Your current download settings only allow downloads over Wi-Fi.\nPlease connect to a Wi-Fi network or change your download settings.")
    /// Remaining
    public static let remaining = CourseLocalization.tr("Localizable", "DOWNLOAD.REMAINING", fallback: "Remaining")
    /// Total
    public static let total = CourseLocalization.tr("Localizable", "DOWNLOAD.TOTAL", fallback: "Total")
    /// Untitled
    public static let untitled = CourseLocalization.tr("Localizable", "DOWNLOAD.UNTITLED", fallback: "Untitled")
    /// Videos
    public static let videos = CourseLocalization.tr("Localizable", "DOWNLOAD.VIDEOS", fallback: "Videos")
  }
  public enum Error {
    /// Course component not found, please reload
    public static let componentNotFount = CourseLocalization.tr("Localizable", "ERROR.COMPONENT_NOT_FOUNT", fallback: "Course component not found, please reload")
    /// There are currently no handouts for this course
    public static let noHandouts = CourseLocalization.tr("Localizable", "ERROR.NO_HANDOUTS", fallback: "There are currently no handouts for this course")
    /// You are not connected to the Internet. Please check your Internet connection.
    public static let noInternet = CourseLocalization.tr("Localizable", "ERROR.NO_INTERNET", fallback: "You are not connected to the Internet. Please check your Internet connection.")
    /// Reload
    public static let reload = CourseLocalization.tr("Localizable", "ERROR.RELOAD", fallback: "Reload")
  }
  public enum HandoutsCellAnnouncements {
    /// Keep up with the latest news
    public static let description = CourseLocalization.tr("Localizable", "HANDOUTS_CELL_ANNOUNCEMENTS.DESCRIPTION", fallback: "Keep up with the latest news")
    /// Announcements
    public static let title = CourseLocalization.tr("Localizable", "HANDOUTS_CELL_ANNOUNCEMENTS.TITLE", fallback: "Announcements")
  }
  public enum HandoutsCellHandouts {
    /// Find important course information
    public static let description = CourseLocalization.tr("Localizable", "HANDOUTS_CELL_HANDOUTS.DESCRIPTION", fallback: "Find important course information")
    /// Handouts
    public static let title = CourseLocalization.tr("Localizable", "HANDOUTS_CELL_HANDOUTS.TITLE", fallback: "Handouts")
  }
  public enum NotAvaliable {
    /// Open in browser
    public static let button = CourseLocalization.tr("Localizable", "NOT_AVALIABLE.BUTTON", fallback: "Open in browser")
    /// Explore other parts of this course or view this on web.
    public static let description = CourseLocalization.tr("Localizable", "NOT_AVALIABLE.DESCRIPTION", fallback: "Explore other parts of this course or view this on web.")
    /// This interactive component isn’t yet available
    public static let title = CourseLocalization.tr("Localizable", "NOT_AVALIABLE.TITLE", fallback: "This interactive component isn’t yet available")
  }
  public enum Outline {
    /// Certificate
    public static let certificate = CourseLocalization.tr("Localizable", "OUTLINE.CERTIFICATE", fallback: "Certificate")
    /// Localizable.strings
    ///   Course
    /// 
    ///   Created by  Stepanok Ivan on 26.09.2022.
    public static let congratulations = CourseLocalization.tr("Localizable", "OUTLINE.CONGRATULATIONS", fallback: "Congratulations!")
    /// This course hasn't started yet.
    public static let courseHasntStarted = CourseLocalization.tr("Localizable", "OUTLINE.COURSE_HASNT_STARTED", fallback: "This course hasn't started yet.")
    /// Course videos
    public static let courseVideos = CourseLocalization.tr("Localizable", "OUTLINE.COURSE_VIDEOS", fallback: "Course videos")
    /// You've passed the course
    public static let passedTheCourse = CourseLocalization.tr("Localizable", "OUTLINE.PASSED_THE_COURSE", fallback: "You've passed the course")
    /// View certificate
    public static let viewCertificate = CourseLocalization.tr("Localizable", "OUTLINE.VIEW_CERTIFICATE", fallback: "View certificate")
  }
  public enum Subtitles {
    /// Subtitles
    public static let title = CourseLocalization.tr("Localizable", "SUBTITLES.TITLE", fallback: "Subtitles")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension CourseLocalization {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

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
