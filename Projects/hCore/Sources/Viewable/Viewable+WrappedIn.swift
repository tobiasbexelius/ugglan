//
//  Viewable+WrappedIn.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

public struct ContainerStackViewable<V: Viewable, Matter: UIView, ContainerView: UIStackView>: Viewable where V.Matter == Matter, V.Events == ViewableEvents, V.Result == Disposable {
    let viewable: V
    let container: ContainerView

    public func materialize(events _: ViewableEvents) -> (ContainerView, Disposable) {
        let bag = DisposeBag()
        bag += container.addArranged(viewable)
        return (container, bag)
    }
}

public struct ContainerStackViewableSignal<V: Viewable, Matter: UIView, ContainerView: UIStackView, SignalValue>: Viewable where V.Matter == Matter, V.Events == ViewableEvents, V.Result == Signal<SignalValue> {
    let viewable: V
    let container: ContainerView

    public func materialize(events _: ViewableEvents) -> (ContainerView, Signal<SignalValue>) {
        return (container, Signal { callback in
            let bag = DisposeBag()
            bag += self.container.addArranged(self.viewable).onValue(callback)
            return bag
        })
    }
}

public struct ContainerViewable<V: Viewable, Matter: UIView, ContainerView: UIView>: Viewable where V.Matter == Matter, V.Events == ViewableEvents, V.Result == Disposable {
    let viewable: V
    let container: ContainerView

    public func materialize(events _: ViewableEvents) -> (ContainerView, Disposable) {
        let bag = DisposeBag()
        bag += container.add(viewable)
        return (container, bag)
    }
}

extension Viewable where Self.Events == ViewableEvents, Self.Result == Disposable, Self.Matter: UIView {
    public func wrappedIn(_ stackView: UIStackView) -> ContainerStackViewable<Self, Self.Matter, UIStackView> {
        return ContainerStackViewable(viewable: self, container: stackView)
    }

    public func wrappedIn(_ view: UIView) -> ContainerViewable<Self, Self.Matter, UIView> {
        return ContainerViewable(viewable: self, container: view)
    }
}

extension Viewable where Self.Events == ViewableEvents, Self.Matter: UIView {
    public func wrappedIn<SignalValue>(_ stackView: UIStackView) -> ContainerStackViewableSignal<Self, Self.Matter, UIStackView, SignalValue> {
        return ContainerStackViewableSignal(viewable: self, container: stackView)
    }
}