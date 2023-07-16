//
//  BMLazyList.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/12/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit

typealias completionBlock = () -> Void

protocol BMLazyListSerializer {
    static func unserializeList(JSON: [[String: Any]]) -> [BMSerializedObjectType]
}

class BMDisposer {
    private var blocks = [BMBlockWrapper]()
    
    fileprivate func addBlock(_ block: BMBlockWrapper) {
        blocks.append(block)
    }
    
    deinit {
        blocks.forEach { wrapper in
            wrapper.block = nil
        }
    }
}

class BMBlockWrapper: NSObject {
    var block: completionBlock?
    
    init(withBlock block: @escaping completionBlock) {
        self.block = block
    }
}

enum BMLazyListSortDirection {
    case None
    case HighestToLowest
    case LowestToHighest
}

// Change generic type
class BMLazyObjectList<T: Comparable> {
    var items = [T]()
    var sortDirection: BMLazyListSortDirection = .None
    private var updateUrl: String
    private var serializer: BMLazyListSerializer.Type
    private var successBlocks = [BMBlockWrapper]()
    private var lastUpdate: TimeInterval = 0
    private let updateInterval: TimeInterval = 7
    private var autoRefreshTimer: Timer?
    
    convenience init(withSerializer serializer: BMLazyListSerializer.Type, base: String, id: UInt, object: String) {
        self.init(withSerializer: serializer, updateUrl: "https://api.warbly.net/get_list/\(base)/\(object)")
    }
    
    convenience init(withSerializer serializer: BMLazyListSerializer.Type, base: String, object: String) {
        self.init(withSerializer: serializer, updateUrl: "https://api.warbly.net/get_list/\(base)/\(object)")
    }
    
    // typealias serializerType = BMSerializer<T>
    
    public init(withSerializer serializer: BMLazyListSerializer.Type, updateUrl: String) {
        self.serializer = serializer // serializerType
        self.updateUrl = updateUrl
    }
    
    // Set the function to be called when the list updates
    func onUpdate(disposer: BMDisposer, completion: @escaping completionBlock) {
        let wrapper = BMBlockWrapper(withBlock: completion)
        successBlocks.append(wrapper)
        disposer.addBlock(wrapper)
        
        // Call once to preload
        //        lastUpdate = 0
        reload()
    }
    
    func onSingleUpdate(disposer: BMDisposer, completion: @escaping completionBlock) {
        let wrapper = BMBlockWrapper(withBlock: completion)
        successBlocks.append(wrapper)
        disposer.addBlock(wrapper)
        
        // Call once to preload
        //        lastUpdate = 7
        reloadSingle()
    }
    
    func onCommentUpdate(disposer: BMDisposer, completion: @escaping completionBlock) {
        let wrapper = BMBlockWrapper(withBlock: completion)
        successBlocks.append(wrapper)
        disposer.addBlock(wrapper)
        
        // Call once to preload
        //        lastUpdate = 0
        reloadComments()
    }
    
    func onContestUpdate(disposer: BMDisposer, completion: @escaping completionBlock) {
        let wrapper = BMBlockWrapper(withBlock: completion)
        successBlocks.append(wrapper)
        disposer.addBlock(wrapper)
        
        // Call once to preload
        //        lastUpdate = 0
        reloadContest()
    }
    
    func onTriviaUpdate(disposer: BMDisposer, completion: @escaping completionBlock) {
        let wrapper = BMBlockWrapper(withBlock: completion)
        successBlocks.append(wrapper)
        disposer.addBlock(wrapper)
        
        // Call once to preload
        //        lastUpdate = 0
        reloadTrivia()
    }
    
    // Loads fresh data into the list
    @objc func reloadInitial() {
        //        if (CACurrentMediaTime() - lastUpdate > 10) {
        //            print("\(CACurrentMediaTime() - lastUpdate) : \(lastUpdate)")
        lastUpdate = CACurrentMediaTime()
        ClientAPI.sharedInstance.requestJson(url: self.updateUrl,
                                             method: .get,
                                             parameters: nil,
                                             cache_time: 0,
                                             success: {
                                                self.loadSuccess(responseData: $0)
        },
                                             failure: { _ in self.loadFailure() })
        //        }
        // }
    }
    @objc func reload() {
        if (CACurrentMediaTime() - lastUpdate > 10) {
            print("\(CACurrentMediaTime() - lastUpdate) : \(lastUpdate)")
            lastUpdate = CACurrentMediaTime()
            ClientAPI.sharedInstance.requestJson(url: self.updateUrl,
                                                 method: .get,
                                                 parameters: nil,
                                                 cache_time: 0.2,
                                                 success: {
                                                    self.loadSuccess(responseData: $0)
            },
                                                 failure: { _ in self.loadFailure() })
        }
        // }
    }
    
