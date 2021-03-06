////
///  TwoLineButton.swift
//

public class TwoLineButton: UIButton {

    public var title: String = "" {
        didSet { updateText() }
    }

    public var count: String = "" {
        didSet { updateText() }
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    func sharedSetup() {
        titleLabel?.numberOfLines = 0
        backgroundColor = .clearColor()
        contentHorizontalAlignment = .Left
    }

    // MARK: Private

    private func attributes(color: UIColor, font: UIFont, underline: Bool = false) -> [String : AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .Left

        return [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName : paragraphStyle,
            NSUnderlineStyleAttributeName : (underline ? NSUnderlineStyle.StyleSingle.rawValue : NSUnderlineStyle.StyleNone.rawValue)
        ]
    }

    private func updateText() {
        let countNormalAttributes = attributes(UIColor.blackColor(), font: UIFont.defaultBoldFont())
        let countSelectedAttributes = attributes(UIColor.greyA(), font: UIFont.defaultBoldFont())

        let titleNormalAttributes = attributes(UIColor.greyA(), font: UIFont.defaultFont(), underline: true)
        let titleSelectedAttributes = attributes(UIColor.greyE5(), font: UIFont.defaultFont(), underline: true)

        let attributedNormalCount = NSAttributedString(string: count + "\n", attributes: countNormalAttributes)
        let attributedSelectedCount = NSAttributedString(string: count + "\n", attributes: countSelectedAttributes)

        let attributedNormalTitle = NSAttributedString(string: title, attributes: titleNormalAttributes)
        let attributedSelectedTitle = NSAttributedString(string: title, attributes: titleSelectedAttributes)

        setAttributedTitle(attributedNormalCount + attributedNormalTitle, forState: .Normal)
        setAttributedTitle(attributedSelectedCount + attributedSelectedTitle, forState: .Highlighted)
        sizeToFit()
    }

}
