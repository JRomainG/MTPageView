<p align="center">
	<img src="resources/icon.png?raw=true">
</p>

MTPageView is a multi-tab controller built using a UIScrollView.

![demo](resources/demo.gif "Demo")

<h3 align="center">Features</h3>

- Manage tabs by adding, removing or reordering them,
- Rapidly scroll past multiple tabs when handling many of them,
- Switch tab without zooming out by swiping with 2 fingers from the edge of the screen,
- Save space by hiding the bars when scrolling through a view's content,
- "Protect" some tabs from being reordered or removed,
- Customize the navigation bar and the toolbars displayed in each state,
- Handle many tabs thanks to a custom UIPageControl that handles displaying any given number of dots.

<h3 align="center">Installing</h3>

- Copy the whole "MTPageView" folder and the license to your workspace,
- If you are using a storyboard, embed your view controller in a navigation controller and change the navigation controller's navigation bar class to MTNavigationBar.

See the MTPageViewExample sample project for an example of implementation.

<h3 align="center">Usage</h3>
MTPageView is used in [Tob](https://github.com/JRock007/Tob), an open source Tor browser for iOS.