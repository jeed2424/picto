//
//  DiscoverViewController.swift
//  Warbly
//
//  Created by Knox Dobbins on 3/23/21.
//  Copyright © 2021 Warbly. All rights reserved.
//

import UIKit
import PixelSDK

class DiscoverViewController: UIViewController, UITableViewDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    

    enum Sections: CaseIterable {
        case top
        case categories
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
        }
    }

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 290, height: 190)
            layout.minimumInteritemSpacing = 15
            layout.minimumLineSpacing = 15
            layout.scrollDirection = .horizontal
            layout.sectionInset.left = 20
            layout.sectionInset.right = 20
            collectionView.collectionViewLayout = layout
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var collectionView1: UICollectionView! {
        didSet {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: (screenWidth/2 - 25), height: (screenWidth/2 - 20)/1.4)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 20
            layout.scrollDirection = .vertical
            layout.sectionInset.left = 20
            layout.sectionInset.right = 20
            layout.sectionInset.top = 25
            layout.sectionInset.bottom = 100
            collectionView1.collectionViewLayout = layout
            collectionView1.showsHorizontalScrollIndicator = false
            collectionView1.showsVerticalScrollIndicator = false
            collectionView1.delegate = self
            collectionView1.dataSource = self
        }
    }
    @IBOutlet weak var collectionView1Height: NSLayoutConstraint!
    
//    var categories = ["Art", "]

//    private let searchController = UISearchController(searchResultsController: nil)
    
    var users = [BMUser]()
    
    static func makeVC() -> DiscoverViewController {
        let vc = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "DiscoverViewController") as! DiscoverViewController
        return vc
    }
    
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let vc = UserFollowersViewController.makeVC(user: me, following: false, forSearch: true, del: self)
//        searchController = UISearchController(searchResultsController: vc)
//        searchController.searchResultsUpdater = self
////        searchController.searchResultsController = UserFollowersViewController.makeVC(user: me, following: false, forSearch: true)
//        searchController.searchBar.placeholder = "Search"
//        searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        
        self.setNavBar(title: "")
        self.collectionView1.reloadData()
//        self.collectionView1Height.constant = CGFloat(ProfileService.make().categories.chunked(into: 2).count * 150) + 65
        let h = (screenWidth/2 - 20)/1.4
        self.collectionView1Height.constant = CGFloat(CGFloat(ProfileService.make().categories.chunked(into: 2).count) * h) + 330
        self.tableView.reloadData()
        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
//        ProfileService.make().getFollowing(user: me, discover: true) { (res, usrs) in
//            self.users = usrs
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavBar(title: "")
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded()
//        if self.searchController.isActive {
//            self.navigationItem.setRightBarButton(nil, animated: false)
//            self.searchController.searchBar.showsCancelButton = true
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNavBar(title: "")
        self.collectionView.reloadData()
        self.collectionView1.reloadData()
//        self.collectionView1Height.constant = CGFloat(ProfileService.make().categories.chunked(into: 2).count * 150) + 65
        let h = (screenWidth/2 - 20)/1.4
        self.collectionView1Height.constant = CGFloat(CGFloat(ProfileService.make().categories.chunked(into: 2).count) * h) + 330
        self.tableView.reloadData()
        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
        BMPostService.make().selectedCat = nil
        if self.searchController.isActive {
            self.navigationItem.setRightBarButton(nil, animated: true)
//            self.searchController.searchBar.showsCancelButton = true
        }
    }
    
    // Do all navigation setup here
    func setNavBar(title: String) {
        self.navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.showsSearchResultsController = true
        self.view.backgroundColor = .systemBackground
        extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.navigationBar.backgroundColor = .white
//        self.navigationController?.navigationBar.barTintColor = .white
//        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = false
//        self.navigationItem.searchController?.searchBar.tintColor = .black
        self.setRightNavBtn(image: UIImage(named: "cameraadd")!, color: .label, action: #selector(self.openCamera), animated: false)
//        self.collectionView1.contentInset.bottom = 50
        self.collectionView1.reloadData()
        let h = (screenWidth/2 - 20)/1.4
        self.collectionView1Height.constant = CGFloat(CGFloat(ProfileService.make().categories.chunked(into: 2).count) * h) + 330
        
        self.tableView.reloadData()
        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
        self.setRightNavBtn(image: UIImage(named: "cameraadd")!, color: .label, action: #selector(self.openCamera), animated: false)
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        searchController.definesPresentationContext = true
    }
    
    var shouldLayout = true
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }

}

// MARK: - UISearchResultsUpdating

//extension DiscoverViewController: UserSearchDelegate {
//    
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
//        print("Searching: ", searchText)
//        if searchText != "" {
//            ProfileService.make().searchUsers(search: searchText) { (res, usrs) in
//                if let resultsController = searchController.searchResultsController as? UserFollowersViewController {
//                    resultsController.search(text: searchText, users: usrs)
//                }
//            }
//        } else {
//            if let resultsController = searchController.searchResultsController as? UserFollowersViewController {
//                if !resultsController.origUsers.isEmpty {
//                    resultsController.search(text: searchText, users: [BMUser]())
//                }
//            }
//        }
//    }
//    
//    func goToProfile(user: BMUser) {
//        let vc = UserProfileViewController.makeVC(user: user)
//        vc.hidesBottomBarWhenPushed = true
//        vc.view.superview?.layoutIfNeeded()
//        vc.view.layoutIfNeeded()
//        vc.fromSearch = true
//        self.push(vc: vc)
//    }
//}

