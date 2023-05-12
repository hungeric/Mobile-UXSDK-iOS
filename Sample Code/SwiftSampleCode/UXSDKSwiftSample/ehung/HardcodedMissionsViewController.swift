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

final class HardcodedMissionsManager: NSObject {
    static let shared = HardcodedMissionsManager()
    
    var currentStatus: CurrentValueSubject<String, Never> = .init("N/A")
    
    private var waypointMission = DJIMutableWaypointMission()
    private var cancellable: AnyCancellable?
    
    private var photoIndex = 0

    override init() {
        super.init()
        camera?.delegate = self
    }

    func loadMission1() {
        waypointMission.removeAllWaypoints()
        photoIndex = 0
        loadM1Sample()
        currentStatus.value = "Loaded M1"
    }

    func loadMission2() {
        waypointMission.removeAllWaypoints()
        photoIndex = 0
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
    var camera: DJICamera? {
        guard let aircraft = DJISDKManager.product() as? DJIAircraft, let camera = aircraft.cameras?.first else {
            return nil
        }

        return camera
    }
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
        waypoint.shootPhotoDistanceInterval = 0.0
        waypoint.actionTimeoutInSeconds = 60
        waypointMission.add(waypoint)

        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.7850134311934, -122.40757533714877))
        waypoint.altitude = 91.44
        waypoint.speed = 8.0
        waypoint.heading = -131
        waypoint.gimbalPitch = 0.0
        waypoint.shootPhotoDistanceInterval = 0.0
        waypoint.actionTimeoutInSeconds = 60
        waypointMission.add(waypoint)
        
        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.7850134311934, -122.40757533714877))
        waypoint.altitude = 60.96
        waypoint.speed = 8.0
        waypoint.heading = 90
        waypoint.gimbalPitch = -90.0
        waypoint.shootPhotoDistanceInterval = 0.0
        waypoint.actionTimeoutInSeconds = 60
        waypointMission.add(waypoint)

        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.7850134311934, -122.40757533714877))
        waypoint.altitude = 60.358997
        waypoint.speed = 6.437376
        waypoint.heading = 90
        waypoint.gimbalPitch = -90.0
        waypoint.shootPhotoDistanceInterval = 16.093441
        waypoint.actionTimeoutInSeconds = 999
        waypointMission.add(waypoint)
        
        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.7850134311934, -122.40666793382216))
        waypoint.altitude = 60.96
        waypoint.speed = 6.437376
        waypoint.heading = 90
        waypoint.gimbalPitch = -90.0
        waypoint.shootPhotoDistanceInterval = 0.0
        waypoint.actionTimeoutInSeconds = 999
        waypointMission.add(waypoint)
       
        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.78526718105283, -122.40666793382216))
        waypoint.altitude = 60.96
        waypoint.speed = 6.437376
        waypoint.heading = -90
        waypoint.gimbalPitch = -90.0
        waypoint.shootPhotoDistanceInterval = 16.093441
        waypoint.actionTimeoutInSeconds = 999
        waypointMission.add(waypoint)

        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(37.78526718105283, -122.40757533714877))
        waypoint.altitude = 60.96
        waypoint.speed = 6.437376
        waypoint.heading = -90
        waypoint.gimbalPitch = -90.0
        waypoint.shootPhotoDistanceInterval = 16.093441
        waypoint.actionTimeoutInSeconds = 999
        waypointMission.add(waypoint)
    }

    func loadM2Sample() {
        let m2JSON = """
        {"waypoints":[{"actionTimeoutInSeconds":60,"speed":8,"gimbalPitch":0,"shootPhotoDistanceInterval":0,"lat":37.785834000000001,"heading":-135,"altitude":91.44000244140625,"long":-122.406417},{"actionTimeoutInSeconds":60,"speed":8,"gimbalPitch":0,"shootPhotoDistanceInterval":0,"lat":37.784909624181608,"heading":-135,"altitude":91.44000244140625,"long":-122.40757533714877},{"actionTimeoutInSeconds":60,"speed":8,"gimbalPitch":-90,"shootPhotoDistanceInterval":0,"lat":37.784909624181608,"heading":90,"altitude":60.959999084472656,"long":-122.40757533714877},{"actionTimeoutInSeconds":999,"speed":7.3152003288269043,"gimbalPitch":-90,"shootPhotoDistanceInterval":18.288000106811523,"lat":37.784909624181608,"heading":90,"altitude":60.358997344970703,"long":-122.40757533714877},{"actionTimeoutInSeconds":999,"speed":7.3152003288269043,"gimbalPitch":-90,"shootPhotoDistanceInterval":0,"lat":37.784909624181608,"heading":90,"altitude":60.959999084472656,"long":-122.40666793382216},{"actionTimeoutInSeconds":999,"speed":7.3152003288269043,"gimbalPitch":-90,"shootPhotoDistanceInterval":18.288000106811523,"lat":37.785197976632126,"heading":-90,"altitude":60.959999084472656,"long":-122.40666793382216},{"actionTimeoutInSeconds":999,"speed":7.3152003288269043,"gimbalPitch":-90,"shootPhotoDistanceInterval":0,"lat":37.785197976632126,"heading":-90,"altitude":60.959999084472656,"long":-122.40757533714877},{"actionTimeoutInSeconds":999,"speed":7.3152003288269043,"gimbalPitch":-90,"shootPhotoDistanceInterval":18.288000106811523,"lat":37.785486327957571,"heading":90,"altitude":60.959999084472656,"long":-122.40757533714877},{"actionTimeoutInSeconds":999,"speed":7.3152003288269043,"gimbalPitch":-90,"shootPhotoDistanceInterval":18.288000106811523,"lat":37.785486327957571,"heading":90,"altitude":60.959999084472656,"long":-122.40666793382216}]}
        """
        let jsonDecoder = JSONDecoder()
        guard let result = try? jsonDecoder.decode(CodableDJIWaypointMission.self, from: m2JSON.data(using: .utf8)!) else { self.currentStatus.value = "M2 load failed"
            return
        }
        waypointMission.addWaypoints(result.mission.allWaypoints())
    }
}

