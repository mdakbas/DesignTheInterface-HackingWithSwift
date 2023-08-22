//
//  HomeViewModel.swift
//  DesigningTheInterface-HackingWithSwift
//
//  Created by Mert Deniz Akbaş on 22.08.2023.
//

import Foundation

protocol HomeViewModelProtocol {
     var view: HomeVCProtocol? { get set }
    
    func viewDidLoad()
}

final class HomeViewModel {
    weak var view: HomeVCProtocol? 
}

extension HomeViewModel: HomeViewModelProtocol {
    func viewDidLoad() {
        view?.setCoreImage()
    }
}
