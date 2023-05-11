//
//  DefaultLayoutViewController.swift
//  UXSDK Sample
//
//  MIT License
//
//  Copyright © 2018-2020 DJI
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Combine
import DJIUXSDK
import UIKit

// We subclass the DUXRootViewController to inherit all its behavior and add
// a couple of widgets in the storyboard.
class HardcodedMissionsViewController: DUXDefaultLayoutViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var m1Button: UIButton!
    @IBOutlet weak var m2Button: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    private var cancellables = Set<AnyCancellable>()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
    
    @IBAction func close () {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func loadMission1(_ sender: Any) {
        statusLabel.text = "Loading M1"
        HardcodedMissionsManager.shared.loadMission1()
    }

    @IBAction func loadMission2(_ sender: Any) {
        statusLabel.text = "Loading M2"
        HardcodedMissionsManager.shared.loadMission2()
    }

    @IBAction func uploadMission(_ sender: Any) {
        statusLabel.text = "Uploading"
        HardcodedMissionsManager.shared.uploadMission()
    }

    @IBAction func startMission(_ sender: Any) {
        statusLabel.text = "Starting mission"
        HardcodedMissionsManager.shared.startMission()
    }

    // We are going to add focus adjustment to the default view.
    override func viewDidLoad() {
        super.viewDidLoad()

//        HardcodedMissionsManager.shared.setup()

        HardcodedMissionsManager.shared.currentStatus.sink(receiveValue: { [weak self] status in
            self?.statusLabel.text = status
        })
        .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.leadingViewController?.view.isHidden = true
        self.trailingViewController?.view.isHidden = true
    }
}

final class HardcodedMissionsManager {
    static let shared = HardcodedMissionsManager()
    
    var currentStatus: CurrentValueSubject<String, Never> = .init("N/A")
    
    private var waypointMission = DJIMutableWaypointMission()
    private var cancellable: AnyCancellable?
    
    func loadMission1() {
        waypointMission.removeAllWaypoints()
        loadM1Sample()
        currentStatus.value = "Loaded M1"
    }

    func loadMission2() {
        waypointMission.removeAllWaypoints()
        loadM2Sample()
        currentStatus.value = "Loaded M2"
    }

    func uploadMission() {
        waypointMission.maxFlightSpeed = 8.0
        waypointMission.autoFlightSpeed = 8.0
        waypointMission.gotoFirstWaypointMode = .safely
        waypointMission.headingMode = .usingWaypointHeading
        waypointMission.finishedAction = .goHome
        waypointMission.rotateGimbalPitch = true
        waypointMission.exitMissionOnRCSignalLost = true
        waypointMission.flightPathMode = .curved

        missionOperator?.load(waypointMission)
        missionOperator?.addListener(toFinished: self, with: .main) { [weak self] error in
            guard error == nil else {
                self?.currentStatus.value = "Mission execution failed."
                return
            }
            self?.currentStatus.value = "Mission execution finished."
        }
        missionOperator?.uploadMission { [weak self] error in
            guard error == nil else {
                self?.currentStatus.value = "Upload mission failed."
                return
            }
            self?.currentStatus.value = "Upload mission finished."
        }
    }

    func startMission() {
        missionOperator?.startMission { [weak self] error in
            guard error == nil else {
                self?.currentStatus.value = "Start mission failed."
                return
            }
            self?.currentStatus.value = "Start mission finished."
        }
    }
}

private extension HardcodedMissionsManager {
    var missionOperator: DJIWaypointMissionOperator? {
        guard let missionOperator = DJISDKManager.missionControl()?.waypointMissionOperator() else {
            currentStatus.value = "Mission Operator is nil"
            return nil
        }
        return missionOperator
    }

    func loadM1Sample() {
        var waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.785834, -122.406417))
        waypoint.altitude = 91.44
        waypoint.speed = 8.0
        waypoint.heading = -131
        waypoint.gimbalPitch = 0.0
        waypoint.shootPhotoTimeInterval = 0.0
        waypoint.actionTimeoutInSeconds = 60
        waypointMission.add(waypoint)

        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.7850134311934, -122.40757533714877))
        waypoint.altitude = 91.44
        waypoint.speed = 8.0
        waypoint.heading = -131
        waypoint.gimbalPitch = 0.0
        waypoint.shootPhotoTimeInterval = 0.0
        waypoint.actionTimeoutInSeconds = 60
        waypointMission.add(waypoint)
        
        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.7850134311934, -122.40757533714877))
        waypoint.altitude = 60.96
        waypoint.speed = 8.0
        waypoint.heading = 90
        waypoint.gimbalPitch = -90.0
        waypoint.shootPhotoTimeInterval = 0.0
        waypoint.actionTimeoutInSeconds = 60
        waypointMission.add(waypoint)

        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.7850134311934, -122.40757533714877))
        waypoint.altitude = 60.358997
        waypoint.speed = 6.437376
        waypoint.heading = 90
        waypoint.gimbalPitch = -90.0
        waypoint.shootPhotoTimeInterval = 16.093441
        waypoint.actionTimeoutInSeconds = 999
        waypointMission.add(waypoint)
        
        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.7850134311934, -122.40666793382216))
        waypoint.altitude = 60.96
        waypoint.speed = 6.437376
        waypoint.heading = 90
        waypoint.gimbalPitch = -90.0
        waypoint.shootPhotoTimeInterval = 0.0
        waypoint.actionTimeoutInSeconds = 999
        waypointMission.add(waypoint)
       
        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.78526718105283, -122.40666793382216))
        waypoint.altitude = 60.96
        waypoint.speed = 6.437376
        waypoint.heading = -90
        waypoint.gimbalPitch = -90.0
        waypoint.shootPhotoTimeInterval = 16.093441
        waypoint.actionTimeoutInSeconds = 999
        waypointMission.add(waypoint)

        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.78526718105283, -122.40757533714877))
        waypoint.altitude = 60.96
        waypoint.speed = 6.437376
        waypoint.heading = -90
        waypoint.gimbalPitch = -90.0
        waypoint.shootPhotoTimeInterval = 16.093441
        waypoint.actionTimeoutInSeconds = 999
        waypointMission.add(waypoint)
    }

    func loadM2Sample() {
        loadM1Sample()
    }
}
