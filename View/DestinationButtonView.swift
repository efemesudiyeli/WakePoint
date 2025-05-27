//
//  DestinationButtonView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 15.05.2025.
//

import CoreLocation
import SwiftUI

struct DestinationButtonView: View {
    var destination: Destination
    var body: some View {
        HStack {
            if let name = destination.address?.name {
                Text("\(name)")
            }

            if let address = destination.address {
                if let locality = address.locality {
                    Text("(\(locality))")
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
}
