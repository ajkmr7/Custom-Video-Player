import SnapKit
import UIKit

class SubtitleCellView: UITableViewCell {
    private let subtitleLanguage = UILabel().configure {
        $0.textColor = VideoPlayerColor(palette: .white).uiColor
        $0.font = FontUtility.helveticaNeueRegular(ofSize: 12)
    }
    
    private let checkMark = UILabel().configure {
        $0.textColor = VideoPlayerColor(palette: .white).uiColor
        $0.text = "\u{2981}"
        $0.font = FontUtility.helveticaNeueRegular(ofSize: 24)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = VideoPlayerColor(palette: .black).uiColor
        contentView.addSubview(subtitleLanguage)
        contentView.addSubview(checkMark)
        
        subtitleLanguage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        checkMark.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func configureCell(title: String, isSelected: Bool) {
        subtitleLanguage.text = title
        checkMark.isHidden = !isSelected
    }
}
