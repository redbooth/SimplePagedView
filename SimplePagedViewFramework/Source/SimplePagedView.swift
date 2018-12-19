import UIKit

public class SimplePagedView: UIViewController {

    // MARK: - Properties
    public static let defaultPageControlConstraints: (PageDotsView, SimplePagedView) -> ([NSLayoutConstraint])
        = { (dotsView: PageDotsView, pagedViewController: SimplePagedView) in
            return [
                dotsView.bottomAnchor.constraint(equalTo: pagedViewController.scrollView.bottomAnchor),
                dotsView.centerXAnchor.constraint(
                    equalTo: pagedViewController.view.centerXAnchor
                ),
                dotsView.leadingAnchor.constraint(equalTo: pagedViewController.view.leadingAnchor),
                dotsView.trailingAnchor.constraint(equalTo: pagedViewController.view.trailingAnchor),
                dotsView.heightAnchor.constraint(equalToConstant: 44)
            ]
    }

    fileprivate enum Constants {
        static let startingPage = 0
        static let pageControllerSpacing: CGFloat = -10
    }

    fileprivate var scrollContentView: UIView = {
        var scrollingView = UIView()
        scrollingView.translatesAutoresizingMaskIntoConstraints = false
        return scrollingView
    }()
    fileprivate var innerPages: [UIView]!
    fileprivate let pageControlConstraints: (PageDotsView, SimplePagedView) -> ([NSLayoutConstraint])
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
    public var pageControl: PageDotsView = {
        var pageControl = PageDotsView(count: 0, frame: .zero)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    public init(
        indicatorColor: UIColor = .red,
        pageControlBackgroundColor: UIColor = .clear,
        initialPage: Int = 0,
        dotSize: CGFloat = 7,
        pageControlConstraints: @escaping (PageDotsView, SimplePagedView) -> ([NSLayoutConstraint])
            = SimplePagedView.defaultPageControlConstraints,
        with views: UIView...
    ) {
        self.pageControlConstraints = pageControlConstraints
        self.initialPage = initialPage
        self.dotSize = dotSize
        super.init(nibName: nil, bundle: nil)
        self.innerPages = setupInnerPages(for: views)

        self.pageControl = setupPageDotsView(
            numberOfDots: self.innerPages.count,
            color: .gray,
            currentColor: indicatorColor,
            dotSize: dotSize,
            currentDot: initialPage
        )

        self.pageControl.backgroundColor = pageControlBackgroundColor
    }

    public init(
        indicatorColor: UIColor = .red,
        pageControlBackgroundColor: UIColor = .clear,
        initialPage: Int = 0,
        dotSize: CGFloat = 7,
        pageControlConstraints: @escaping (PageDotsView, SimplePagedView) -> ([NSLayoutConstraint])
            = SimplePagedView.defaultPageControlConstraints,
        with views: [UIView]
    ) {
        self.pageControlConstraints = pageControlConstraints
        self.initialPage = initialPage
        self.dotSize = dotSize
        super.init(nibName: nil, bundle: nil)
        self.innerPages = setupInnerPages(for: views)

        self.pageControl = setupPageDotsView(
            numberOfDots: self.innerPages.count,
            color: .gray,
            currentColor: indicatorColor,
            dotSize: dotSize,
            currentDot: initialPage
        )

        self.pageControl.backgroundColor = pageControlBackgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupConstraints()
        self.scrollView.delegate = self
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.didSwitchPages?(0)

        self.setupGestures(pageControl: self.pageControl)
        self.viewDidLayoutSubviews()
    }

    /// Scrolls to the given page
    ///
    /// - Parameters:
    ///   - page: 0 indexed page number
    ///   - animated: should the scrolling be animated
    public func scrollTo(page: Int, animated: Bool) {
        self.scrollView.setContentOffset(
            CGPoint(x: CGFloat(Int(scrollView.frame.size.width) * page), y: 0),
            animated: animated
        )

        let newPageControl = try! pageControl.moveTo(index: page)

        self.replace(subview: self.pageControl, with: newPageControl, constraints: self.pageControlConstraints)
    }

    @objc func panned(sender: UIPanGestureRecognizer) {
        print("panned")
        let cgNumberOfPages: CGFloat = CGFloat(self.innerPages.count)
        var page: Int = Int(floor(Double((sender.location(in: self.view).x/pageControl.frame.width) * cgNumberOfPages)))

        page = (page >= self.innerPages.count)
            ? self.innerPages.count - 1
            : (page < 0)
            ? 0
            : page

        scrollTo(page: page, animated: false)
    }
}

// MARK: - View Setup
fileprivate extension SimplePagedView {

    func setupInnerPages(for views: [UIView]) -> [UIView] {
        if views.count == 0 {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .white
            return [view]
        }

        return views.map { $0.translatesAutoresizingMaskIntoConstraints = false; return $0 }
    }

    func setupGestures(pageControl: PageDotsView) {
        if pageIndicatorIsInteractive {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panned(sender:)))

            panGestureRecognizer.maximumNumberOfTouches = 1
            panGestureRecognizer.minimumNumberOfTouches = 1

            pageControl.addGestureRecognizer(panGestureRecognizer)
        }
    }

    func setupSubviews() {
        let customView = ExternallyInteractiveUIView(frame: self.view.frame)
        self.view = customView

        self.view.addSubview(scrollView)
        self.scrollView.addSubview(scrollContentView)

        for page in innerPages {
            scrollContentView.addSubview(page)
        }

//        pageControl.numberOfPages = innerPages.count
        self.view.addSubview(pageControl)
    }

    // swiftlint:disable next function_body_length
    func setupConstraints() {
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
            self.pageControlConstraints(self.pageControl, self),
            pageConstraints
        )
    }

    func setupPageDotsView(numberOfDots: Int, color: UIColor, currentColor: UIColor, dotSize: CGFloat, currentDot: Int) -> PageDotsView {
        let view = PageDotsView(count: numberOfDots, dotColor: color, currentDotColor: currentColor, dotSize: dotSize, currentDot: currentDot, frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "PageDotsView"

        view.frame = CGRect(x: 0, y: 0, width: view.intrinsicContentSize.width, height: view.intrinsicContentSize.height)

        return view
    }
}

// MARK: - UIScrollViewDelegate Methods
extension SimplePagedView: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        let newPageControl = try! self.pageControl.moveTo(index: page)

        self.replace(subview: self.pageControl, with: newPageControl, constraints: self.pageControlConstraints)

        self.didSwitchPages?(page)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.viewDidLayoutSubviews()
    }

    func replace(subview: PageDotsView, with other: PageDotsView, constraints: (PageDotsView, SimplePagedView) -> [NSLayoutConstraint]) {
        let newConstraints = constraints(other, self)
        subview.removeFromSuperview()

        setupGestures(pageControl: other)

        self.view.addSubview(other)
        NSLayoutConstraint.activate(newConstraints)

        self.pageControl = other
    }
}
