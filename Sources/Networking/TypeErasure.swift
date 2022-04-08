//
//  File.swift
//  
//
//  Created by Omran, Amr on 08.11.21.
//

import Foundation

public struct AnyEncodable: Encodable {
    
    let value: Encodable
    
    public init(_ value: Encodable) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: &container)
    }
}

public extension Encodable {
    func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}
