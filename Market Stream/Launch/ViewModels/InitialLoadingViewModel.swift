//
//  InitialLoadingViewModel.swift
//  Market Stream
//
//  Created by Michael Grimmer on 3/4/21.
//

import Foundation

final class InitialLoadingViewModel: InitialLoadingViewModelType {
    // MARK: - Initialization
    
    init(router: InitialLoadingRouterType) {
        self.router = router
    }
    
    // MARK: - InitialLoadingViewModelType Conformance
    
    lazy var screenTitle: String =  {
        Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? Constants.defaultScreenTitle
    }()
    
    // MARK: - Private
    
    // MARK: Properties
    
    private let router: InitialLoadingRouterType
}

private enum Constants {
    static let defaultScreenTitle = "Market Stream"
}
