//
//  Response.swift
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

public struct Response {
    public let request: URLRequest
    public let data: Data?
    public let httpUrlResponse: HTTPURLResponse?
    
    public var httpStatusCode: Int {
        return httpUrlResponse?.statusCode ?? 200
    }

    public init(request: URLRequest,
                data: Data?,
                httpUrlResponse: HTTPURLResponse?) {
        self.request = request
        self.data = data
        self.httpUrlResponse = httpUrlResponse
    }
    
    public func decode<T: Decodable>(to: T.Type) throws -> T {
        guard let data = data else { throw APIClientError.noData }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIClientError.couldNotDecode
        }
    }
}

extension Response {
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
    public var logDescription: String {
        var result = "[RESPONSE]"
        
        guard let httpUrlResponse = httpUrlResponse, let url = httpUrlResponse.url, let data = data else { return result }
        
        result += " \(httpUrlResponse.statusCode) \(url)"

        let headers = httpUrlResponse.allHeaderFields.logDescription
        if !headers.isEmpty {
            result += "\n ├─ Headers\n\(headers)"
        }

        let content = data.logDescription
        if !content.isEmpty {
            result += "\n ├─ Content\n\(content)"
        }
        return result
    }
}

