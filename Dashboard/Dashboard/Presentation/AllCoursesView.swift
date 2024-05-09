//
//  AllCoursesView.swift
//  Dashboard
//
//  Created by  Stepanok Ivan on 24.04.2024.
//

import SwiftUI
import Core
import Theme

public struct AllCoursesView: View {
    
    @StateObject
    private var viewModel: AllCoursesViewModel
    private let router: DashboardRouter
    @Environment (\.isHorizontal) private var isHorizontal
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    public init(viewModel: AllCoursesViewModel, router: DashboardRouter) {
        self._viewModel = StateObject(wrappedValue: { viewModel }())
        self.router = router
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                VStack {
                    BackNavigationButton(
                        color: Theme.Colors.textPrimary,
                        action: {
                            router.back()
                        }
                    )
                    .backViewStyle()
                    .padding(.leading, isHorizontal ? 48 : 9)
                    .padding(.top, 13)
                    
                }.frame(minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .topLeading)
                .zIndex(1)
                
                if let myEnrollments = viewModel.myEnrollments,
                            myEnrollments.courses.isEmpty,
                            !viewModel.fetchInProgress {
                    NoCoursesView(selectedMenu: viewModel.selectedMenu)
                }
                // MARK: - Page body
                VStack(alignment: .center) {
                    RefreshableScrollViewCompat(action: {
                        await viewModel.getCourses(page: 1, refresh: true)
                    }) {
                        learnTitleAndSearch()
                        CategoryFilterView(selectedOption: $viewModel.selectedMenu)
                            .disabled(viewModel.fetchInProgress)
                        if let myEnrollments = viewModel.myEnrollments {
                            LazyVGrid(columns: columns(), spacing: 15) {
                                ForEach(
                                    Array(myEnrollments.courses.enumerated()),
                                    id: \.offset
                                ) { index, course in
                                    Button(action: {
                                        viewModel.trackDashboardCourseClicked(
                                            courseID: course.courseID,
                                            courseName: course.name
                                        )
                                        router.showCourseScreens(
                                            courseID: course.courseID,
                                            isActive: course.isActive,
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
                                            progressEarned: course.progressEarned,
                                            progressPossible: course.progressPossible,
                                            courseStartDate: course.courseStart,
                                            courseEndDate: course.courseEnd,
                                            isActive: course.isActive,
                                            isFullCard: false
                                        ).padding(8)
                                    })
                                    .accessibilityIdentifier("course_item")
                                    .onAppear {
                                        Task {
                                            await viewModel.getMyCoursesPagination(index: index)
                                        }
                                    }
                                }
                            }
                            .padding(10)
                            .frameLimit(width: proxy.size.width)
                        }
                        // MARK: - ProgressBar
                        if viewModel.nextPage <= viewModel.totalPages {
                            VStack(alignment: .center) {
                                ProgressBar(size: 40, lineWidth: 8)
                                    .padding(.top, 20)
                            }.frame(maxWidth: .infinity,
                                    maxHeight: .infinity)
                        }
                        VStack {}.frame(height: 40)
                    }
                    .accessibilityAction {}
                }
                .padding(.top, 8)
                
                // MARK: - Offline mode SnackBar
                OfflineSnackBarView(connectivity: viewModel.connectivity,
                                    reloadAction: {
                    await viewModel.getCourses(page: 1, refresh: true)
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
                    await viewModel.getCourses(page: 1)
                }
            }
            .onChange(of: viewModel.selectedMenu) { _ in
                Task {
                    await viewModel.getCourses(page: 1, refresh: true)
                }
            }
            .background(
                Theme.Colors.background
                    .ignoresSafeArea()
            )
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .navigationTitle(DashboardLocalization.Learn.allCourses)
        }
    }
    
    private func columns() -> [GridItem] {
        isHorizontal || idiom == .pad
        ? [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        : [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }
    
    private func learnTitleAndSearch() -> some View {
        HStack(alignment: .center) {
            Text(DashboardLocalization.Learn.allCourses)
                .font(Theme.Fonts.displaySmall)
                .foregroundColor(Theme.Colors.textPrimary)
                .accessibilityIdentifier("all_courses_header_text")
            Spacer()
            Button(action: {
                router.showDiscoverySearch(searchQuery: "")
            }, label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.Colors.textPrimary)
                    .accessibilityIdentifier(DashboardLocalization.search)
            })
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(DashboardLocalization.Header.courses + DashboardLocalization.Header.welcomeBack)
    }
}

#if DEBUG
struct AllCoursesView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = AllCoursesViewModel(
            interactor: DashboardInteractor.mock,
            connectivity: Connectivity(),
            analytics: DashboardAnalyticsMock()
        )
        
        AllCoursesView(viewModel: vm, router: DashboardRouterMock())
            .preferredColorScheme(.light)
            .previewDisplayName("AllCoursesView Light")
        
        AllCoursesView(viewModel: vm, router: DashboardRouterMock())
            .preferredColorScheme(.dark)
            .previewDisplayName("AllCoursesView Dark")
    }
}
#endif
