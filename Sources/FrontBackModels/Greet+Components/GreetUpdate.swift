//
//  UpdateGreetObject.swift
//  akin
//
//  Created by Scott Lydon on 4/12/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Greet {

    public enum Update: Equatable, Codable {
        case errorMessage(String)
        case exitReason(ExitReason)
        case message(Message)
        case viewSetting(ViewSetting)

        public static func == (lhs: Greet.Update, rhs: Greet.Update) -> Bool {
            switch (lhs, rhs) {
            case (let .errorMessage(errorMessage1), let .errorMessage(errorMessage2)):
                return errorMessage1 == errorMessage2
            case (let .exitReason(exitReason1), let .exitReason(exitReason2)):
                return exitReason1 == exitReason2
            case (let .message(greetMessage1), let .message(greetMessage2)):
                return greetMessage1 == greetMessage2
            case (let .viewSetting(viewSetting1), let .viewSetting(viewSetting2)):
                return viewSetting1 == viewSetting2
            default: return false
            }
        }

        public init(
            this: Status,
            otherUser: Status?,
            withinRange: Bool,
            rejectedProposal: Int?,
            viewForProposal: ViewSetting,
            otherUserName: String
        ) {

            guard let otherStatus = otherUser else {
                switch this {
                case .exceededRange:
                    self = .exitReason(.exceededRange(.my))
                case .rejectedOther:
                    self = .exitReason(.rejected(.my))
                case .enroute:
                    self = .errorMessage("if the other user is nil, this user should not be enroute")
                case .viewed:
                    self = .viewSetting(viewForProposal)
                case .confirmedMet:
                    self = .errorMessage("If this user is confirming that both met, how can the other user be nil?")
                }
                return
            }

            switch (this, otherStatus) {

                //THIS AGREED
            case (.confirmedMet, .confirmedMet): self = .exitReason(.thisConfirmedMet)
            case (.confirmedMet, .enroute):  self = .exitReason(.thisConfirmedMet)
            case (.confirmedMet, .exceededRange): self = .errorMessage("exceededRange can only happen prior to both user's agreeing to meet.")
            case (.confirmedMet, .rejectedOther): self = .errorMessage("if other user rejected, should exit before this user can confirm met.  If confirmed met, it shoudl have navigated away from GreetVC")
            case (.confirmedMet, .viewed):
                self = .errorMessage("in order for this user to confirm meeting the other user, both users would have had to have had enroute status, viewed would be impossible.")


                //THIS ENROUTE
            case (.enroute, .confirmedMet): self = .message(.theySayTheyMet(otherUserName))
            case (.enroute, .enroute):
                self = withinRange ? .message(.youAreCloseTo(otherUserName)) : .viewSetting(.inGreet)
            case (.enroute, .exceededRange):  self = .exitReason(.exceededRange(.their))
            case (.enroute, .rejectedOther): self = .exitReason(.rejected(.their))
            case (.enroute, .viewed): self = .errorMessage("impossible")


                //THIS EXCEEDEDRANGE
            case (.exceededRange, .confirmedMet): self = .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")
            case (.exceededRange, .enroute): self = .errorMessage("impossible, report to mustafa, exceeded range can only occur when viewing or none.")
            case (.exceededRange, .exceededRange): self = .exitReason(.exceededRange(.my))
            case (.exceededRange, .rejectedOther): self = .exitReason(.exceededRange(.my))
            case (.exceededRange, .viewed):  self = .exitReason(.exceededRange(.my))

                //THIS REJECTED
            case (.rejectedOther, _): self = .exitReason(.rejected(.my))

                //THIS VIEWED
            case (.viewed, .confirmedMet): self = .errorMessage("impossible")
            case (.viewed, .enroute): self = .errorMessage("impossible")
            case (.viewed, .exceededRange): self = .exitReason(.exceededRange(.their))
            case (.viewed, .rejectedOther): self = .exitReason(.rejected(.their))
            case (.viewed, .viewed):
                if let time = rejectedProposal {
                    self = .message(.cant(time))
                    return
                }
                self = .viewSetting(viewForProposal)
            }
        }
    }
}
