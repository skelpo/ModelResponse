import XCTest
import Vapor
@testable import ModelResponse

final class ModelResponseTests: XCTestCase {
    var app: Application!
    
    override func setUp() {
        super.setUp()
        
        self.app = try! Application(config: Config.default(), environment: Environment.detect(), services: Services.default())
    }

    override func tearDown() {
        self.app = nil
        
        super.tearDown()
    }
    
    func testUser()throws {
        let user = User(name: "Caleb", password: "bad-password", age: 42)
        let response = try user.response(on: self.app).wait()
        
        XCTAssertEqual(response.age, 42)
        XCTAssertEqual(response.name, "Caleb")
    }
    
    func testArray()throws {
        let users = [User(name: "Caleb", password: "bad-password", age: 42), User(name: "Tanner", password: "0101", age: 31)]
        let response = try users.response(on: self.app).wait()
        
        XCTAssertEqual(response[0].age, 42)
        XCTAssertEqual(response[0].name, "Caleb")
        XCTAssertEqual(response[1].age, 31)
        XCTAssertEqual(response[1].name, "Tanner")
    }
    
    func testDictionary()throws {
        let users = [
            "Caleb": User(name: "Caleb", password: "bad-password", age: 42),
            "Tanner": User(name: "Tanner", password: "0101", age: 31)
        ]
        let response = try users.response(on: self.app).wait()
        
        XCTAssertEqual(response["Caleb"]?.age, 42)
        XCTAssertEqual(response["Caleb"]?.name, "Caleb")
        XCTAssertEqual(response["Tanner"]?.age, 31)
        XCTAssertEqual(response["Tanner"]?.name, "Tanner")
    }
    
    func testFuture()throws {
        let user = self.app.future(User(name: "Caleb", password: "bad-password", age: 42))
        let response = try user.response(on: self.app).wait()
        
        XCTAssertEqual(response.age, 42)
        XCTAssertEqual(response.name, "Caleb")
    }
    
    func testFutureArrayDictionary()throws {
        let user = self.app.future(["users": [User(name: "Caleb", password: "bad-password", age: 42)]])
        let response = try user.response(on: self.app).wait()
        
        XCTAssertEqual(response["users"]?[0].age, 42)
        XCTAssertEqual(response["users"]?[0].name, "Caleb")
    }
    
    func testDefault()throws {
        let token = Token(hash: "#AF0091")
        let response = try token.response(on: self.app).wait()
        
        XCTAssertEqual(response.hash, "#AF0091")
    }
    
    static var allTests = [
        ("testUser", testUser),
        ("testArray", testArray),
        ("testDictionary", testDictionary),
        ("testFuture", testFuture),
        ("testFutureArrayDictionary", testFutureArrayDictionary),
        ("testDefault", testDefault)
    ]
}

final class User {
    let password: String
    let name: String
    let age: Int
    
    init(name: String, password: String, age: Int) {
        self.password = password
        self.name = name
        self.age = age
    }
}

extension User: Respondable {
    struct Result: Content {
        let name: String
        let age: Int
    }
    
    func response(on container: Container) -> EventLoopFuture<User.Result> {
        return container.future(User.Result(name: self.name, age: self.age))
    }
}

final class Token: Content, Respondable {
    typealias Result = Token
    
    let hash: String
    
    init(hash: String) {
        self.hash = hash
    }
}
