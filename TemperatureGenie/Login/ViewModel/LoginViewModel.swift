//
//  LoginViewModel.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 27/03/2025.
//

import Foundation
import Combine

public class LoginViewModel: ObservableObject {
    private var service = LoginAPI()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var alertMessageTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    
    func loginWithUsernameAndPassword(username: String, password: String, authenticationHelper: AuthenticationHelper) {
        self.service.loginUser(username: username, password: password, firebaseToken: "", session: URLSession.shared)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink { res  in
                switch res {
                    case .failure(let error):
                        self.alertMessageTitle = "Login error"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    case .finished:
                        break
                }
            } receiveValue: { loginTokenObject in
                authenticationHelper.saveToken(login: loginTokenObject)
            }
            .store(in: &cancellables)
    }
}
