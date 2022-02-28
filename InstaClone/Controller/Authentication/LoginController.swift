//
//  LoginController.swift
//  InstaClone
//
//  Created by Ronan Mak on 19/2/2022.
//

import UIKit

protocol AuthenticationDelegate: AnyObject {
    func authenticationDidComplete()
}

class LoginController: UIViewController {
    
    // MARK: - Properties
    private var viewModel = LoginViewModel()

    // make sure it's a weak reference and not a strong reference, because if you have two strong references like a viewController or a class, it's gonna be hard for the memory management to destory both of those strong references. Then you will get what's known as a retained cycle where one of the references never gets deleted. So it causes a retained cycle which damages the performance of your application and cause memory leaks.
    weak var delegate: AuthenticationDelegate?
    
    private let iconImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Instagram_logo_white"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // TextField
    
    private let emailTextField: UITextField = {
        let textField = CustomTextField("Email")
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = CustomTextField("Password")
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray.withAlphaComponent(0.5)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Forgot your password? ", secondPart: "contact us")
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Register an account? ", secondPart: "Sign Up")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }
    
    // MARK: - Actions
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        AuthService.logUserIn(with: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: filed to log user in \(error.localizedDescription)")
                return
            }
            
            self.delegate?.authenticationDidComplete()
        }
    }
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        updateForm()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        
        //                let barAppearance = UINavigationBarAppearance()
        //                barAppearance.backgroundColor = .blue
        //                barAppearance.backgroundEffect = UIBlurEffect(style: .dark)
        //                navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        
        configureGradientLayer()
        
        view.backgroundColor = .black
        // status bar color like time, wifi connection, battary color
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        iconImage.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            paddingTop: 32
        )
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, forgotPasswordButton])
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
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}
// MARK: - FormViewModel

extension LoginController: FormViewModel {
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.setTitleColor((viewModel.buttonTitleColor), for: .normal)
        loginButton.isEnabled = viewModel.formIsValid
    }
}
