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
    }
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer!
    @IBOutlet private var systemVolumeHolder: UIView!

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIFromViewDidLoad()
        initAudioPlayer()
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
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] (_) in
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
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Settings",
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
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("Audio Player cannot be initialized")
            return
        }
        audioPlayer.prepareToPlay()
        audioPlayer.volume = 1.0
        audioPlayer.numberOfLoops = -1
    }
    
    func initSystemVolumeHolder() {
        systemVolumeHolder.backgroundColor = UIColor.clear
        let mpVolumeView = MPVolumeView(frame: systemVolumeHolder.bounds)
        systemVolumeHolder.addSubview(mpVolumeView)
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
            switch indexPath.row {
            case 0:
                print("I am safe")
            case 1:
                print("Help me")
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
