///
/// GKTurnBasedMatchmakerView.swift
/// VocaBurn
/// 
/// Created by Sascha Müllner on 22.11.20.
/// Unauthorized copying or usage of this file, via any medium is strictly prohibited.
/// Proprietary and confidential.
/// Copyright © 2020 Webblazer EG. All rights reserved.

import Foundation
import GameKit
import SwiftUI

public struct GKTurnBasedMatchmakerView: UIViewControllerRepresentable {
    
    private let matchRequest: GKMatchRequest
    private let canceled: () -> Void
    private let failed: (Error) -> Void
    private let started: (GKTurnBasedMatch) -> Void
    
    public init(matchRequest: GKMatchRequest,
                canceled: @escaping () -> Void,
                failed: @escaping (Error) -> Void,
                started: @escaping (GKTurnBasedMatch) -> Void) {
        self.matchRequest = matchRequest
        self.canceled = canceled
        self.failed = failed
        self.started = started
    }
    
    public init(minPlayers: Int,
                maxPlayers: Int,
                inviteMessage: String,
                canceled: @escaping () -> Void,
                failed: @escaping (Error) -> Void,
                started: @escaping (GKTurnBasedMatch) -> Void) {
        let matchRequest = GKMatchRequest()
        matchRequest.minPlayers = minPlayers
        matchRequest.maxPlayers = maxPlayers
        matchRequest.inviteMessage = inviteMessage
        self.matchRequest = matchRequest
        self.canceled = canceled
        self.failed = failed
        self.started = started
    }
    
    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<GKTurnBasedMatchmakerView>) -> TurnBasedMatchmakerViewController {
        return TurnBasedMatchmakerViewController(
            matchRequest: self.matchRequest) {
            self.canceled()
        } failed: { (error) in
            self.failed(error)
        } started: { (match) in
            self.started(match)
        }
    }
    
    public func updateUIViewController(
        _ uiViewController: TurnBasedMatchmakerViewController,
        context: UIViewControllerRepresentableContext<GKTurnBasedMatchmakerView>) {
    }
}

public class TurnBasedMatchmakerViewController: UIViewController, GKTurnBasedMatchmakerViewControllerDelegate, GKMatchDelegate {

    private let matchRequest: GKMatchRequest
    private let canceled: () -> Void
    private let failed: (Error) -> Void
    private let started: (GKTurnBasedMatch) -> Void
    
    public init(matchRequest: GKMatchRequest,
                canceled: @escaping () -> Void,
                failed: @escaping (Error) -> Void,
                started: @escaping (GKTurnBasedMatch) -> Void) {
        self.matchRequest = matchRequest
        self.canceled = canceled
        self.failed = failed
        self.started = started
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let viewController = GKTurnBasedMatchmakerViewController(matchRequest: self.matchRequest)
        viewController.turnBasedMatchmakerDelegate = self
        self.addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(viewController.view)
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            viewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            viewController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            viewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ])
    }

    public func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true, completion: nil)
        self.canceled()
    }

    public func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true, completion: nil)
        self.failed(error)
    }

    public func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFind match: GKTurnBasedMatch) {
        viewController.dismiss(animated: true, completion: nil)
        self.started(match)
    }
}
