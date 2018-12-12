# SimplePagedView

SimplePagedView is an iOS component that makes it as easy as possible to set up a page view for things like onboarding or presenting information.

()[image here]

## Installation

```ruby
pod 'SimplePagedView'
```

## Usage

```swift
// Create a PagedViewController by providing it with a view for each page you'd like it to contain
let pagedViewController = PagedViewController(with:
    LogoView(presenter: welcomePresenter),
    CardPageView(image: ThemeManager.Images.welcomeTourSlide1,
                        subtitle: "Complete and resolve tasks on the go"),
    CardPageView(image: ThemeManager.Images.welcomeTourSlide2,
                        subtitle: "Comment on tasks and conversations"),
    CardPageView(image: ThemeManager.Images.welcomeTourSlide3,
                        subtitle: "Add files and pictures in seconds")
)

// Add the pagedViewController as a child view controller
self.add(pagedViewController) { (childView) -> [NSLayoutConstraint] in
    // Return an array of constraints to apply to the paged view
    return [
        childView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
        childView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
        childView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
        childView.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor)
    ]
}
```
