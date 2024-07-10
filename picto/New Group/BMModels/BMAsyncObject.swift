//
//  BMAsyncObject.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/12/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation
import QuartzCore
import ObjectMapper

protocol BMSerializedObjectType: Mappable {
    static var identifier: String { get }
    
    var id: UInt! { get set }
    
}

public class BMSerializedObject: BMSerializedObjectType, Equatable {
    class var identifier: String { return "_BMBase" }
    var id: UInt!
    
    init() {
        id = 0
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id              <- map["id"]
        if id == nil {
            id = 0
        }
    }
    
    static public func == (lhs: BMSerializedObject, rhs: BMSerializedObject) -> Bool {
        return lhs.id == rhs.id
    }
}

// Move
class ObjectLoader {
    static let shared = ObjectLoader()
    
    var cache = [String: [UInt: BMSerializedObjectType]]()
    
    func cacheObject(_ object: BMSerializedObjectType, key: String) {
        
        if (cache[key] == nil) {
            cache[key] = [UInt: BMSerializedObjectType]()
        }
        cache[key]![object.id] = object
    }
    
//    func getCachedObjects(_ object: inout BMSerializedObjectType, type: BMSerializedObject) -> [BMSerializedObject] {
//        var objects = [BMSerializedObjectType]()
//        for i in ObjectLoader.shared.cache {
//            let val = i.value[object.id!]
//            if let ob = val {
//                if ob.toJSON()["id"] as! UInt == object.id! {
////                    let new = BMSerializedObject.identifier
//                    objects.append(ob)
//                    print("FOUND OBJECT IN CACHE")
//                }
//            }
//        }
////        return objects
//    }
    func getCachedObjects(_ object: BMSerializedObject) -> [BMSerializedObjectType] {
        var objects = [BMSerializedObjectType]()
        for i in ObjectLoader.shared.cache {
            let val = i.value[object.id!]
            if let ob = val {
                if ob.toJSON()["id"] as? UInt == object.id! {
//                    let new = BMSerializedObject.identifier
                    objects.append(ob)
                    print("FOUND OBJECT IN CACHE")
                }
            }
        }
        return objects
    }
    
    func from(id: UInt, key: String) -> BMSerializedObjectType? {
        return cache[key]?[id]
    }
    
//    func fromJson(id: UInt) {
//        return cache.
//    }
}

class BMSerializer<T: BMSerializedObjectType>: BMLazyListSerializer {
    
    static func unserializeList(JSON: [[String : Any]]) -> [BMSerializedObjectType] {
        let objectArray = JSON
        var objects = [T]()
        
        for object in objectArray {
            let unserializedObject = unserialize(JSON: object)
            objects.append(unserializedObject)
        }
        return objects
    }
    
    let DataService = ClientAPI.sharedInstance
    
    private var lastUpdate: CFTimeInterval = 0
    
    static func updateAndSave(object: inout T, withJSON JSON: [String: Any]) {
        Mapper<T>(context: nil, shouldIncludeNilValues: true).update(object: &object, fromJSON: JSON)
        ObjectLoader.shared.cacheObject(object, key: T.identifier)
    }
    
    static func unserialize(JSON: [String: Any]) -> T {
        guard let objectId = JSON["id"] as? UInt else {  fatalError() }
//        if var cachedObject = from(id: objectId) {
//            Mapper<T>(context: nil, shouldIncludeNilValues: true).update(object: &cachedObject, fromJSON: JSON)
//            return cachedObject
//        } else {
//            if let newObject = T(JSON: JSON) {
//                assert(newObject.id > 0)
//                ObjectLoader.shared.cacheObject(newObject, key: T.identifier)
//                return newObject
//            }
//        }
        if var cachedObject = from(id: objectId) {
//            Mapper<T>(context: nil, shouldIncludeNilValues: false).map(JSON: JSON, toObject: cachedObject)
            if let newObj = T(JSON: JSON) {
                ObjectLoader.shared.cacheObject(newObj, key: T.identifier)
                Mapper<T>(context: nil, shouldIncludeNilValues: true).update(object: &cachedObject, fromJSON: JSON)
//                Mapper<T>(context: nil, shouldIncludeNilValues: false).map(JSON: JSON, toObject: cachedObject)
                return newObj
            }
            Mapper<T>(context: nil, shouldIncludeNilValues: true).update(object: &cachedObject, fromJSON: JSON)
            return cachedObject
        } else {
            if let newObject = T(JSON: JSON) {
                assert(newObject.id > 0)
                ObjectLoader.shared.cacheObject(newObject, key: T.identifier)
                return newObject
            }
        }
        fatalError("Unable to unserialize object")
    }
    
