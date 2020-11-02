//
//  MUTextFieldViewDelegate.swift
//  FrameOk
//
//  Created by Dmitry Smirnov on 02.11.2020.
//

// MARK: - MUTextFieldViewDelegate

import UIKit

@objc public protocol MUTextFieldViewDelegate: class {

    @objc optional func textFieldViewBeginEditing(_ textFieldView: UIView)
    @objc optional func textFieldViewDidEndEditing(_ textFieldView: UIView)
    @objc optional func textFieldViewShouldReturn(_ textFieldView: UIView)
    @objc optional func textFieldViewChanged(_ textFieldView: UIView)
    @objc optional func textFieldViewButtonDidTap(_ textFieldView: UIView)
    @objc optional func textFieldViewBackwardDidTap(_ textFieldView: UIView)
}
