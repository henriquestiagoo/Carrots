//
//  ResponseTests.swift
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

class ResponseTests: XCTestCase {
    
    func testDecodeResponseWithSuccess() throws {
        let expectedUsers = [User(id: 1, name: "Tiago")]
        let data = try JSONEncoder().encode(expectedUsers)
        let response = Response(request: UsersAPI.users.request(with: API.baseUsersURL), data: data, httpUrlResponse: nil)
        
        let decodedUsers = try response.decode(to: [User].self)
        XCTAssertEqual(decodedUsers, expectedUsers)
    }
    
    func testDecodeResponseReturnsAPIClientErrorNoData() {
        let response = Response(request: UsersAPI.users.request(with: API.baseUsersURL), data: nil, httpUrlResponse: nil)
        
        XCTAssertThrowsError(try response.decode(to: [User].self)) { error in
            if let apiClientError = error as? APIClientError {
                XCTAssertEqual(apiClientError.errorDescription, "No data.")
            } else {
                XCTFail("Error type mismatch")
            }
        }
    }
    
    func testDecodeResponseWithAPIClientErrorCouldNotDecodeJSON() throws {
        let data = try JSONEncoder().encode([User(id: 1, name: "Tiago")])
        let response = Response(request: UsersAPI.users.request(with: API.baseUsersURL), data: data, httpUrlResponse: nil)

        XCTAssertThrowsError(try response.decode(to: User.self)) { error in
            if let apiClientError = error as? APIClientError {
                XCTAssertEqual(apiClientError.errorDescription, "Failed to decode object.")
            } else {
                XCTFail("Error type mismatch")
            }
        }
    }
    
    func testResponseLogDescription() throws {
        let data = try JSONEncoder().encode(User(id: 1, name: "Tiago"))
        let request: URLRequest = UsersAPI.users.request(with: API.baseUsersURL)
        let httpUrlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])
        let response = Response(request: request, data: data, httpUrlResponse: httpUrlResponse)
        
        let expectedLogDescription = """
                [RESPONSE] 200 https://example.com/users?fullName=true
                 ├─ Headers
                 │ Content-Type: application/json
                 ├─ Content
                  {
                    "id" : 1,
                    "name" : "Tiago"
                  }
                """
        
        XCTAssertEqual(response.logDescription, expectedLogDescription)
    }
}
