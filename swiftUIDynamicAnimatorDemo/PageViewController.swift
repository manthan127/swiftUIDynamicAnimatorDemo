//
//  PageViewController.swift
//  swiftUIDynamicAnimatorDemo
//
//  Created by mac on 27/09/22.
//

import UIKit

class ExampleViewController: UIViewController {
    let theLabel: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .orange
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(theLabel)
        NSLayoutConstraint.activate([
            theLabel.topAnchor.constraint(equalTo: view.topAnchor),
            theLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            theLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

class MyPageViewController: UIPageViewController {
    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        view.backgroundColor = .black
        setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if let _ = view as? UIScrollView {
                view.frame = self.view.frame
            } else if let _ = view as? UIPageControl {
                view.backgroundColor = .clear
            }
        }
    }
}

extension MyPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }

        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return pages.last }

        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }

        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return pages.first }

        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
