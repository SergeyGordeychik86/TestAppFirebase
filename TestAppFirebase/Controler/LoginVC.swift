//
//  ViewController.swift
//  TestAppFirebase
//
//  Created by MacBook on 13.01.2022.
//

import UIKit
import Firebase
class LoginVC: UIViewController {

        var ref: DatabaseReference!
        var user: User!
        var tasks = [Task]()
        
    
        @IBOutlet private weak var warnLabel: UILabel!
        @IBOutlet private weak var emailTF: UITextField!
        @IBOutlet private weak var passwordTF: UITextField!

        override func viewDidLoad() {
            super.viewDidLoad()

            ref = Database.database().reference(withPath: "users")

            NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)

            Auth.auth().addStateDidChangeListener { (auth, user) in
                guard let _ = user else { return }
              
            }
            // текущий пользователь
                   guard let currentUser = Auth.auth().currentUser else { return }
                   // сохраним currentUser
                   user = User(user: currentUser)
                   // создаем reference
                   ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // чистим поля
            emailTF.text = ""
            passwordTF.text = ""
            // наблюдатель за значениями
            ref.observe(.value) { [weak self] snapshot in
                var tasks = [Task]()
                for item in snapshot.children { // вытаскиваем все tasks
                    guard let snapshot = item as? DataSnapshot, let task = Task(snapshot: snapshot) else { continue }
                    tasks.append(task)
                }
                self?.tasks = tasks
            }
            
        }
// Кнопка для Крашлитики, будет время реализую
        @IBAction func crashButtonTapped(_ sender: AnyObject) {
   
        }
        
        
        @IBAction func loginTapped(_ sender: UIButton) {
            // проверяем все поля
            guard let email = emailTF.text, let password = passwordTF.text, email != "", password != "" else {
                // показываем уникальный error
                displayWarningLabel(withText: "info is incorrect")
                return
            }

            // логинемся
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
                if let _ = error {
                    self?.displayWarningLabel(withText: "Error ocured")
                    
                    return
                } else {
                    self?.displayWarningLabel(withText: "No such user")
                }
            }
        }

        @IBAction func registerTapped(_ sender: UIButton) {
            // проверяем все поля
            guard let email = emailTF.text, let password = passwordTF.text, email != "", password != "" else {
                displayWarningLabel(withText: "Info is incorrect")
                return
            }

            // createUser
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
                guard error == nil, user != nil else {
                    self?.displayWarningLabel(withText: "Registration was incorrect")
                    print(error!.localizedDescription)
                    return
                }

                guard let user = user else { return }
                let userRef = self?.ref.child(user.user.uid)
                userRef?.setValue(["email": user.user.email])
            }
        }
        
   
    @IBAction func addTapped(_ sender: UIButton) {}
        
        private func displayWarningLabel(withText text: String) {
            warnLabel.text = text
            // curveEaseInOut - плавно появляется и плавно исчезает
            UIView.animate(withDuration: 4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { [weak self] in self?.warnLabel.alpha = 1 }) { [weak self] complete in
                self?.warnLabel.alpha = 0 }
        }

        @objc func keyboardDidShow (notification: Notification) {
            guard let userInfo = notification.userInfo, let scrollView = view as? UIScrollView else { return }
            let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height + kbFrameSize.height)
            scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbFrameSize.height, right: 0)
        }

        @objc func keyboardDidHide () {
            guard let scrollView = view as? UIScrollView else { return }
            scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
        }
    }






