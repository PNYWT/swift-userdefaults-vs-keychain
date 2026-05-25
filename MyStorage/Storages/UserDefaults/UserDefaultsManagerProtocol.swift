//
//  UserDefaultsManagerProtocol.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

protocol UserDefaultsManagerProtocol {
    func bool(forKey key: String) -> Bool
    func string(forKey key: String) -> String?

    func set(_ value: Bool, forKey key: String)
    func set(_ value: String, forKey key: String)

    func remove(forKey key: String)
}
