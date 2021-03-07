# 🥕 Carrots

<p align="left">
    <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" />
    <img src="https://img.shields.io/badge/platforms-iOS | macOS | watchOS | tvOS-brightgreen.svg?style=flat" alt="Mac" />
    <a href="https://www.linkedin.com/in/tiago-henriques-38896472/">
        <img src="https://img.shields.io/badge/linkedin-@_Tiago%20Henriques-blue.svg?style=flat" alt="Linkedin: @Tiago Henriques" />
    </a>
</p>

- [x] A scalable and easy to use HTTP client written in Swift.
- [x] An elegant wrapper around NSURLSession.
- [x] Combine extensions to the HTTP client.
- [x] Maps HTTP Client errors responses into a single generic type.
- [x] Optional Logging on requests and responses.

## 🔨 Installation

### Swift Package Manager 
If you wish to integrate Carrots through Swift Package Manager, add the library as a dependency to your `Package.swift` file:

 `.package(url: "https://github.com/henriquestiagoo/Carrots.git", .upToNextMajor(from: "1.0.0"))`
 

### CocoaPods
Otherwise, if you confortable using CocoaPods, you can add Carrots into your Xcode project by declaring it in your `Podfile`:

```ruby
pod 'Carrots', :git => 'https://github.com/henriquestiagoo/Carrots.git', :tag => '1.0.0'
```

Then, run the following command:

```bash
$ pod install
```

### Manually
You can even prefer not to use any of the dependency managers and integrate Carrots into your project manually. You just need to clone this repository and drag  the source files to your project directory.

## 📖 Getting started
Let's begin by exploring all the features using the [Rest Countries API](https://restcountries.eu/) as an example. At the time of the writing, this API was at the version 2.0.5.<br/>
Set up an `enum` with all of your API resources like the following:

```swift
enum CountriesAPI {
  case name(name: String)
  case alphaCodes(codes: [String])
  case postExample(name: String, body: Encodable)
  case postExampleParameters(name: String, body: [String: Any])
  ...
}
```

Extend `enum` and confom to the `Resource` protocol.

```swift
extension CountriesAPI: Resource {

    var path: String {
        switch self {
        case .name(let name):
            return "name/\(name)"
        case .alphaCodes:
            return "alpha"
        case .postExample(let name, _), .postExampleParameters(let name ,_):
            return "name/\(name)"
        }
    }
    
    var urlQueryParameters: [String : String] {
        switch self {
        case .name:
            return ["fullText": "true"]
        case .alphaCodes(let codes):
            return ["codes": codes.joined(separator: ";")]
        default:
            return [:]
        }
    } 
    
    var method: HTTPMethod {
        switch self {
        case .postExample, .postExampleParameters:
            return .post
        default:
            return .get
        }
    }
    
    var httpBody: HTTPBody? {
        switch self {
        case .postExample(_, let body):
            return .requestWithEncodable(body)
        case .postExampleParameters(_, let parameters):
            return .requestWithParameters(parameters)
        default:
            return nil
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .postExample, .postExampleParameters:
            return ["Content-Type": "application/json"]
        default:
            return [:]
        }
    }
    
}
```

## 👷 Creating the HTTP client
The `APIClient` worker is responsible for performing calls to an API and handling its responses. To create an HTTP client, you need to provide the base URL and, if you want, you can pass any additional parameters or headers that you would like to append to all requests, like an authorization header or/and an url query parameter like a language specification.

```Swift
let apiClient = APIClient(baseURL: URL(string: "https://restcountries.eu/rest/v2")!,
                          configuration: APIClientConfig(headers: ["Authorization": "Bearer xyz"],
                                                         urlQueryParameters: ["language": "pt"]))
```

### 🏃🏿‍♂️ Handling API requests
```swift
apiClient.run(resource: CountriesAPI.name(name: "Portugal")) { (result) in
    switch result {
    case let .failure(error):
        print(error)
    case let .success(response):
        let countries = try? response.decode(to: [Country].self)
        print(countries)
    }
}

// or this if you want to decode the response to a Codable object.

apiClient.run(resource: CountriesAPI.name(name: "Portugal"), to: [Country].self) { (result) in
    switch result {
    case let .failure(error):
        print(error)
    case let .success(countries):
        print(countries)
    }
}
```

## 🧞 Combine
Swift 5 system frameworks already provide us the tools that we need to write concise networking layer and Carrots provides reactive extensions for Combine framework.
```swift 
apiClient.runPublisher(resource: CountriesAPI.name(name: "Portugal"))
    .sink(receiveCompletion: { _ in }) { (response) in
        let countries = try? response.decode(to: [Country].self)
        print(countries)
    }
    .store(in: &cancellables)
```

## 📋 Logging requests and responses
Each `APIClient` instance can log requests and responses using a [SwiftLog](https://github.com/apple/swift-log) logging API.

To start using it and being able to log requests and responses, you just need to declare the `.debug` log-level when initializing the APIClient.

```Swift
let apiClient: APIClient = APIClient(baseURL: URL(string: "https://restcountries.eu/rest/v2")!,
                                     logLevel: .debug)

```

Carrots parses the headers and JSON responses, producing structured and easily readable logs. Here you can check an example of the output produced by a [`GET /name/Portugal?fullText=true`](https://restcountries.eu/#api-endpoints-full-name) request:

``` 
 2021-02-17T17:58:24+0000 debug APIClientLogger : [RESPONSE] 200 https://restcountries.eu/rest/v2/name/Portugal?fullText=true
 ├─ Headers
 │ cf-cache-status: DYNAMIC
 │ Cache-Control: public, max-age=86400
 │ Server: cloudflare
 │ access-control-allow-headers: Accept, X-Requested-With
 │ Content-Type: application/json;charset=utf-8
 │ Access-Control-Allow-Origin: *
 │ Date: Wed, 17 Feb 2021 17:58:24 GMT
 │ access-control-allow-methods: GET
 │ nel: {"max_age":604800,"report_to":"cf-nel"}
 │ expect-ct: max-age=604800, report-uri="https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct"
 │ Content-Encoding: br
 ├─ Content
  [
    {
      "alpha2Code" : "PT",
      "alpha3Code" : "PRT",
      "altSpellings" : [
        "PT",
        "Portuguesa",
        "Portuguese Republic",
        "República Portuguesa"
      ],
      "area" : 92090,
      "borders" : [
        "ESP"
      ],
      "callingCodes" : [
        "351"
      ],
      "capital" : "Lisbon",
  ...
```

### 📜 License
Carrots is released under the MIT license. Check [LICENSE](https://github.com/henriquestiagoo/Carrots/blob/master/LICENSE) for details.
