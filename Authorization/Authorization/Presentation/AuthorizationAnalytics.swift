//
//  AuthorizationAnalytics.swift
//  Authorization
//
//  Created by  Stepanok Ivan on 27.06.2023.
//

import Foundation

public enum AuthMethod: Equatable {
    case password
    case socailAuth(SocialAuthMethod)

    public var analyticsValue: String {
        switch self {
        case .password:
            "Password"
        case .socailAuth(let socialAuthMethod):
            socialAuthMethod.rawValue
        }
    }
}

public enum SocialAuthMethod: String {
    case facebook = "Facebook"
    case google = "Google"
    case microsoft = "Microsoft"
    case apple = "Apple"
    case oauth2 = "Custom OAuth2"
}

//sourcery: AutoMockable
public protocol AuthorizationAnalytics {
    func setUserID(_ id: String)
    func userLogin(method: AuthMethod)
    func signUpClicked()
    func createAccountClicked()
    func registrationSuccess()
    func forgotPasswordClicked()
    func resetPasswordClicked(success: Bool)
}

#if DEBUG
class AuthorizationAnalyticsMock: AuthorizationAnalytics {
    public func setUserID(_ id: String) {}
    public func userLogin(method: AuthMethod) {}
    public func signUpClicked() {}
    public func createAccountClicked() {}
    public func registrationSuccess() {}
    public func forgotPasswordClicked() {}
    public func resetPasswordClicked(success: Bool) {}
}
#endif
