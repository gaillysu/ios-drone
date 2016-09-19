//
//  PagingMenuOptions.swift
//  PagingMenuController
//
//  Created by Yusuke Kita on 5/17/15.
//  Copyright (c) 2015 kitasuke. All rights reserved.
//

import UIKit

open class PagingMenuOptions {
    open var defaultPage = 0
    open var scrollEnabled = true // in case of using swipable cells, set false
    open var backgroundColor = UIColor.white
    open var selectedBackgroundColor = UIColor.white
    open var textColor = UIColor.lightGray
    open var selectedTextColor = UIColor.black
    open var font = UIFont.systemFont(ofSize: 16)
    open var selectedFont = UIFont.systemFont(ofSize: 16)
    open var menuPosition: MenuPosition = .top
    open var menuHeight: CGFloat = 50
    open var menuItemMargin: CGFloat = 20
    open var menuItemDividerImage: UIImage?
    open var animationDuration: TimeInterval = 0.3
    open var deceleratingRate: CGFloat = UIScrollViewDecelerationRateFast
    open var menuDisplayMode = MenuDisplayMode.standard(widthMode: PagingMenuOptions.MenuItemWidthMode.flexible, centerItem: false, scrollingMode: PagingMenuOptions.MenuScrollingMode.pagingEnabled)
    open var menuSelectedItemCenter = true
    open var menuItemMode = MenuItemMode.underline(height: 3, color: UIColor.blue, horizontalPadding: 0, verticalPadding: 0)
    open var lazyLoadingPage: LazyLoadingPage = .three
    open var menuControllerSet: MenuControllerSet = .multiple
    open var menuComponentType: MenuComponentType = .all
    internal var menuItemCount = 0
    internal let minumumSupportedViewCount = 1
    internal let dummyMenuItemViewsSet = 3
    internal var menuItemViewContent: MenuItemViewContent = .text
    
    public enum MenuPosition {
        case top
        case bottom
    }
    
    public enum MenuScrollingMode {
        case scrollEnabled
        case scrollEnabledAndBouces
        case pagingEnabled
    }
    
    public enum MenuItemWidthMode {
        case flexible
        case fixed(width: CGFloat)
    }
    
    public enum MenuDisplayMode {
        case standard(widthMode: MenuItemWidthMode, centerItem: Bool, scrollingMode: MenuScrollingMode)
        case segmentedControl
        case infinite(widthMode: MenuItemWidthMode, scrollingMode: MenuScrollingMode)
    }
    
    public enum MenuItemMode {
        case none
        case underline(height: CGFloat, color: UIColor, horizontalPadding: CGFloat, verticalPadding: CGFloat)
        case roundRect(radius: CGFloat, horizontalPadding: CGFloat, verticalPadding: CGFloat, selectedColor: UIColor)
    }
    
    public enum LazyLoadingPage {
        case one
        case three
    }
    
    public enum MenuControllerSet {
        case single
        case multiple
    }
    
    public enum MenuComponentType {
        case menuView
        case menuController
        case all
    }
    
    internal enum MenuItemViewContent {
        case text, image
    }
    
    public init() {}
}
