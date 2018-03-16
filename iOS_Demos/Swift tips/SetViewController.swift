//
//  SetViewController.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 12/03/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import UIKit


//这样的话查询效率就很低

//    class RatingsManager {
//        private typealias Rating = (score: Int, movieID: UUID)
//
//        private var ratings = [Rating]()
//    }


//extension RatingsManager {
//    func containsRating(for movie: Movie) -> Bool {
//        for rating in ratings {
//            if rating.movieID == movie.id {
//                return true
//            }
//        }
//
//        return false
//    }
//}

struct Movie {
    var id:UUID  = UUID()
}

class RatingsManager {
    typealias Rating = (score: Int, movieID: UUID)
    
    fileprivate var ratings = [Rating]()
    fileprivate var movieIDs = Set<UUID>()
}


extension RatingsManager {
    func insertRating(_ score: Int, for movie: Movie) {
    self.ratings.append((score, movie.id))
    self.movieIDs.insert(movie.id)
    }
}

extension RatingsManager {
    func containsRating(for movie: Movie) -> Bool {
        return self.movieIDs.contains(movie.id)
    }
}


// MARK: 求交集

//extension User {
//    func hasFriendsInCommon(with otherUser: User) -> Bool {
//        return !friendIDs.isDisjoint(with: otherUser.friendIDs)
//    }
//}
//
//extension User {
//    func hasAllFriendsInCommon(with otherUser: User) -> Bool {
//        return friendIDs.isSubset(of: otherUser.friendIDs)
//    }
//}
//
//extension User {
//    func idsOfFriendsInCommon(with otherUser: User) -> Set<UUID> {
//        return friendIDs.intersection(otherUser.friendIDs)
//    }
//}

// MARK: 插入操作，有可能重复
//protocol ContentOperation: AnyObject {
//    /// Prepare/preload the operation. Only executed once.
//    func prepare()
//
//    /// Perform the operation using a content loader.
//    func perform(using loader: ContentLoader,
//                 then handler: @escaping () -> Void)
//}
//
//class ContentManager {
//    func perform(_ operation: ContentOperation,
//                 then handler: @escaping () -> Void) {
//        operation.perform(using: loader, then: handler)
//    }
//}
//
//
//class ContentManager {
//    private var preparedOperationIDs = Set<ObjectIdentifier>()
//
//    func perform(_ operation: ContentOperation,
//                 then handler: @escaping () -> Void) {
//        prepareIfNeeded(operation)
//        operation.perform(using: loader, then: handler)
//    }
//
//    private func prepareIfNeeded(_ operation: ContentOperation) {
//        let id = ObjectIdentifier(operation)
//
//        guard preparedOperationIDs.insert(id).inserted else {
//            return
//        }
//
//        operation.prepare()
//    }
//}

class SetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}

