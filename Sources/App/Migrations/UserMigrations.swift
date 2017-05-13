//
// Created by Erik Little on 5/12/17.
//

import Foundation
import Fluent
import Vapor

struct AddPasswordFieldToUser : Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify("users") {user in
            user.string("pw", length: 512, optional: true, default: nil)
        }
    }

    static func revert(_ database: Database) throws { }
}
