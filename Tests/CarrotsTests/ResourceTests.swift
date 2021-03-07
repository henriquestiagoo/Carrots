//
//  ResourceTest.swift
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

struct ResourceUtils {
    static let usersMethod: HTTPMethod = UsersAPI.users.method
    static let userMethod: HTTPMethod = UsersAPI.user(id: 1).method
    static let postUserEncodableMethod: HTTPMethod = UsersAPI.postUserEncodable(id: 1, body: User(id: 1, name: "Tiago")).method
    static let postUserParametersMethod: HTTPMethod = UsersAPI.postUserParameters(id: 1, parameters: ["id": 1, "name": "Tiago"]).method
    
    static let usersPath: String = UsersAPI.users.path
    static let userPath: String = UsersAPI.user(id: 1).path
    
    static let usersUrlQueryParameters: [String: String] = UsersAPI.users.urlQueryParameters
    static let userPostEncodableUrlQueryParameters: [String: String] = UsersAPI.postUserEncodable(id: 1, body: User(id: 1, name: "Tiago")).urlQueryParameters
    
    static let usersHeaders: [String: String] = UsersAPI.users.headers
    static let userPostHeaders: [String: String] = UsersAPI.postUserEncodable(id: 1, body: User(id: 1, name: "Tiago")).headers
    
    static let usersHTTPBody: HTTPBody? = UsersAPI.users.httpBody
}

class ResourceTest: XCTestCase {
    
    func testResourceHTTPMethods() {
        XCTAssertEqual(ResourceUtils.usersMethod.rawValue, "GET")
        XCTAssertEqual(ResourceUtils.userMethod.rawValue, "GET")
        XCTAssertEqual(ResourceUtils.postUserEncodableMethod.rawValue, "POST")
        XCTAssertEqual(ResourceUtils.postUserParametersMethod.rawValue, "POST")
    }
    
    func testResourcePaths() {
        XCTAssertEqual(ResourceUtils.usersPath, "users")
        XCTAssertEqual(ResourceUtils.userPath, "users/1")
    }
    
    func testResourceUrlQueryParameters() {
        XCTAssertEqual(ResourceUtils.usersUrlQueryParameters, ["fullName": "true"])
        XCTAssertEqual(ResourceUtils.userPostEncodableUrlQueryParameters, [:])
    }
    
    func testResourceHeaders() {
        XCTAssertEqual(ResourceUtils.userPostHeaders, ["Content-Type": "application/json"])
        XCTAssertEqual(ResourceUtils.usersHeaders, [:])
    }
    
    func testResourceHTTPBody() {
        XCTAssertNil(ResourceUtils.usersHTTPBody)
    }
    
}

