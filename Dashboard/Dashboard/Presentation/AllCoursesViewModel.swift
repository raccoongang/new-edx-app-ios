//
//  AllCoursesViewModel.swift
//  Dashboard
//
//  Created by  Stepanok Ivan on 24.04.2024.
//

import Foundation
import Core
import SwiftUI
import Combine

public class AllCoursesViewModel: ObservableObject {
    
    public var nextPage = 1
    public var totalPages = 1
    @Published public private(set) var fetchInProgress = false
    @Published var selectedMenu: CategoryOption = .all
    
    @Published var myEnrollments: MyEnrollments?
    @Published var showError: Bool = false
    var errorMessage: String? {
        didSet {
            withAnimation {
                showError = errorMessage != nil
            }
        }
    }
    
    let connectivity: ConnectivityProtocol
    private let interactor: DashboardInteractorProtocol
    private let analytics: DashboardAnalytics
    private var onCourseEnrolledCancellable: AnyCancellable?
    
    public init(interactor: DashboardInteractorProtocol,
                connectivity: ConnectivityProtocol,
                analytics: DashboardAnalytics) {
        self.interactor = interactor
        self.connectivity = connectivity
        self.analytics = analytics
        
        onCourseEnrolledCancellable = NotificationCenter.default
            .publisher(for: .onCourseEnrolled)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task {
                    await self.getCourses(page: 1, refresh: true)
                }
            }
    }
    
    @MainActor
    public func getCourses(page: Int, refresh: Bool = false) async {
        fetchInProgress = true
        do {
            if connectivity.isInternetAvaliable {
                if refresh || page == 1 {
                    myEnrollments?.courses = []
                    nextPage = 1
                    myEnrollments = try await interactor.getAllCourses(filteredBy: selectedMenu.status, page: page)
                    self.totalPages = myEnrollments?.totalPages ?? 1
                    self.nextPage = 2
                } else {
                    myEnrollments?.courses += try await interactor.getAllCourses(
                        filteredBy: selectedMenu.status, page: page
                    ).courses
                    self.nextPage += 1
                }
                totalPages = myEnrollments?.totalPages ?? 1
                fetchInProgress = false
            } else {
                self.totalPages = 1
                self.nextPage = 2
                myEnrollments = try await interactor.getAllCoursesOffline()
                fetchInProgress = false
            }
        } catch let error {
            fetchInProgress = false
            if error is NoCachedDataError {
                errorMessage = CoreLocalization.Error.noCachedData
            } else {
                errorMessage = CoreLocalization.Error.unknownError
            }
        }
    }
    
    @MainActor
    public func getMyCoursesPagination(index: Int) async {
        guard let courses = myEnrollments?.courses else { return }
        if !fetchInProgress {
            if totalPages > 1 {
                if index == courses.count - 3 {
                    if totalPages != 1 {
                        if nextPage <= totalPages {
                            await getCourses(page: self.nextPage)
                        }
                    }
                }
            }
        }
    }
    
    func trackDashboardCourseClicked(courseID: String, courseName: String) {
        analytics.dashboardCourseClicked(courseID: courseID, courseName: courseName)
    }
}
