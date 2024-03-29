//
//  InitialLoadingViewController.swift
//  Market Stream
//
//  Created by Michael Grimmer on 2/4/21.
//

import UIKit

final class InitialLoadingViewController: UIViewController {
    // MARK: - Initialization
    
    init(viewModel: InitialLoadingViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: InitialLoadingViewController.self), bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init(viewModel:), init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    // MARK: - Private
    
    // MARK: Properties
    
    @IBOutlet private weak var screenTitleLabel: UILabel!
    
    private let viewModel: InitialLoadingViewModelType
    
    // MARK: Functions
    
    private func configureView() {
        screenTitleLabel.text = viewModel.screenTitle
    }
}
