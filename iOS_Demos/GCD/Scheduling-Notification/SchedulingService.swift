//
// Created by 张一鸣 on 2018/5/23.
// Copyright (c) 2018 张一鸣. All rights reserved.
//

import Foundation

public protocol SchedulingServiceDelegate: class {
    func schedulingService(_ service: SchedulingService, didAdd request: SchedulingRequest)
    func schedulingService(_ service: SchedulingService, didComplete request: SchedulingRequest)
    func schedulingService(_ service: SchedulingService, didCancel request: SchedulingRequest)
    func schedulingServiceDidChange(_ service: SchedulingService)
}

public final class SchedulingService {

    deinit {
        cancelAllRequests()
    }

    public weak var delegate: SchedulingServiceDelegate?

    private var _requests: [SchedulingRequest] = [] {
        didSet {
            NotificationCenter.default.post(name: .SchedulingServiceDidChange, object: self)
            delegate?.schedulingServiceDidChange(self)
        }
    }

    private var _scheduledRequests: [SchedulingRequest: Timer] = [:]

    public private(set) var isPaused: Bool = true

    public var scheduledRequests: [SchedulingRequest] {
        return _requests.sorted(by: { $0.date < $1.date })
    }

    @discardableResult
    public func schedule(identifier: String = UUID().uuidString, date: Date, using closure: ((SchedulingRequest) -> Void)? = nil) -> SchedulingRequest {
        var request = SchedulingRequest(identifier: identifier, date: date, notification: .closure)
        request.handler = closure
        schedule(request: request)
        return request
    }

    @discardableResult
    public func schedule(identifier: String = UUID().uuidString, date: Date, notification: Notification.Name) -> SchedulingRequest {
        let request = SchedulingRequest(identifier: identifier, date: date, notification: notification)
        schedule(request: request)
        return request
    }

    private func schedule(request: SchedulingRequest) {
        if _requests.contains(request) {
            // if we have an existing request, invalidate its timer
            _scheduledRequests[request]?.invalidate()
        } else {
            // otherwise append it
            _requests.append(request)
            delegate?.schedulingService(self, didAdd: request)
        }

        guard !isPaused else { return }

        // if we're not paused, start the timer
        enqueueTimer(for: request)
    }

    fileprivate func handleRequest(_ request: SchedulingRequest) {
        removeRequest(request)

        // execute the handler if it was set, and post the notification
        request.handler?(request)

        if request.notification != .closure {
            // if a valid name was specified, post a notification
            NotificationCenter.default.post(name: request.notification, object: request)
        }

        // send a catch-all notification as well for all requests
        NotificationCenter.default.post(name: .SchedulingServiceDidCompleteRequest, object: request)
        delegate?.schedulingService(self, didComplete: request)
    }

    public func cancel(request: SchedulingRequest) {
        removeRequest(request)
        NotificationCenter.default.post(name: .SchedulingServiceDidCancelRequest, object: request)
        delegate?.schedulingService(self, didCancel: request)
    }

    public func cancelAllRequests() {
        for request in scheduledRequests {
            cancel(request: request)
        }
    }

    public func resume() {
        isPaused = false

        _requests.forEach {
            enqueueTimer(for: $0)
        }
    }

    public func pause() {
        isPaused = true

        _scheduledRequests.values.forEach {
            $0.invalidate()
        }
    }

    private func enqueueTimer(for request: SchedulingRequest) {
        guard request.date >= Date() else {
            // if the date is in the past, handle it immediately
            handleRequest(request)
            return
        }

        let timer = Timer(fire: request.date, interval: 0, repeats: false) { [weak self] _ in
            self?.handleRequest(request)
        }

        _scheduledRequests[request] = timer
        RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
    }

    private func removeRequest(_ request: SchedulingRequest) {
        guard let index = _requests.index(of: request) else { return }

        _requests.remove(at: index)
        _scheduledRequests[request]?.invalidate()
        _scheduledRequests[request] = nil
    }

}

extension SchedulingService: CustomStringConvertible {

    public var description: String {
        return "\(type(of: self)) (\(isPaused ? "Paused" : "Running")) | \(scheduledRequests.count) pending request(s)"
    }

}

extension SchedulingService: CustomDebugStringConvertible {

    public var debugDescription: String {
        var string = description

        for request in _requests {
            string.append("\n▹ \(request)")
        }

        return string
    }

}

extension SchedulingService: Codable {

    public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        _requests = try container.decode(Array<SchedulingRequest>.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(_requests)
    }

}

public struct SchedulingRequest: Codable {

    public enum CodingKeys: String, CodingKey {
        case identifier
        case date
        case notification
    }

    public let identifier: String
    public let date: Date
    public let notification: Notification.Name

    fileprivate var handler: ((SchedulingRequest) -> Void)? = nil

    fileprivate init(identifier: String = UUID().uuidString, date: Date, notification: Notification.Name) {
        self.identifier = identifier
        self.date = date
        self.notification = notification
    }

}

extension SchedulingRequest: Hashable {

    public var hashValue: Int {
        return identifier.hashValue
    }

    public static func ==(lhs: SchedulingRequest, rhs: SchedulingRequest) -> Bool {
        return lhs.identifier == rhs.identifier
    }

}

extension SchedulingRequest: CustomStringConvertible {

    public var description: String {
        return "Request (\(identifier)) | \(date)"
    }

}

extension Notification.Name: Codable {
    public static let SchedulingServiceDidCompleteRequest = Notification.Name(rawValue: "SchedulingServiceDidHandleRequest")
    public static let SchedulingServiceDidCancelRequest = Notification.Name(rawValue: "SchedulingServiceDidCancelRequest")
    public static let SchedulingServiceDidChange = Notification.Name(rawValue: "SchedulingServiceDidChange")

    // used to specify an empty notification for closure based requests
    fileprivate static let closure = Notification.Name(rawValue: "")
}