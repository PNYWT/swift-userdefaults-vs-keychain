//
//  SecureStoreServiceProtocol.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

protocol SecureStoreServiceProtocol {
    func loadCredentials() throws -> AuthCredentials?
    func saveCredentials(_ credentials: AuthCredentials) throws
    func clearCredentials() throws
}
