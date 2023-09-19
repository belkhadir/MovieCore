//
//  ErrorAlertView.swift
//  MovieiOS
//
//  Created by Belkhadir Anas on 19/9/2023.
//

import SwiftUI

protocol GenericAlertViewing {
    var title: String { get }
    var description: String { get }
    var buttonText: String { get }
    var buttonAction: () -> Void { get }
}

struct GenericAlertView: View {
    var title: String
    var description: String
    var buttonText: String
    var buttonAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: buttonAction) {
                Text(buttonText)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

// MARK: - GenericAlertViewing
extension GenericAlertView: GenericAlertViewing {}

struct GenericAlertView_Previews: PreviewProvider {
    static var previews: some View {
        GenericAlertView(title: "Hello, SwiftUI!", description: "This is a simple container with a title, description, and a button.", buttonText: "Tap me!") {
            print("Button tapped!")
        }
    }
}
