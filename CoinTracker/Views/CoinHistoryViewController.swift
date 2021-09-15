//
//  CoinHistoryViewController.swift
//  CoinTracker
//
//  Created by Satish Bandaru on 15/09/21.
//

import UIKit

final class CoinHistoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let spinner = UIActivityIndicatorView(style: .gray)
    
    // TODO: - Try injecting via initialiser
    var viewModel: CoinHistoryViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Coin history"
        
        tableView.tableFooterView = UIView()
        tableView.backgroundView = spinner
        spinner.hidesWhenStopped = true
        
        viewModel.getHistoricalData()
    }
}

extension CoinHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cellViewModel = viewModel[indexPath.row] else { return }
        
        // TODO: Navigate to details screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "PriceDetailViewController") as? PriceDetailViewController {
            let viewModel = PriceDetailViewModel(baseEuroPrice: cellViewModel.priceInEuros,
                                                 dateString: cellViewModel.dateString,
                                                 delegate: viewController)
            
            viewController.viewModel = viewModel
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CoinHistoryTableViewCell.self))
                as? CoinHistoryTableViewCell else {
            fatalError("Unable to instantiate cell for coin history")
        }
        
        if let cellViewModel: CoinHistoryCellViewModel = viewModel[indexPath.row] {
            cell.configure(for: cellViewModel)
        }
        
        return cell
    }
}

extension CoinHistoryViewController: CoinHistoryViewModelProtocol {
    func refreshData() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func toggleLoading(_ load: Bool) {
        DispatchQueue.main.async { [weak self] in
            load ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
        }
    }
}

