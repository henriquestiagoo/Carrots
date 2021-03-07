//
//  URLRequestTests.swift
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

import XCTest
@testable import Carrots

class URLRequestTests: XCTestCase {
    
    func testRequestAddingQueryParametersReturnsExpectedRequest() {
        let request = UsersAPI.users.request(with: API.baseUsersURL).addParameters(parameters: ["language": "pt"])
                
        var components = URLComponents(string: "https://example.com/users")!
        components.queryItems = [
            URLQueryItem(name: "fullName", value: "true"),
            URLQueryItem(name: "language", value: "pt")
        ]
        let expectedRequest = URLRequest(url: components.url!)
        
        XCTAssertEqual(request, expectedRequest)
    }
    
    func testRequestAddingHeadersReturnsExpectedRequest() {
        let request = UsersAPI.users.request(with: API.baseUsersURL).addHeaders(headers: ["Accept": "application/json"])
        
        var expectedRequest = URLRequest(url: URL(string: "https://example.com/users?fullName=true")!)
        expectedRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        XCTAssertEqual(request, expectedRequest)
    }
    
    func testRequestLogDescription() {
        let request = UsersAPI.users.request(with: API.baseUsersURL)
        
        let expectedLogDescription = "[REQUEST] GET https://example.com/users?fullName=true"
        
        XCTAssertEqual(request.logDescription, expectedLogDescription)
    }
    
    func testRequestWithHeadersAndBodyLogDescription() {
        let request = UsersAPI.postUserEncodable(id: 1, body: User(id: 1, name: "Tiago")).request(with: API.baseUsersURL)
        
        let expectedLogDescription = """
                [REQUEST] POST https://example.com/users/1
                 ├─ Headers
                 │ Content-Type: application/json
                 ├─ Body
                  {
                    "id" : 1,
                    "name" : "Tiago"
                  }
                """
        
        XCTAssertEqual(request.logDescription, expectedLogDescription)
    }

}
