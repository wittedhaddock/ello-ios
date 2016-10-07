////
///  ProfileBaseView.swift
//

public class ProfileBaseView: UIView {

    convenience init() {
        self.init(frame: .zero)
        privateInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func privateInit() {
        style()
        bindActions()
        setText()
        arrange()

        // for controllers that use "container" views, they need to be set to the correct dimensions,
        // otherwise there'll be constraint violations.
        layoutIfNeeded()
    }
}

extension ProfileBaseView {

    func style() {}

    func bindActions() {}

    func setText() {}

    func arrange() {}
}
