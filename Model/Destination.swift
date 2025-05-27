//
//  Destination.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 4.05.2025.
//
import MapKit

struct Destination: Identifiable, Codable, Equatable {
    static func == (lhs: Destination, rhs: Destination) -> Bool {
        lhs.id == rhs.id
    }

    var id = UUID().uuidString
    var address: Address? = nil
    var coordinate: CLLocationCoordinate2D
}
