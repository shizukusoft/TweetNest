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

    private var titleText: some StringProtocol {
        switch error {
        case .some(TwitterError.serverError(let payload, urlResponse: _)):
            switch payload {
            case .error(let error):
                return error.title
            case .string(_):
                return "Error"
            case .none:
                return "Error"
            }
        default:
            return "Error"
        }
    }

    func body(content: Content) -> some View {
        content
            .alert(titleText, isPresented: $isPresented, presenting: error) { _ in

            } message: { error in
                switch error {
                case TwitterError.serverError(let payload, urlResponse: _):
                    switch payload {
                    case .error(let error):
                        Text(error.detail)
                    case .string(let string):
                        Text(string)
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
    func alertError(isPresented: Binding<Bool>, error: Binding<Swift.Error?>) -> some View {
        modifier(
            ErrorAlert(isPresented: isPresented, error: error)
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
