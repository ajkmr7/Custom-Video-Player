import SnapKit
import UIKit

class SelectionCellView: UITableViewCell {
    // MARK: - View Components
    
    private let subtitleLanguage = UILabel().configure {
        $0.textColor = VideoPlayerColor(palette: .white).uiColor
        $0.font = FontUtility.helveticaNeueRegular(ofSize: 12)
    }
    
    private let checkMark = UILabel().configure {
        $0.textColor = VideoPlayerColor(palette: .white).uiColor
        $0.text = "\u{2981}"
        $0.font = FontUtility.helveticaNeueRegular(ofSize: 24)
    }
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - View Setup
    
    /// Sets up the appearance and layout of the cell's subviews.
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
    
    // MARK: - Cell Configuration
    
    /// Configures the cell with the provided title and selection status.
    ///
    /// - Parameters:
    ///   - title: The title to be displayed in the cell.
    ///   - isSelected: A Boolean value indicating whether the cell is selected.
    func configureCell(title: String, isSelected: Bool) {
        subtitleLanguage.text = title
        checkMark.isHidden = !isSelected
    }
}