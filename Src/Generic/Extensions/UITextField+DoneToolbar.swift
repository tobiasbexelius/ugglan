//
//  UITextField+DoneToolbar.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-18.
//

import Flow
import Foundation
import UIKit

extension UITextField {
    func addDoneToolbar() -> Disposable {
        let bag = DisposeBag()
        let doneToolbar = UIToolbar()
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(system: .flexibleSpace)
        let done = UIBarButtonItem(title: String(key: .TOOLBAR_DONE_BUTTON), style: .navigationBarButtonPrimary)

        doneToolbar.items = [flexSpace, done]

        bag += didLayoutSignal.onValue { _ in
            doneToolbar.sizeToFit()
        }

        inputAccessoryView = doneToolbar

        bag += done.onValue { _ in
            self.resignFirstResponder()
        }

        return bag
    }
}