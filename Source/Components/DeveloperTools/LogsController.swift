//
//  LogsController.swift
//  
//
//  Created by IF on 25/06/2019.
//  Copyright © 2019 MobileUp. All rights reserved.
//

import UIKit

// MARK: - LogsController

class LogsController: MUViewController {

    // MARK: - Overriden properties
    
    override class var storyboardName: String { return "DeveloperTools" }
    
    // MARK: - Private properties
    
    @IBOutlet private weak var textView: UITextView!
    
    @IBOutlet private var filterButtons: [UIButton]!
    
    private var selectedTypes: [MULogLevel] {
        
        return filterButtons.compactMap({ (button: UIButton) -> MULogLevel? in
            
            return button.isSelected ? MULogLevel(value: button.tag) : nil
        })
    }
    
    // MARK: - Overriden methods
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.textView.text = MULogManager.collectedLogs()
    }
    
    // MARK: - Private methods
    
    @IBAction private func close() {
    
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func copyButtonTapped() {
        
        UIPasteboard.general.string = MULogManager.collectedLogs()
    }
    
    @IBAction private func filterLogs(_ sender: UIButton) {
        
        sender.isSelected = sender.isSelected == false
        
        textView.text = MULogManager.collectedLogs(selectedTypes)
    }
}

// MARK: - MULogLevel

extension MULogLevel {
    
    init(value: Int) {
        switch value {
        case 0  : self = .details
        case 1  : self = .event
        case 2  : self = .error
        case 3  : self = .critical
        default : self = .details
        }
    }
}
