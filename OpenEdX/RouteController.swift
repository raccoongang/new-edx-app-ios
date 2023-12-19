//
//  RouteController.swift
//  OpenEdX
//
//  Created by Vladimir Chekyrta on 13.09.2022.
//

import UIKit
import SwiftUI
import Core
import Authorization
import WhatsNew
import Swinject

class RouteController: UIViewController {
    
    private lazy var navigation: UINavigationController = {
        diContainer.resolve(UINavigationController.self)!
    }()
    
    private lazy var appStorage: CoreStorage = {
        diContainer.resolve(CoreStorage.self)!
    }()
    
    private lazy var analytics: AuthorizationAnalytics = {
        diContainer.resolve(AuthorizationAnalytics.self)!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = appStorage.user, appStorage.accessToken != nil {
            analytics.setUserID("\(user.id)")
            DispatchQueue.main.async {
                self.showMainOrWhatsNewScreen()
            }
        } else {
            DispatchQueue.main.async {
                self.showStartupScreen()
            }
        }
    }
    
    private func showStartupScreen() {
        if let config = Container.shared.resolve(ConfigProtocol.self), config.features.startupScreenEnabled {
            let controller = UIHostingController(
                rootView: StartupView(viewModel: diContainer.resolve(StartupViewModel.self)!))
            navigation.viewControllers = [controller]
            present(navigation, animated: false)
        } else {
            let controller = UIHostingController(
                rootView: SignInView(viewModel: diContainer.resolve(SignInViewModel.self)!)
            )
            navigation.viewControllers = [controller]
            present(navigation, animated: false)
        }
    }

    private func showAuthorization() {
        let controller = UIHostingController(
            rootView: SignInView(viewModel: diContainer.resolve(SignInViewModel.self)!, navigationController: self.navigation)
        )
        navigation.viewControllers = [controller]
        present(navigation, animated: false)
    }
    
    private func showMainOrWhatsNewScreen() {
        var storage = Container.shared.resolve(WhatsNewStorage.self)!
        let config = Container.shared.resolve(ConfigProtocol.self)!

        let viewModel = WhatsNewViewModel(storage: storage)
        let shouldShowWhatsNew = viewModel.shouldShowWhatsNew()

        if shouldShowWhatsNew && config.features.whatNewEnabled {
            if let jsonVersion = viewModel.getVersion() {
                storage.whatsNewVersion = jsonVersion
            }
            let whatsNewView = WhatsNewView(
                router: Container.shared.resolve(WhatsNewRouter.self)!,
                viewModel: viewModel
            )
            let controller = UIHostingController(rootView: whatsNewView)
            navigation.viewControllers = [controller]
        } else {
            let viewModel = Container.shared.resolve(MainScreenViewModel.self)!
            let controller = UIHostingController(rootView: MainScreenView(viewModel: viewModel))
            navigation.viewControllers = [controller]
        }
        present(navigation, animated: false)
    }
}
