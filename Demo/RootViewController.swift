//
//  RootViewController.swift
//  Demo
//
//  Created by Oliver Pearmain on 22/04/2020.
//  Copyright © 2020 Oliver Pearmain. All rights reserved.
//

import UIKit

protocol HasRootViewController {
    var rootViewController: RootViewController { get }
}

class RootViewController: UIViewController {
    
    @IBOutlet private var instanciatedLabel: UILabel!
    @IBOutlet private var nowLabel: UILabel!
    @IBOutlet private var refreshButton: UIButton!
    
    typealias Dependencies = HasRootPresenter
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let rootViewModel = dependencies.rootPresenter.rootViewModel
        loadData(rootViewModel: rootViewModel)
    }
    
    @IBAction private func refreshButtonTapped() {
        dependencies.rootPresenter.refreshButtonTapped()
    }

    private func loadData(rootViewModel: RootViewModel) {
        instanciatedLabel.text = rootViewModel.dateInstanciated
        nowLabel.text = rootViewModel.dateNow
    }
}

extension RootViewController: RootPresenterDelegate {
    
    func rootPresenter(_ rootPresenter: RootPresenter, didUpdateRootViewModel rootViewModel: RootViewModel) {
        loadData(rootViewModel: rootViewModel)
    }
        
}
