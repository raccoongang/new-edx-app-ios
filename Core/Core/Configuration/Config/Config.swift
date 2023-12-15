//
//  Config.swift
//  Core
//
//  Created by Muhammad Umer on 11/11/2023.
//

import Foundation

public protocol ConfigProtocol {
    var baseURL: URL { get }
    var oAuthClientId: String { get }
    var tokenType: TokenType { get }
    var webLogin: Bool { get }
    var feedbackEmail: String { get }
    var appStoreLink: String { get }
    var platformName: String { get }
    var agreement: AgreementConfig { get }
    var firebase: FirebaseConfig { get }
    var facebook: FacebookConfig { get }
    var microsoft: MicrosoftConfig { get }
    var google: GoogleConfig { get }
    var appleSignIn: AppleSignInConfig { get }
    var features: FeaturesConfig { get }
    var uiComponents: UIComponentsConfig { get }
}

public enum TokenType: String {
    case jwt = "JWT"
    case bearer = "BEARER"
}

private enum ConfigKeys: String {
    case baseURL = "API_HOST_URL"
    case oAuthClientID = "OAUTH_CLIENT_ID"
    case tokenType = "TOKEN_TYPE"
    case webLogin = "false"
    case feedbackEmailAddress = "FEEDBACK_EMAIL_ADDRESS"
    case environmentDisplayName = "ENVIRONMENT_DISPLAY_NAME"
    case platformName = "PLATFORM_NAME"
    case organizationCode = "ORGANIZATION_CODE"
    case appstoreID = "APP_STORE_ID"
}

public class Config {
    let configFileName = "config"
    
    internal var properties: [String: Any] = [:]
    
    internal init(properties: [String: Any]) {
        self.properties = properties
    }
    
    public convenience init() {
        self.init(properties: [:])
        loadAndParseConfig()
    }
    
    private func loadAndParseConfig() {
        guard let path = Bundle.main.path(forResource: configFileName, ofType: "plist"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let dict = try? PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil) as? [String: Any] 
        else { return }
        
        properties = dict
    }
    
    internal subscript(key: String) -> Any? {
        return properties[key]
    }
    
    func dict(for key: String) -> [String: Any]? {
        return properties[key] as? [String: Any]
    }
    
    func value<T>(for key: String) -> T? {
        return properties[key] as? T
    }
    
    func value(for key: String) -> Any? {
        return properties[key]
    }
    
    func value(for key: String, dict: [String: Any]) -> String? {
        return dict[key] as? String ?? nil
    }
    
    func string(for key: String) -> String? {
        return value(for: key) as? String ?? nil
    }
    
    func string(for key: String, dict: [String: Any]) -> String? {
        return value(for: key, dict: dict)
    }
    
    func bool(for key: String) -> Bool {
        return value(for: key) as? Bool ?? false
    }
}

extension Config: ConfigProtocol {
    public var baseURL: URL {
        guard let urlString = string(for: ConfigKeys.baseURL.rawValue),
              let url = URL(string: urlString) else {
            fatalError("Unable to find base url in config.")
        }
        return url
    }
    
    public var oAuthClientId: String {
        guard let clientID = string(for: ConfigKeys.oAuthClientID.rawValue) else {
            fatalError("Unable to find OAuth ClientID in config.")
        }
        return clientID
    }
    
    public var tokenType: TokenType {
        guard let tokenTypeValue = string(for: ConfigKeys.tokenType.rawValue),
              let tokenType = TokenType(rawValue: tokenTypeValue)
        else { return .jwt }
        return tokenType
    }
    
    public var webLogin: Bool {
        return Bool(ConfigKeys.webLogin.rawValue) ?? false
    }
    
    public var feedbackEmail: String {
        return string(for: ConfigKeys.feedbackEmailAddress.rawValue) ?? ""
    }

    public var platformName: String {
        return string(for: ConfigKeys.platformName.rawValue) ?? ""
    }

    private var appStoreId: String {
        return string(for: ConfigKeys.appstoreID.rawValue) ?? "0000000000"
    }
    
    public var appStoreLink: String {
        "itms-apps://itunes.apple.com/app/id\(appStoreId)?mt=8"
    }
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public class ConfigMock: Config {
    private let config: [String: Any] = [
        "API_HOST_URL": "https://www.example.com",
        "OAUTH_CLIENT_ID": "oauth_client_id",
        "FEEDBACK_EMAIL_ADDRESS": "example@mail.com",
        "PLATFORM_NAME": "OpenEdx",
        "TOKEN_TYPE": "JWT",
        "WHATS_NEW_ENABLED": false,
        "AGREEMENT_URLS": [
            "PRIVACY_POLICY_URL": "https://www.example.com/privacy",
            "TOS_URL": "https://www.example.com/tos"
        ],
        "GOOGLE": [
            "ENABLED": true,
            "CLIENT_ID": "clientId"
        ],
        "FACEBOOK": [
            "ENABLED": true,
            "FACEBOOK_APP_ID": "facebookAppId",
            "CLIENT_TOKEN": "client_token"
        ],
        "MICROSOFT": [
            "ENABLED": true,
            "APP_ID": "appId"
        ],
        "APPLE_SIGNIN": [
            "ENABLED": true
        ]
    ]
    
    public init() {
        super.init(properties: config)
    }
}
#endif
