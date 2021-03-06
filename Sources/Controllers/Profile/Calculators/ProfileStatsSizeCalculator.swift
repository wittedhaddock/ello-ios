////
///  ProfileStatsSizeCalculator.swift
//

import FutureKit


public struct ProfileStatsSizeCalculator {

    public func calculate(item: StreamCellItem) -> Future<CGFloat> {
        let promise = Promise<CGFloat>()
        promise.completeWithSuccess(ProfileStatsView.Size.height)
        return promise.future
    }
}

private extension ProfileStatsSizeCalculator {}
