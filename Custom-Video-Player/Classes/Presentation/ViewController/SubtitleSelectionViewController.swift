import AVFoundation
import SnapKit
import UIKit

/// Protocol for handling subtitle selection events.
protocol SubtitleSelectionDelegate: AnyObject {
    /// Called when a subtitle track is selected.
    func onSubtitleTrackSelected(subtitleTrack: AVMediaSelectionOption?)
    /// Called when the subtitle selection view is dismissed.
    func onDismissed()
}

/// View controller for selecting subtitles.
class SubtitleSelectionViewController: UIViewController {
    private static let cellIdentifier = "SubtitleCell"
    
    // MARK: - UI Components
    
    /// The main container view for the subtitle selection.
    private let popOverView = UIView().configure {
        $0.backgroundColor = VideoPlayerColor(palette: .black).uiColor
        $0.roundCorners(cornerRadius: CGFloat.space40 / 2)
    }
    
    /// Table view for displaying available subtitle options.
    private let tableView = UITableView().configure { tableView in
        tableView.register(SelectionCellView.self, forCellReuseIdentifier: cellIdentifier)
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
    }
    
    /// The grabber view for indicating draggable area.
    private let grabberView = UIView().configure {
        $0.backgroundColor = VideoPlayerColor(palette: .white).uiColor.withAlphaComponent(0.5)
        $0.layer.cornerRadius = CGFloat.space6 / 2
    }
    
    /// Header label for the subtitle selection view.
    private let header = UILabel().configure {
        $0.textColor = VideoPlayerColor(palette: .pearlWhite).uiColor
        $0.text = "Subtitle"
        $0.font = FontUtility.helveticaNeueMedium(ofSize: 16)
    }
    
    // MARK: - Properties
    
    /// Delegate for handling subtitle selection events.
    weak var delegate: SubtitleSelectionDelegate?
    /// View model for managing subtitle selection logic.
    private let viewModel: SubtitleSelectionViewModel
    
    // MARK: - Initialization
    
    /// Initializes the subtitle selection view controller with a view model.
    init(viewModel: SubtitleSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Required initializer. Returns nil to force initialization with the designated initializer.
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        modalPresentationStyle = .popover
    }
    
    // MARK: - View Setup
    
    /// Sets up the main view and its subviews.
    private func setupView() {
        view.addSubview(popOverView)
        popOverView.snp.makeConstraints { make in
            make.width.equalTo(375)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-CGFloat.space40)
            make.top.greaterThanOrEqualToSuperview().offset(CGFloat.space40)
        }
        
        setupPopOverView()
        setupGestureRecognizers()
    }
    
    /// Sets up gesture recognizers for dismissing the view.
    private func setupGestureRecognizers() {
        let overlayTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        overlayTapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(overlayTapGesture)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissView))
        swipeDown.direction = .down
        popOverView.addGestureRecognizer(swipeDown)
    }
    
    /// Sets up the subviews within the popover view.
    private func setupPopOverView() {
        popOverView.addSubview(grabberView)
        popOverView.addSubview(header)
        popOverView.addSubview(tableView)
        
        grabberView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(CGFloat.space8)
            make.width.equalTo(44)
            make.height.equalTo(CGFloat.space6)
        }
        
        header.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(grabberView.snp.bottom).offset(CGFloat.space40 / 2)
        }
        setupTableView()
    }
    
    /// Sets up the table view for displaying subtitle options.
    private func setupTableView() {
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(CGFloat.space16)
            make.leading.equalToSuperview().offset(CGFloat.space24)
            make.trailing.equalToSuperview().offset(-CGFloat.space24)
            make.bottom.equalToSuperview().offset(-CGFloat.space8)
            make.height.equalTo(CGFloat.space128)
        }
    }
    
    // MARK: - Actions
    
    /// Dismisses the subtitle selection view.
    @objc private func dismissView() {
        dismiss(animated: true)
        delegate?.onDismissed()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SubtitleSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.subtitleOptionsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleSelectionViewController.cellIdentifier, for: indexPath) as! SelectionCellView
        let subtitleLanguage = viewModel.subtitleOption(indexPath.row)
        let isSelected = indexPath.row == viewModel.selectedItemIndex
        cell.configureCell(title: subtitleLanguage, isSelected: isSelected)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedItemIndex = indexPath.row
        tableView.reloadData()
        delegate?.onSubtitleTrackSelected(subtitleTrack: viewModel.subtitleTrack)
        dismissView()
    }
    
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return CGFloat.space38
    }
}