
import UIKit

class AllRecipesViewController: UIViewController, RecipeManagerDelegate, iCarouselDataSource, iCarouselDelegate {
    
    
    var loadingIndicator = UIActivityIndicatorView(style: .large)
    
    var k = K()
    var recipeManager = RecipeManager()
    var user = UserData()
    var recipes: [RecipeModel] = []
    
    var isLoaded:Bool = false
    var isShowingTable = true
    var recipesTableVC = RecipesTableViewController()
    
    var scrollView = UIScrollView()
    var mainStackView = UIStackView()
    var verticalStackView = UIStackView()
    var labelsScrollView = UIScrollView()
    var labelsStackView = UIStackView()
    var carousel: iCarousel!
    var nameLabel = UILabel()
    var ingredientsLabel = UILabel()
    var instructionsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        recipeManager.delegate = self
        setupLoadingIndicator()
        
        if let savedRecipes = user.loadRecipesFromUserDefaults() {
            recipes = savedRecipes
            isLoaded = true
            loadingIndicator.stopAnimating()
            setUpUI()
        } else {
            loadRandomRecipes()
        }
        recipesTableVC.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        
    }

    @objc func toggleView() {
        isShowingTable.toggle()
        let newOffset = isShowingTable ? CGPoint(x: 0, y: 0) : CGPoint(x: scrollView.frame.width, y: 0)
        UIView.animate(withDuration: 0.3) {
            self.scrollView.setContentOffset(newOffset, animated: false)
        }
        UIView.animate(withDuration: 0.3) {
            self.carousel.alpha = self.isShowingTable ? 0 : 1
        }
        
        navigationItem.rightBarButtonItem?.title = isShowingTable ? "Show Carousel" : "Show Table"
    }
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 12
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIView
        let itemWidth = view?.frame.width ?? self.view.frame.width * 0.8
        let itemHeight = itemWidth
        
        if let view = view {
            itemView = view
        } else {
            itemView = UIView(frame: CGRect(x: 0, y: 0, width: itemWidth, height: itemHeight))
            itemView.backgroundColor = .clear
            let imageContainer = UIView(frame: itemView.bounds)
            imageContainer.contentMode = .scaleAspectFill
            imageContainer.clipsToBounds = true
            imageContainer.layer.cornerRadius = 20
            let imageView = UIImageView(frame: imageContainer.bounds)
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.center = imageView.center
            imageView.addSubview(activityIndicator)
            
            let recipeImageSrc = recipes[index].imageSrc
            ImageLoader.shared.loadImage(from: recipeImageSrc, into: imageView, with: activityIndicator)
            imageContainer.addSubview(imageView)
            itemView.addSubview(imageContainer)
            let label = UILabel(frame: CGRect(x: 0, y: imageContainer.frame.maxY - 50, width: imageContainer.frame.width, height: 50))
            label.text = recipes[index].mealName
            label.textAlignment = .center
            label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            label.textColor = .white
            imageContainer.addSubview(label)
        }
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        nameLabel.text = recipes[index].mealName
        ingredientsLabel.text = recipes[index].measuredIngredients
        instructionsLabel.text = recipes[index].instructions
        
        updateLabes()
    }
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
//        nameLabel.text = recipes[carousel.currentItemIndex].mealName
//        ingredientsLabel.text = recipes[carousel.currentItemIndex].measuredIngredients
//        instructionsLabel.text = recipes[carousel.currentItemIndex].instructions
//        
//        updateLabes()
    }
    
    func setupLoadingIndicator() {
        loadingIndicator.center = view.center
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    func loadRandomRecipes() {
        CoreDataManager.shared.deleteAllRecipesFromCoreData()
        CoreDataManager.shared.printAllRecipesFromCoreData()
        for _ in 1...k.recipesCount {
            recipeManager.getRecipes()
        }
    }
    func didUpdateRecipe(newRecipe: RecipeModel) {
        DispatchQueue.main.async {
            var isNew = true
            for i in 0..<self.recipes.count{
                if newRecipe.id == self.recipes[i].id{
                    isNew = false
                }
            }
            if isNew{
                self.recipes.append(newRecipe)
            }else{
                self.recipeManager.getRecipes()
            }
            
            if self.recipes.count == self.k.recipesCount {
                self.isLoaded = true
                self.loadingIndicator.stopAnimating()
                self.recipesTableVC.dataSource = self.recipes
                self.user.saveRecipesToUserDefaults(self.recipes)
                self.setUpUI()
                self.carousel.reloadData()
            }
        }
    }
    
    func didFailWithError(error: any Error) {
        print(error)
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
        }
    }
}