    static func unserializeNoUpdate(JSON: [String: Any]) -> T {
        guard let objectId = JSON["id"] as? UInt else {  fatalError() }
//        if let newObject = T(JSON: JSON) {
//            assert(newObject.id > 0)
//            ObjectLoader.shared.cacheObject(newObject, key: T.identifier)
//            return newObject
//        }
        if var cachedObject = from(id: objectId) {
//            Mapper<T>(context: nil, shouldIncludeNilValues: false).map(JSON: JSON, toObject: cachedObject)
            if let newObj = T(JSON: JSON) {
                ObjectLoader.shared.cacheObject(newObj, key: T.identifier)
                Mapper<T>(context: nil, shouldIncludeNilValues: true).update(object: &cachedObject, fromJSON: JSON)
                return newObj
            }
            Mapper<T>(context: nil, shouldIncludeNilValues: true).update(object: &cachedObject, fromJSON: JSON)
            return cachedObject
        } else {
            if let newObject = T(JSON: JSON) {
                assert(newObject.id > 0)
                ObjectLoader.shared.cacheObject(newObject, key: T.identifier)
                return newObject
            }
        }
        fatalError("Unable to unserialize object")
    }
    
    static func unserializeListNoUpdate(JSON: [String: Any]) -> T {
        guard let objectId = JSON["id"] as? UInt else {  fatalError() }
        if let newObject = T(JSON: JSON) {
            assert(newObject.id > 0)
            ObjectLoader.shared.cacheObject(newObject, key: T.identifier)
            return newObject
        }
//        if let cachedObject = from(id: objectId) {
////            Mapper<T>(context: nil, shouldIncludeNilValues: false).map(JSON: JSON, toObject: cachedObject)
//            return cachedObject
//        } else {
//            if let newObject = T(JSON: JSON) {
//                assert(newObject.id > 0)
//                ObjectLoader.shared.cacheObject(newObject, key: T.identifier)
//                return newObject
//            }
//        }
        fatalError("Unable to unserialize object")
    }
    
    static func from(id: UInt) -> T? {
        return ObjectLoader.shared.from(id: id, key: T.identifier) as? T
    }
    
    func loadObjectData(completion: (() -> Void)?) {
        
    }
}

class UserSerializer: BMSerializer<BMUser> {}
class ConversationSerializer: BMSerializer<BMConversation> {}
class MessageSerializer: BMSerializer<BMMessage> {}
class PostSerializer: BMSerializer<BMPost> {}
class PostMediaSerializer: BMSerializer<BMPostMedia> {}
class PostLikeSerializer: BMSerializer<BMPostLike> {}
class PostCommentSerializer: BMSerializer<BMPostComment> {}
class PostSubCommentSerializer: BMSerializer<BMPostSubComment> {}
class SavedPostSerializer: BMSerializer<BMSavedPost> {}
class CategorySerializer: BMSerializer<BMCategory> {}

class BMTransform<T: BMSerializedObjectType>: TransformType {
    public typealias Object = T
    public typealias JSON = [String: Any]
    private var required: Bool
    
    public init(required: Bool = true) {
        self.required = required
    }
    
