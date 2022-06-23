
import UIKit
import FloatingTabBarController
import SwiftUI

class TabViewController: FloatingTabBarController{
    
    var dataManager:DataManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = UIColor(named: "tFcolor")
        tabBar.alpha = 1
        
        viewControllers = (1...3).map { "Tab\($0)" }.map {
            let selected = UIImage(named: $0 + "-Large")!
            let normal = UIImage(named: $0 + "-Small")!
            let controller = storyboard!.instantiateViewController(withIdentifier: $0)
            controller.title = $0
            controller.floatingTabItem = FloatingTabItem(selectedImage: selected, normalImage: normal)
            return controller
        }
        
    }
    
    func hide(bool:Bool){
        
        if(bool){
            tabBar.transform = CGAffineTransform(translationX: 0, y: 256)
        } else {
            tabBar.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
}








