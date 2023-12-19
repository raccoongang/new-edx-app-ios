//
//  AppDelegate.swift
//  OpenEdX
//
//  Created by Vladimir Chekyrta on 13.09.2022.
//

import UIKit
import Core
import Swinject
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import Profile
import GoogleSignIn
import FacebookCore
import MSAL
import Theme
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var shared: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow?
        
    private var assembler: Assembler?
    
    private var lastForceLogoutTime: TimeInterval = 0
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        initDI()
        
        if let config = Container.shared.resolve(ConfigProtocol.self) {
            if let configuration = config.firebase.firebaseOptions {
                FirebaseApp.configure(options: configuration)
                Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
            }

            if config.facebook.enabled {
                ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions
                )
            }
        }

        Theme.Fonts.registerFonts()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RouteController()
        window?.makeKeyAndVisible()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(forceLogoutUser),
            name: .onTokenRefreshFailed,
            object: nil
        )
        
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if url.host == "oauth2Callback" {
          // TODO: Update to better match the other OAuth redirect behaviors
          OAuthSwift.handle(url: url)
        }
        if let config = Container.shared.resolve(ConfigProtocol.self) {
            if config.facebook.enabled {
                ApplicationDelegate.shared.application(
                    app,
                    open: url,
                    sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                    annotation: options[UIApplication.OpenURLOptionsKey.annotation]
                )
            }

            if config.google.enabled {
                return GIDSignIn.sharedInstance.handle(url)
            }

            if config.microsoft.enabled {
                return MSALPublicClientApplication.handleMSALResponse(
                    url,
                    sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
                )
            }
        return true
    }
    
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        //Allows external windows, such as WebView Player, to work in any orientation
        if window == self.window {
            return UIDevice.current.userInterfaceIdiom == .phone ? orientationLock : .all
        } else {
            return UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
        }

        return false
    }

    private func initDI() {
        let navigation = UINavigationController()
        navigation.modalPresentationStyle = .fullScreen
        
        assembler = Assembler(
            [
                AppAssembly(navigation: navigation),
                NetworkAssembly(),
                ScreenAssembly()
            ],
            container: Container.shared
        )
    }
    
    @objc private func forceLogoutUser() {
        guard Date().timeIntervalSince1970 - lastForceLogoutTime > 5 else {
            return
        }
        let analytics = Container.shared.resolve(AnalyticsManager.self)
        analytics?.userLogout(force: true)
        
        lastForceLogoutTime = Date().timeIntervalSince1970
        
        Container.shared.resolve(CoreStorage.self)?.clear()
        Container.shared.resolve(DownloadManagerProtocol.self)?.deleteAllFiles()
        Container.shared.resolve(CoreDataHandlerProtocol.self)?.clear()
        window?.rootViewController = RouteController()
    }
    
}
