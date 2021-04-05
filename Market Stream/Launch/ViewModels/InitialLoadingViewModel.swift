//
//  InitialLoadingViewModel.swift
//  Market Stream
//
//  Created by Michael Grimmer on 3/4/21.
//

final class InitialLoadingViewModel: InitialLoadingViewModelType {
    // MARK: - Initialization
    
    init(router: InitialLoadingRouterType) {
        self.router = router
    }
    
    // MARK: - Private
    
    // MARK: Properties
    
    private let router: InitialLoadingRouterType
}
