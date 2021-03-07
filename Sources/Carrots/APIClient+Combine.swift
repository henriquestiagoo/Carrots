//
//  APIClient+Combine.swift
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

#if canImport(Combine)
import Foundation
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol APIClientPublisherService {
    func runPublisher(resource: Resource) -> AnyPublisher<Response, APIClientError>
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension APIClient: APIClientPublisherService {
    
    public func runPublisher(resource: Resource) -> AnyPublisher<Response, APIClientError>  {
        let request = resource.request(with: baseURL)
        
        logger.debug("\(request.logDescription)")
                
        return session.dataTaskPublisher(for: request)
            .tryMap { [logger] (data, urlResponse) -> Response in
                let response = Response(request: request, data: data, httpUrlResponse: urlResponse as? HTTPURLResponse)
                
                logger.debug("\(response.logDescription)")
                
                if let urlResponse = urlResponse as? HTTPURLResponse,
                    (200..<300).contains(urlResponse.statusCode) == false {
                    throw APIClientError.badStatus(status: urlResponse.statusCode)
                }

                return response
            }
            .mapError { error -> APIClientError in
                guard let apiClientError = error as? APIClientError else {
                    return .other(error)
                }
                return apiClientError
            }
            .eraseToAnyPublisher()
    }
    
    public func runPublisher<T: Codable>(resource: Resource, to: T.Type) -> AnyPublisher<T, APIClientError> {
        return runPublisher(resource: resource)
            .tryMap { try $0.decode(to: T.self) }
            .mapError { error -> APIClientError in
                guard let apiClientError = error as? APIClientError else {
                    return .other(error)
                }
                return apiClientError
            }
            .eraseToAnyPublisher()
    }
}
#endif
