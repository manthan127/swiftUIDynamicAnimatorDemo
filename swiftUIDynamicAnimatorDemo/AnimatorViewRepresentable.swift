//
//  AnimatorViewRepresentable.swift
//  swiftUIDynamicAnimator
//
//  Created by mac on 14/09/22.
//

import SwiftUI

struct AnimatorViewRepresentable: UIViewRepresentable {
    let view = UIView()
    static var coordinator: Coordinator!
    @Binding var playing: Bool
    
    var coordinator: Coordinator {
        AnimatorViewRepresentable.coordinator
    }
    
    func makeUIView(context: Context) -> UIView {
        AnimatorViewRepresentable.coordinator = context.coordinator
        context.coordinator.setUpView()
        
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
        
        private var totalHeight: CGFloat!
        
        init(parent: AnimatorViewRepresentable) {
            self.parent = parent
        }
        
        func setUpView() {
            let scriptTitle = UILabel()
            scriptTitle.text = "Title"
            scriptTitle.font = UIFont(descriptor: UIFontDescriptor(), size: 33)
            
            let content = UILabel()
            content.text = .longText
            content.font = UIFont(descriptor: UIFontDescriptor(), size: 23)
            content.numberOfLines = 0
            
            let titleHeight = scriptTitle.text!.height(withConstrainedWidth: size.width, font: scriptTitle.font)
            let contentHeight = content.text!.height(withConstrainedWidth: size.width, font: content.font)
            totalHeight = contentHeight + titleHeight
            
            stack = UIStackView(frame: CGRect(x: 0, y: 0, width: size.width, height: totalHeight))
            stack.axis = .vertical
            stack.addArrangedSubview(scriptTitle)
            stack.addArrangedSubview(content)
            stack.backgroundColor = .red
            
            let panGesture = UIPanGestureRecognizer()
            panGesture.addTarget(self, action: #selector(viewDragged(_ :)))
            stack.addGestureRecognizer(panGesture)
            
            parent.view.addSubview(stack)
            
            setUpAnimator()
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
            print("collision")
            stop()
            parent.playing = false
        }
    }
}

extension String {
    static let longText = """
            The most important thing, says O’Malley, is to pay attention to your child, so you can work out what their vulnerabilities are. You know your child better than anyone: what are their emotional needs? Do they need love and belonging, or crave power, status and recognition from others? The first of these could be a passive, gentle child who might be more vulnerable to bullying, or to being recruited by a bully to be one of their supporters. Similarly, if your child needs power and recognition – and that’s a great cocktail for success in many sectors – it can easily trigger bullying behaviour, and as a parent you need to be aware of that, and active in how you manage it.
            
            “A kid like this has wonderful strengths, but they need to learn empathy,” she says. “If you can nurture a sense of kindness in that child, help them understand how others are feeling, you’ll be combatting their bullying tendencies. Every child, every human being, has their flaws. Bullying has become demonised, but children can easily tip into it, and we need to help them out of it.” And the good thing, says O’Malley, is that it’s relatively easy to help a primary-school-age child out of being a bully. “They’re primed to be told how to behave, and they can learn to be different.”
            
            The most important thing, says O’Malley, is to pay attention to your child, so you can work out what their vulnerabilities are. You know your child better than anyone: what are their emotional needs? Do they need love and belonging, or crave power, status and recognition from others? The first of these could be a passive, gentle child who might be more vulnerable to bullying, or to being recruited by a bully to be one of their supporters. Similarly, if your child needs power and recognition – and that’s a great cocktail for success in many sectors – it can easily trigger bullying behaviour, and as a parent you need to be aware of that, and active in how you manage it.
            """
    
    static let smallText = """
            “A kid like this has wonderful strengths, but they need to learn empathy,” she says. “If you can nurture a sense of kindness in that child, help them understand how others are feeling, you’ll be combatting their bullying tendencies. Every child, every human being, has their flaws. Bullying has become demonised, but children can easily tip into it, and we need to help them out of it.” And the good thing, says O’Malley, is that it’s relatively easy to help a primary-school-age child out of being a bully. “They’re primed to be told how to behave, and they can learn to be different.”
            """
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}
