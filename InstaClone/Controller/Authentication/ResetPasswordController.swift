//
//  ResetPasswordController.swift
//  InstaClone
//
//  Created by Ronan Mak on 29/3/2022.
//

import UIKit

protocol ResetPasswordControllerDelegate: AnyObject {
    func controllerDidSendPasswordLink(_ controller: ResetPasswordController)
}

class ResetPasswordController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel = resetPasswordViewModel()
    private let emailTextField = CustomTextField("Email")
    
    var email: String?
    
    weak var delegate: ResetPasswordControllerDelegate?
    
    private let iconImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Instagram_logo_white"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let resetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray.withAlphaComponent(0.5)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        configureUI()
    }
    
    // MARK: - Actions
    
    @objc func handleResetPassword() {
        guard let email = emailTextField.text else { return }
        showLoader(true)
        AuthService.resetPassword(with: email) { error in
            
            if let error = error {
                self.showMessage(withTitle: "Error", message: error.localizedDescription)
                self.showLoader(false)
                return
            }
             
            self.delegate?.controllerDidSendPasswordLink(self)
        }
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        }
        updateForm()
    }
    
    @objc func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        configureGradientLayer()
        
        emailTextField.text = email
        updateForm()
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16)
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        iconImage.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            paddingTop: 32
        )
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, resetPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(
            top: iconImage.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 32,
            paddingLeft: 32,
            paddingRight: 32
        )
    }
}

// MARK: - FormViewModel

extension ResetPasswordController: FormViewModel {
    func updateForm() {
        resetPasswordButton.backgroundColor = viewModel.buttonBackgroundColor
        resetPasswordButton.setTitleColor((viewModel.buttonTitleColor), for: .normal)
        resetPasswordButton.isEnabled = viewModel.formIsValid
    }
}
  
