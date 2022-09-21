//
//  ContentView.swift
//  swiftUIDynamicAnimatorDemo
//
//  Created by mac on 20/09/22.
//

import SwiftUI

struct ContentView: View {
    @State var play = false
    var body: some View {
        let customScroll = AnimatorViewRepresentable(playing: $play)
        return VStack {
            
            GeometryReader { geo in
                customScroll
                    .onAppear {
                        customScroll.coordinator.size = geo.size
                    }
            }
            
            HStack{
                Spacer()
                Button {
                    customScroll.prev()
                } label: {
                    Text("Prev")
                }
                
                Spacer()
                Button {
                    customScroll.playOrPause()
                } label: {
                    Text(play ? "Pause" : "Play")
                }
                
                Spacer()
                Button {
                    customScroll.next()
                } label: {
                    Text("Next")
                }
                Spacer()
            }
            .background(Color.white)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//class TabOneViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        self.view.backgroundColor = UIColor.blue
//        self.title = "Tab 1"
//    }
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//}
//
//class TabTwoViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        self.view.backgroundColor = UIColor.red
//        self.title = "Tab 2"
//    }
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//}
//
//class ViewController: UITabBarController, UITabBarControllerDelegate {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.delegate = self
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // Create Tab one
//        let tabOne = TabOneViewController()
//        let tabOneBarItem = UITabBarItem(title: "Tab 1", image: UIImage(named: "defaultImage.png"), selectedImage: UIImage(named: "selectedImage.png"))
//
//        tabOne.tabBarItem = tabOneBarItem
//
//
//        // Create Tab two
//        let tabTwo = TabTwoViewController()
//        let tabTwoBarItem2 = UITabBarItem(title: "Tab 2", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
//
//        tabTwo.tabBarItem = tabTwoBarItem2
//
//
//        self.viewControllers = [tabOne, tabTwo]
//    }
//
//    // UITabBarControllerDelegate method
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        print("Selected \(viewController.title!)")
//    }
//}
