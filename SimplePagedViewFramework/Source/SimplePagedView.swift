import UIKit

public class SimplePagedView: UIViewController {

    // MARK: - Properties
    private static let defaultPageControlConstraints: (SimplePagedView) -> ([NSLayoutConstraint])
        = { (pagedViewController: SimplePagedView) in
            return [
                pagedViewController.pageControl.bottomAnchor.constraint(
                    equalTo: pagedViewController.scrollView.bottomAnchor,
                    constant: Constants.pageControllerSpacing
                ),
                pagedViewController.pageControl.centerXAnchor.constraint(
                    equalTo: pagedViewController.view.centerXAnchor
                ),
                pagedViewController.pageControl.leadingAnchor.constraint(
                    equalTo: pagedViewController.scrollView.leadingAnchor
                ),
                pagedViewController.pageControl.trailingAnchor.constraint(
                    equalTo: pagedViewController.scrollView.trailingAnchor
                )
            ]
    }

    private enum Constants {
        static let startingPage = 0
        static let pageControllerSpacing: CGFloat = -10
    }

    fileprivate var scrollContentView: UIView = {
        var scrollingView = UIView()
        scrollingView.translatesAutoresizingMaskIntoConstraints = false
        return scrollingView
    }()
    fileprivate var innerPages: [UIView]!
    fileprivate let pageControlConstraints: (SimplePagedView) -> ([NSLayoutConstraint])
    fileprivate let initialPage: Int
    fileprivate var didInit = false
    fileprivate let dotSize: CGFloat


    /// Can be defined in order to trigger an action when pages are switched. Pages are 0 indexed.
    public var didSwitchPages: ((Int) -> Void)?
    /// Can be set to allow or disallow user interaction with the page dot indicators. Defaults to false.
    public var pageIndicatorIsInteractive: Bool = false
    /// The last dot can in the page indicator can be replaced with an image by setting this property
    public var lastPageIndicator: UIImageView?

    public var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.alwaysBounceHorizontal = false
        return scrollView
    }()
    public var pageControl: UIPageControl = {
        var pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPage = Constants.startingPage
        pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.6980392157, green: 0.6980392157, blue: 0.6980392157, alpha: 1)
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.937254902, green: 0.2392156863, blue: 0.3098039216, alpha: 1)
        pageControl.isUserInteractionEnabled = true
        return pageControl
    }() {
        didSet {
            self.viewDidLayoutSubviews()
        }
    }

    init(
        indicatorColor: UIColor = .red,
        pageControlBackgroundColor: UIColor = .clear,
        initialPage: Int = 0,
        dotSize: CGFloat = 7,
        pageControlConstraints: @escaping (SimplePagedView) -> ([NSLayoutConstraint])
            = SimplePagedView.defaultPageControlConstraints,
        with views: UIView...
    ) {
        self.pageControlConstraints = pageControlConstraints
        self.initialPage = initialPage
        self.dotSize = dotSize
        super.init(nibName: nil, bundle: nil)
        self.innerPages = setupInnerPages(for: views)
        self.pageControl.currentPageIndicatorTintColor = indicatorColor
        self.pageControl.backgroundColor = pageControlBackgroundColor
    }

    init(
        indicatorColor: UIColor = .red,
        pageControlBackgroundColor: UIColor = .clear,
        initialPage: Int = 0,
        dotSize: CGFloat = 7,
        pageControlConstraints: @escaping (SimplePagedView) -> ([NSLayoutConstraint])
            = SimplePagedView.defaultPageControlConstraints,
        with views: [UIView]
    ) {
        self.pageControlConstraints = pageControlConstraints
        self.initialPage = initialPage
        self.dotSize = dotSize
        super.init(nibName: nil, bundle: nil)
        self.innerPages = setupInnerPages(for: views)
        self.pageControl.currentPageIndicatorTintColor = indicatorColor
        self.pageControl.backgroundColor = pageControlBackgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        super.loadView()

        self.setupSubviews()
        self.setupConstraints()
        self.scrollView.delegate = self
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.didSwitchPages?(0)

        self.setupGestures()
        self.viewDidLayoutSubviews()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !self.didInit {
            self.didInit = true
            self.scrollTo(page: self.initialPage, animated: false)
            self.pageControl.currentPage = self.initialPage
        }

        var lastFrame: CGRect = self.lastPageIndicator?.frame ?? .zero
        lastFrame.origin = CGPoint(x: self.pageControl.frame.origin.x, y: self.pageControl.frame.origin.y)

        self.pageControl.subviews.enumerated().forEach { index, subview in
            let currentFrame = subview.frame

            if let lastPageIndicator = self.lastPageIndicator,
                (subview as? UIImageView != nil || index == self.pageControl.numberOfPages - 1) {
                subview.removeFromSuperview()
                let newFrame = CGRect(
                    x: lastFrame.origin.x + dotSize + 11,
                    y: lastFrame.origin.y - (lastPageIndicator.frame.height/2 - dotSize/2),
                    width: lastPageIndicator.frame.width,
                    height: lastPageIndicator.frame.height
                )

                self.lastPageIndicator?.frame = newFrame
                self.lastPageIndicator?.image = lastPageIndicator.image?.tint(
                    with: self.pageControl.pageIndicatorTintColor!
                )

                pageControl.addSubview(self.lastPageIndicator!)
            } else {
                subview.frame = CGRect(
                    x: currentFrame.origin.x,
                    y: currentFrame.origin.y,
                    width: dotSize,
                    height: dotSize
                )
                lastFrame = subview.frame
            }
        }
    }

    /// Scrolls to the given page
    ///
    /// - Parameters:
    ///   - page: <#page description#>
    ///   - animated: <#animated description#>
    public func scrollTo(page: Int, animated: Bool) {
        self.scrollView.setContentOffset(
            CGPoint(x: CGFloat(Int(scrollView.frame.size.width) * page), y: 0),
            animated: animated
        )
        pageControl.currentPage = page
        self.viewDidLayoutSubviews()
    }

    @objc func panned(sender: UIPanGestureRecognizer) {
        let cgNumberOfPages: CGFloat = CGFloat(self.pageControl.numberOfPages)
        var page: Int = Int(floor(Double((sender.location(in: self.view).x/pageControl.frame.width) * cgNumberOfPages)))

        page = (page >= pageControl.numberOfPages)
            ? pageControl.numberOfPages - 1
            : (page < 0)
            ? 0
            : page

        scrollTo(page: page, animated: false)
    }
}

