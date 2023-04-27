//
//  ContainerViewController.swift
//  Clima
//
//  Created by Varun Kumar on 22/04/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    @IBOutlet var homeButton: UIButton!
    @IBOutlet var favButton: UIButton!
    @IBOutlet var recentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func homePressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        print("home")
    }
    
    @IBAction func favPressed(_ sender: Any) {
        print("favo")
    }
    
    @IBAction func recentPressed(_ sender: Any) {
        print("search")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