//MARK: - UIExtension

extension AllRecipesViewController {
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.title = "Recipes"
        let switchButton = UIBarButtonItem(title: "Show Carousel", style: .plain, target: self, action: #selector(toggleView))
        navigationItem.rightBarButtonItem = switchButton
    }
    
    func setUpUI() {
        setupScrollView()
        setupMainStackView()
        
        recipesTableVC.dataSource = recipes
        addChild(recipesTableVC)
        mainStackView.addArrangedSubview(recipesTableVC.view)
        recipesTableVC.didMove(toParent: self)
        
        setupVerticalStackView()
        
        carousel = setupCarousel()
        verticalStackView.addArrangedSubview(carousel)
        
        setupLabelsScrollView()
        updateLabes()
        verticalStackView.addArrangedSubview(labelsScrollView)
        
        mainStackView.addArrangedSubview(verticalStackView)
        
        scrollView.isScrollEnabled = false
        recipesTableVC.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        carousel.alpha = 0
    }
    
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupMainStackView() {
        mainStackView.axis = .horizontal
        mainStackView.distribution = .fillEqually
        mainStackView.alignment = .fill
        mainStackView.spacing = 10
        scrollView.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            mainStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 2)
        ])
    }
    
    func setupVerticalStackView() {
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillEqually
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 0
        mainStackView.addArrangedSubview(verticalStackView)
        
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: mainStackView.topAnchor, constant: 70),
            verticalStackView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: mainStackView.bottomAnchor)
        ])
    }
    
    func setupLabelsScrollView() {
        labelsScrollView.translatesAutoresizingMaskIntoConstraints = false
        labelsScrollView.isScrollEnabled = true
        labelsScrollView.showsVerticalScrollIndicator = true
        
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 10
        labelsStackView.alignment = .fill
        labelsStackView.distribution = .fill
        
        labelsScrollView.addSubview(labelsStackView)
        
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: labelsScrollView.topAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: labelsScrollView.leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: labelsScrollView.trailingAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: labelsScrollView.bottomAnchor),
            labelsStackView.widthAnchor.constraint(equalTo: labelsScrollView.widthAnchor)
        ])
    }
    
    func updateLabes() {
        labelsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        
        ingredientsLabel.font = UIFont.systemFont(ofSize: 16)
        ingredientsLabel.textColor = .white
        ingredientsLabel.numberOfLines = 0
        ingredientsLabel.textAlignment = .left
        
        instructionsLabel.font = UIFont.systemFont(ofSize: 16)
        instructionsLabel.textColor = .white
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textAlignment = .left
        
        labelsStackView.addArrangedSubview(nameLabel)
        labelsStackView.addArrangedSubview(ingredientsLabel)
        labelsStackView.addArrangedSubview(instructionsLabel)
        
        setupLabelMargins(for: nameLabel)
        setupLabelMargins(for: ingredientsLabel)
        setupLabelMargins(for: instructionsLabel)
        
        updateScrollViewContentSize()
    }
    
    private func setupLabelMargins(for label: UILabel) {
        label.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        label.preservesSuperviewLayoutMargins = true
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: labelsStackView.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: labelsStackView.trailingAnchor, constant: -15)
        ])
    }
    
    func updateScrollViewContentSize() {
        labelsScrollView.contentSize = labelsStackView.frame.size
    }
    
    func setupCarousel() -> iCarousel {
        let carousel = iCarousel()
        carousel.dataSource = self
        carousel.delegate = self
        carousel.type = .rotary
        return carousel
    }
}
