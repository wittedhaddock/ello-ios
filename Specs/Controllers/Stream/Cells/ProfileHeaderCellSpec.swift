////
///  ProfileHeaderCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderCellSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderCell") {
            var cell: ProfileHeaderCell!
            xcontext("while loading") {
                beforeEach {
//                    cell = ProfileHeaderCell.loadFromNib() as ProfileHeaderCell
                    let item: StreamCellItem = StreamCellItem(type: .ProfileHeader)
                    ProfileHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .CurrentUserStream, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)
                }
                it("has valid snapshot with no image") {
                    expectValidSnapshot(cell, device: .Phone6_Portrait)
                }
                it("has valid snapshot with an avatar") {
                    expectValidSnapshot(cell, device: .Phone6_Portrait)
                }
            }

            xcontext("user loaded") {
                beforeEach {
//                    cell = ProfileHeaderCell.loadFromNib() as ProfileHeaderCell
                    let user = User.stub([
                        "username": "666",
                        "name": "Archer Sterling",
                        "postsCount": 1,
                        "lovesCount": 1,
                        "followersCount": "1",
                        "followingCount": 1,
                        ])
                    let item: StreamCellItem = StreamCellItem(jsonable: user, type: .ProfileHeader)
                    ProfileHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .CurrentUserStream, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)
                }
                it("has valid snapshot with user info, no avatar") {
                    expectValidSnapshot(cell, device: .Phone6_Portrait)
                }
            }
        }
    }
}
