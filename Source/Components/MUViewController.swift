//
//  MUViewController.swift
//
//  Created by Dmitry Smirnov on 26.03.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUViewController

open class MUViewController: UIViewController {

    // MARK: - LoadMethod

    public enum InstantiateMethod {

        case fromStoryboard, fromNib, none
    }

    // MARK: - Public properties

    public static var defaultInstantiateMethod: InstantiateMethod = .fromStoryboard

    open class var storyboardName: String { return "" }

    open class var storyboardIdentifier: String { return String(describing: self) }

    open class var initMethod: InstantiateMethod { return MUViewController.defaultInstantiateMethod }

    @IBOutlet open weak var keyboardContainer: UIView? { didSet { keyboardControl.containerView = keyboardContainer } }

    open var isErrorRecipient: Bool { return true }

    open var isVisible: Bool { return view.isVisible }

    open var isFirstAppear: Bool = true

    open var interactivePopGestureEnabled: Bool { return true }

    open var shouldRemoveFromNavigation: Bool { return false }

    open var hasNavigationBar: Bool? { return nil }

    open var hasScroll: Bool { return false }

    open var isLoading: Bool = false { didSet { updateStateActivityIndicator() } }

    // MARK: - Controls

    open var keyboardControl = MUKeyboardControl()

    open var indicatorControl = MUActivityIndicatorControl()

    open var loadControl = MULoadControl()

    open var popupControl = MUPopupControl()

    // MARK: - Private properties

    private var isNotificationSubscribed: Bool = false

    private static var viewControllersArray: [String: MUViewControllerContainer] = [:]

    // MARK: Override methods

    open override func viewDidLoad() {

        super.viewDidLoad()

        keyboardControl.setup(with: self)

        popupControl.setup(with: self)

        loadControl.setup(with: self)

        subscribeOnCustomNotifications()
    }

    open override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        configureNavigationBar()

        updateViewControllersArray()

        configureNavigatioBar()

        configureInteractivePopGestureRecognizer()

        subscribeOnNotifications()

        updateErrorRecipient()
    }

    open override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        view.layoutIfNeeded()

        isFirstAppear = false
    }

    open override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        view.endEditing(true)

        unsubscribeFromNotifications()

        removeViewControllersArray()
    }

    open override func viewDidDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        if shouldRemoveFromNavigation {

            navigationController?.remove(controller: self)
        }
    }

    // MARK: - Public methods

    func subscribeOnNotifications() {

        guard isVisible, isNotificationSubscribed == false else { return }

        isNotificationSubscribed = true

        keyboardControl.subscribeOnNotifications()

        subscribeOnErrorNotifications()

        subscribeOnAppNotifications()
    }

    func unsubscribeFromNotifications() {

        isNotificationSubscribed = false

        keyboardControl.unsubscribeOnNotifications()

        NotificationCenter.default.removeObserver(self)
    }

    func subscribeOnCustomNotifications() {

    }

    func appDidBecomeActive() {

    }

    func appWillResignActive() {

    }

    func appErrorDidBecome(error: Error) {

        hideActivityIndicator()

        isLoading = false
    }

    func appErrorDidClear() {

    }

    // MARK: - Public methods

    func close(animated: Bool = true, toRoot: Bool = false, popOnly: Bool = false, completion: (() -> Void)? = nil) {

        popupControl.dismiss()

        if let presentingMUViewController = presentingViewController, popOnly == false {

            presentingMUViewController.dismiss(animated: animated)

            completion?()
        }

        else if let navigationController = navigationController, navigationController.viewControllers.count > 1 {

            if toRoot {

                navigationController.popToRootViewController(animated: animated, completion: completion)
            } else {
                navigationController.popViewController(animated: animated, completion: completion)
            }
        }
    }

    // MARK: - Private methods

    private func configureNavigatioBar() {

        guard let hasNavigationBar = hasNavigationBar else { return }

        navigationController?.setNavigationBarHidden(hasNavigationBar == false, animated: true)
    }

    private func configureInteractivePopGestureRecognizer() {

        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    private func configureNavigationBar() {

        guard let hasNavigationBar = hasNavigationBar else { return }

        navigationController?.setNavigationBarHidden(hasNavigationBar == false, animated: true)
    }

    private func updateViewControllersArray() {

        MUViewController.viewControllersArray[className] = MUViewControllerContainer(with: self)
    }

    private func removeViewControllersArray() {

        MUViewController.viewControllersArray.removeValue(forKey: className)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MUViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        return interactivePopGestureEnabled
    }
}

