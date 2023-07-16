import UIKit

protocol PostCategoryDelegate {
    func setCategory(cat: BMCategory)
}

class PostCategoryViewController: UICollectionViewController {

    var delegate: PostCategoryDelegate?
    
    static func makeVC(delegate: PostCategoryDelegate) -> PostCategoryViewController {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "PostCategoryViewController") as! PostCategoryViewController
        vc.delegate = delegate
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBar(title: "Choose Category")
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (screenWidth/2 - 25), height: (screenWidth/2 - 20)/1.4)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .vertical
        layout.sectionInset.left = 20
        layout.sectionInset.right = 20
        layout.sectionInset.top = 25
        layout.sectionInset.bottom = 100
        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.delegate = self
        collectionView.dataSource = self
        self.setBackBtn(color: .label, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setBackBtn(color: .label, animated: false)
//        self.setNavBar(title: self.category!.title!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNavBar(title: "Choose Category")
        self.setBackBtn(color: .label, animated: false)
        self.collectionView.reloadData()
//        self.collectionView.reloadData()
    }
    
    // Do all navigation setup here
    func setNavBar(title: String) {
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.barTintColor = .systemBackground
//        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
//        self.navigationController!.navigationBar.sizeToFit()
        self.setNavTitle(text: title, font: BaseFont.get(.bold, 18), letterSpacing: 0.1, color: .label)
        self.setRightNavBtn(image: UIImage(named: "cameraadd")!, color: .label, action: #selector(self.openCamera), animated: false)
        self.setBackBtn(color: .label, animated: false)
    }

}

extension PostCategoryViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProfileService.make().categories.count
        print("cool my life: \(ProfileService.make().categories.count)")
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.setCategory(cat: ProfileService.make().categories[indexPath.item])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let d = self.delegate {
            addHaptic(style: .light)
            d.setCategory(cat: ProfileService.make().categories[indexPath.item])
            self.popVC()
        }
    }
    
}
