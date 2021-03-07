//
//  UsersAPI.swift
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
@testable import Carrots

struct API {
    static let baseUsersURL = URL(string: "https://example.com")!
}

enum UsersAPI {
    case users
    case user(id: Int)
    case postUserEncodable(id: Int, body: Encodable)
    case postUserParameters(id: Int, parameters: [String: Any])
}

extension UsersAPI: Resource {
    var path: String {
        switch self {
        case .users:
            return "users"
        case .user(let id), .postUserEncodable(let id, _), .postUserParameters(let id, _):
            return "users/\(id)"
        }
    }
    
    var urlQueryParameters: [String : String] {
        switch self {
        case .users, .user:
            return ["fullName": "true"]
        default:
            return [:]
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .postUserEncodable, .postUserParameters:
            return .post
        default:
            return .get
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .postUserEncodable, .postUserParameters:
            return ["Content-Type": "application/json"]
        default:
            return [:]
        }
    }
    
    var httpBody: HTTPBody? {
        switch self {
        case .postUserEncodable(_, let user):
            return .requestWithEncodable(user)
        case .postUserParameters(_ , let params):
            return .requestWithParameters(params)
        default:
            return nil
        }
    }
}
