////
////  MenuViewController.swift
////  Clima
////
////  Created by Varun Kumar on 21/04/23.
////  Copyright © 2023 App Brewery. All rights reserved.
////
//
//import UIKit
//
//protocol MenuViewControllerDelegate : AnyObject {
//    func didSelect(menuItem : MenuViewController.MenuOptions)
//}
//
//class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    weak var delegate : MenuViewControllerDelegate?
//
//    enum MenuOptions : String , CaseIterable {
//        case home = "Home"
//        case favorites = "Favorites"
//        case recentSearch = "Recent Search"
//        case settings = "Settings"
//        case info = "Info"
//        case logout = "Log-Out"
//
//        var imageName : String{
//            switch self {
//            case .home:
//                return "house"
//            case .favorites:
//                return "favorites"
//            case .recentSearch:
//                return "search"
//            case .info:
//                return "airplane"
//            case .settings:
//                return "gear"
//            case .logout:
//                return "logout"
//            }
//        }
//
//    }
//
//
//
//    private let tableView : UITableView = {
//        let table = UITableView()
//        table.backgroundColor = nil
//        table.register(UITableViewCell.self, forCellReuseIdentifier: "cells")
//        return table
//    } ()
//
//    let grayColor = UIColor(red: 33/225.0, green: 33/225.0, blue: 33/225.0, alpha: 1)
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.addSubview(tableView)
//        tableView.delegate = self
//        tableView.dataSource = self
//        view.backgroundColor  = grayColor
//
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        tableView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.size.width, height: view.bounds.size.height)
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return MenuOptions.allCases.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cells",for: indexPath)
//        cell.textLabel?.text = MenuOptions.allCases[indexPath.row].rawValue
//        cell.textLabel?.textColor = .white
//        cell.imageView?.image = UIImage(contentsOfFile: MenuOptions.allCases[indexPath.row].imageName)
//        cell.imageView?.tintColor = .white
//        cell.backgroundColor = grayColor
//        cell.contentView.backgroundColor = grayColor
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let item = MenuOptions.allCases[indexPath.row]
//        delegate?.didSelect(menuItem: item)
//    }
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
