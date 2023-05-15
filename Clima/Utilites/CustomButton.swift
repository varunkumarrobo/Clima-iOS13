//
//  CustomButton.swift
//  Clima
//
//  Created by Varun Kumar on 15/05/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    var isButtonOpen: Bool = false {
        didSet {
            updateButtonState()
        }
    }

    override var isSelected: Bool {
        get {
            return isButtonOpen
        }
        set {
            isButtonOpen = newValue
        }
    }

    private func updateButtonState() {
        let buttonColor: UIColor = isButtonOpen ? .red : .blue
        setTitleColor(buttonColor, for: .normal)
        // Additional customization if needed
    }
    
}