// MARK: - UISearchBarDelegate

extension DiscoverViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.setRightBarButton(nil, animated: false)
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.setRightNavBtn(image: UIImage(named: "cameraadd")!, color: .label, action: #selector(self.openCamera), animated: true)
    }
}

extension DiscoverViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionView1 {
            print("\(ProfileService.make().categories.count)")
            return ProfileService.make().categories.count
        } else {
            return 2
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionView1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.setCategory(cat: ProfileService.make().categories[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.setTop(index: indexPath.item)
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView == collectionView1 {
            let vc = CategoryViewController.makeVC(cat: ProfileService.make().categories[indexPath.item])

            self.push(vc: vc)
        } else {
            showAlertPopup(title: "Coming Soon", message: "We'll be adding more categories to highlight new and exciting content happening on Gala soon.", image: .get(name: "homeicon1-selected", tint: .systemBackground))
        }
    }
    
}

class CategoryViewController: UICollectionViewController {

    var category: BMCategory?
    var posts = [BMPost]()
    
    static func makeVC(cat: BMCategory) -> CategoryViewController {
        let vc = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
        vc.category = cat
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBar(title: self.category!.title!)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (screenWidth/2 - 30), height: 215)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .vertical
        layout.sectionInset.left = 20
        layout.sectionInset.right = 20
        layout.sectionInset.top = 30
        layout.sectionInset.bottom = 100
        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        BMPostService.make().selectedCat = self.category
        self.presentLoadingAlertModal(animated: false, completion: nil)
        if self.category!.title! == "Liked Posts" {
            BMPostService.make().selectedCat = nil

            if let user = BMUser.me() {
                BMPostService.make().getLikedPosts(user: user) { (response, p) in
                    self.posts = p
                    self.collectionView.fadeReload()
                    self.dismissLoadingAlertModal(animated: true, completion: {
                        self.collectionView.fadeReload()
                    })
                }
            }

        } else {
            BMPostService.make().getRelated(search: self.category!.title!, count: 10) { (response, p) in
                self.posts = p
                self.collectionView.fadeReload()
                self.dismissLoadingAlertModal(animated: true, completion: {
                    self.collectionView.fadeReload()
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.setNavBar(title: self.category!.title!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNavBar(title: self.category!.title!)
        self.collectionView.reloadData()
//        self.collectionView.reloadData()
    }
    
    // Do all navigation setup here
    func setNavBar(title: String) {
//        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.navigationBar.backgroundColor = .clear
//        self.navigationController?.navigationBar.barTintColor = .clear
//        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
//        self.navigationController!.navigationBar.sizeToFit()
        self.setNavTitle(text: title, font: BaseFont.get(.bold, 17), letterSpacing: 0.1, color: .label)
        self.setRightNavBtn(image: UIImage(named: "cameraadd")!, color: .label, action: #selector(self.openCamera), animated: false)
        self.setBackBtn(color: .label, animated: false)
    }

}

extension CategoryViewController: FeedCardDelegate, UICollectionViewDelegateFlowLayout {
    
    // tapped avatar on card cell (would do whatever action here)
    func tappedUser(post: BMPost) {
        print("tapped user avatar on card!")
        if let profile = UserProfileViewController.makeVC(user: post.user!) {
            self.push(vc: profile)
        }
    }
    
    func showMenu(post: BMPost) {
        let actionSheet = ATActionSheet()
        let collection = ATAction(title: "Add to Collection", image: nil) {
            print("Collections")
            actionSheet.dismissAlert()
        }
        let share = ATAction(title: "Share Post", image: nil) {
            print("Share")
            actionSheet.dismissAlert()
        }
        let report = ATAction(title: "Report", image: nil, style: .destructive, completion: {
            print("Report")
            actionSheet.dismissAlert()
        })
        actionSheet.addActions([collection, share, report])
        present(actionSheet, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let heightRatio = CGFloat(1.333)
        return CGSize(width: (screenWidth/2 - 30), height: 215)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RelatedPostCell", for: indexPath) as! RelatedPostCell
        cell.setPost(post: self.posts[indexPath.item])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let posts = self.posts
        let vc = PostPageViewController.makeVC(post: self.posts[indexPath.item], otherPosts: self.posts)
        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.navigationBar.backgroundColor = .clear
//        self.navigationController?.navigationBar.barTintColor = .clear
        self.push(vc: vc)
    }
    
}

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var category: BMCategory!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
    }
    
    func setTop(index: Int) {
        self.icon?.addShadow()
        if index == 0 {
            
            self.imgView.setImage(string: "https://firebasestorage.googleapis.com/v0/b/warbly-265ed.appspot.com/o/images%2Fpopular.png?alt=media")
            self.titleLbl.text = "Popular Now"
            self.icon?.image = .get(name: "fire", tint: .white)
        }  else {
            self.imgView.setImage(string: "https://firebasestorage.googleapis.com/v0/b/warbly-265ed.appspot.com/o/images%2Fnaturepic.png?alt=media")
            self.titleLbl.text = "On The Rise"
            self.icon?.image = .get(name: "risearrow", tint: .white)
        }
        self.titleLbl.textDropShadow()
        self.imgView.layer.cornerCurve = .continuous
    }
    
    func setCategory(cat: BMCategory) {
        self.titleLbl.text = cat.title!
        self.titleLbl.textDropShadow()
        self.imgView.contentMode = .scaleAspectFill
        self.imgView.setImage(string: cat.imageUrl!)
        self.imgView.layer.cornerCurve = .continuous
    }
    
}
