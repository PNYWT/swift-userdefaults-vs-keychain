//
//  KeychainConfiguration.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
import Security

struct KeychainConfiguration {
    let service: String
    let accessibleAttribute: CFString

    static let `default`: KeychainConfiguration = KeychainConfiguration(
        service: AppStorageConfiguration.keychainService,
        accessibleAttribute: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    )
}
