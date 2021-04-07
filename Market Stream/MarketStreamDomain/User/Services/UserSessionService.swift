//
//  UserSessionService.swift
//  Market Stream
//
//  Created by Michael Grimmer on 5/4/21.
//

final class UserSessionService: UserSessionServiceType {
    
    private(set) static var session: UserSessionServiceType?
    
    // MARK: - UserSessionServiceType Conformance
    
    static func createSessionIfNeeded() {
        if UserSessionService.session == nil {
            session = UserSessionService()
        }
    }
}
