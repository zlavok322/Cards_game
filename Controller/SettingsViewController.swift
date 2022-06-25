//
//  SettingsViewController.swift
//  Cards_game
//
//  Created by Слава Шестаков on 19.05.2022.
//

import UIKit

class SettingsViewController: UIViewController {

     lazy var button = createButtonBack()
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(button)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.view.backgroundColor = .orange
    }
    
    func createButtonBack() -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.center = self.view.center
        button.setTitle("Назад", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.addTarget(self, action: #selector(buttonPres(_:)), for: .touchUpInside)
        
        return button
    }

    @objc func buttonPres(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
