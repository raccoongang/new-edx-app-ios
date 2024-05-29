//
//  Router.swift
//  Core
//
//  Created by Vladimir Chekyrta on 13.09.2022.
//

import Foundation
import SwiftUI

//sourcery: AutoMockable
public protocol BaseRouter {
    
    func backToRoot(animated: Bool)
    
    func back(animated: Bool)
    
    func backWithFade()
    
    func dismiss(animated: Bool)
    
    func removeLastView(controllers: Int)

    func showMainOrWhatsNewScreen(sourceScreen: LogistrationSourceScreen)
    
    func showStartupScreen()
    
    func showLoginScreen(sourceScreen: LogistrationSourceScreen)
    
    func showRegisterScreen(sourceScreen: LogistrationSourceScreen)
    
    func showForgotPasswordScreen()
    
    func showDiscoveryScreen(searchQuery: String?, sourceScreen: LogistrationSourceScreen)

    func showWebBrowser(title: String, url: URL)

    func presentAlert(
        alertTitle: String,
        alertMessage: String,
        positiveAction: String,
        onCloseTapped: @escaping () -> Void,
        okTapped: @escaping () -> Void,
        type: AlertViewType
    )
    
    func presentAlert(
        alertTitle: String,
        alertMessage: String,
        nextSectionName: String?,
        action: String,
        image: SwiftUI.Image,
        onCloseTapped: @escaping () -> Void,
        okTapped: @escaping () -> Void,
        nextSectionTapped: @escaping () -> Void
    )
    
    func presentView(transitionStyle: UIModalTransitionStyle, view: any View, completion: (() -> Void)?)
    
    func presentView(transitionStyle: UIModalTransitionStyle, animated: Bool, content: () -> any View)
    @MainActor
    func showUpgradeInfo(productName: String, sku: String, courseID: String, screen: CourseUpgradeScreen) async
    @MainActor
    func hideUpgradeInfo(animated: Bool) async
    @MainActor
    func showUpgradeLoaderView(animated: Bool) async
    @MainActor
    func hideUpgradeLoaderView(animated: Bool) async
}

extension BaseRouter {
    public func backToRoot(animated: Bool = true) {
        backToRoot(animated: animated)
    }
    
    public func back(animated: Bool = true) {
        back(animated: animated)
    }
}

// Mark - For testing and SwiftUI preview
#if DEBUG
open class BaseRouterMock: BaseRouter {

    public init() {}

    public func dismiss(animated: Bool) {}

    public func showMainOrWhatsNewScreen(sourceScreen: LogistrationSourceScreen) {}
    
    public func showStartupScreen() {}

    public func showLoginScreen(sourceScreen: LogistrationSourceScreen) {}
    
    public func showRegisterScreen(sourceScreen: LogistrationSourceScreen) {}
    
    public func showForgotPasswordScreen() {}
    
    public func showDiscoveryScreen(searchQuery: String?, sourceScreen: LogistrationSourceScreen) {}
    
    public func backToRoot(animated: Bool) {}
        
    public func back(animated: Bool) {}
    
    public func backWithFade() {}
    
    public func removeLastView(controllers: Int) {}

    public func showWebBrowser(title: String, url: URL) {}

    public func presentAlert(
        alertTitle: String,
        alertMessage: String,
        positiveAction: String,
        onCloseTapped: @escaping () -> Void,
        okTapped: @escaping () -> Void,
        type: AlertViewType
    ) {}
    
    public func presentAlert(
        alertTitle: String,
        alertMessage: String,
        nextSectionName: String? = nil,
        action: String,
        image: SwiftUI.Image,
        onCloseTapped: @escaping () -> Void,
        okTapped: @escaping () -> Void,
        nextSectionTapped: @escaping () -> Void
    ) {}

    public func presentView(transitionStyle: UIModalTransitionStyle, view: any View, completion: (() -> Void)?) {}

    public func presentView(transitionStyle: UIModalTransitionStyle, animated: Bool, content: () -> any View) {}
    
    @MainActor
    public func showUpgradeInfo(productName: String, sku: String, courseID: String, screen: CourseUpgradeScreen) async {}
    @MainActor
    public func hideUpgradeInfo(animated: Bool) async {}
    @MainActor
    public func showUpgradeLoaderView(animated: Bool) async {}
    @MainActor
    public func hideUpgradeLoaderView(animated: Bool) async {}
}
#endif
