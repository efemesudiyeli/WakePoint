//
//  CustomMapStyle.swift
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
        case .standard: .standard
        case .hybrid: .hybrid
        case .imagery: .imagery
        }
    }

    static func from(mapStyle _: MapStyle) -> CustomMapStyle {
        .standard
    }
}
