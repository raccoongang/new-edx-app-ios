//
//  AppAssembly.swift
//  OpenEdX
//
//  Created by Vladimir Chekyrta on 13.09.2022.
//

import UIKit
import Core
import Swinject
import KeychainSwift
import Discovery
import Dashboard
import Course
import Discussion
import Authorization
import Profile
import WhatsNew

// swiftlint:disable function_body_length
class AppAssembly: Assembly {
    
    private let navigation: UINavigationController
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func assemble(container: Container) {
        container.register(UINavigationController.self) { _ in
            self.navigation
        }.inObjectScope(.container)
        
        container.register(Router.self) { r in
            Router(navigationController: r.resolve(UINavigationController.self)!, container: container)
        }
        
        container.register(AnalyticsManager.self) { _ in
            AnalyticsManager()
        }
        
        container.register(AuthorizationAnalytics.self) { r in
            r.resolve(AnalyticsManager.self)!
        }.inObjectScope(.container)
        
        container.register(MainScreenAnalytics.self) { r in
            r.resolve(AnalyticsManager.self)!
        }.inObjectScope(.container)
        
        container.register(DiscoveryAnalytics.self) { r in
            r.resolve(AnalyticsManager.self)!
        }.inObjectScope(.container)
        
        container.register(DashboardAnalytics.self) { r in
            r.resolve(AnalyticsManager.self)!
        }.inObjectScope(.container)
        
        container.register(ProfileAnalytics.self) { r in
            r.resolve(AnalyticsManager.self)!
        }.inObjectScope(.container)
        
        container.register(CourseAnalytics.self) { r in
            r.resolve(AnalyticsManager.self)!
        }.inObjectScope(.container)
        
        container.register(DiscussionAnalytics.self) { r in
            r.resolve(AnalyticsManager.self)!
        }.inObjectScope(.container)
        
        container.register(ConnectivityProtocol.self) { _ in
            Connectivity()
        }
        
        container.register(DatabaseManager.self) { _ in
            DatabaseManager(databaseName: "Database")
        }.inObjectScope(.container)
        
        container.register(CoreDataHandlerProtocol.self) { r in
            r.resolve(DatabaseManager.self)!
        }.inObjectScope(.container)
        
        container.register(CorePersistenceProtocol.self) { r in
            CorePersistence(context: r.resolve(DatabaseManager.self)!.context)
        }.inObjectScope(.container)
        
        container.register(DownloadManagerProtocol.self, factory: { r in
            DownloadManager(persistence: r.resolve(CorePersistenceProtocol.self)!,
                            appStorage: r.resolve(CoreStorage.self)!,
                            connectivity: r.resolve(ConnectivityProtocol.self)!)
        }).inObjectScope(.container)
        
        container.register(AuthorizationRouter.self) { r in
            r.resolve(Router.self)!
        }.inObjectScope(.container)
                
        container.register(DiscoveryRouter.self) { r in
            r.resolve(Router.self)!
        }.inObjectScope(.container)
        
        container.register(ProfileRouter.self) { r in
            r.resolve(Router.self)!
        }.inObjectScope(.container)
        
        container.register(DashboardRouter.self) { r in
            r.resolve(Router.self)!
        }.inObjectScope(.container)
        
        container.register(CourseRouter.self) { r in
            r.resolve(Router.self)!
        }.inObjectScope(.container)
        
        container.register(DiscussionRouter.self) { r in
            r.resolve(Router.self)!
        }.inObjectScope(.container)
        
        container.register(WhatsNewRouter.self) { r in
            r.resolve(Router.self)!
        container.register(Config.self) { _ in
            Config(
                baseURL: BuildConfiguration.shared.baseURL,
                oAuthClientId: BuildConfiguration.shared.clientId,
                webLogin: BuildConfiguration.shared.webLogin
            )
        }.inObjectScope(.container)
        
        container.register(ConfigProtocol.self) { _ in
            Config()
        }.inObjectScope(.container)
        
        container.register(CSSInjector.self) { r in
            CSSInjector(
                config: r.resolve(ConfigProtocol.self)!
            )
        }.inObjectScope(.container)
        
        container.register(KeychainSwift.self) { _ in
            KeychainSwift()
        }.inObjectScope(.container)
        
        container.register(UserDefaults.self) { _ in
            UserDefaults.standard
        }.inObjectScope(.container)
        
        container.register(AppStorage.self) { r in
            AppStorage(
                keychain: r.resolve(KeychainSwift.self)!,
                userDefaults: r.resolve(UserDefaults.self)!
            )
        }.inObjectScope(.container)
        
        container.register(CoreStorage.self) { r in
            r.resolve(AppStorage.self)!
        }.inObjectScope(.container)
        
        container.register(WhatsNewStorage.self) { r in
            r.resolve(AppStorage.self)!
        }.inObjectScope(.container)
        
        container.register(ProfileStorage.self) { r in
            r.resolve(AppStorage.self)!
        }.inObjectScope(.container)
        
        container.register(Validator.self) { _ in
            Validator()
        }.inObjectScope(.container)
    }
}
// swiftlint:enable function_body_length
