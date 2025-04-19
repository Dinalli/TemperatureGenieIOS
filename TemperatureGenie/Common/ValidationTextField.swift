//
//  ValidationTextField.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 19/04/2025.
//

import SwiftUI

struct ValidationTextField: View {
    var placeHolderText: String
    var promptText: String
    @Binding var fieldValue: String
    var isSecure:Bool = false
    var isNumeric:Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if isSecure {
                    SecureField(placeHolderText, text: $fieldValue)
                        .autocapitalization(.none)
                        .font(.custom("poppins_medium", size: 17))
                        .foregroundColor(Color("GenieBlue"))
                } else {
                    TextField(placeHolderText, text: $fieldValue).autocapitalization(.none)
                        .keyboardType(isNumeric ? .numbersAndPunctuation : .default)
                        .font(.custom("poppins_medium", size: 17))
                        .foregroundColor(Color("GenieBlue"))
                }
            }
            .padding(8)
            .background(Color(UIColor.secondarySystemBackground))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("GeniePurple"), lineWidth: 1))
            Text(promptText)
            .fixedSize(horizontal: false, vertical: true)
            .font(.caption)
            .foregroundColor(Color("GeniePurple"))
        }
    }
}

#Preview {
    @Previewable @State var fieldValue: String = ""
    ValidationTextField(placeHolderText: "This is the placeholder text", promptText: "Prompt me", fieldValue: $fieldValue, isSecure: false)
}
