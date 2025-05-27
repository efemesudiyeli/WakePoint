//
//  MapStyleType.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 27.05.2025.
//

import _MapKit_SwiftUI
enum MapStyleType {
    case standard, hybrid, imagery
}

func currentMapStyleType(from mapStyle: MapStyle) -> MapStyleType {
    let description = String(describing: mapStyle)
    if description.contains("Hybrid") {
        return .hybrid
    } else if description.contains("Imagery") {
        return .imagery
    } else {
        return .standard
    }
}
