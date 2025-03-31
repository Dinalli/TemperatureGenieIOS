//
//  LoginView.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 27/03/2025.
//

import SwiftUI

public struct LoginView: View {
    @EnvironmentObject var authenticationHelper: AuthenticationHelper
    
    @StateObject var viewModel: LoginViewModel = LoginViewModel()
    
    @State private var showPassword = false
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State var showUsernameForgot: Bool = false
    @State var showPasswordForgot: Bool = false
    @State var showRegister: Bool = false
    
    public init() {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    public var body: some View {
        ZStack {
            Color("GenieBackground").ignoresSafeArea(.all)
            VStack {
                VStack {
                    HStack {
                        Text("Username").font(.custom("poppins_medium", size: 12)).foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }
                    TextField("Username", text: $username).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/).font(.custom("poppins_medium", size: 17)).foregroundColor(Color("GenieBlue"))
                        .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("GeniePurple"), lineWidth: 1)
                    )
                }
                VStack {
                    HStack {
                        Text("Password").font(.custom("poppins_medium", size: 12)).foregroundColor(Color("GenieBlue"))
                        Spacer()
                    }
                    HStack {
                        if showPassword {
                            TextField("Password", text: $password).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/).font(.custom("poppins_medium", size: 17)).foregroundColor(Color("GenieBlue")).overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("GeniePurple"), lineWidth: 1)
                            )
                        } else {
                            SecureField("Password", text: $password).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/).foregroundColor(Color("GenieBlue"))
                        }
                        Button {
                            showPassword.toggle()
                        } label: {
                            Image("Eye").foregroundColor(Color("GenieBlue"))
                        }.background(Color("GenieBlue"))
                    }.overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("GeniePurple"), lineWidth: 1)
                    )
                }.padding(.bottom)
                Button {
                    login()
                } label: {
                    Text("Login").font(.custom("poppins_medium", size: 17))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color("GenieLightBlue"))
                        .cornerRadius(8)
                        .foregroundColor(Color.white)
                }
                .alert(viewModel.alertMessageTitle, isPresented: $viewModel.showAlert) {
                    Button("OK") {
                        viewModel.showAlert = false
                    }
                } message: {
                    Text(viewModel.alertMessage)
                }
                .padding()
            }
            .ignoresSafeArea(.all)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    func login() {
        if username.isEmpty || password.isEmpty {
            viewModel.alertMessageTitle = "Login error"
            viewModel.alertMessage = "You need to enter username and password"
            viewModel.showAlert = true
            return
        }
        DispatchQueue.global().async {
            viewModel.loginWithUsernameAndPassword(username: username, password: password, authenticationHelper: authenticationHelper)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.black)
            LoginView()
                .environmentObject(AuthenticationHelper())
        }
    }
}

