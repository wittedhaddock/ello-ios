////
///  CategoryGenerator.swift
//

public protocol CategoryStreamDestination: StreamDestination {
    func setCategories(categories: [Category])
}

public final class CategoryGenerator: StreamGenerator {

    public var currentUser: User?
    public var streamKind: StreamKind
    weak private var categoryStreamDestination: CategoryStreamDestination?
    weak public var destination: StreamDestination? {
        get { return categoryStreamDestination }
        set {
            if !(newValue is CategoryStreamDestination) { fatalError("CategoryGenerator.destination must conform to CategoryStreamDestination") }
            categoryStreamDestination = newValue as? CategoryStreamDestination
        }
    }

    private var category: Category?
    private var categories: [Category]?
    private var slug: String
    private var pagePromotional: PagePromotional?
    private var posts: [Post]?
    private var hasPosts: Bool?
    private var localToken: String!
    private var loadingToken = LoadingToken()

    private let queue = NSOperationQueue()

    func headerItems() -> [StreamCellItem] {
        var items: [StreamCellItem] = []

        if usesPagePromo() {
            if let pagePromotional = pagePromotional {
                items += [StreamCellItem(jsonable: pagePromotional, type: .PagePromotionalHeader)]
            }
        }
        else if let category = self.category where category.hasPromotionalData {
            items += [StreamCellItem(jsonable: category, type: .CategoryPromotionalHeader)]
        }

        return items
    }

    public init(slug: String,
                currentUser: User?,
                streamKind: StreamKind,
                destination: StreamDestination?
        ) {
        self.slug = slug
        self.currentUser = currentUser
        self.streamKind = streamKind
        self.localToken = loadingToken.resetInitialPageLoadingToken()
        self.destination = destination
    }

    public func reset(streamKind streamKind: StreamKind, category: Category, pagePromotional: PagePromotional?) {
        self.streamKind = streamKind
        self.category = category
        self.slug = category.slug
        self.pagePromotional = nil
    }

    public func load(reload reload: Bool = false) {
        if reload {
            pagePromotional = nil
        }

        let doneOperation = AsyncOperation()
        queue.addOperation(doneOperation)

        localToken = loadingToken.resetInitialPageLoadingToken()
        setPlaceHolders()
        setInitialJSONAble(doneOperation)
        loadCategories()
        loadCategory(doneOperation, reload: reload)
        if usesPagePromo() {
            loadPagePromotional(doneOperation)
        }
        loadCategoryPosts(doneOperation)
    }

    public func toggleGrid() {
        guard let posts = posts else { return }
        destination?.replacePlaceholder(.CategoryPosts, items: parse(posts)) {}
    }

}

private extension CategoryGenerator {

    func setPlaceHolders() {
        destination?.setPlaceholders([
            StreamCellItem(type: .Placeholder, placeholderType: .CategoryHeader),
            StreamCellItem(type: .Placeholder, placeholderType: .CategoryPosts)
        ])
    }

    func setInitialJSONAble(doneOperation: AsyncOperation) {
        guard let category = category else { return }

        let jsonable: JSONAble?
        if usesPagePromo() {
            jsonable = pagePromotional
        }
        else {
            jsonable = category
        }

        if let jsonable = jsonable {
            destination?.setPrimaryJSONAble(jsonable)
            destination?.replacePlaceholder(.CategoryHeader, items: headerItems()) {}
            doneOperation.run()
        }
    }

    func usesPagePromo() -> Bool {
        let discoverType = DiscoverType.fromURL(slug)
        // discover types are featured/trending/recent, they always use a page promo
        guard discoverType == nil else {
            return true
        }

        guard let category = category else {
            return false
        }

        return category.usesPagePromo
    }

