//
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 27/03/2025.
//

import UIKit

/// Config Struct for V3 Keychain service access group
struct KeychainConfiguration {
    /// service Name
    static let serviceName = "TemperatureGenie"
    /// access group
    static let accessGroup: String? = nil
}

/// Token Helper class for common methods use to save and get access and refresh tokens
public class AuthenticationHelper: NSObject, ObservableObject {
    private var passwordItems = [KeychainPasswordItem]()

    @Published public var isAuthenticated: Bool = false

    /// Save the token to the keychain and add expiry time to the user defaults
    func saveToken(login: LoginToken) {
        do {
            let accessTokenPasswordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "access_token", accessGroup: KeychainConfiguration.accessGroup)
            // Save the password for the new item.
            try accessTokenPasswordItem.savePassword(login.token)
            isAuthenticated = true
        } catch {
            //fatalError("Error saving tokens to  keychain - \(error)")
            print("Error saving tokens to  keychain - \(error)")
        }
        UserDefaultsHelper.shared.addToUserDefaults(key: "expiration", value: login.expiration)
        saveTokenCreationTime()
    }

    /// get the access token from the keychain
    func getAccessToken() -> String {
        var token = ""
        do {
            passwordItems = try KeychainPasswordItem.passwordItems(forService: KeychainConfiguration.serviceName, accessGroup: KeychainConfiguration.accessGroup)
            let accessTokenItem: [KeychainPasswordItem] = passwordItems.filter { $0.account == "token" }
            if accessTokenItem.count > 0 {
                token = try accessTokenItem.first!.readPassword()
            } else { return token }
        } catch {
            //fatalError("Error fetching password items - \(error.localizedDescription)")
        }
        return token
    }

    /// Clear down the token when we no longer need it
    func clearToken() {
        do {
            passwordItems = try KeychainPasswordItem.passwordItems(forService: KeychainConfiguration.serviceName, accessGroup: KeychainConfiguration.accessGroup)
            for passwordItem in passwordItems {
                try passwordItem.deleteItem()
            }
        } catch {
            //fatalError("Error deleting password item - \(error.localizedDescription)")
        }
        UserDefaultsHelper.shared.removeFromUserDefaults(key: "expiration")
        UserDefaultsHelper.shared.removeFromUserDefaults(key: "tokenCreationDate")
        isAuthenticated = false
    }

    /// Save token creation time to persistant App store
    private func saveTokenCreationTime() {
        UserDefaultsHelper.shared.addToUserDefaults(key: "tokenCreationDate", value: Date().toString(dateFormat: "dd/MM/yyyy HH:mm:ss"))
    }

    /// Check if we need to force a new Login session for the user
    func isFreshTokenRequired() -> Bool {
        guard let tokenCreationDateString = UserDefaults.standard.string(forKey: "tokenCreationDate") else { return true }
        if !tokenCreationDateString.isEmpty {
            guard let tokenCreationDate = tokenCreationDateString.toDate(dateFormat: "dd/MM/yyyy HH:mm:ss") else { return true }
            guard let expiryLifetime = UserDefaultsHelper.shared.getFromUserDefaults(key: "expiration") as? Int else { return true }
            let timeIntervalDouble = Double(expiryLifetime)
            let timeInterval = TimeInterval(timeIntervalDouble)
            if tokenCreationDate.addingTimeInterval(timeInterval) < Date() {
                isAuthenticated = false
                return true
            } else {
                return false
            }
        }
        return true
    }
}

/// Helper class to do common calls on user defaults
class UserDefaultsHelper: NSObject {
    static let shared = UserDefaultsHelper()

    /// set variable for use defaults
    let userDefaults = UserDefaults.standard

    /// add a key value to User Defaults
    func addToUserDefaults(key: String, value: Any) {
        userDefaults.set(value, forKey: key)
    }

    /// Get value for Key from User Defaults
    func getFromUserDefaults(key: String) -> Any? {
        let value = userDefaults.value(forKey: key)
        return value
    }

    /// Remove Object from User defaults
    func removeFromUserDefaults(key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
