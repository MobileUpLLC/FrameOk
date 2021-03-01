//
//  MUFormController.swift
//
//  Created by Dmitry Smirnov on 09.04.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - VerifyFieldProtocol

public protocol VerifyFieldProtocol {
    
    var value: String { set get }
    
    var isError: Bool   { set get }
    
    func setError(on: Bool, message: String?)
}

// MARK: - VerifyObject

private struct VerifyObject {
    
    var field: VerifyFieldProtocol
    
    var rules: [MUValidateRule]
    
    var message: String?
}

// MARK: - FieldValidationOption

public enum ValidationOption: String {
   
    case all, filledOnly, activeFieldOnly
}

// MARK: - MUFormController

open class MUFormController: MUViewController {
    
    // MARK: - Behavior properties
    
    open var isPresented: Bool = false
    
    // MARK: - Public properties
    
    open var fieldsValidation: ValidationOption { return .all }
    
    open var isValid: Bool { return !hasError }
    
    open var isFilled: Bool { return verifyObjects.first { $0.field.value.isEmpty } == nil }
    
    @IBOutlet open weak var submitButton: UIButton?
    
    @IBOutlet open weak var continueButton: UIButton?
    
    private(set) var activeEditedField: UIView?
        
    // MARK: - Private properties
    
    private var hasError: Bool = false
    
    private var verifyObjects: [VerifyObject] = []
    
    private var isDisappearing: Bool = false
    
    // MARK: - Public methods
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(submitButtonTap)))
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        
        isDisappearing = false
    
        super.viewWillAppear(animated)
        
        view.layoutIfNeeded()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        view.layoutIfNeeded()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        isDisappearing = true
    }
    
    open func removeAllVerifications() {
        
        verifyObjects.removeAll(keepingCapacity: false)
    }
    
    open func addVerify(field: VerifyFieldProtocol?, rules: [MUValidateRule], message: String? = nil) {
        
        guard let field = field else {
            
            return
        }
        
        verifyObjects.append(VerifyObject(field: field, rules: rules, message: message))
    }
    
    open func fieldChanged(_ field: UIView) {
        
    }
    
    open func fieldBeginEditing(_ field: UIView) {
        
    }
    
    open func validateWhenEditing() {
        
        hasError = false
        
        for object in verifyObjects {
            
            let isValid = MUValidateManager.shared.checkIsValid(value: object.field.value, match: object.rules)
            
            if isValid {
                
                object.field.setError(on: false, message: object.message)
                
            } else {
                
                hasError = true
            }
        }
        
        afterValidate()
    }
    
    open func validate(validation: ValidationOption = .all) {
        
        guard isDisappearing == false else { return }
        
        hasError = false
        
        for object in getObjects(with: validation) {

            let isError = !MUValidateManager.shared.checkIsValid(value: object.field.value, match: object.rules)

            object.field.setError(on: isError, message: object.message)

            if isError {

                hasError = true
            }
        }
        
        if !customValidate() {
            
            hasError = true
        }
        
        afterValidate()
    }
    
    open func customValidate() -> Bool {
        
        return true
    }
    
    open func afterValidate() {
        
        updateSubmitButton()
    }
    
    open func submitForm() {

    }
    
    open func deleteBackward(_ field: UIView) {
        
    }
    
    // MARK: - Private methods
    
    private func getObjects(with validation: ValidationOption) -> [VerifyObject] {
        
        switch validation {
        case .filledOnly      : return verifyObjects.filter { $0.field.value.isEmpty }
        case .activeFieldOnly : return hasNextActiveField ? verifyObjects.filter { (findTextFieldView(in: $0) as? UIView) == activeEditedField } : verifyObjects
        default               : return verifyObjects
        }
    }
    
    private func checkThatNextFieldAllowed() -> Bool {
        
        switch fieldsValidation {
        case .activeFieldOnly : return true
        default               : return false
        }
    }
    
    private func checkAllRequiredFieldsNotEmpty(validation: ValidationOption = .all) -> Bool {
        
        for object in getObjects(with: validation) {
            
            if MUValidateManager.shared.checkIsRequiredFilled(value: object.field.value, match: object.rules) == false {
                
                return false
            }
        }
        
        return true
    }
    
    private func getField(after position: Int) -> VerifyFieldProtocol? {
        
        guard position + 1 < verifyObjects.count else {
            
            return nil
        }
        
        return verifyObjects[position + 1].field
    }
    
    private func findTextFieldView(in object: VerifyObject) -> VerifyFieldProtocol? {
        
        guard let field = (object.field as? UIView) else { return nil }
        
        let allViews = [field] + field.allSubviews()
        
        return allViews.first { $0 is VerifyFieldProtocol } as? VerifyFieldProtocol
    }
    
    @objc private func submitButtonTap() {
        
        validate()
        
        guard isValid else { return }
        
        view.endEditing(true)
        
        submitForm()
    }
    
    private func updateSubmitButton() {
        
        continueButton?.isEnabled = isValid
        
        submitButton?.isEnabled = checkAllRequiredFieldsNotEmpty()
    }
}

// MARK: - MUTextFieldViewDelegate

extension MUFormController: MUTextFieldViewDelegate {
    
    open func textFieldViewChanged(_ textFieldView: UIView) {
        
        validateWhenEditing()
        
        fieldChanged(textFieldView)
    }
    
    open func textFieldViewBeginEditing(_ textFieldView: UIView) {
        
        activeEditedField = textFieldView
        
        fieldBeginEditing(textFieldView)
    }
    
    open func textFieldViewDidEndEditing(_ textFieldView: UIView) {
        
        activeEditedField = nil
        
        validate()
    }
    
    open func textFieldViewShouldReturn(_ textFieldView: UIView) {
        
        for (index, object) in verifyObjects.enumerated() {
            
            let isSubview: Bool = (object.field as? UIView)?.allSubviews().contains(textFieldView) ?? false
            
            guard isSubview, (object.field as? UIView) == textFieldView else { continue }
            
            validate(validation: fieldsValidation)
            
            if let nextField = getField(after: index) {
                
                guard !object.field.isError || checkThatNextFieldAllowed() else { return }
                
                (nextField as? UIView)?.becomeFirstResponder()
                
            } else {
                
                guard isValid else { return }
                
                view.endEditing(true)
                
                submitForm()
            }
            
            return
        }
    }
    
    open func textFieldViewBackwardDidTap(_ textFieldView: UIView) {
        
        deleteBackward(textFieldView)
    }
}

// MARK: - MUFormController

public extension MUFormController {
    
    // MARK: - Public properties
    
    var hasNextActiveField: Bool { return nextActiveField == nil ? false : true }
    
    var nextActiveField: UIView? {
        
        for (index, object) in verifyObjects.enumerated() where checkActiveEditedField(with: object.field) {
            
            return getField(after: index) as? UIView
        }
        
        return nil
    }
    
    // MARK: - Private methods
    
    private func checkActiveEditedField(with object: VerifyFieldProtocol) -> Bool {
        
        guard
            
            let activeEditedField = activeEditedField,
            
            let verifyField = object as? UIView,
            
            let textField = verifyField.allSubviews().filter({ $0 is VerifyFieldProtocol }).first,
            
            textField == activeEditedField
            
        else {
                
            return false
        }
        
        return true
    }
}