    @objc func reloadSingle() {
        if (CACurrentMediaTime() - lastUpdate > 10) {
            print("\(CACurrentMediaTime() - lastUpdate) : \(lastUpdate)")
            lastUpdate = CACurrentMediaTime()
            ClientAPI.sharedInstance.requestJson(url: self.updateUrl,
                                                 method: .get,
                                                 parameters: nil,
                                                 cache_time: 0.2,
                                                 success: {
                                                    self.loadSingleSuccess(responseData: $0)
            },
                                                 failure: { _ in self.loadFailure() })
        }
    }
    
    @objc func reloadContest() {
        // if (CACurrentMediaTime() - lastUpdate > updateInterval) {
        // print("\(lastUpdate) : \(self.updateUrl), \(self)")
        lastUpdate = CACurrentMediaTime()
        ClientAPI.sharedInstance.requestJson(url: self.updateUrl,
                                             method: .get,
                                             parameters: nil,
                                             cache_time: 1,
                                             success: {
                                                self.loadSuccess(responseData: $0)
        },
                                             failure: { _ in self.loadFailure() })
        // }
    }
    
    @objc func reloadComments() {
        // if (CACurrentMediaTime() - lastUpdate > updateInterval) {
        // print("\(lastUpdate) : \(self.updateUrl), \(self)")
        lastUpdate = CACurrentMediaTime()
        ClientAPI.sharedInstance.requestJson(url: self.updateUrl,
                                             method: .get,
                                             parameters: nil,
                                             cache_time: 1,
                                             success: {
                                                self.loadSuccess(responseData: $0)
        },
                                             failure: { _ in self.loadFailure() })
        // }
    }
    
    @objc func reloadTrivia() {
        // if (CACurrentMediaTime() - lastUpdate > updateInterval) {
        // print("\(lastUpdate) : \(self.updateUrl), \(self)")
        lastUpdate = CACurrentMediaTime()
        ClientAPI.sharedInstance.requestJson(url: self.updateUrl,
                                             method: .get,
                                             parameters: nil,
                                             cache_time: 250,
                                             success: {
                                                self.loadSuccess(responseData: $0)
        },
                                             failure: { _ in self.loadFailure() })
        // }
    }
    
    // Load more items into the list
    func loadMore() {
        
    }
    
    func startAutoRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = Timer.scheduledTimer(timeInterval: updateInterval + 1,
                                                target: self,
                                                selector: #selector(self.reload),
                                                userInfo: nil,
                                                repeats: true)
    }
    
    func start30AutoRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = Timer.scheduledTimer(timeInterval: 90,
                                                target: self,
                                                selector: #selector(self.reload),
                                                userInfo: nil,
                                                repeats: true)
    }
    
    func startCommentsAutoRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = Timer.scheduledTimer(timeInterval: 5,
                                                target: self,
                                                selector: #selector(self.reloadComments),
                                                userInfo: nil,
                                                repeats: true)
    }
    
    func stopAutoRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }
    
    func add(_ object: T) {
        if items.contains(object) { return }
        items.append(object)
        sort()
        self.triggerUpdate()
    }
    
    func remove(_ object: T) {
        if let index = items.index(of: object) {
            items.remove(at: index)
        }
        //items.remove(at: object as! Int)
        self.triggerUpdate()
    }
    
    func sort() {
        switch sortDirection {
        case .HighestToLowest:
            self.items.sort(by: >)
        case .LowestToHighest:
            self.items.sort(by: <)
        default:
            break
        }
        
    }
    
    func triggerUpdate() {
        // At each update, filter out nulled blocks
        successBlocks = successBlocks.filter({ wrapper in
            wrapper.block != nil
        })
        successBlocks.forEach { wrapper in
            wrapper.block?()
        }
    }
    
    private func loadSuccess(responseData: [String: Any]) {
        let serializedObjects = responseData["list"] as! [[String : Any]]
        let objects: [T] = self.serializer.unserializeList(JSON: serializedObjects) as! [T]
        //items.removeAll(keepingCapacity: true)
        //items.append(objects)
        items = objects
        sort()
        triggerUpdate()
    }
    private func loadObjects(responseData: [String: Any]) {
        let serializedObjects = responseData["data"] as! [[String : Any]]
        let objects: [T] = self.serializer.unserializeList(JSON: serializedObjects) as! [T]
        //items.removeAll(keepingCapacity: true)
        //items.append(objects)
        items = objects
        sort()
//        triggerUpdate()
    }
    
    private func loadSingleSuccess(responseData: [String: Any]) {
        let serializedObjects = responseData["list"] as! [[String : Any]]
        let objects: [T] = self.serializer.unserializeList(JSON: serializedObjects) as! [T]
        //items.removeAll(keepingCapacity: true)
        //items.append(objects)
        items = objects
        sort()
        triggerUpdate()
        successBlocks.forEach { wrapper in
            wrapper.block = nil
        }
    }
    
    private func loadFailure() {
        
    }
}

