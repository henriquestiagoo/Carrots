//
//  Resource.swift
//  Carrots
//
//  Copyright (c) 2021 Tiago Henriques
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

public protocol Resource {
    var method: HTTPMethod { get }
    var path: String { get }
    var urlQueryParameters: [String: String] { get }
    var httpBody: HTTPBody? { get }
    var headers: [String: String] { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

public extension Resource {
    var method: HTTPMethod {
        return .get
    }

    var headers: [String: String] {
        return [:]
    }
    
    var httpBody: HTTPBody? {
        return nil
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
    
    func request(with baseURL: URL) -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        
        // URLComponents can fail due to programming errors, so prefer crashing than returning an optional
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            fatalError("Could not create URL components from \(url).")
        }
        
        if !urlQueryParameters.isEmpty {
            components.queryItems = urlQueryParameters.map {
                URLQueryItem(name: String($0), value: String($1))
            }
        }
                
        guard let finalURL = components.url else {
            fatalError("Could not retrieve final URL.")
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        
        if method == .post || method == .put, let body = httpBody {
            switch body {
            case .requestWithParameters(let parameters):
                request.httpBody = encode(parameters: parameters)
            case .requestWithEncodable(let encodable):
                request.httpBody = encode(encodable: EncodableWrapper(value: encodable))
            }
        }
                
        for (field, value) in headers {
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        request.cachePolicy = cachePolicy
                
        return request
    }
    
    func encode(parameters: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
    
    func encode<T>(encodable: T) -> Data? where T: Encodable {
        return try? JSONEncoder().encode(encodable)
    }
}
