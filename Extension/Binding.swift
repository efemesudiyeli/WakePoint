//
//  Binding.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 18.05.2025.
//
import SwiftUI

extension Binding where Value == Bool {
    func map(_ transform: @escaping (Bool) -> Bool) -> Binding<Bool> {
        Binding<Bool>(
            get: { transform(self.wrappedValue) },
            set: { newValue in self.wrappedValue = !newValue }
        )
    }
}
