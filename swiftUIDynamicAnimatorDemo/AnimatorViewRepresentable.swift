//
//  AnimatorViewRepresentable.swift
//  swiftUIDynamicAnimator
//
//  Created by mac on 14/09/22.
//

import SwiftUI

struct AnimatorViewRepresentable: UIViewRepresentable {
    let view = UIView()
    
    lazy var p: MyPageViewController = {
        let views = ["trash", "folder.fill", "mic"]
            .map {
                let x = ExampleViewController()
                x.theLabel.image = UIImage(systemName: $0)
                return x
            }
        let p = MyPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        p.pages = views
        return p
    }()
    
    static var coordinator: Coordinator!
    @Binding var playing: Bool
    let script: Script
    
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
        var parent: AnimatorViewRepresentable
        
        var size = UIScreen.main.bounds.size
        
        private var animator: UIDynamicAnimator!
        private var gravity: UIGravityBehavior!
        private var collision: UICollisionBehavior!
        private var itemBehavior: UIDynamicItemBehavior!
        
        var stack: UIStackView = UIStackView()
        var totalHeight: CGFloat = 0
        var script: Script {
            parent.script
        }
        
        init(parent: AnimatorViewRepresentable) {
            self.parent = parent
        }
        
        lazy var scriptTitle: UILabel = {
            let scriptTitle = UILabel()
            scriptTitle.text = script.title
            scriptTitle.font = UIFont(descriptor: UIFontDescriptor(), size: CGFloat(script.size+10))
            return scriptTitle
        }()
        
        lazy var content: UILabel = {
            let content = UILabel()
            content.text = script.text
//            content.textAlignment = NSTextAlignment(rawValue: script.textAlignment.rawValue)//script.textAlignment
            content.font = UIFont(descriptor: UIFontDescriptor(), size: CGFloat(script.size))
            content.numberOfLines = 0
            return content
        }()
        
        func setView() {
            let titleHeight = scriptTitle.text!.height(withConstrainedWidth: size.width, font: scriptTitle.font)
            let contentHeight = content.text!.height(withConstrainedWidth: size.width, font: content.font)
            
            totalHeight += contentHeight + titleHeight
            if !script.recordings.isEmpty {
                totalHeight += 400
                stack.addArrangedSubview(parent.p.view)
            }
            stack.axis = .vertical
            stack.addArrangedSubview(scriptTitle)
            stack.addArrangedSubview(content)
            
            stack.frame = CGRect(origin: CGPoint(), size: CGSize(width: size.width, height: totalHeight))
            coordinator.totalHeight = totalHeight
            let panGesture = UIPanGestureRecognizer()
            panGesture.addTarget(self, action: #selector(viewDragged(_ :)))
            stack.addGestureRecognizer(panGesture)
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
