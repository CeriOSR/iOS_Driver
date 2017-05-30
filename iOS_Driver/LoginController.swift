//
//  EmailPhoneLoginController.swift
//  iOS_persian
//
//  Created by Rey Cerio on 2017-05-27.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .emailAddress
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.placeholder = "email"
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 6.0
        tf.layer.masksToBounds = true
        return tf
    }()
    
    let phoneTextField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .numberPad
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.placeholder = "phone # no spaces"
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 6.0
        tf.layer.masksToBounds = true
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.isSecureTextEntry = true
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.placeholder = "password"
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 6.0
        tf.layer.masksToBounds = true
        return tf
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let orLabel1: UILabel = {
        let label = UILabel()
        label.text = "or"
        return label
    }()
    
    let orLabel2: UILabel = {
        let label = UILabel()
        label.text = "or"
        return label
    }()

    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.addTarget(self, action: #selector(handleRegisterButton), for: .touchUpInside)
        return button
    }()
    
    
    lazy var driverOrDispatcherSegCon: UISegmentedControl = {
        let segCon = UISegmentedControl(items: ["Dispatcher", "Driver"])
        segCon.selectedSegmentIndex = 0
        segCon.addTarget(self, action: #selector(hideTrackerEmailTextField), for: .valueChanged)
        return segCon
    }()
    
    let trackerEmailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "tracker email"
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 6.0
        tf.layer.masksToBounds = true
        tf.isHidden = false
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func hideTrackerEmailTextField() {
        if driverOrDispatcherSegCon.selectedSegmentIndex == 0 {
            trackerEmailTextField.isHidden = true
        } else {
            trackerEmailTextField.isHidden = false
        }
    }
    
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(phoneTextField)
        view.addSubview(loginButton)
        view.addSubview(orLabel1)
        view.addSubview(registerButton)
        view.addSubview(trackerEmailTextField)
        view.addSubview(orLabel2)

        view.addConstraintsWithVisualFormat(format: "H:|-50-[v0]-50-|", views: emailTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-170-[v0(20)]", views: orLabel1)
        view.addConstraintsWithVisualFormat(format: "H:|-50-[v0]-50-|", views: phoneTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-50-[v0]-50-|", views: passwordTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-156-[v0(50)]", views: loginButton)
        view.addConstraintsWithVisualFormat(format: "H:|-170-[v0(20)]", views: orLabel2)
        view.addConstraintsWithVisualFormat(format: "H:|-150-[v0(65)]", views: registerButton)



        view.addConstraintsWithVisualFormat(format: "V:|-100-[v0(40)]-10-[v1(20)]-10-[v2(40)]-10-[v3(40)]-30-[v4(40)]-10-[v5(20)]-10-[v6(40)]", views: emailTextField, orLabel1, phoneTextField, passwordTextField, loginButton, orLabel2, registerButton)
    }
    
    func handleLogin(){
        guard let password = passwordTextField.text else {return}
        if emailTextField.text == "" && phoneTextField.text == "" {
            self.createAlert(title: "Invalid email or phone #", message: "Please enter a valid email or phone number.")
        }
        if emailTextField.text == "" {
            guard let phoneAuth = phoneTextField.text else {return}
    
        } else {
            guard let emailAuth = emailTextField.text else {return}
            Auth.auth().signIn(withEmail: emailAuth, password: password) { (user, error) in
                if error != nil {
                    self.createAlert(title: "Login Failed.", message: "Please try again.")
                }
                let driverController = DriverController()
                let navController = UINavigationController(rootViewController: driverController)
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func handleRegisterButton() {
        let registerController = RegisterController()
        let navController = UINavigationController(rootViewController: registerController)
        self.present(navController, animated: true, completion: nil)
    }
 
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            //self.dismiss(animated: true, completion: nil)
            return
        }))
        self.present(alert, animated: true, completion: nil)
    }


}
