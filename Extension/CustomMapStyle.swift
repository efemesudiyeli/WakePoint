//
//  MyMapStyle.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 27.05.2025.
//

import _MapKit_SwiftUI

enum CustomMapStyle: Equatable {
    case standard
    case hybrid
    case imagery

    var mapKitStyle: MapStyle {
        switch self {
        case .standard: return .standard
        case .hybrid: return .hybrid
        case .imagery: return .imagery
        }
    }

    static func from(mapStyle: MapStyle) -> CustomMapStyle {
        return .standard
    }
}
