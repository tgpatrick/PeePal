//
//  DetailShape.swift
//  PeePal
//
//  Created by Thomas Patrick on 9/14/23.
//

import SwiftUI

struct DetailShape: Shape {
    let expanded: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let pointBottom = CGPoint(x: rect.width / 2, y: rect.height)
        let pointRight = CGPoint(x: (rect.width / 2) * 1.1, y: rect.height * 0.95)
        let pointLeft = CGPoint(x: (rect.width / 2) * 0.9, y: rect.height * 0.95)
        
        let bottomRight1 = CGPoint(x: rect.width, y: rect.height * 0.95)
        let bottomRight2 = CGPoint(x: rect.width, y: rect.height * 0.85)
        
        let topRight1 = CGPoint(x: rect.width, y: 0)
        let topRight2 = CGPoint(x: rect.width * 0.8, y: 0)
        
        let topLeft1 = CGPoint(x: 0, y: 0)
        let topLeft2 = CGPoint(x: 0, y: rect.height * 0.2)
        
        let bottomLeft1 = CGPoint(x: 0, y: rect.height * 0.95)
        let bottomLeft2 = CGPoint(x: rect.width * 0.2, y: rect.height * 0.95)
        
        let cornerRadius = 15.0
        
        if !expanded {
            path.move(to: pointBottom)
            path.addLine(to: pointRight)
        } else {
            path.move(to: CGPoint(x: rect.width / 2, y: rect.height * 0.95))
        }
        path.addArc(tangent1End: bottomRight1, tangent2End: bottomRight2, radius: cornerRadius)
        path.addArc(tangent1End: topRight1, tangent2End: topRight2, radius: cornerRadius)
        path.addArc(tangent1End: topLeft1, tangent2End: topLeft2, radius: cornerRadius)
        path.addArc(tangent1End: bottomLeft1, tangent2End: bottomLeft2, radius: cornerRadius)
        if !expanded {
            path.addLine(to: pointLeft)
            path.addLine(to: pointBottom)
        }
        return path
    }
}

struct DetailShape_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.edgesIgnoringSafeArea(.all)
            Rectangle()
                .foregroundColor(.red)
                .frame(height: 250)
                .mask(DetailShape(expanded: true))
                .padding(.horizontal)
        }
    }
}
