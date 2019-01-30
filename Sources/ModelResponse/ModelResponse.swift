import Vapor

public protocol Respondable {
    associatedtype Result: ResponseEncodable
    
    func response(on container: Container) -> Future<Self.Result>
}

extension Respondable where Self: ResponseEncodable {
    public func response(on container: Container) -> Future<Self> {
        return container.future(self)
    }
}

extension Array: Respondable where Element: Respondable, Element.Result: Content {
    public typealias Result = [Element.Result]
    
    public func response(on container: Container) -> Future<[Element.Result]> {
        return self.map { $0.response(on: container) }.flatten(on: container)
    }
}

extension Dictionary: Respondable where Key == String, Value: Respondable, Value.Result: Content {
    public typealias Result = [String: Value.Result]
    
    public func response(on container: Container) -> Future<[String: Value.Result]> {
        return self.map { key, value in value.response(on: container).and(result: key) }.flatten(on: container).map { list in
            return list.reduce(into: [:]) { result, pair in
                result[pair.1] = pair.0
            }
        }
    }
}

extension Future: Respondable where T: Respondable {
    public typealias Result = T.Result
    
    public func response(on container: Container) -> EventLoopFuture<T.Result> {
        return self.flatMap { t in t.response(on: container) }
    }
}
