//
//  UserDetailsView.swift
//  Discussion
//
//  Created by  Stepanok Ivan on 10.10.2023.
//

import SwiftUI
import Core
import Profile
import Kingfisher

public struct UserDetailsView: View {
    
    @StateObject private var viewModel: UserDetailsViewModel
    
    public init(viewModel: UserDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: { viewModel }())
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Page Body
            RefreshableScrollViewCompat(action: {
                await viewModel.getUserProfile(withProgress: false)
            }) {
                VStack {
                    if viewModel.isShowProgress {
                        ProgressBar(size: 40, lineWidth: 8)
                            .padding(.top, 200)
                            .padding(.horizontal)
                    } else {
                        UserAvatar(url: viewModel.userModel?.avatarUrl ?? "")
                        Text(viewModel.userModel?.name ?? "")
                            .font(Theme.Fonts.headlineSmall)
                            .padding(.top, 20)
                        
                        Text("@\(viewModel.userModel?.username ?? "")")
                            .font(Theme.Fonts.labelLarge)
                            .padding(.top, 4)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .padding(.bottom, 10)
                        
                        // MARK: - Profile Info
                        if viewModel.userModel?.yearOfBirth != 0 || viewModel.userModel?.shortBiography != "" {
                            VStack(alignment: .leading, spacing: 14) {
                                Text(ProfileLocalization.info)
                                    .padding(.horizontal, 24)
                                    .font(Theme.Fonts.labelLarge)
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    if viewModel.userModel?.yearOfBirth != 0 {
                                        HStack {
                                            Text(ProfileLocalization.Edit.Fields.yearOfBirth)
                                                .foregroundColor(Theme.Colors.textSecondary)
                                            Text(String(viewModel.userModel?.yearOfBirth ?? 0))
                                        }
                                    }
                                    if let bio = viewModel.userModel?.shortBiography, bio != "" {
                                        HStack(alignment: .top) {
                                            Text(ProfileLocalization.bio + " ")
                                                .foregroundColor(Theme.Colors.textSecondary)
                                            + Text(bio)
                                        }
                                    }
                                }
                                .cardStyle(
                                    bgColor: Theme.Colors.textInputUnfocusedBackground,
                                    strokeColor: .clear
                                )
                            }.padding(.bottom, 16)
                        }
                    }
                    Spacer()
                }
            }.frameLimit(sizePortrait: 420)
                .padding(.top, 8)
                .navigationBarHidden(false)
                .navigationBarBackButtonHidden(false)
            
            // MARK: - Error Alert
            if viewModel.showError {
                VStack {
                    Spacer()
                    SnackBarView(message: viewModel.errorMessage)
                }
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
                await viewModel.getUserProfile()
            }
        }
        .background(
            Theme.Colors.background
                .ignoresSafeArea()
        )
    }
}

#Preview {
    
    let router = DiscussionRouterMock()
    let vm = UserDetailsViewModel(interactor: DiscussionInteractor.mock,
                                  analytics: DiscussionAnalyticsMock(),
                                  username: "demo")
    
    return UserDetailsView(viewModel: vm)
}

struct UserAvatar: View {
    
    private var url: URL?
    
    init(url: String) {
        if let rightUrl = URL(string: url) {
            self.url = rightUrl
        } else {
            self.url = nil
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Theme.Colors.avatarStroke)
                .frame(width: 104, height: 104)
            KFImage(url)
                .onFailureImage(CoreAssets.noCourseImage.image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .cornerRadius(50)
        }
    }
}
