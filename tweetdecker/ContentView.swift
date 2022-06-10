//
//  ContentView.swift
//  tweetdecker
//
//  Created by いちご on 2022/06/07.
//

import SwiftUI
import WebKit

struct ContentView: View {
    var webViewModel = WebViewModel(url:URL(string:  "https://tweetdeck.twitter.com")!)
    
    var body: some View {
        ZStack{
            WebView(viewModel:webViewModel)
                .frame(minWidth: 400, minHeight: 200)
        }
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
