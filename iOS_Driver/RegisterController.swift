//
//  RegisterController.swift
//  iOS_Driver
//
//  Created by Rey Cerio on 2017-05-28.
//  Copyright © 2017 Rey Cerio. All rights reserved.
//

import UIKit
import Firebase

class RegisterController: UIViewController {
    
    let nameTextField: UITextField = {
        
        let tf = UITextField()
        tf.placeholder = "name"
        tf.autocapitalizationType = .words
        tf.layer.cornerRadius = 6.0
        tf.borderStyle = .roundedRect
        tf.layer.masksToBounds = true
        return tf
    }()

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
    
    let trackerPhoneNumberTextField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .numberPad
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.placeholder = "tracker phone number"
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
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))

        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(nameTextField)
        view.addSubview(phoneTextField)
        view.addSubview(orLabel1)
        view.addSubview(registerButton)
        view.addSubview(orLabel2)
        
        
        view.addConstraintsWithVisualFormat(format: "H:|-50-[v0]-50-|", views: nameTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-50-[v0]-50-|", views: emailTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-170-[v0(20)]", views: orLabel1)
        view.addConstraintsWithVisualFormat(format: "H:|-50-[v0]-50-|", views: phoneTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-50-[v0]-50-|", views: passwordTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-170-[v0(20)]", views: orLabel2)
        view.addConstraintsWithVisualFormat(format: "H:|-150-[v0(65)]", views: registerButton)
        
        
        
        view.addConstraintsWithVisualFormat(format: "V:|-100-[v0(40)]-4-[v1(40)]-10-[v2(40)]-10-[v3(40)]-30-[v4(40)]", views: nameTextField, emailTextField, phoneTextField, passwordTextField, registerButton)

    }

    func handleRegister() {
        guard let userEmail = emailTextField.text, let userPhone = phoneTextField.text, let userName = nameTextField.text,  let password = passwordTextField.text else {
            self.createAlert(title: "Empty Fields", message: "Please fill all the fields.")
            return
        }
        let values = ["email": userEmail, "phoneNumber": userPhone, "name": userName, "trackerId": "Pending dispatcher acceptance", "password": password]
        Auth.auth().createUser(withEmail: userEmail, password: password) { (user, error) in
            if error != nil {
                print(error ?? "unknown error")
                self.createAlert(title: "Registration Failed", message: "Please try again.")
            }
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let databaseRef = Database.database().reference().child("CER_drivers").child(uid)
            databaseRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error ?? "unknown error")
                    return
                }
                let registrationFanRef = Database.database().reference().child("CER_Pending_Drivers")
                registrationFanRef.updateChildValues([uid: userEmail], withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error ?? "unknown error")
                        return
                    }
                    self.emailTextField.text = ""
                    self.phoneTextField.text = ""
                    self.nameTextField.text = ""
                    self.trackerPhoneNumberTextField.text = ""
                    self.passwordTextField.text = ""
                    let driverController = DriverController()
                    let navController = UINavigationController(rootViewController: driverController)
                    self.present(navController, animated: true, completion: nil)
                })
            })
        }
    }
    
    func handleBack() {
        let loginController = LoginController()
        self.present(loginController, animated: true, completion: nil)
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