    func transformFromJSON(_ value: Any?) -> Object? {
        if let id = value as? UInt {
            return BMSerializer<T>.from(id: id)
        }
        if let JSON = value as? [String: Any] {
//            return BMSerializer<T>.unserialize(JSON: JSON)
//            if self.required == false {
//                return BMSerializer<T>.unserializeNoUpdate(JSON: JSON)
//            } else {
//                return BMSerializer<T>.unserialize(JSON: JSON)
//            }
            if let id = JSON["id"] as? UInt {
                if var object = BMSerializer<T>.from(id: id) {
                    object = T(JSON: JSON) ?? object
                    return object
                }
//                return BMSerializer<T>.unserializeNoUpdate(JSON: JSON)
//                return BMSerializer<T>.from(id: id) ?? BMSerializer<T>.unserializeNoUpdate(JSON: JSON)
            }
            return BMSerializer<T>.unserializeNoUpdate(JSON: JSON)
        }
        
        //        assert(required == false, "Unable to transform required \(String(describing: value))")
        return nil
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        if let object = value {
            return object.toJSON()
        }
        return nil
    }
}

class BMListTransform<T: BMSerializedObjectType>: TransformType {
    
    public typealias Object = [T]
    public typealias JSON = [[String: Any]]
    private var required: Bool
    
    public init(required: Bool = true) {
        self.required = required
    }
    
    func transformFromJSON(_ value: Any?) -> Object? {
        if let JSONArray = value as? [[String: Any]] {
            return JSONArray.map({ JSON in
                if let id = JSON["id"] as? UInt {
                    if var object = BMSerializer<T>.from(id: id) {
                        object = T(JSON: JSON) ?? object
                        ObjectLoader.shared.cacheObject(object, key: T.identifier)
                        return object
                    }
    //                return BMSerializer<T>.unserializeNoUpdate(JSON: JSON)
    //                return BMSerializer<T>.from(id: id) ?? BMSerializer<T>.unserializeNoUpdate(JSON: JSON)
                }
                return BMSerializer<T>.unserializeNoUpdate(JSON: JSON)
//                if self.required == false {
//                    return BMSerializer<T>.unserializeNoUpdate(JSON: JSON)
//                } else {
//                    return BMSerializer<T>.unserialize(JSON: JSON)
//                }
//                return BMSerializer<T>.unserialize(JSON: JSON)
            })
        }
        
        assert(required, "Unable to transform \(String(describing: value))")
        return nil
    }
    
    func transformListFromJSON(ids: [UInt]) -> Object? {
        
        print("GOT ARRAY FOR TRANSFORM")
        var list = [T]()
        for id in ids {
            if let content = BMSerializer<T>.from(id: id) as? BMListTransform<T>.Object {
                list.append(contentsOf: content)
            }
//            list.append(contentsOf: )
        }
        return list
//        if let JSONArray = value as? [[String: Any]] {
//            return JSONArray.map({ JSON in
//                return BMSerializer<T>.unserialize(JSON: JSON)
//            })
//        }
        
        assert(required, "Unable to transform \(String(describing: ids))")
        return nil
    }
    
    func transformToJSON(_ values: Object?) -> JSON? {
        if let objects = values {
            return objects.map({ object in
                return object.toJSON()
            })
        }
        return nil
    }
}

extension Mapper {
    public func update(object: inout N, fromJSON JSON: [String: Any]) {
        let map = Map(mappingType: .fromJSON, JSON: JSON, context: context, shouldIncludeNilValues: shouldIncludeNilValues)
        
        if N.self is StaticMappable.Type { // Check if object is StaticMappable
            object.mapping(map: map)
        } else if N.self is Mappable.Type { // Check if object is Mappable
            object.mapping(map: map)
        } else if N.self is ImmutableMappable.Type { // Check if object is ImmutableMappable
            assertionFailure("Can't update ImmutableMappable")
        } else {
            // Ensure BaseMappable is not implemented directly
            assert(false, "BaseMappable should not be implemented directly. Please implement Mappable, StaticMappable or ImmutableMappable")
        }
    }
}
