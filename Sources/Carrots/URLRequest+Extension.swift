//
//  URLRequest+Extension.swift
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

extension URLRequest {
    
    public func addParameters(parameters: [String: String]) -> URLRequest {
        guard !parameters.isEmpty, let url = url else { return self }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        let queryItems = (components.queryItems ?? []) + parameters.map { name, value in
            URLQueryItem(name: name, value: value)
        }

        components.queryItems = queryItems.sorted { $0.name < $1.name }

        var result = self
        result.url = components.url

        return result
    }

    public func addHeaders(headers: [String: String]) -> URLRequest {
        guard !headers.isEmpty else { return self }

        var result = self

        for (field, value) in headers {
            result.addValue(value, forHTTPHeaderField: field)
        }

        return result
    }
}

extension URLRequest {
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
    internal var logDescription: String {
        var result = "[REQUEST] \(httpMethod!) \(url!)"

        if let logDescription = allHTTPHeaderFields?.logDescription, !logDescription.isEmpty {
            result += "\n ├─ Headers\n\(logDescription)"
        }

        if let logDescription = httpBody?.logDescription, !logDescription.isEmpty {
            result += "\n ├─ Body\n\(logDescription)"
        }

        return result
    }
}
