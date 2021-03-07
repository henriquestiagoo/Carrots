//
//  APIClient.swift
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
import Logging

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public protocol APIClientService {
    func run(resource: Resource, completion: @escaping (Result<Response, APIClientError>) -> Void)
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public final class APIClient: APIClientService {
    public let baseURL: URL
    public let configuration: APIClientConfig
    public let session: URLSession
    public var logger = Logger(label: "APIClientLogger")
    
    public init(baseURL: URL,
         configuration: APIClientConfig = APIClientConfig(),
         session: URLSession = URLSession(configuration: .default),
         logLevel: Logger.Level = .info) {
        self.baseURL = baseURL
        self.configuration = configuration
        self.session = session
        self.logger.logLevel = logLevel
    }
        
    public func run(resource: Resource, completion: @escaping (Result<Response, APIClientError>) -> Void) {
        let request = resource.request(with: baseURL)
            .addHeaders(headers: configuration.headers)
            .addParameters(parameters: configuration.urlQueryparameters)
        
        logger.debug("\(request.logDescription)")
        
        loadResponse(request: request) { (response, error) in
            if let error = error {
                completion(.failure(APIClientError.other(error)))
                return
            }
            
            if let httpUrlResponse = response.httpUrlResponse, 200 ..< 300 ~= httpUrlResponse.statusCode {
                completion(.success(response))
            } else {
                completion(.failure(APIClientError.badStatus(status: response.httpStatusCode)))
            }
        }
    }

    public func run<T: Codable>(resource: Resource, to: T.Type, completion: @escaping (Result<T, APIClientError>) -> Void) {
        run(resource: resource) { (result) in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(response):
                do {
                    let decoded = try response.decode(to: T.self)
                    completion(.success(decoded))
                } catch let error {
                    completion(.failure(error as! APIClientError))
                }
            }
        }
    }
    
    public func loadResponse(request: URLRequest, completion: @escaping (Response, Error?) -> Void) {
        let task = session.dataTask(with: request) { [logger] (data, urlResponse, error) in
            let response = Response(request: request,
                                    data: data,
                                    httpUrlResponse: urlResponse as? HTTPURLResponse)
            
            logger.debug("\(response.logDescription)")
            
            completion(response, error)
        }
        task.resume()
    }
}
