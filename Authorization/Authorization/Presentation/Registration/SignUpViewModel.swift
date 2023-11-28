//
//  SignUpViewModel.swift
//  Authorization
//
//  Created by  Stepanok Ivan on 24.10.2022.
//

import Foundation
import Core
import SwiftUI
import AuthenticationServices
import FacebookLogin
import GoogleSignIn
import MSAL

public class SignUpViewModel: ObservableObject {
    
    @Published var isShowProgress = false
    @Published var scrollTo: Int?
    @Published var showError: Bool = false
    var errorMessage: String? {
        didSet {
            withAnimation {
                showError = errorMessage != nil
            }
        }
    }
    
    @Published var fields: [FieldConfiguration] = []
    
    let router: AuthorizationRouter
    let config: ConfigProtocol
    let cssInjector: CSSInjector
    
    private let interactor: AuthInteractorProtocol
    private let analytics: AuthorizationAnalytics
    private let validator: Validator
    
    public init(
        interactor: AuthInteractorProtocol,
        router: AuthorizationRouter,
        analytics: AuthorizationAnalytics,
        config: ConfigProtocol,
        cssInjector: CSSInjector,
        validator: Validator
    ) {
        self.interactor = interactor
        self.router = router
        self.analytics = analytics
        self.config = config
        self.cssInjector = cssInjector
        self.validator = validator
    }

    var socialLoginEnabled: Bool {
        config.socialLoginEnabled
    }

    private func showErrors(errors: [String: String]) -> Bool {
        var containsError = false
        errors.forEach { key, value in
            if let index = fields.firstIndex(where: { $0.field.name == key }) {
                fields[index].error = value
                if value.count > 0 { containsError = true }
            }
        }
        scrollTo = fields.firstIndex(where: {$0.error != ""})
        return containsError
    }
    
    @MainActor
    public func getRegistrationFields() async {
        isShowProgress = true
        do {
            let fields = try await interactor.getRegistrationFields()
            self.fields = fields.map { FieldConfiguration(field: $0) }
            isShowProgress = false
        } catch let error {
            isShowProgress = false
            if error.isInternetError {
                errorMessage = CoreLocalization.Error.slowOrNoInternetConnection
            } else if error.isUpdateRequeiredError {
                router.showUpdateRequiredView(showAccountLink: false)
            } else {
                errorMessage = CoreLocalization.Error.unknownError
            }
        }
    }
    
    @MainActor
    func registerUser(externalToken: String? = nil, backend: String? = nil) async {
        do {
            var validateFields: [String: String] = [:]
            fields.forEach { validateFields[$0.field.name] = $0.text }
            validateFields["honor_code"] = "true"
            validateFields["terms_of_service"] = "true"
            if let externalToken = externalToken, let backend = backend {
                validateFields["access_token"] = externalToken
                validateFields["provider"] = backend
                validateFields["client_id"] = config.oAuthClientId
                if validateFields.contains(where: {$0.key == "password"}) {
                    validateFields.removeValue(forKey: "password")
                }
            }
            let errors = try await interactor.validateRegistrationFields(fields: validateFields)
            guard !showErrors(errors: errors) else { return }
            isShowProgress = true
            let user = try await interactor.registerUser(
                fields: validateFields,
                isSocial: externalToken != nil
            )
            analytics.setUserID("\(user.id)")
            analytics.registrationSuccess()
            isShowProgress = false
            router.showMainOrWhatsNewScreen()
            
        } catch let error {
            isShowProgress = false
            if case APIError.invalidGrant = error {
                errorMessage = CoreLocalization.Error.invalidCredentials
            } else if error.isInternetError {
                errorMessage = CoreLocalization.Error.slowOrNoInternetConnection
            } else {
                errorMessage = CoreLocalization.Error.unknownError
            }
        }
    }

    func register(with result: Result<SocialResult, Error>) {
        result.success(social)
        result.failure { error in
            errorMessage = error.localizedDescription
        }
    }

    private func social(result: SocialResult) {
        switch result {
        case .apple(let appleCredentials):
            appleLogin(appleCredentials, backend: result.backend)
        case .facebook:
            facebookLogin(backend: result.backend)
        case .google(let gIDSignInResult):
            googleLogin(gIDSignInResult, backend: result.backend)
        case .microsoft(_, let token):
            microsoftLogin(token, backend: result.backend)
        }
    }

    private func appleLogin(_ credentials: AppleCredentials, backend: String) {
        registerSocial(
            externalToken: credentials.token,
            backend: backend
        )
    }

    private func facebookLogin(backend: String) {
        guard let currentAccessToken = AccessToken.current?.tokenString else {
            return
        }
        registerSocial(
            externalToken: currentAccessToken,
            backend: backend
        )
    }

    private func googleLogin(_ result: GIDSignInResult, backend: String) {
        registerSocial(
            externalToken: result.user.accessToken.tokenString,
            backend: backend
        )
    }

    private func microsoftLogin(_ token: String, backend: String) {
        registerSocial(
            externalToken: token,
            backend: backend
        )
    }

    private func registerSocial(externalToken: String, backend: String) {
        Task { @MainActor in
            await registerUser(
                externalToken: externalToken,
                backend: backend
            )
        }
    }

    func trackCreateAccountClicked() {
        analytics.createAccountClicked()
    }
}
