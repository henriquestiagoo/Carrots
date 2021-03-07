//
//  APIClientPublisherTests.swift
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
import XCTest
@testable import Carrots

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class MockPublisherClient: APIClientPublisherService {
    var response: Response?
    var apiClientError: APIClientError?
    
    func runPublisher(resource: Resource) -> AnyPublisher<Response, APIClientError> {
        if let response = response {
            return Just(response)
                .setFailureType(to: APIClientError.self)
                .eraseToAnyPublisher()
            
        } else if let apiClientError = apiClientError {
            return Fail(error: apiClientError)
                .eraseToAnyPublisher()
            
        } else {
            return Just(Response(request: UsersAPI.users.request(with: API.baseUsersURL), data: nil, httpUrlResponse: nil))
                .setFailureType(to: APIClientError.self)
                .eraseToAnyPublisher()
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class APIClientPublisherTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    func testRunPublisherWithSuccess() {
        let sut = MockPublisherClient()
        let expectedSuccessResponse = Response(request: UsersAPI.users.request(with: API.baseUsersURL), data: nil, httpUrlResponse: nil)
        sut.response = expectedSuccessResponse

        let didReceiveValue = expectation(description: "didReceiveValue")
        
        sut.runPublisher(resource: UsersAPI.users)
            .sink(receiveCompletion: { _ in }, receiveValue: { response in
                XCTAssertEqual(response, expectedSuccessResponse)
                didReceiveValue.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [didReceiveValue], timeout: 1)
    }
    
    func testRunPublisherAndDecodeWithSuccess() throws {
        let sut = MockPublisherClient()
        let expectedUsers = [User(id: 1, name: "Tiago")]
        let data = try JSONEncoder().encode(expectedUsers)
        let expectedSuccessResponse = Response(request: UsersAPI.users.request(with: API.baseUsersURL), data: data, httpUrlResponse: nil)
        sut.response = expectedSuccessResponse
        
        sut.runPublisher(resource: UsersAPI.users)
            .tryMap { try $0.decode(to: [User].self) }
            .sink(receiveCompletion: { _ in }) { (receivedValue) in
                XCTAssertEqual(receivedValue, expectedUsers)
            }
            .store(in: &cancellables)
    }
    
    func testRunPublisherWithError() {
        let sut = MockPublisherClient()
        sut.apiClientError = APIClientError.badStatus(status: 500)

        sut.runPublisher(resource: UsersAPI.users)
            .sink { completion in
                switch completion {
                case let .failure(receivedError):
                    XCTAssertEqual(receivedError.errorDescription, "Bad status \(500).")
                default:
                    XCTFail("Should receive error")
                }
            } receiveValue: { (receivedValue) in
                XCTFail("Should not receive value")
            }
            .store(in: &cancellables)
    }
    
    func testRunPublisherAndDecodeWithError() throws {
        let sut = MockPublisherClient()
        sut.apiClientError = APIClientError.couldNotDecode
        
        sut.runPublisher(resource: UsersAPI.users)
            .tryMap { try $0.decode(to: [User].self) }
            .sink { (completion) in
                switch completion {
                case let .failure(error):
                    XCTAssertEqual((error as? APIClientError)?.errorDescription, "Failed to decode object.")
                default:
                    XCTFail("Should receive error")
                }
            } receiveValue: { (users) in
                XCTFail("Should not receive users")
            }
            .store(in: &cancellables)
    }
    
}

#endif
