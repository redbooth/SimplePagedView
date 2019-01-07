# SimplePagedView

SimplePagedView is an iOS component that makes it as easy as possible to set up a page view for things like onboarding or presenting information.

<img src="https://user-images.githubusercontent.com/5561501/49899079-87bbda80-fe0f-11e8-82ec-ea523e6cd42c.png" alt="simulator screen shot - iphone 8 - 2018-12-12 at 12 54 46" width=400 />

## Installation

```ruby
pod 'SimplePagedView'
```

## Usage

### Programmatic setup
```swift
// Create a PagedViewController by providing it with a view for each page you'd like it to contain
let simplePagedView = SimplePagedView(with:
    LogoView(presenter: welcomePresenter),
    CardPageView(image: ThemeManager.Images.welcomeTourSlide1,
                        subtitle: "Complete and resolve tasks on the go"),
    CardPageView(image: ThemeManager.Images.welcomeTourSlide2,
                        subtitle: "Comment on tasks and conversations"),
    CardPageView(image: ThemeManager.Images.welcomeTourSlide3,
                        subtitle: "Add files and pictures in seconds")
)

// Add as subview and setup constraints/frame
```
