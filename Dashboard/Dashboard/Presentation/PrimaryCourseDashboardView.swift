//
//  PrimaryCourseDashboardView.swift
//  Dashboard
//
//  Created by  Stepanok Ivan on 16.04.2024.
//

import SwiftUI
import Core
import Theme
//import Discovery
import Swinject

public struct PrimaryCourseDashboardView<ProgramView: View>: View {
    
    @StateObject
    private var viewModel: PrimaryCourseDashboardViewModel
    private let router: DashboardRouter
    private let config = Container.shared.resolve(ConfigProtocol.self)
    @ViewBuilder let programView: ProgramView
    private var openDiscoveryPage: () -> Void
    
    @State private var selectedMenu: MenuOption = .courses
    
    public init(
        viewModel: PrimaryCourseDashboardViewModel,
        router: DashboardRouter,
        programView: ProgramView,
        openDiscoveryPage: @escaping () -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: { viewModel }())
        self.router = router
        self.programView = programView
        self.openDiscoveryPage = openDiscoveryPage
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                if !viewModel.fetchInProgress, viewModel.enrollments?.primaryCourse == nil {
                    NoCoursesView(openDiscovery: {
                        openDiscoveryPage()
                    }).zIndex(1)
                }
                    // MARK: - Page body
                    VStack(alignment: .center) {
                        RefreshableScrollViewCompat(action: {
                            await viewModel.getEnrollments(showProgress: false)
                        }) {
                            ZStack(alignment: .topLeading) {
                                learnTitleAndSearch()
                                    .zIndex(1)
                                if !viewModel.fetchInProgress, viewModel.enrollments?.primaryCourse == nil {
                                    
                                } else if viewModel.fetchInProgress {
                                    VStack(alignment: .center) {
                                        ProgressBar(size: 40, lineWidth: 8)
                                            .padding(.top, 200)
                                    }.frame(maxWidth: .infinity,
                                            maxHeight: .infinity)
                                } else {
                                    LazyVStack(spacing: 0) {
                                        Spacer(minLength: 50)
                                        switch selectedMenu {
                                        case .courses:
                                            if let  enrollments = viewModel.enrollments {
                                                if let primary = enrollments.primaryCourse {
                                                    PrimaryCardView(
                                                        courseName: primary.name,
                                                        org: primary.org,
                                                        courseImage: primary.courseBanner,
                                                        courseStartDate: primary.courseStart,
                                                        courseEndDate: primary.courseEnd,
                                                        futureAssignments: primary.futureAssignments,
                                                        pastAssignments: primary.pastAssignments,
                                                        progressEarned: primary.progressEarned ?? 0,
                                                        progressPossible: primary.progressPossible ?? 0,
                                                        canResume: primary.lastVisitedBlockID != nil,
                                                        resumeTitle: primary.resumeTitle,
                                                        pastAssignmentAction: { lastVisitedBlockID in
                                                            router.showCourseScreens(
                                                                courseID: primary.courseID,
                                                                hasAccess: primary.hasAccess,
                                                                courseStart: primary.courseStart,
                                                                courseEnd: primary.courseEnd,
                                                                enrollmentStart: nil,
                                                                enrollmentEnd: nil,
                                                                title: primary.name,
                                                                selection: lastVisitedBlockID == nil ? .dates : .course,
                                                                lastVisitedBlockID: lastVisitedBlockID
                                                            )
                                                        },
                                                        futureAssignmentAction: { lastVisitedBlockID in
                                                            router.showCourseScreens(
                                                                courseID: primary.courseID,
                                                                hasAccess: primary.hasAccess,
                                                                courseStart: primary.courseStart,
                                                                courseEnd: primary.courseEnd,
                                                                enrollmentStart: nil,
                                                                enrollmentEnd: nil,
                                                                title: primary.name,
                                                                selection: lastVisitedBlockID == nil ? .dates : .course,
                                                                lastVisitedBlockID: lastVisitedBlockID
                                                            )
                                                        },
                                                        resumeAction: {
                                                            router.showCourseScreens(
                                                                courseID: primary.courseID,
                                                                hasAccess: primary.hasAccess,
                                                                courseStart: primary.courseStart,
                                                                courseEnd: primary.courseEnd,
                                                                enrollmentStart: nil,
                                                                enrollmentEnd: nil,
                                                                title: primary.name,
                                                                selection: .course,
                                                                lastVisitedBlockID: primary.lastVisitedBlockID
                                                            )
                                                        }
                                                    )
                                                }
                                                if !enrollments.courses.isEmpty {
                                                    viewAll(enrollments)
                                                }
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 16) {
                                                        ForEach(
                                                            Array(enrollments.courses.enumerated()),
                                                            id: \.offset
                                                        ) { _, course in
                                                            Button(action: {
                                                                viewModel.trackDashboardCourseClicked(
                                                                    courseID: course.courseID,
                                                                    courseName: course.name
                                                                )
                                                                router.showCourseScreens(
                                                                    courseID: course.courseID,
                                                                    hasAccess: course.hasAccess,
                                                                    courseStart: course.courseStart,
                                                                    courseEnd: course.courseEnd,
                                                                    enrollmentStart: course.enrollmentStart,
                                                                    enrollmentEnd: course.enrollmentEnd,
                                                                    title: course.name,
                                                                    selection: .course,
                                                                    lastVisitedBlockID: nil
                                                                )
                                                            }, label: {
                                                                CourseCardView(
                                                                    courseName: course.name,
                                                                    courseImage: course.imageURL,
                                                                    progressEarned: 0,
                                                                    progressPossible: 0,
                                                                    courseStartDate: nil,
                                                                    courseEndDate: nil,
                                                                    hasAccess: course.hasAccess,
                                                                    isFullCard: false
                                                                ).frame(width: 120)
                                                            }
                                                            )
                                                            .accessibilityIdentifier("course_item")
                                                        }
                                                        if enrollments.courses.count < enrollments.count {
                                                            viewAllButton(enrollments)
                                                        }
                                                    }
                                                    .padding(20)
                                                }
                                            } else {
                                                EmptyPageIcon()
                                            }
                                        case .programs:
                                            programView
                                        }
                                    }
                                }
                            }
                            .frameLimit(width: proxy.size.width)
                        }.accessibilityAction {}
                    }.padding(.top, 8)
                    
                // MARK: - Offline mode SnackBar
                OfflineSnackBarView(connectivity: viewModel.connectivity,
                                    reloadAction: {
                    await viewModel.getEnrollments(showProgress: false)
                })
                
                // MARK: - Error Alert
                if viewModel.showError {
                    VStack {
                        Spacer()
                        SnackBarView(message: viewModel.errorMessage)
                    }
                    .padding(.bottom, viewModel.connectivity.isInternetAvaliable
                             ? 0 : OfflineSnackBarView.height)
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        doAfter(Theme.Timeout.snackbarMessageLongTimeout) {
                            viewModel.errorMessage = nil
                        }
                    }
                }
            }
            .onFirstAppear {
                Task {
                    await viewModel.getEnrollments()
                }
            }
            .background(
                Theme.Colors.background
                    .ignoresSafeArea()
            )
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .navigationTitle(DashboardLocalization.title)
        }
    }
    
    private func viewAllButton(_ enrollments: PrimaryEnrollment) -> some View {
        Button(action: {
            router.showAllCourses(courses: enrollments.courses)
        }, label: {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    CoreAssets.viewAll.swiftUIImage
                    Text(DashboardLocalization.Learn.viewAll)
                        .font(Theme.Fonts.labelMedium)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Spacer()
                }
                .frame(width: 120)
            }
            .background(Theme.Colors.background)
            .cornerRadius(8)
            .shadow(color: Theme.Colors.courseCardShadow, radius: 6, x: 2, y: 2)
            
        })
    }
    
    private func viewAll(_ enrollments: PrimaryEnrollment) -> some View {
        Button(action: {
            router.showAllCourses(courses: enrollments.courses)
        }, label: {
            HStack {
                Text(DashboardLocalization.Learn.viewAllCourses(enrollments.count))
                    .font(Theme.Fonts.titleSmall)
                    .accessibilityIdentifier("courses_welcomeback_text")
                Image(systemName: "chevron.right")
            }
            .padding(.horizontal, 16)
            .foregroundColor(Theme.Colors.textPrimary)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        })
    }
    
    private func learnTitleAndSearch() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(DashboardLocalization.Learn.title)
                    .font(Theme.Fonts.displaySmall)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .accessibilityIdentifier("courses_header_text")
                Spacer()
                Button(action: {
                    router.showDiscoverySearch(searchQuery: "")
                }, label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Theme.Colors.textPrimary)
                        .accessibilityIdentifier(DashboardLocalization.search)
                })
            }
            if let config, config.program.enabled, config.program.isWebViewConfigured {
                DropDownMenu(selectedOption: $selectedMenu)
            }
        }
        .listRowBackground(Color.clear)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(DashboardLocalization.Header.courses + DashboardLocalization.Header.welcomeBack)
    }
}

#if DEBUG
struct PrimaryCourseDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = PrimaryCourseDashboardViewModel(
            interactor: DashboardInteractor.mock,
            connectivity: Connectivity(),
            analytics: DashboardAnalyticsMock()
        )
        
        PrimaryCourseDashboardView(viewModel: vm,
                  router: DashboardRouterMock(),
                  programView: EmptyView(),
                  openDiscoveryPage: {
        })
        .preferredColorScheme(.light)
        .previewDisplayName("DashboardView Light")
        
        PrimaryCourseDashboardView(viewModel: vm,
                  router: DashboardRouterMock(),
                  programView: EmptyView(),
                  openDiscoveryPage: {
        })
        .preferredColorScheme(.dark)
        .previewDisplayName("DashboardView Dark")
    }
}
#endif
