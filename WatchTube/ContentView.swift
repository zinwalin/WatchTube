//
//  ContentView.swift
//  WatchTube
//
//  Created by llsc12 on 18/02/2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Image(colorScheme == .dark ? "iconDark" : "iconLight")
                .resizable()
                .frame(width: 200.0, height: 200.0)
                .scaledToFit()
                .clipShape(Circle())
            Text("Under Construction!")
                .font(Font.system(size:30))
                .padding(.top, 5.0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
