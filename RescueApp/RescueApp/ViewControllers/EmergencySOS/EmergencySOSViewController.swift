//
/*
EmergencySOSViewController.swift
Created on: 12/9/18

Abstract:
 self descriptive

*/

import UIKit
import AVFoundation
import MediaPlayer
import MessageUI

final class EmergencySOSViewController: UIViewController, RANavigationProtocol {
    
    // MARK: Properties
    private let toolsSections = ["Flashlight", "Strobe Light", "Alarm"]
    private let safetySections = [
        [C.SAFETY_BUTTON_CONFIG.TITLE_KEY: "MARK AS SAFE", C.SAFETY_BUTTON_CONFIG.COLOR_KEY: RAColorSet.SAFE_GREEN],
        [C.SAFETY_BUTTON_CONFIG.TITLE_KEY: "NEED HELP", C.SAFETY_BUTTON_CONFIG.COLOR_KEY: RAColorSet.WARNING_RED]]
    private struct C {
        static let TITLE = "Emergency/SOS"
        static let CELL_WITH_SWITCH_ID = "SOSCellWithSwitch"
        static let CELL_WITH_Button_ID = "SOSCellWithButton"
        struct SAFETY_BUTTON_CONFIG {
            static let TITLE_KEY = "title"
            static let COLOR_KEY = "color"
        }
        static let SEGUE_TO_SETTINGS = "segueToSettings"
        static let STROBE_TIME_INTERVAL = 0.2
    }
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer!
    @IBOutlet private var systemVolumeHolder: UIView!
    private var contacts = [EmergencyContact]()
    @IBOutlet private weak var tableView: UITableView!

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIFromViewDidLoad()
        initAudioPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchContacts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initSystemVolumeHolder()
    }
    
    // MARK: Button Actions
    
    func onToggleFlashlight() {
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            do {
                try device.lockForConfiguration()
                let torchOn = device.torchMode
                try device.setTorchModeOn(level: 1.0)
                device.torchMode = torchOn == .off ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("error")
            }
        }
    }
    
    func turnOffFlashlight() {
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = .off
                device.unlockForConfiguration()
            } catch {
                print("error")
            }
        }
    }
    
    func onToggleStrobeLight() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
            turnOffFlashlight()
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: C.STROBE_TIME_INTERVAL, repeats: true) { [weak self] (_) in
                self?.onToggleFlashlight()
            }
            timer?.fire()
        }
    }
    
    func onToggleAlarm() {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        } else {
            audioPlayer.play()
        }
    }
    
    @objc func onSettingsClick(_ sender: Any) {
        performSegue(withIdentifier: C.SEGUE_TO_SETTINGS, sender: nil)
    }
}

// MARK: Helper Methods

private extension EmergencySOSViewController {
    func configureUIFromViewDidLoad() {
        configureNavigationBar(RAColorSet.RED)
        title = C.TITLE
        navigationItem.backBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(onSettingsClick(_:)))
    }
    
    func initAudioPlayer() {
        guard let path = Bundle.main.path(forResource: "alarm", ofType: "wav") else {
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            try AVAudioSession.sharedInstance()
                .setCategory(
                    AVAudioSession.Category(
                        rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)
                    ),
                    mode: AVAudioSession.Mode.default
            )
        } catch {
            print("Audio Player cannot be initialized")
            return
        }
        audioPlayer.prepareToPlay()
        audioPlayer.volume = 1.0
        audioPlayer.numberOfLoops = -1
    }
    
    func initSystemVolumeHolder() {
        let subview = systemVolumeHolder.viewWithTag(101)
        subview?.removeFromSuperview()
        systemVolumeHolder.backgroundColor = UIColor.clear
        let mpVolumeView = MPVolumeView(frame: systemVolumeHolder.bounds)
        mpVolumeView.tag = 101
        systemVolumeHolder.addSubview(mpVolumeView)
    }
    
    func fetchContacts() {
        contacts = EmergencyContactUtil.fetchContacts()
        tableView.reloadData()
    }
    
    func sendSMS(messageKey key: String) {
        guard let message = UserDefaults.standard.string(forKey: key) else {
            return
        }
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = message
            controller.recipients = contacts.map { $0.contactNumbers }.flatMap{ $0 }
            controller.messageComposeDelegate = self
            present(controller, animated: true, completion: nil)
        }
    }
}

extension EmergencySOSViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if section == 0 {
            rowCount = toolsSections.count
        } else if section == 1 {
            rowCount = safetySections.count
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: C.CELL_WITH_SWITCH_ID)
            let label = cell.viewWithTag(1) as! UILabel
            label.text = toolsSections[indexPath.row]
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: C.CELL_WITH_Button_ID)
            let label = cell.viewWithTag(1) as! UILabel
            let safetyConfig = safetySections[indexPath.row]
            label.text = safetyConfig[C.SAFETY_BUTTON_CONFIG.TITLE_KEY] as? String
            label.backgroundColor = safetyConfig[C.SAFETY_BUTTON_CONFIG.COLOR_KEY] as? UIColor
            label.isEnabled = contacts.count > 0
        default:
            abort()
        }
        cell.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String!
        if section == 0 {
            title = "Emergency Tools"
        } else if section == 1 {
            title = "Safety Actions"
            if contacts.count == 0 {
                title = "\(title!) (INACTIVE)"
            }
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let cell = tableView.cellForRow(at: indexPath)
            let toggleSwitch = cell?.viewWithTag(2) as! UISwitch
            toggleSwitch.isOn = !toggleSwitch.isOn
            switch indexPath.row {
            case 0:
                onToggleFlashlight()
            case 1:
                onToggleStrobeLight()
            case 2:
                onToggleAlarm()
            default:
                abort()
            }
        case 1:
            if contacts.count == 0 {
                return
            }
            switch indexPath.row {
            case 0:
                sendSMS(messageKey: Constants.UserDefaultsKeys.MARK_AS_SAFE_MESSAGE)
            case 1:
                sendSMS(messageKey: Constants.UserDefaultsKeys.DANGER_NEED_HELP_MESSAGE)
            default:
                abort()
            }
        default:
            abort()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 44.0
        if indexPath.section == 1 {
            height = 64
        }
        return height
    }
}

extension EmergencySOSViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
