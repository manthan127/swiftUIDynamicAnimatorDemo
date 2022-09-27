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
        v.backgroundColor = .white
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(theLabel)
        NSLayoutConstraint.activate([
            theLabel.topAnchor.constraint(equalTo: view.topAnchor),
            theLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            theLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10)
        ])
    }
}

class MyPageViewController: UIPageViewController {
    let colors: [UIColor] = [
        .red,
        .green,
        .blue,
        .cyan,
        .yellow,
        .orange
    ]
    
    lazy var pages = [UIViewController]()
//        .map{ s -> UIViewController in
//            let x = ExampleViewController()
//            x.theLabel.image = UIImage(systemName: s)
//            x.theLabel.backgroundColor = colors.randomElement() ?? .red
//            return x
//        }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = nil

        view.backgroundColor = .gray
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

        guard pages.count > previousIndex else { return nil }

        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }

        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return pages.first }

        guard pages.count > nextIndex else { return nil }

        return pages[nextIndex]
    }
}

extension MyPageViewController: UIPageViewControllerDelegate {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