// MARK: - View Setup
fileprivate extension SimplePagedView {

    fileprivate func setupInnerPages(for views: [UIView]) -> [UIView] {
        if views.count == 0 {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .white
            return [view]
        }

        return views.map { $0.translatesAutoresizingMaskIntoConstraints = false; return $0 }
    }

    fileprivate func setupGestures() {
        if pageIndicatorIsInteractive {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panned(sender:)))

            panGestureRecognizer.maximumNumberOfTouches = 1
            panGestureRecognizer.minimumNumberOfTouches = 1

            pageControl.addGestureRecognizer(panGestureRecognizer)
        }
    }

    fileprivate func setupSubviews() {
        let customView = ExternallyInteractiveUIView(frame: self.view.frame)
        self.view = customView

        self.view.addSubview(scrollView)
        self.scrollView.addSubview(scrollContentView)

        for page in innerPages {
            scrollContentView.addSubview(page)
        }

        pageControl.numberOfPages = innerPages.count
        self.view.addSubview(pageControl)
    }

    // swiftlint:disable next function_body_length
    fileprivate func setupConstraints() {
        let scrollViewConstraints = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        let innerViewConstraints = [
            scrollContentView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            scrollContentView.heightAnchor.constraint(equalTo: view.heightAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CGFloat(innerPages.count)),
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ]

        let pageConstraints: [NSLayoutConstraint] = {
            var widthConstraints: [NSLayoutConstraint] = []
            var heightConstraints: [NSLayoutConstraint] = []
            var leadingEdgeConstraints: [NSLayoutConstraint] = []
            var topConstraints: [NSLayoutConstraint] = []
            var bottomConstraints: [NSLayoutConstraint] = []

            for page in innerPages {
                widthConstraints.append(page.widthAnchor.constraint(equalTo: view.widthAnchor))
                heightConstraints.append(page.heightAnchor.constraint(equalTo: view.heightAnchor))
            }

            leadingEdgeConstraints.append(innerPages[0].leadingAnchor.constraint(equalTo: scrollView.leadingAnchor))

            for index in 1..<innerPages.count {
                leadingEdgeConstraints.append(innerPages[index].leadingAnchor.constraint(
                    equalTo: innerPages[index-1].trailingAnchor)
                )
            }

            for page in innerPages {
                topConstraints.append(page.topAnchor.constraint(equalTo: scrollView.topAnchor))
                bottomConstraints.append(page.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor))
            }

            let allConstraints = Array([
                widthConstraints,
                heightConstraints,
                leadingEdgeConstraints,
                topConstraints,
                bottomConstraints
                ].joined())
            return allConstraints
        }()

        NSLayoutConstraint.activate(
            scrollViewConstraints,
            innerViewConstraints,
            self.pageControlConstraints(self),
            pageConstraints
        )
    }
}

// MARK: - UIScrollViewDelegate Methods
extension SimplePagedView: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        self.pageControl.currentPage = page
        self.didSwitchPages?(page)
        self.viewDidLayoutSubviews()

        if let lastPageIndicator = self.lastPageIndicator,
            self.pageControl.currentPage == self.pageControl.numberOfPages - 1 {
            self.lastPageIndicator?.image = lastPageIndicator.image?.tint(
                with: self.pageControl.currentPageIndicatorTintColor!
            )
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.viewDidLayoutSubviews()
    }
}
