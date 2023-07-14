//
//  Extensions.swift
//  FindMyNIK
//
//  Created by Dimas Wisodewo on 09/07/23.
//

import UIKit

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        
        self.layer.mask = mask
    }
}

class TextFieldNoCopyPaste: UITextField {
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action == #selector(UIResponderStandardEditActions.paste(_:)) ||
//            action == #selector(UIResponderStandardEditActions.copy(_:)) ||
//        {
//            return false
//        }
//
//        return super.canPerformAction(action, withSender: sender)
        return false
        
    }
}
