//
//  PlansView.swift
//  WatchTube
//
//  Created by llsc12 on 19/02/2022.
//

import SwiftUI

struct PlansView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Spacer()
                Text("WatchTube is going to have new features! \n These aren't guaranteed, but we're going to try!")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Text("We're going to add YouTube login!\n You will be able to")
                    .multilineTextAlignment(.center)
                Spacer()
                Text("• View subscriptions\n• Have a tailored video feed on your home page!\n• Manage subscriptions\n• View notifications\n• Access your private playlists")
                    .multilineTextAlignment(.leading)
                Spacer()
                Text("And likely more to come!\nJust know that there's a chance it might not happen!")
                    .multilineTextAlignment(.center)
                Spacer()
                Spacer()
                Spacer()
            }
        .padding()
        }
    }
}


struct PlansView_Previews: PreviewProvider {
    static var previews: some View {
        PlansView()
    }
}
