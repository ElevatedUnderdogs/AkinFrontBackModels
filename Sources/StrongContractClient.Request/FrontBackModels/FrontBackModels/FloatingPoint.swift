//
//  FloatingPoint.swift
//  
//
//  Created by lsd on 13/05/24.
//

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

extension Double {
    static let earthRadius: Self = 6367444.7
}
