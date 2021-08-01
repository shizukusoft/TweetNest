//
//  MainView.swift
//  TweetNest
//
//  Created by Jaehong Kang on 2021/02/24.
//

import SwiftUI
import CoreData
import TweetNestKit
import AuthenticationServices

struct MainView: View {
    @State var selectedAccount: Account?

    var body: some View {
        AppSidebarNavigation()
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, Session.preview.container.viewContext)
    }
}
#endif
