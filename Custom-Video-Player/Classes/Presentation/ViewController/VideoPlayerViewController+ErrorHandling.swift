import AVFoundation

extension VideoPlayerViewController {
    
    // TODO: Error handling when something happens in between while playing video
    
    func handlePlayerError(_ error: Error?) {
        guard let error = error else {
            return
        }
        if error is URLError {
            setUpPlayerItemError(errorMessage: "Please check your internet connection. Seems to be offline!")
        } else if error is AVError {
            setUpPlayerItemError(errorMessage: "Video Player failed to load!")
        } else {
            setUpPlayerItemError(errorMessage: "Something went wrong. Please try again!")
        }
    }
    
    func setUpPlayerItemError(errorMessage: String) {
        resetPlayerItems()
        let errorView = VideoPlayerErrorView(
            title: errorMessage,
            onBackButtonClicked: { [weak self] in
                guard let self = self else { return }
                self.coordinator.navigationController.dismiss(animated: true)
            }
        )
        view.addSubview(errorView)
        errorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(CGFloat.space16)
            make.trailing.equalToSuperview().offset(-CGFloat.space16)
            make.top.bottom.equalToSuperview()
        }
    }
}