extension HardcodedMissionsManager: DJICameraDelegate {
    func camera(_ camera: DJICamera, didGenerateNewMediaFile newMedia: DJIMediaFile) {
        photoIndex += 1
        currentStatus.value = "photo taken index: \(photoIndex)"
        print("ehung")
        print(newMedia.description)
    }
}

final class CodableDJIWaypointMission: Codable {
    let mission: DJIWaypointMission

    init(mission: DJIWaypointMission) {
        self.mission = mission
    }

    var codableDJIWaypoints: [CodableDJIWaypoint] {
        return mission.allWaypoints().map { point in
            CodableDJIWaypoint(waypoint: point)
        }
    }

    enum CodingKeys: String, CodingKey {
        case waypoints
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(codableDJIWaypoints, forKey: .waypoints)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let waypoints = try container.decode([CodableDJIWaypoint].self, forKey: .waypoints)
        let mission = DJIMutableWaypointMission()
        mission.addWaypoints(waypoints.map { $0.waypoint } )
        self.mission = mission
    }
}

final class CodableDJIWaypoint: Codable {
    let waypoint: DJIWaypoint

    init(waypoint: DJIWaypoint) {
        self.waypoint = waypoint
    }

    enum CodingKeys: String, CodingKey {
        case lat
        case long
        case coordinate
        case altitude
        case speed
        case heading
        case gimbalPitch
        case shootPhotoDistanceInterval
        case actionTimeoutInSeconds
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(waypoint.coordinate.latitude, forKey: .lat)
        try container.encode(waypoint.coordinate.longitude, forKey: .long)
        try container.encode(waypoint.altitude, forKey: .altitude)
        try container.encode(waypoint.speed, forKey: .speed)
        try container.encode(waypoint.heading, forKey: .heading)
        try container.encode(waypoint.gimbalPitch, forKey: .gimbalPitch)
        try container.encode(waypoint.shootPhotoDistanceInterval, forKey: .shootPhotoDistanceInterval)
        try container.encode(waypoint.actionTimeoutInSeconds, forKey: .actionTimeoutInSeconds)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lat = try container.decode(Double.self, forKey: .lat)
        let long = try container.decode(Double.self, forKey: .long)
        let altitude = try container.decode(Float.self, forKey: .altitude)
        let speed = try container.decode(Float.self, forKey: .speed)
        let heading = try container.decode(Int.self, forKey: .heading)
        let gimbalPitch = try container.decode(Float.self, forKey: .gimbalPitch)
        let shootPhotoDistanceInterval = try container.decode(Float.self, forKey: .shootPhotoDistanceInterval)
        let actionTimeoutInSeconds = try container.decode(Int.self, forKey: .actionTimeoutInSeconds)
        waypoint = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(lat, long))
        waypoint.altitude = altitude
        waypoint.speed = speed
        waypoint.heading = heading
        waypoint.gimbalPitch = gimbalPitch
        waypoint.shootPhotoDistanceInterval = shootPhotoDistanceInterval
        waypoint.actionTimeoutInSeconds = Int32(actionTimeoutInSeconds)
    }
}
