//
//  DeveloperToolsController.swift
//  
//
//  Created by IF on 26/06/2019.
//  Copyright © 2019 MobileUp. All rights reserved.
//

import UIKit

// MARK: - MUEnvironment

public struct MUEnvironment {

    // MARK: - Public properties
    
    public let index: String
    public let title: String
    
    // MARK: - Public methods
    
    public init(index: String, title: String) {
        
        self.index = index
        self.title = title
    }
}

// MARK: - MUDeveloperToolsDelegate

public protocol MUDeveloperToolsDelegate: class {

    func developerToolsEnvironmentArray() -> [MUEnvironment]
    func developerToolsDidEnvironmentChanged(with environment: MUEnvironment)
}

// MARK: - MUDeveloperToolsCustomActionDelegate

public protocol MUDeveloperToolsCustomActionDelegate: class {

    func developerToolCustomActionDidTapped(_ developerTools: MUDeveloperToolsController)
}

// MARK: - MUDeveloperToolsController

open class MUDeveloperToolsController: MUViewController {
    
    // MARK: - Overriden properties
    
    public override class var storyboardName: String { return "DeveloperTools" }
    
    // MARK: - Private properties
    
    @IBOutlet private var separatorHeights: [NSLayoutConstraint]!
    
    @IBOutlet private weak var darkView: UIView!
    
    @IBOutlet private weak var connectionErrorSwitcher: UISwitch!
    
    @IBOutlet private weak var serverErrorSwitcher: UISwitch!
    
    @IBOutlet private weak var badConnectionSwitcher: UISwitch!
    
    @IBOutlet private weak var autocompleteFormsSwitcher: UISwitch!
    
    @IBOutlet private weak var webLogsSwitcher: UISwitch!
    
    // MARK: - Overriden methods
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        separatorHeights.forEach { $0.constant = 0.5 }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        dark(true)
        
        updateSwitcherValues()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        dark(false)
    }
    
    // MARK: - Private methods
    
    private func dark(_ on: Bool) {
        
        UIView.animate(withDuration: 0.2) {
            
            self.darkView.backgroundColor = on ? #colorLiteral(red: 0.4547695518, green: 0.4547695518, blue: 0.4547695518, alpha: 0.5) : .clear
        }
    }
    
    private func updateSwitcherValues() {
        
        connectionErrorSwitcher.isOn   = MUDeveloperToolsManager.alwaysReturnConnectionError
        serverErrorSwitcher.isOn       = MUDeveloperToolsManager.alwaysReturnServerError
        badConnectionSwitcher.isOn     = MUDeveloperToolsManager.shouldSimulateBadConnection
        autocompleteFormsSwitcher.isOn = MUDeveloperToolsManager.shouldAutoCompleteForms
        webLogsSwitcher.isOn           = MUDeveloperToolsManager.shouldShowWebLogs
    }
    
    @IBAction private func connectionErrorSwitcherChanged(_ sender: UISwitch) {
        
        MUDeveloperToolsManager.alwaysReturnConnectionError = sender.isOn
        
        NotificationCenter.post(forName: .developToolsDidAlwaysReturnConnectionErrorChanged)
    }
    
    @IBAction private func serverErrorSwitcherChanged(_ sender: UISwitch) {
        
        MUDeveloperToolsManager.alwaysReturnServerError = sender.isOn
    }
    
    @IBAction private func simulateBadConnectionChanged(_ sender: UISwitch) {
        
        MUDeveloperToolsManager.shouldSimulateBadConnection = sender.isOn
    }
    
    @IBAction private func autocompleteSwitcherChanged(_ sender: UISwitch) {
        
        MUDeveloperToolsManager.shouldAutoCompleteForms = sender.isOn
        
        NotificationCenter.post(forName: .developToolsDidAutoCompleteFormsChanged)
    }
    
    @IBAction private func webLogsSwitcherChanged(_ sender: UISwitch) {
        
        MUDeveloperToolsManager.shouldShowWebLogs = sender.isOn
        
        if MUDeveloperToolsManager.shouldShowWebLogs {
            
            MUWebLogsManager.start()
            
            showPopup(title: MUWebLogsManager.url)
            
        } else {
         
            MUWebLogsManager.stop()
        }
    }
    
    @IBAction private func changeEnvironment(_ button: UIButton) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let environments = MUDeveloperToolsManager.delegate?.developerToolsEnvironmentArray() ?? []

        for environment in environments {

            let action = UIAlertAction(

                title   : environment.title,
                style   : .default,
                handler : { [weak self] _ in

                    MUDeveloperToolsManager.delegate?.developerToolsDidEnvironmentChanged(with: environment)

                    self?.dismiss(animated: true)
                }
            )

            alert.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Отмена".localize, style: .cancel, handler: nil)

        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    @IBAction private func customButtonTapped(_ button: UIButton) {

        MUDeveloperToolsManager.customActionDelegate?.developerToolCustomActionDidTapped(self)
    }

    @IBAction private func close() {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func clear(_ sender: Any) {
        
        MULogManager.clear()
    }
}

// MARK: - Notification.Name

public extension Notification.Name {
    
    static let developToolsDidAutoCompleteFormsChanged = Notification.Name("developToolsDidAutoCompleteFormsChanged")
    
    static let developToolsDidAlwaysReturnConnectionErrorChanged = Notification.Name("developToolsDidAlwaysReturnConnectionErrorChanged")
}

// MARK: - MUDeveloperToolsManager

public extension MUDeveloperToolsManager {
    
    // MARK: - Public methods
    
    static func setup() {
        
        NotificationCenter.default.addObserver(forName: .deviceHaveBeenShaken, object: nil, queue: nil) { _ in
            
            guard let topController = UIApplication.presentedViewController() else { return }
            
            show(with: topController)
        }
        
        MUWebLogsManager.setup()
    }
    
    static func show(with topController: UIViewController) {
        
        if topController.isKind(of: MULogsController.self) {
            
            topController.dismiss(animated: true, completion: nil)
            
            return
        }
        
        if topController.isKind(of: MUDeveloperToolsController.self) {
            
            topController.dismiss(animated: true, completion: nil)
            
        } else {
                                    
            let controller = MUDeveloperToolsController.instantiate(
                
                storyboardName : "DeveloperTools",
                identifier     : "MUDeveloperToolsController",
                bundle         : Bundle(for: MUDeveloperToolsController.self)
            )
    
            guard let developerToolsController = controller else { return }

            MUPopupControl.closeAll()
            
            developerToolsController.modalPresentationStyle = .overCurrentContext
            
            topController.present(developerToolsController, animated: true, completion: nil)
        }
    }
}

// MARK: - UIWindow

public extension UIWindow {
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        if MUDeveloperToolsManager.isEnabled == true && motion == .motionShake {
            
            Log.event("Device have been shaken.")
            
            NotificationCenter.default.post(name: .deviceHaveBeenShaken, object: nil)
            
        } else {
            
            super.motionEnded(motion, with: event)
        }
    }
}
