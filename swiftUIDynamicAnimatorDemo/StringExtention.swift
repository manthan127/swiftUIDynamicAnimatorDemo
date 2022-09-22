//
//  StringExtention.swift
//  swiftUIDynamicAnimatorDemo
//
//  Created by mac on 22/09/22.
//

import SwiftUI

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
