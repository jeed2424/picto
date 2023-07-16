//
//  PostLocationViewController.swift
//  Warbly
//
//  Created by Knox Dobbins on 3/26/21.
//  Copyright © 2021 Warbly. All rights reserved.
//

import UIKit
import PixelSDK
import MapKit
import CoreLocation

protocol PostLocationDelegate {
    func setLocation(location: String)
}

class PostLocationViewController: UITableViewController {
    
    var delegate: PostLocationDelegate?
    var localSearch: MKLocalSearch?
    let request = MKLocalSearch.Request()
    var placemarks = [CLPlacemark]()
    var locations = [MKMapItem]()
    var results = [String]()
    
    let searchController = UISearchController(searchResultsController: nil)
    let searchBar = UISearchBar()
    static func makeVC(delegate: PostLocationDelegate) -> PostLocationViewController {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "PostLocationViewController") as! PostLocationViewController
        vc.delegate = delegate
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        searchController.searchResultsUpdater = self
//        searchController.searchBar.placeholder = "Search for places..."
//        searchController.searchBar.delegate = self
        searchBar.placeholder = "Search for places..."
        searchBar.delegate = self
//        configureSearchController()
//        self.definesPresentationContext = true
        
        self.setNavBar(title: "")
        self.tableView.reloadData()
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded()
//        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavBar(title: "")
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNavBar(title: "")
        self.tableView.reloadData()
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded()
//        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
    }
    
    // Do all navigation setup here
    func setNavBar(title: String) {
        self.navigationItem.titleView = searchBar
//        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.automaticallyShowsSearchResultsController = false
//        searchController.
//        searchController.showsSearchResultsController = false
//        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.setBackBtn(color: .label, animated: false)
        self.tableView.reloadData()
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsSearchResultsController = false
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.placeholder = "Search for places..."
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
//        searchController.definesPresentationContext = true
        self.definesPresentationContext = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }

}

// MARK: - UISearchResultsUpdating

extension PostLocationViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        print("Searching: ", searchText)
        request.naturalLanguageQuery = searchText
        localSearch = MKLocalSearch(request: request)
        localSearch?.start { (searchResponse, _) in
            guard let items = searchResponse?.mapItems else {
                return
            }
            self.placemarks = [CLPlacemark]()
            self.locations = items.uniqued()
            self.results = self.locations.map({$0.name ?? ""}).uniqued()
            for pm in items {
                self.placemarks.append(pm.placemark)
            }
            self.tableView.fadeReload(duration: 0.15)
        }
    }
}

// MARK: - UISearchBarDelegate

extension PostLocationViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        self.navigationItem.setRightBarButton(nil, animated: false)
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Searching: ", searchText)
        request.naturalLanguageQuery = searchText
        localSearch = MKLocalSearch(request: request)
        localSearch?.start { (searchResponse, _) in
            guard let items = searchResponse?.mapItems else {
                return
            }
            self.placemarks = [CLPlacemark]()
            self.locations = items.uniqued()
            self.results = self.locations.map({$0.name ?? ""}).uniqued()
            for pm in items {
                self.placemarks.append(pm.placemark)
            }
            self.tableView.fadeReload(duration: 0.15)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        self.setRightNavBtn(image: UIImage(named: "cameraadd")!, color: .label, action: #selector(self.openCamera), animated: true)
    }
}

extension PostLocationViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        cell.lbl.text = self.results[indexPath.row]
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let d = self.delegate {
            addHaptic(style: .light)
            d.setLocation(location: self.results[indexPath.row])
            self.popVC()
        }
    }
}


class LocationCell: UITableViewCell {
    
    @IBOutlet weak var lbl: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lbl.text = ""
    }
    
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
}
