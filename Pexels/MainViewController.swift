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
    
    var searchPhotosResponse: SearchPhotosResponse? {
        didSet {
            DispatchQueue.main.async {
                self.imageCollectionView.reloadData()
            }
        }
    }
    
    var photos: [Photo] {
        return searchPhotosResponse?.photos ?? []
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Pexels"
        
        searchBar.delegate = self
        
        // Image CollectionView Setup
        imageCollectionView.layer.cornerRadius = 10
        
        imageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        imageCollectionView.register(UINib(nibName: PhootoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhootoCollectionViewCell.identifier)
        imageCollectionView.dataSource = self
        
        imageCollectionView.delegate = self
        imageCollectionView.refreshControl = UIRefreshControl()
        imageCollectionView.refreshControl!.addTarget(self, action: #selector(search), for: .valueChanged)
        
        
    }
    @objc
    func search() {
        self.searchPhotosResponse = nil
        
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
            URLQueryItem(name: "per_page", value: "20")
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
        
        if imageCollectionView.refreshControl?.isRefreshing == false {
            imageCollectionView.refreshControl?.beginRefreshing()
        }
        
        let urlSession: URLSession = URLSession(configuration: .default)
        let dataTask: URLSessionDataTask = urlSession.dataTask(with: urlRequest, completionHandler: searchPhotosHandler(data:urlResponse:error:))
        
        dataTask.resume()
        
    }
    
    func searchPhotosHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        
        print("Method searchPhotosHandler was called")
        
        DispatchQueue.main.async {
            if self.imageCollectionView.refreshControl?.isRefreshing == true {
                self.imageCollectionView.refreshControl?.endRefreshing()
            }
        }
        
        if let error = error {
            print("Search Photos endpoint error - \(error.localizedDescription)")
        }else if let data = data {
            
            do {
                
//                let jsonObject = try JSONSerialization.jsonObject(with: data)
//                print("Search Photos endpoint jsonObject - \(jsonObject)")
                
                let searchPhotosResponse = try JSONDecoder().decode(SearchPhotosResponse.self, from: data)
                print("Search Photos endpoint searchPhotosResponse - \(searchPhotosResponse)")
                
                
                self.searchPhotosResponse = searchPhotosResponse
                
            }catch let error {
                print("Search Photos endpoint serialization error - \(error.localizedDescription)")
            }
        }
        
        if let urlResponse = urlResponse, let httpResponse = urlResponse as? HTTPURLResponse {
            print("Search Photos enpoint http response url status - \(httpResponse.statusCode)")
        }
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


extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhootoCollectionViewCell.identifier, for: indexPath) as! PhootoCollectionViewCell
        cell.setup(photo: self.photos[indexPath.item])
        return cell
    }
}


extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout: UICollectionViewFlowLayout? = collectionViewLayout as? UICollectionViewFlowLayout
        let horizontalSpacing: CGFloat = ( flowLayout?.minimumInteritemSpacing ?? 0 ) + collectionView.contentInset.left + collectionView.contentInset.right
        let width: CGFloat = ( collectionView.frame.width - horizontalSpacing ) / 2
        let height: CGFloat = width + (width / 2)
        
        return CGSize(width: width, height: height)
    }
}
