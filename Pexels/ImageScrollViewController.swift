//
//  ImageScrollViewController.swift
//  Pexels
//
//  Created by Alibek Allamzharov on 11.09.2023.
//

import UIKit

class ImageScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var avtivityIndicatorView: UIActivityIndicatorView!
    
    
    let imageURL: String
    
    init(imageURL: String) {
        self.imageURL = imageURL
        super.init(nibName: "ImageScrollViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        scrollView.delegate = self
        
        loadImage()
    }
    
    func loadImage() {
        
        guard let url = URL(string: imageURL) else {
            print("Couldn't create URL instance with image url")
            return
        }
        
        self.avtivityIndicatorView.startAnimating()
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: completionHundler(data:urlResponse:error:))
        dataTask.resume()
    }
    
    func completionHundler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        
        DispatchQueue.main.async {
            self.avtivityIndicatorView.stopAnimating()
        }
        
        if let error = error {
            print("Image loading Image: \(error.localizedDescription)")
        }else if let data = data {
            
            DispatchQueue.main.async {
                self .imageView.image = UIImage(data: data)
            }
        }
    }


}

extension ImageScrollViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
