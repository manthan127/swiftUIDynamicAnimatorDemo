//
//  AnimatorViewRepresentable.swift
//  swiftUIDynamicAnimator
//
//  Created by mac on 14/09/22.
//

import SwiftUI

struct AnimatorViewRepresentable: UIViewRepresentable {
    static var coordinator: Coordinator!
    @Binding var playing: Bool
    let script: Script
    
    var coordinator: Coordinator {
        Self.coordinator
    }
    
    let view = UIView()
    
    func makeUIView(context: Context) -> UIView {
        Self.coordinator = context.coordinator
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func setUP() {
        coordinator.setView()
        view.addSubview(coordinator.stack)
    }
    
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
    
    class Coordinator: NSObject {
        var parent: AnimatorViewRepresentable
        var size = UIScreen.main.bounds.size
        
        var totalHeight: CGFloat = 0
        var script: Script {
            parent.script
        }
        
        init(parent: AnimatorViewRepresentable) {
            self.parent = parent
        }
        
        let stack: UIStackView = UIStackView()
        
        lazy var scriptTitle: UILabel = {
            let scriptTitle = UILabel()
            scriptTitle.text = script.title
            scriptTitle.font = UIFont(descriptor: UIFontDescriptor(), size: CGFloat(script.size+10))
            return scriptTitle
        }()
        
        lazy var content: UILabel = {
            let content = UILabel()
            content.text = script.text
            content.textAlignment = NSTextAlignment(rawValue: script.textAlignment.rawVal) ?? .left
            content.font = UIFont(descriptor: UIFontDescriptor(), size: CGFloat(script.size))
            content.numberOfLines = 0
            return content
        }()
        
        lazy var p: UIViewController = {
            return UIHostingController(
                rootView:
                    TabView {
                        ForEach(script.recordings.map{$0.path}, id: \.self) { i in
                            Image(systemName: i)
                                .resizable()
                            .onTapGesture {
                                print("navigate tab", i)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .background(Color.orange)
            )
        }()
        
        lazy var v: UIViewController = {
            let x = UIHostingController(
                rootView:
                    VStack {
                        ForEach(script.recordings, id: \.self){ recording in
                            ZStack{
                                HStack(alignment: .center, spacing: 24) {
                                    Text(recording.path)
//                                    .font(.opensan(size: 16))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                    
                                    Button {
                                        print("delete", recording.path)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    
                                    Button {
                                        print("share", recording.path)
                                    } label: {
                                        Image(systemName: "square")
                                    }
                                }
                                .foregroundColor(.accentColor)
                                .padding(.vertical)
                                .padding(.horizontal, 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                                .background(Color.white)
                                .onTapGesture {
                                    print("navigate row", recording.path)
                                }
                            }
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
            )
            return x
        }()
        
        private lazy var animator: UIDynamicAnimator = {
            UIDynamicAnimator(referenceView: parent.view)
        }()
        
        private lazy var gravity: UIGravityBehavior = {
            let gravity = UIGravityBehavior(items: [stack])
            gravity.gravityDirection = CGVector(dx: 0, dy: -1)
            gravity.magnitude = 0.1
            return gravity
        }()
        
        private lazy var collision: UICollisionBehavior = {
            let collision = UICollisionBehavior(items: [stack])
//        MARK: needs improvement(maybe)
            collision.setTranslatesReferenceBoundsIntoBoundary(
                with: UIEdgeInsets(
                    top: -totalHeight,
                    left: 0,
                    bottom: totalHeight,
                    right: 0
                )
            )
            collision.collisionDelegate = self
            return collision
        }()
        
        private lazy var itemBehavior: UIDynamicItemBehavior = {
            let itemBehavior = UIDynamicItemBehavior(items: [stack])
            itemBehavior.angularResistance = 1
            itemBehavior.allowsRotation = false
            itemBehavior.resistance = 3
            
            itemBehavior.action = itemBehaviorAction
            return itemBehavior
        }()
    }
}

extension AnimatorViewRepresentable.Coordinator: UICollisionBehaviorDelegate{
    func setView() {
        let titleHeight = scriptTitle.text!.height(withConstrainedWidth: size.width, font: scriptTitle.font)
        let contentHeight = content.text!.height(withConstrainedWidth: size.width, font: content.font)
        
        totalHeight += contentHeight + titleHeight
        if !script.recordings.isEmpty {
            totalHeight += 400
            stack.addArrangedSubview(p.view)
        }
        stack.axis = .vertical
        stack.addArrangedSubview(scriptTitle)
        stack.addArrangedSubview(content)
        
        let n = script.recordings.count
        let h: CGFloat = CGFloat(n*70 + (n-1)*10)
        
        stack.addArrangedSubview(v.view)
        totalHeight += h
        
        stack.frame = CGRect(origin: CGPoint(), size: CGSize(width: size.width, height: totalHeight))
        
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(viewDragged(_ :)))
        stack.addGestureRecognizer(panGesture)
    }
    
    func itemBehaviorAction() {
        self.stack.frame.origin.x = 0
        var sholdContinue = false
        if self.stack.frame.minY > 0 {
            UIView.animate(withDuration: 0.1) {
                self.stack.frame.origin.y = 0
            }
            self.animator.removeBehavior(self.itemBehavior)
            sholdContinue = true
        } else if self.stack.frame.maxY < self.size.height {
            UIView.animate(withDuration: 0.1) {
                self.stack.frame.origin.y = -(self.totalHeight - self.size.height)+1
            }
            self.animator.removeBehavior(self.itemBehavior)
            self.stop()
            self.parent.playing = false
        }
        
        if self.parent.playing {
            if sholdContinue {
                self.start()
            }
            let x = abs(self.itemBehavior.linearVelocity(for: self.stack).y)
            if x < 15 {
                self.animator.removeBehavior(self.itemBehavior)
                
                self.start()
            }
        }
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        self.stop()
        parent.playing = false
    }
}

extension AnimatorViewRepresentable.Coordinator{
    @objc func viewDragged(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began :
            if parent.playing {
                stop()
            }
            animator.removeBehavior(itemBehavior)
        case .changed:
            let translation = sender.translation(in: parent.view)
            stack.center = CGPoint(x: stack.center.x, y: stack.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: parent.view)
        case .ended:
            if totalHeight < parent.view.frame.height {
                UIView.animate(withDuration: 0.1) {
                    self.stack.frame.origin.y = 0
                }
                return
            }
            
            let velocity = sender.velocity(in: sender.view!)
            
            itemBehavior.addLinearVelocity(velocity, for: stack)
            animator.addBehavior(itemBehavior)
            
        default:
            break
        }
    }
    
    func start() {
        guard totalHeight > size.height else {return}
        animator.removeBehavior(itemBehavior)
        
        DispatchQueue.main.async {
            self.animator.addBehavior(self.collision)
            self.animator.addBehavior(self.gravity)
        }
        self.parent.playing = true
    }
    
    func stop() {
        DispatchQueue.main.async {
            self.animator.removeAllBehaviors()
        }
    }
    
    func prev() {
        guard totalHeight > size.height else {return}
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
        guard totalHeight > size.height else {return}
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
}

extension TextAlignment {
    var rawVal: Int {
        switch self {
        case .leading:
            return 0
        case .center:
            return 1
        case .trailing:
            return 2
        }
    }
}
