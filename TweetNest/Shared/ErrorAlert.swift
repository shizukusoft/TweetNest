//
//  ErrorAlert.swift
//  ErrorAlert
//
//  Created by Jaehong Kang on 2021/08/07.
//

import SwiftUI
import Twitter

struct ErrorAlert: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var error: Swift.Error?
    
    let dismissHandler: ((Error) -> Void)?

    private var title: Text {
        switch error {
        case .some(TwitterError.serverError(let payload, urlResponse: _)):
            switch payload {
            case .error(let error):
                return Text(LocalizedStringKey(error.title))
            case .string(_):
                return Text("Error")
            case .none:
                return Text("Error")
            }
        default:
            return Text("Error")
        }
    }

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented, presenting: error) { error in
                Button(role: .cancel) {
                    dismissHandler?(error)
                } label: {
                    Text("Cancel")
                }
            } message: { error in
                switch error {
                case TwitterError.serverError(let payload, urlResponse: _):
                    switch payload {
                    case .error(let error):
                        Text(LocalizedStringKey(error.detail))
                    case .string(let string):
                        Text(LocalizedStringKey(string))
                            .lineLimit(1)
                    case .none:
                        Text(error.localizedDescription)
                    }
                default:
                    Text(error.localizedDescription)
                }
            }
    }
}

extension View {
    func alertError(isPresented: Binding<Bool>, error: Binding<Swift.Error?>, onDismiss: ((Swift.Error) -> Void)? = nil) -> some View {
        modifier(
            ErrorAlert(isPresented: isPresented, error: error, dismissHandler: onDismiss)
        )
    }
}

#if DEBUG
struct ErrorAlert_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .alertError(isPresented: .constant(true), error: .constant(CocoaError(.coderValueNotFound)))
    }
}
#endif
