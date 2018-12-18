import UIKit
import SimplePagedViewFramework
import PlaygroundSupport

let green = UIView()
green.backgroundColor = .green

let red = UIView()
red.backgroundColor = .red

let orange = UIView()
orange.backgroundColor = .orange

let pagedView = SimplePagedView(
//    indicatorColor: .cyan,
//    dotSize: 20,
    with: green, red, orange
)

PlaygroundPage.current.liveView = pagedView
