//
//  APIClientServiceTests.swift
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

import XCTest
@testable import Carrots

class MockClient: APIClientService {
    var result: Result<Response, APIClientError>?
    
    func run(resource: Resource, completion: @escaping (Result<Response, APIClientError>) -> Void) {
        result.map(completion)
    }
}

final class APIClientServiceTests: XCTestCase {
    
    func testRunWithSuccess() throws {
        let expectedUsers = [User(id: 1, name: "Tiago")]
        let encodedData = try JSONEncoder().encode(expectedUsers)
        let response = Response(request: UsersAPI.users.request(with: API.baseUsersURL), data: encodedData, httpUrlResponse: nil)
    
        let mockClient = MockClient()
        mockClient.result = .success(response)
        
        var result: Result<Response, APIClientError>?

        mockClient.run(resource: UsersAPI.users) { result = $0 }
        
        XCTAssertEqual(response, result?.value)
        
        let decodeResponse = try result?.value?.decode(to: [User].self)
        
        XCTAssertEqual(decodeResponse, expectedUsers)
    }
    
    func testRunWithFailure() throws {
        let mockClient = MockClient()
        mockClient.result = .failure(APIClientError.noData)
        
        var result: Result<Response, APIClientError>?

        mockClient.run(resource: UsersAPI.users) { result = $0 }
        
        XCTAssertNotNil(result?.error)
        XCTAssertTrue(result?.error?.errorDescription == "No data.")
    }
    
    func testRunBefore() {
        let sut = APIClient(baseURL: API.baseUsersURL)
        
        sut.run(resource: UsersAPI.users) { _ in }
        
        let lastRequest = sut.session.tasks.last?.currentRequest
        XCTAssertEqual(lastRequest?.url, UsersAPI.users.request(with: API.baseUsersURL).url)
    }

}

extension URLSession {
    var tasks: [URLSessionTask] {
        var tasks: [URLSessionTask] = []
        let group = DispatchGroup()
        group.enter()
        getAllTasks {
            tasks = $0
            group.leave()
        }
        group.wait()
        return tasks
    }
}

extension Response: Equatable {
    public static func == (lhs: Response, rhs: Response) -> Bool {
        return lhs.data == rhs.data &&
            lhs.request == rhs.request &&
            lhs.httpUrlResponse == rhs.httpUrlResponse
    }
}
