//
//  KeychainManagerProtocol.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

protocol KeychainManagerProtocol {
    func data(forKey key: String) throws -> Data?
    func string(forKey key: String) throws -> String?

    func set(_ value: Data, forKey key: String) throws
    func set(_ value: String, forKey key: String) throws

    func remove(forKey key: String) throws
}
