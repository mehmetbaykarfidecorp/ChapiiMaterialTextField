//
//  ChapiiMaterialTextField.swift
//  ChapiiMaterialTextField
//
//  Created by Mehmet Baykar on 25/08/2022.
//  Copyright © 2022 Chapii. All rights reserved.
//

import UIKit

open class ChapiiMaterialTextField: UITextField {
    
    //  MARK: - Open variables -
    
    /**
     * Sets hint color for not focused state
     */
    open var inactiveHintColor = UIColor.black {
        didSet { configureHint() }
    }
    
    /**
     * Sets hint color for focused state
     */
    open var activeHintColor = UIColor.black
    
    /**
     * Sets background color for not focused state
     */
    open var defaultBackgroundColor = UIColor.clear {
        didSet { backgroundColor = defaultBackgroundColor }
    }
    
    open var defaultBorderColor = UIColor.lightGray{
        didSet{
            layer.borderColor = defaultBorderColor.cgColor
        }
    }
    
    open var defaultHintFont: UIFont{
        set { hintLabel.font = newValue }
        get { return hintLabel.font }
    }
    
    /**
    * Sets background color for focused state
    */
    open var focusedBackgroundColor = UIColor.clear
    
    open var focusedBorderColor = UIColor.clear
    
    /**
    * Sets border width
    */
    open var borderWidth: CGFloat = 1.0 {
        didSet { layer.borderWidth = borderWidth }
    }
    
    /**
    * Sets corner radius
    */
    open var cornerRadius: CGFloat = 10 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    /**
    * Sets error color
    */
    open var errorColor = UIColor.red {
        didSet { errorLabel.textColor = errorColor }
    }
    
    override open var placeholder: String? {
        set { hintLabel.text = newValue }
        get { return hintLabel.text }
    }
    
    
    public override var text: String? {
        didSet { updateHint() }
    }
    
    private var isHintVisible = false
    private let hintLabel = UILabel()
    private let errorLabel = UILabel()
    
    private let padding: CGFloat = 16
    private var initialBoundsWereCalculated = false
    
    //  MARK: Public
    
    public func setError(errorString: String) {
        UIView.animate(withDuration: 0.4) {
            self.layer.borderColor = self.errorColor.cgColor
            self.errorLabel.alpha = 1
        }
        errorLabel.text = errorString
        updateErrorLabelPosition()
        errorLabel.shake(offset: 10)
    }
    
    //  MARK: Private
    
    private func initializeTextField() {
        configureTextField()
        configureHint()
        configureErrorLabel()
        addObservers()
    }
    
    private func addObservers() {
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func configureTextField() {
        autocorrectionType = .no
        spellCheckingType = .no
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        addSubview(hintLabel)
    }
    
    private func configureHint() {
        hintLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        updateHint()
        hintLabel.textColor = inactiveHintColor
    }

    private func updateHint() {
        if isHintVisible {
            // Small placeholder
            hintLabel.alpha = 1
            hintLabel.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -hintHeight())
        } else if text?.isEmpty ?? true {
            // Large placeholder
            hintLabel.alpha = 1
            hintLabel.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
        }
    }
    
    private func configureErrorLabel() {
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textAlignment = .right
        errorLabel.textColor = errorColor
        errorLabel.alpha = 0
        addSubview(errorLabel)
    }
    
    private func activateTextField() {
        if isHintVisible { return }
        isHintVisible.toggle()
        
        UIView.animate(withDuration: 0.2) {
            self.updateHint()
            self.hintLabel.textColor = self.activeHintColor
            self.backgroundColor = self.focusedBackgroundColor
            self.layer.borderColor = self.focusedBorderColor.cgColor
        }
    }
    
    private func deactivateTextField() {
        if !isHintVisible { return }
        isHintVisible.toggle()
        
        UIView.animate(withDuration: 0.2) {
            self.updateHint()
            self.hintLabel.textColor = self.inactiveHintColor
            self.backgroundColor = self.defaultBackgroundColor
            self.layer.borderColor = self.defaultBorderColor.cgColor
        }
    }
    
    private func hintHeight() -> CGFloat {
        return defaultHintFont.lineHeight - padding / 8
    }
    
    private func updateErrorLabelPosition() {
        let size = errorLabel.sizeThatFits(CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        errorLabel.frame.size = size
        errorLabel.frame.origin.x = frame.width - size.width
        errorLabel.frame.origin.y = frame.height + padding / 4
    }
    
    @objc private func textFieldDidChange() {
        UIView.animate(withDuration: 0.2) {
            self.errorLabel.alpha = 0
            self.layer.borderColor = self.focusedBorderColor.cgColor

        }
    }
    
    //  MARK: UIKit methods
    
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        activateTextField()
        return super.becomeFirstResponder()
    }

    @discardableResult
    override open func resignFirstResponder() -> Bool {
        deactivateTextField()
        return super.resignFirstResponder()
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds)
        let rect = CGRect(
            x: padding,
            y: hintHeight() - padding / 8,
            width: superRect.size.width - padding * 1.5,
            height: superRect.size.height
        )
        return rect
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
       textRect(forBounds: bounds)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.size.width, height: 64)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if !initialBoundsWereCalculated {
            hintLabel.frame = CGRect(
                origin: CGPoint(x: padding, y: 0),
                size: CGSize(width: frame.width - padding * 3, height: frame.height)
            )
            initialBoundsWereCalculated = true
        }
    }
    
    //  MARK: Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeTextField()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeTextField()
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let offset = 15.0
        let width  = 22.0
        let height = 12.0
        let x = bounds.width - width - offset
        let y =  (bounds.height / 2.0)
        let rightViewBounds = CGRect(x: x, y: y, width: width, height: height)
        return rightViewBounds
    }
}
