//
//  BottomTabController.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/4/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift

enum TabBarType: String {
    case home = "Home"
    case market = "Market"
    case order = "Order"
    case stock = "Stock"
    case account = "Account"
}

class BottomTabController: UITabBarController {
    
    private let loginModel = OnBoardingViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func configure(){
        self.tabBar.unselectedItemTintColor = Color.tabItemTintColor
        setupBarItems()
        
        let tabBarItemAppearance = UITabBarItem.appearance()
        tabBarItemAppearance.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.setLightFont(of:10), NSAttributedString.Key.foregroundColor: Color.tabItemTintColor], for: .normal)
        tabBarItemAppearance.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.setBoldFont(of:10), NSAttributedString.Key.foregroundColor: Color.accentColor], for: .selected)
        
    }
    
    func setupBarItems(){
        
        let vc1 = UIStoryboard().controllerFor(identifier: "HomeVC")
        vc1.tabBarItem = UITabBarItem(title: "Home", image: #imageLiteral(resourceName: "home"), tag: 1)
        
        let vc2 = UIStoryboard().controllerFor(identifier: "MarketVC")
        vc2.tabBarItem = UITabBarItem(title: "Market", image: #imageLiteral(resourceName: "market"), tag: 2)
        
        let vc3 = UIStoryboard().controllerFor(identifier: "OrderVC")
        vc3.tabBarItem = UITabBarItem(title: "Order", image: #imageLiteral(resourceName: "order"), tag: 3)
        
        let vc4 = UIStoryboard().controllerFor(identifier: "StockVC")
        vc4.tabBarItem = UITabBarItem(title: "Stock", image: #imageLiteral(resourceName: "stock"), tag: 4)
        
        let vc5 = UIStoryboard().controllerFor(identifier: "AccountVC")
        vc5.tabBarItem = UITabBarItem(title: "Account", image: #imageLiteral(resourceName: "account"), tag: 5)
        
        viewControllers = [vc1, vc2, vc3, vc4, vc5]
    }
    
}
