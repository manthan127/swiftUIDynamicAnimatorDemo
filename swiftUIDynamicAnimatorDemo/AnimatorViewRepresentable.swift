//
//  AnimatorViewRepresentable.swift
//  swiftUIDynamicAnimator
//
//  Created by mac on 14/09/22.
//

import SwiftUI

struct AnimatorViewRepresentable: UIViewRepresentable {
    let view = UIView()
    let p = MyPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    static var coordinator: Coordinator!
    @Binding var playing: Bool
    
    var coordinator: Coordinator {
        Self.coordinator
    }
    
    func makeUIView(context: Context) -> UIView {
        Self.coordinator = context.coordinator
        context.coordinator.setView()
        view.addSubview(context.coordinator.stack)
        context.coordinator.setUpAnimator()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func playOrPause() {
        if playing {
            coordinator.stop()
            playing = false
        } else {
            coordinator.start()
        }
    }
    
    func prev() {
        coordinator.prev()
    }
    
    func next() {
        coordinator.next()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UICollisionBehaviorDelegate {
        let parent: AnimatorViewRepresentable
        
        var size = UIScreen.main.bounds.size
        
        private var animator: UIDynamicAnimator!
        private var gravity: UIGravityBehavior!
        private var collision: UICollisionBehavior!
        private var itemBehavior: UIDynamicItemBehavior!
        
        var stack: UIStackView!
        
        var totalHeight: CGFloat!
        
        init(parent: AnimatorViewRepresentable) {
            self.parent = parent
        }
        
        func setView() {
            let scriptTitle = UILabel()
            scriptTitle.text = "Title"
            scriptTitle.font = UIFont(descriptor: UIFontDescriptor(), size: 33)
            
            let content = UILabel()
            content.text = .longText
            content.font = UIFont(descriptor: UIFontDescriptor(), size: 23)
            content.numberOfLines = 0
            
            let titleHeight = scriptTitle.text!.height(withConstrainedWidth: size.width, font: scriptTitle.font)
            let contentHeight = content.text!.height(withConstrainedWidth: size.width, font: content.font)
            totalHeight = contentHeight + titleHeight + 400
            
            stack = UIStackView(frame: CGRect(origin: CGPoint(), size: CGSize(width: size.width, height: totalHeight)))
            stack.axis = .vertical
            stack.addArrangedSubview(parent.p.view)
            stack.addArrangedSubview(scriptTitle)
            stack.addArrangedSubview(content)
            
            coordinator.totalHeight = totalHeight
            let panGesture = UIPanGestureRecognizer()
            panGesture.addTarget(self, action: #selector(viewDragged(_ :)))
            stack?.addGestureRecognizer(panGesture)
        }
        
        func setUpAnimator() {
            animator = UIDynamicAnimator(referenceView: parent.view)
            
            gravity = UIGravityBehavior(items: [stack])
            gravity.gravityDirection = CGVector(dx: 0, dy: -1)
            gravity.magnitude = 0.1
            
            itemBehavior = UIDynamicItemBehavior(items: [stack])
            itemBehavior.resistance = 1
            itemBehavior.angularResistance = 1
            itemBehavior.allowsRotation = false
            
            collision = UICollisionBehavior(items: [stack])
            //MARK: needs improvement(maybe)
            collision.setTranslatesReferenceBoundsIntoBoundary(
                with: UIEdgeInsets(
                    top: -totalHeight,
                    left: 0,
                    bottom: totalHeight,
                    right: 0
                )
            )
            collision.collisionDelegate = self
        }
        
        @objc func viewDragged(_ sender: UIPanGestureRecognizer) {
            switch sender.state {
            case .began :
                if parent.playing {
                    stop()
                }
            case .changed:
                let translation = sender.translation(in: parent.view)
                stack.center = CGPoint(x: stack.center.x, y: stack.center.y + translation.y)
                sender.setTranslation(CGPoint.zero, in: parent.view)
            case .ended:
                UIView.animate(withDuration: 0.1) {
                    if self.stack.frame.minY > 0 {
                        self.stack.frame.origin.y = 0
                    } else if self.stack.frame.maxY < self.size.height {
                        self.stack.frame.origin.y = -(self.totalHeight - self.size.height)+1
                    }
                }
                if parent.playing {
                    start()
                }
            default:
                break
            }
        }
        
        func start() {
            animator.addBehavior(itemBehavior)
            animator.addBehavior(collision)
            animator.addBehavior(gravity)
            parent.playing = true
        }
        
        func stop() {
            animator.removeAllBehaviors()
        }
        
        func prev() {
            stop()
            UIView.animate(withDuration: 0.2) {
                self.stack.center.y += 100
                if self.stack.frame.minY > 0 {
                    self.stack.frame.origin.y = 0
                }
            }
            if parent.playing {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.start()
                }
            }
        }
        
        func next() {
            stop()
            UIView.animate(withDuration: 0.2) {
                self.stack.center.y -= 100
                if self.stack.frame.maxY < self.size.height {
                    self.stack.frame.origin.y = -(self.totalHeight - self.size.height)+1
                }
            }
            if parent.playing {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.start()
                }
            }
        }
        
        func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
            DispatchQueue.main.async {
                self.stop()
            }
            parent.playing = false
        }
    }
}

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
    
    lazy var pages = ["trash", "folder.fill", "folder.badge.person.crop", "mic"]
        .compactMap{ s -> UIViewController in
            let x = ExampleViewController()
            x.theLabel.image = UIImage(systemName: s)
            x.theLabel.backgroundColor = colors.randomElement() ?? .red
            return x
        }
    
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

//        guard pages.count > previousIndex else { return nil }

        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }

        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return pages.first }

//        guard pages.count > nextIndex else { return nil }

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
