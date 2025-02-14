//
//  ToastViewModifier.swift
//  GameSocial
//
//  Created by Adam Gumm on 2/3/25.
//


import SwiftUI

struct ToastViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                // The semi-transparent background
                Color.black.opacity(0.0)
                    .edgesIgnoringSafeArea(.all)
                
                // Toast message
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(message)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(12)
                        Spacer()
                    }
                    .padding(.bottom, 75) // Adjust for your layout
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(.bouncy), value: isPresented)
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, message: String) -> some View {
        self.modifier(ToastViewModifier(isPresented: isPresented, message: message))
    }
}
