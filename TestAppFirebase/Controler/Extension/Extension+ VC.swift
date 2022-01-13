//
//  Extension+ VC.swift
//  TestAppFirebase
//
//  Created by MacBook on 13.01.2022.
//

import UIKit
import Firebase

extension LoginVC {
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "New task", message: "Add new task", preferredStyle: .alert)
        alertController.addTextField()
        // action 1
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            // достали text
            guard let textField = alertController.textFields?.first,
                let text = textField.text,
                let uid = self?.user.uid else { return }
            // создаем задачу
            let task = Task(title: text, userId: uid)
            // где хранится на сервере
            let taskRef = self?.ref.child(task.title.lowercased()) // нижний регистр
            // добавляем на сервак
            taskRef?.setValue(task.convertToDictionary()) // помещаем словарь по ref
        }
        // action 2
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
    
    
}