// MARK: - Errors

public extension MUViewController {

    func updateErrorRecipient() {

        guard isErrorRecipient, isVisible else { return }

        MUErrorManager.recipient = self
    }

    func subscribeOnErrorNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(appErrorNotification), name: .appErrorDidCome, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(appErrorDidClearNotification), name: .appErrorDidClear, object: nil)
    }

    // MARK: - Private methods

    @objc private func appErrorNotification(notification: Notification) {

        guard let notification = notification.userInfo?["notification"] as? MUErrorNotification else {

            return FrameOkError.unknownError.post()
        }

        guard notification.recipient == self else {

            return
        }

        Log.error("error: \(notification)")

        appErrorDidBecome(error: notification.error)
    }

    @objc private func appErrorDidClearNotification(notification: Notification) {

        guard let notification = notification.userInfo?["notification"] as? MUErrorClearNotification else {

            return FrameOkError.unknownError.post()
        }

        guard notification.recipient == self else {

            return
        }

        appErrorDidClear()
    }
}

// MARK: - Instantiate and Presenting

public extension MUViewController {

    func children<T: MUViewController>(sameAs: T.Type) -> T? {

        return children.filter { $0.isKind(of: T.self) }.first as? T
    }

    func find<T: MUViewController>(sameAs: T.Type) -> T? {

        return MUViewController.viewControllersArray["\(T.self)"]?.controller as? T
    }

    static func find<T: MUViewController>() -> T? {

        return MUViewController.viewControllersArray["\(T.self)"]?.controller as? T
    }

    static func getInstantiate<T: MUViewController>(with type: T.Type) -> T? {

        switch T.initMethod {
        case .fromNib        : return T.instantiate()
        case .fromStoryboard : return T.instantiate(storyboardName: T.storyboardName, identifier: T.storyboardIdentifier)
        case .none           : return nil
        }
    }

    @available(*, deprecated, message: "Use getInstantiate(with:)")
    static func getInstantiate<T: MUViewController>() -> T? {

        guard storyboardName != "" else {

            Log.error("error: storyboardName not specified for \(self)")

            return nil
        }

        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)

        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as? T
    }

    func push(

        with controller : UIViewController,
        animated        : Bool = true,
        pushCompletion  : (() -> Void)? = nil
    ) {

        navigationController?.pushViewController(controller, animated: animated) { pushCompletion?() }
    }

    func push<T: MUViewController>(

        with type      : T.Type,
        animated       : Bool = true,
        pushCompletion : (() -> Void)? = nil,
        setup          : ((T) -> Void)? = nil
    ) {

        guard let instantiate = T.getInstantiate(with: T.self) else {

            return
        }

        setup?(instantiate)

        push(

            with           : instantiate,
            animated       : animated,
            pushCompletion : pushCompletion
        )
    }

    func present<T: MUViewController>(

        with type      : T.Type,
        withNavigation : Bool = false,
        animated       : Bool = true,
        style          : UIModalPresentationStyle? = .fullScreen,
        setup          : ((T) -> Void)? = nil

    ) {

        guard let instantiate = T.getInstantiate(with: T.self) else {

            return
        }

        setup?(instantiate)

        var presentedController: UIViewController = instantiate

        if withNavigation {

            presentedController = instantiate.addNavigation()
        }

        if let style = style {

            presentedController.modalPresentationStyle = style
        }

        present(presentedController, animated: animated, completion: {})
    }

    @available(*, deprecated, message: "Use push(with:)")
    static func push<T: MUViewController>(

        to controller  : MUViewController?,
        at index       : Int?            = nil,
        animated       : Bool            = true,
        pushCompletion : (() -> Void)?   = nil,
        setup          : ((T) -> Void)?  = nil)
    {

        guard let instantiate: T = getInstantiate() as? T  else {

            return Log.error("failed to create instantiate for \(self)")
        }

        setup?(instantiate)

        controller?.push(

            with           : instantiate,
            animated       : animated,
            pushCompletion : pushCompletion
        )
    }

    @available(*, deprecated, message: "Use present(with:)")
    static func present<T: MUViewController>(

        in controller : UIViewController?,
        asRoot        : Bool                       = false,
        animated      : Bool                       = true,
        style         : UIModalPresentationStyle?  = .fullScreen,
        setup         : ((T) -> Void)?             = nil

        ) {

        guard let instantiate: T = getInstantiate()  else {

            return
        }

        setup?(instantiate)

        var presentedController: UIViewController = instantiate

        if asRoot {

            if let navigationController = findNavigationController(storyboardName: storyboardName) {

                navigationController.setViewControllers([instantiate], animated: false)

                presentedController = navigationController

            } else {

                presentedController = createNavigationController(with: instantiate)
            }
        }

        if let style = style {

            presentedController.modalPresentationStyle = style
        }

        controller?.present(presentedController, animated: animated, completion: {})
    }

    @available(*, deprecated, message: "")
    func insert<T: MUViewController>(

        controller screen     : T.Type,
        into insertTargetView : UIView?         = nil,
        to appendTargetView   : UIView?         = nil,
        setup                 : ((T) -> Void)?  = nil
    ) {

        guard let instantiate: T = screen.getInstantiate() else {

            return
        }

        setup?(instantiate)

        addChild(instantiate)

        instantiate.didMove(toParent: self)

        if let appendTargetView = appendTargetView {

            instantiate.view.frame = appendTargetView.frame

            view.insertSubview(instantiate.view, aboveSubview: appendTargetView)

        } else {

            (insertTargetView ?? view).addSubview(instantiate.view)
        }

        instantiate.view.appendConstraints(to: insertTargetView ?? view)
    }

    func insert(controller instantiate: UIViewController, into insertTargetView: UIView? = nil) {

        addChild(instantiate)

        (insertTargetView ?? view).addSubview(instantiate.view)

        instantiate.view.appendConstraints(to: insertTargetView ?? view)

        instantiate.didMove(toParent: self)
    }

    func remove(child controller: UIViewController) {

        controller.willMove(toParent: nil)

        controller.view.removeFromSuperview()

        controller.removeFromParent()
    }

    func addNavigation(barHidden: Bool = true) -> UINavigationController {

        let navigationController = UINavigationController(rootViewController: self)

        navigationController.isNavigationBarHidden = barHidden

        return navigationController
    }

    @available(*, deprecated, message: "Use addNavigation(barHidden:)")
    static func createNavigationController(with controller: MUViewController) -> UINavigationController {

        let navigationController = UINavigationController(rootViewController: controller)

        navigationController.isNavigationBarHidden = true

        return navigationController
    }

    @available(*, deprecated, message: "")
    static func findNavigationController(storyboardName: String) -> UINavigationController? {

        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)

        return storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
    }
}

