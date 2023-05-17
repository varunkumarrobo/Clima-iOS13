//
//  EmptyViewController.swift
//  Clima
//
//  Created by Varun Kumar on 17/05/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit

protocol CustomAlertDelegate {
    func yesButtonTapped()
    func noButtonTapped()
    func alertMessage(_ message: String)
}

class CustomAlertBox: UIViewController {

    
    @IBOutlet weak var alertMessageLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var alertView: UIView!
    
    
    var delegate : CustomAlertDelegate?
    
    var isFavourtie : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
        animateView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Handle the tap gesture here
        self.dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func setUpView(){
        alertView.layer.cornerRadius = 0.0
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView(){
        alertView.alpha = 0
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 0
        UIView.animate(withDuration: 0.0) {
            self.alertView.alpha = 1.0
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 0
        }
    }
    
    
    @IBAction func noButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func yesButton(_ sender: UIButton) {
        delegate?.yesButtonTapped()
    }
    
    func setAlertMessage(_ message: String) {
            alertMessageLabel.text = message
        }
    
}
