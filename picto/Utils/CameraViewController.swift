import Foundation
import UIKit
import Combine
import CameraManager

class CameraViewController: UIViewController {

    enum FlashState: Int, CaseIterable {
        case flashAuto
        case flashOff
        case flashOn
        case expanded
    }

    var flashState: FlashState? = .flashAuto {
        didSet {
            resetFlashValues()
            switch flashState {
            case .flashAuto:
                flashVerticalStack.addArrangedSubview(btnFlashAuto)
                cameraManager.flashMode = .auto
            case .flashOff:
                flashVerticalStack.addArrangedSubview(btnFlashOff)
                cameraManager.flashMode = .off
            case .flashOn:
                flashVerticalStack.addArrangedSubview(btnFlashOn)
                cameraManager.flashMode = .on
            case .expanded:
                flashVerticalStack.borderColor = .white
                flashVerticalStack.borderWidth = 0.5
                flashVerticalStack.layer.cornerRadius = 10
                flashVerticalStack.addArrangedSubviews([
                    btnFlashAuto,
                    btnFlashOff,
                    btnFlashOn])
            default:
                return
            }
        }
    }

    enum ShutterState: Int, CaseIterable {
        case photo
        case record
    }

    var shutterState: ShutterState? = .photo {
        didSet {
            switch shutterState {
            case .photo:
                btnShutter.setImage(R.image.cam_takephoto()?.resize(CGSize(width: 50, height: 50)).tint(.white), for: .normal)
                cameraManager.cameraOutputMode = .stillImage
            case .record:
                btnShutter.setImage(R.image.cam_takephoto()?.resize(CGSize(width: 50, height: 50)).tint(.red), for: .normal)
                cameraManager.cameraOutputMode = .videoWithMic
                cameraManager.startRecordingVideo()
            default:
                return
            }
        }
    }

    // MARK: - Variables
    let cameraManager = CameraManager()
    private var subscriptions = Set<AnyCancellable>()
    private var myImage: UIImage = UIImage()
    
    // MARK: - UI Components
    private lazy var cameraView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0.5

        return view
    }()

    private lazy var btnExit: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setImage(R.image.cancel()?.resize(CGSize(width: 20, height: 20)).tint(.white), for: .normal)

        button.addTarget(self, action: #selector(dismissView(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var flashVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isUserInteractionEnabled = true

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10

        return stack
    }()

    private lazy var btnFlashOn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setImage(R.image.flash()?.resize(CGSize(width: 30, height: 30)).tint(.white), for: .normal)
        button.addTarget(self, action: #selector(setFlash(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var btnFlashOff: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setImage(R.image.flashOutline()?.resize(CGSize(width: 30, height: 30)).tint(.white), for: .normal)
        button.addTarget(self, action: #selector(setFlash(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var btnFlashAuto: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setImage(R.image.flashauto()?.resize(CGSize(width: 30, height: 30)).tint(.white), for: .normal)
        button.addTarget(self, action: #selector(setFlash(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var btnSwitchSide: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setImage(R.image.flipCamera()?.resize(CGSize(width: 30, height: 30)).tint(.white), for: .normal)
        button.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)

        return button
    }()

    private lazy var btnShutter: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setImage(R.image.cam_takephoto()?.resize(CGSize(width: 50, height: 50)).tint(.white), for: .normal)

        return button
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        // let cameraInstance = cameraManager.addPreviewLayerToView(self.view)
        showFlashOptions()
        addShutterGestures()
        setupStyle()
        checkCameraAuth()
    }
}

// MARK: - UI
extension CameraViewController {
    private func setupStyle() {
        view.addSubviews([
            cameraView,
            btnExit,
            flashVerticalStack,
            bottomView
        ])

        bottomView.addSubviews([
            btnSwitchSide,
            btnShutter
        ])

        NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: view.frame.height / 2.75),
            btnExit.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            btnExit.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            flashVerticalStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            flashVerticalStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            btnSwitchSide.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -15),
            btnSwitchSide.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            btnShutter.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            btnShutter.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            btnExit.widthAnchor.constraint(equalToConstant: 20),
            btnExit.heightAnchor.constraint(equalToConstant: 20),
            btnShutter.widthAnchor.constraint(equalToConstant: 50),
            btnShutter.heightAnchor.constraint(equalToConstant: 50),
            btnSwitchSide.widthAnchor.constraint(equalToConstant: 30),
            btnSwitchSide.heightAnchor.constraint(equalToConstant: 30),
            btnFlashOn.widthAnchor.constraint(equalToConstant: 30),
            btnFlashOn.heightAnchor.constraint(equalToConstant: 30),
            btnFlashOff.widthAnchor.constraint(equalToConstant: 30),
            btnFlashOff.heightAnchor.constraint(equalToConstant: 30),
            btnFlashAuto.widthAnchor.constraint(equalToConstant: 30),
            btnFlashAuto.heightAnchor.constraint(equalToConstant: 30)
        ])

        flashVerticalStack.addArrangedSubviews([
            btnFlashAuto,
            btnFlashOff,
            btnFlashOn])
        self.flashState = .flashAuto
    }
}

// MARK: - Gestures
extension CameraViewController {

