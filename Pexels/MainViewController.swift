//
//  MainViewController.swift
//  Pexels
//
//  Created by Alibek Allamzharov on 02.09.2023.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchHistooryCollectionView: UICollectionView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Pexels"
        
        searchBar.delegate = self
        
        
    }
    
    func search() {
        
        guard let searchText = searchBar.text else {
            print("Search bar text is nil")
            return
        }
        
        guard !searchText.isEmpty else {
            print("Search bar text is empty")
            return
        }
        
        let endpoint: String = "https://api.pexels.com/v1/search"
        guard var urlComponents = URLComponents(string: endpoint) else {
            print("Couldn't create URLComponents instance from endpoint - \(endpoint)")
            return
        }
        
        let parameters = [
            URLQueryItem(name: "query", value: searchText),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        urlComponents.queryItems = parameters
        
        guard let url: URL = urlComponents.url else {
            print("URL is nil")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let APIKey: String = "1VICU1HooGGM3ZZKEryGCHhpmNN53yeqilpoexinoq54h1oK2qiLcndb"
        urlRequest.addValue(APIKey, forHTTPHeaderField: "Authorization")
        
        let urlSession: URLSession = URLSession(configuration: .default)
        let dataTask: URLSessionDataTask = urlSession.dataTask(with: urlRequest, completionHandler: searchPhotosHandler(data:urlResponse:error:))
        
        dataTask.resume()
        
    }
    
    func searchPhotosHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        
        print("Method searchPhotosHandler was called")
    }

}

extension MainViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        search()
    }
    
}