// MARK: - Activity indicator

public extension MUViewController {

    @available(*, deprecated, message: "Use isLoading property")
    func showActivityIndicator(on view: UIView? = nil, delay: TimeInterval = 0.6) {

        loadControl.isLoading = true

        indicatorControl.showIndicator(above: view ?? self.view, delay: delay)
    }

    @available(*, deprecated, message: "Use isLoading property")
    func hideActivityIndicator() {

        loadControl.isLoading = false

        indicatorControl.hideIndicator()
    }

    func updateStateActivityIndicator() {

        loadControl.isLoading = isLoading

        if isLoading {

            indicatorControl.showIndicator(above: view, delay: 0.6)
        } else {
            indicatorControl.hideIndicator()
        }
    }
}

// MARK: - App

extension MUViewController {

    @objc private func appNotification(notification: Notification) {

        switch notification.name {

        case .appDidBecomeActive: appDidBecomeActive()
        case .appWillResignActive: appWillResignActive()
        default: break
        }
    }

    private func subscribeOnAppNotifications() {

        NotificationCenter.addObserver(self, selector: #selector(appNotification), name: .appDidBecomeActive)
        NotificationCenter.addObserver(self, selector: #selector(appNotification), name: .appWillResignActive)
    }
}

// MARK: - Notification

public extension Notification.Name {

    static let appDidBecomeActive     = Notification.Name("appDidBecomeActive")
    static let appWillResignActive    = Notification.Name("appWillResignActive")
    static let appDidEnterBackground  = Notification.Name("appDidEnterBackground")
    static let appWillEnterBackground = Notification.Name("appWillEnterBackground")
}

// MARK: - MUViewControllerContainer

open class MUViewControllerContainer {

    weak var controller: MUViewController?

    convenience init(with controller: MUViewController) {

        self.init()

        self.controller = controller
    }
}

// MARK: - UIViewController

public extension UIViewController {

    static func instantiate() -> Self {

        let controller = Self(nibName: String(describing: self), bundle: nil)

        return controller
    }

    static func instantiate(storyboardName: String, identifier: String) -> Self? {

        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)

        return storyboard.instantiateViewController(withIdentifier: identifier) as? Self
    }
}