    @objc func showFlashOptions() {
        let tap: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(flashOptions))
        tap.minimumPressDuration = 0.5
        tap.cancelsTouchesInView = false
        flashVerticalStack.addGestureRecognizer(tap)
    }

    @objc func flashOptions() {
        guard flashState != .expanded else { return }
        self.flashState = .expanded
    }

    @objc func setFlash(_ sender: UIButton) {
        if sender == btnFlashOn {
            self.flashState = .flashOn
        } else if sender == btnFlashOff {
            self.flashState = .flashOff
        } else if sender == btnFlashAuto {
            self.flashState = .flashAuto
        }

    }

    @objc func addShutterGestures() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = false
        btnShutter.addGestureRecognizer(tapGesture)

        let record: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(startRecording))
        record.minimumPressDuration = 0.5
        record.cancelsTouchesInView = false
        btnShutter.addGestureRecognizer(record)

        btnShutter.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
    }

    @objc func takePhoto() {
        print("Should take picture")
        cameraManager.capturePictureWithCompletion({ result in
            switch result {
            case .failure:
                print("failure")
            case .success(let content):
                if let image = content.asImage {
                    self.myImage = image
                    self.showImageConfirmation(image: self.myImage)
                    print("Took picture")
                } else {
                    return
                }
            }
        })
    }

    @objc func startRecording() {
        self.shutterState = .record
    }

    @objc func stopRecording() {
        guard self.shutterState == .record else { return }
        cameraManager.stopVideoRecording({ (videoURL, recordError) -> Void in
            guard let videoURL = videoURL else {
                // Handle error of no recorded video URL
                return
            }
            do {
                let fileName = "\(Int(Date().timeIntervalSince1970)).\(videoURL.pathExtension)"
                // create new URL
                let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
                try FileManager.default.copyItem(at: videoURL, to: newUrl)
            }
            catch {
                // Handle error occured during copy
            }
        })
        self.shutterState = .photo
    }

}

// MARK: - Actions
extension CameraViewController {

    @objc private func dismissView( _ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @objc func flipCamera() {
        guard cameraManager.hasFrontCamera else { return }
        cameraManager.cameraDevice = cameraManager.cameraDevice == .front ? .back : .front
    }
}

// MARK: - Functions
extension CameraViewController {
    private func resetFlashValues() {
        flashVerticalStack.borderWidth = 0
        if flashVerticalStack.arrangedSubviews.contains(btnFlashOff) {
            btnFlashOff.removeFromSuperview()
        }
        if flashVerticalStack.arrangedSubviews.contains(btnFlashOn) {
            btnFlashOn.removeFromSuperview()
        }
        if flashVerticalStack.arrangedSubviews.contains(btnFlashAuto) {
            btnFlashAuto.removeFromSuperview()
        }
    }

    private func checkCameraAuth() {
        let currentCameraState = cameraManager.currentCameraStatus()
        if currentCameraState == .notDetermined {
            askForCameraPermissions()
        } else if currentCameraState == .ready {
            addCameraToView()
        } else {
            showPermissionCameraAlert(settingsURL: UIApplication.openSettingsURLString)
        }

    }

    private func askForCameraPermissions() {
        cameraManager.askUserForCameraPermission { permissionGranted in

            if permissionGranted {
                self.addCameraToView()
            } else {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        }
    }

    private func showPermissionCameraAlert(settingsURL: String) {

        let alert = CustomAlertView(viewModel: .init(title: "Enable camera", descriptionText: "It appears you denied access to your camera. You need to enable camera access to post pictures on Picto.", leftButtonTitle: "Cancel", rightButtonTitle: "Continue"))
        alert.leftButtonTapPublisher
            .sink { [unowned self] _ in
            alert.removeFromSuperview()
        }.store(in: &self.subscriptions)

        alert.rightButtonTapPublisher
            .sink { [unowned self] _ in
            UIApplication.shared.open(URL(string: settingsURL)!)
        }.store(in: &self.subscriptions)

        self.view.addSubview(alert)

        NSLayoutConstraint.activate([
            alert.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alert.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alert.widthAnchor.constraint(equalToConstant: view.frame.width / 1.5)
        ])

        alert.layer.cornerRadius = 7
    }

    private func addCameraToView() {
        cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: CameraOutputMode.stillImage)
        cameraManager.showErrorBlock = { [unowned self] (erTitle: String, erMessage: String) -> Void in

            let alert = CustomAlertView(viewModel: .init(title: erTitle, descriptionText: erMessage, leftButtonTitle: nil, rightButtonTitle: "OK"))
            alert.rightButtonTapPublisher
                .sink { [unowned self] _ in
                alert.removeFromSuperview()
            }.store(in: &self.subscriptions)

            self.view.addSubview(alert)

            NSLayoutConstraint.activate([
                alert.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                alert.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                alert.widthAnchor.constraint(equalToConstant: view.frame.width / 1.5)
            ])
            
            alert.layer.cornerRadius = 7

        }
        cameraManager.shouldFlipFrontCameraImage = false
        cameraManager.writeFilesToPhoneLibrary = false

#warning("Should make it true once multiple aspect ratios are handled in postCells (Home)")
        cameraManager.shouldRespondToOrientationChanges = false
    }

    private func showImageConfirmation(image: UIImage) {
        let confirmation = ImageConfirmationViewController(viewModel: .init(image: image))
        confirmation.cancelButtonTapPublisher
            .sink { [unowned self] _ in
            confirmation.removeFromSuperview()
        }.store(in: &self.subscriptions)

        confirmation.nextButtonTapPublisher
            .sink { [unowned self] _ in
#warning("Handle postupload")
            print("Next pressed")
        }.store(in: &self.subscriptions)

        self.view.addSubview(confirmation)

        NSLayoutConstraint.activate([
            confirmation.bottomView.topAnchor.constraint(equalTo: self.bottomView.topAnchor),
            confirmation.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            confirmation.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            confirmation.topAnchor.constraint(equalTo: view.topAnchor),
            confirmation.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
