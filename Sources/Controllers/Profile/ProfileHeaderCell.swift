////
///  ProfileHeaderCell.swift
//

@objc
public protocol EditProfileResponder {
    func onEditProfile()
}

@objc
public protocol PostsTappedResponder {
    func onPostsTapped()
}

@objc
public protocol ProfileHeaderResponder {
    func onCategoryBadgeTapped(cell: UICollectionViewCell)
    func onLovesTapped(cell: UICollectionViewCell)
    func onFollowersTapped(cell: UICollectionViewCell)
    func onFollowingTapped(cell: UICollectionViewCell)
}

public class ProfileHeaderCell: UICollectionViewCell {

    static let reuseIdentifier = "ProfileHeaderCell"

    let headerView = ProfileHeaderCompactView()
    var calculatedCellHeights: CalculatedCellHeights? {
        didSet {
            headerView.calculatedCellHeights = calculatedCellHeights
        }
    }

    var avatarView: ProfileAvatarView { get { return headerView.avatarView } }
    var namesView: ProfileNamesView { get { return headerView.namesView } }
    var totalCountView: ProfileTotalCountView { get { return headerView.totalCountView } }
    var statsView: ProfileStatsView { get { return headerView.statsView } }
    var bioView: ProfileBioView { get { return headerView.bioView } }
    var linksView: ProfileLinksView { get { return headerView.linksView } }

    weak var webLinkDelegate: WebLinkDelegate? {
        set {
            bioView.webLinkDelegate = newValue
            linksView.webLinkDelegate = newValue
        }
        get { return bioView.webLinkDelegate }
    }

    weak var simpleStreamDelegate: SimpleStreamDelegate?
    weak var userDelegate: UserDelegate?

    var user: User?
    var currentUser: User?

    var onHeightMismatch: OnCalculatedCellHeightsMismatch?

    // this little hack prevents constraints from breaking on initial load
    override public var bounds: CGRect {
        didSet {
          contentView.frame = bounds
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        bindActions()
        arrange()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bindActions() {
        avatarView.onHeightMismatch = { avatarHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileAvatar = avatarHeight
            calculatedCellHeights.oneColumn = ProfileHeaderCellSizeCalculator.calculateHeightFromCellHeights(calculatedCellHeights)
            self.calculatedCellHeights = calculatedCellHeights
            self.onHeightMismatch?(calculatedCellHeights)
        }

        bioView.onHeightMismatch = { bioHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileBio = bioHeight
            calculatedCellHeights.oneColumn = ProfileHeaderCellSizeCalculator.calculateHeightFromCellHeights(calculatedCellHeights)
            self.calculatedCellHeights = calculatedCellHeights
            self.onHeightMismatch?(calculatedCellHeights)
        }

        linksView.onHeightMismatch = { linkHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileLinks = linkHeight
            calculatedCellHeights.oneColumn = ProfileHeaderCellSizeCalculator.calculateHeightFromCellHeights(calculatedCellHeights)
            self.calculatedCellHeights = calculatedCellHeights
            self.onHeightMismatch?(calculatedCellHeights)
        }
    }

    private func arrange() {
        backgroundColor = .clearColor()
        contentView.backgroundColor = .clearColor()
        contentView.addSubview(headerView)

        headerView.snp_makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
    }

    public override func prepareForReuse() {
        onHeightMismatch = nil

        avatarView.prepareForReuse()
        statsView.prepareForReuse()
        totalCountView.prepareForReuse()
        namesView.prepareForReuse()
        bioView.prepareForReuse()
        linksView.prepareForReuse()
    }
}
