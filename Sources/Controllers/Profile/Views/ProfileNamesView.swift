////
///  ProfileNamesView.swift
//

public class ProfileNamesView: ProfileBaseView {

    let tmpLabel = UITextField()

    public struct Size {
    }
}

extension ProfileNamesView {

    override func style() {
        backgroundColor = .magentaColor()
    }

    override func bindActions() {

    }

    override func setText() {
        tmpLabel.text = "Names View"
        tmpLabel.textAlignment = .Center
    }

    override func arrange() {
        addSubview(tmpLabel)

        tmpLabel.snp_makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
            make.width.equalTo(self)
        }

        layoutIfNeeded()
    }
}

extension ProfileNamesView: ProfileViewProtocol {}