    func loadCategory(doneOperation: AsyncOperation, reload: Bool = false) {
        guard !doneOperation.finished || reload else { return }
        guard !usesPagePromo() else { return }

        CategoryService().loadCategory(slug)
            .onSuccess { [weak self] category in
                guard let sself = self else { return }
                guard sself.loadingToken.isValidInitialPageLoadingToken(sself.localToken) else { return }
                sself.category = category
                sself.destination?.setPrimaryJSONAble(category)
                sself.destination?.replacePlaceholder(.CategoryHeader, items: sself.headerItems()) {}
                doneOperation.run()
            }
            .onFail { [weak self] _ in
                guard let sself = self else { return }
                sself.destination?.primaryJSONAbleNotFound()
                sself.queue.cancelAllOperations()
            }
    }

    func loadPagePromotional(doneOperation: AsyncOperation) {
        guard usesPagePromo() else { return }

        PagePromotionalService().loadPagePromotionals()
            .onSuccess { [weak self] promotionals in
                guard let sself = self else { return }
                guard sself.loadingToken.isValidInitialPageLoadingToken(sself.localToken) else { return }

                if let pagePromotional = promotionals?.randomItem() {
                    sself.pagePromotional = pagePromotional
                    sself.destination?.setPrimaryJSONAble(pagePromotional)
                }
                sself.destination?.replacePlaceholder(.CategoryHeader, items: sself.headerItems()) {}
                doneOperation.run()
            }
            .onFail { [weak self] _ in
                guard let sself = self else { return }
                sself.destination?.primaryJSONAbleNotFound()
                sself.queue.cancelAllOperations()
        }
    }

    func loadCategories() {
        CategoryService().loadCategories()
            .onSuccess { [weak self] categories in
                guard let sself = self else { return }
                sself.categories = categories
                sself.categoryStreamDestination?.setCategories(categories)
            }.ignoreFailures()
    }

    func loadCategoryPosts(doneOperation: AsyncOperation) {
        let displayPostsOperation = AsyncOperation()
        displayPostsOperation.addDependency(doneOperation)
        queue.addOperation(displayPostsOperation)

        self.destination?.replacePlaceholder(.CategoryPosts, items: [StreamCellItem(type: .StreamLoading)]) {}

        var apiEndpoint: ElloAPI?
        if usesPagePromo() {
            guard let discoverType = DiscoverType.fromURL(slug) else { return }
            apiEndpoint = .Discover(type: discoverType)
        }
        else {
            apiEndpoint = .CategoryPosts(slug: slug)
        }

        guard let endpoint = apiEndpoint else { return }

        StreamService().loadStream(
            endpoint,
            streamKind: streamKind,
            success: { [weak self] (jsonables, responseConfig) in
                guard let sself = self else { return }
                guard sself.loadingToken.isValidInitialPageLoadingToken(sself.localToken) else { return }

                sself.destination?.setPagingConfig(responseConfig)
                sself.posts = jsonables as? [Post]
                let items = sself.parse(jsonables)
                displayPostsOperation.run {
                    inForeground {
                        if items.count == 0 {
                            sself.hasPosts = false
                            let noItems = [StreamCellItem(type: .NoPosts)]
                            sself.destination?.replacePlaceholder(.CategoryPosts, items: noItems) {
                                sself.destination?.pagingEnabled = false
                            }
                            sself.destination?.replacePlaceholder(.CategoryHeader, items: sself.headerItems()) {}
                        }
                        else {
                            sself.destination?.replacePlaceholder(.CategoryPosts, items: items) {
                                sself.destination?.pagingEnabled = true
                            }
                        }
                    }
                }
            }, failure: { [weak self] _ in
                guard let sself = self else { return }
                sself.destination?.primaryJSONAbleNotFound()
                sself.queue.cancelAllOperations()
            }, noContent: { [weak self] in
                guard let sself = self else { return }
                let noContentItem = StreamCellItem(type: .Text(data: TextRegion(content: "Nothing to see here")))
                sself.destination?.replacePlaceholder(.CategoryPosts, items: [noContentItem]) {}
                sself.destination?.primaryJSONAbleNotFound()
                sself.queue.cancelAllOperations()
        })
    }
}
