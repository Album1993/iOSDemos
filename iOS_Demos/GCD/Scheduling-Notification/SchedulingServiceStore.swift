//
// Created by 张一鸣 on 2018/5/23.
// Copyright (c) 2018 张一鸣. All rights reserved.
//

import Foundation


public final class SchedulingServiceStore {

    public let service: SchedulingService

    public init(service: SchedulingService? = nil) {
        if let service = service {
            self.service = service
        } else {
            if let data = try? Data(contentsOf: SchedulingServiceStore.storeUrl),
               let service = try? JSONDecoder().decode(SchedulingService.self, from: data) {
                self.service = service
            } else {
                self.service = SchedulingService()
            }
        }

        NotificationCenter.default.addObserver(forName: .SchedulingServiceDidChange, object: nil, queue: .main) {
            [weak self] note in
            self?.save()
        }
    }

    public func save() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(service)
            try data.write(to: SchedulingServiceStore.storeUrl)
        } catch {
            print(error)
        }
    }

    private static var storeUrl: URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return URL(fileURLWithPath: path).appendingPathComponent("SchedulingService.json")
    }

}