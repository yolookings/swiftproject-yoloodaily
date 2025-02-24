//
//  yoloodailyUITests.swift
//  yoloodailyUITests
//
//  Created by Maulana Ahmad Zahiri on 14/02/25.
//

import XCTest

final class yoloodailyUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    func testLoginFlow() throws {
        // Navigasi ke screen login
        app.tabBars.buttons["Profile"].tap()
        app.buttons["Login"].tap()
        
        // Mengisi form login
        let emailField = app.textFields["emailField"]
        let passwordField = app.secureTextFields["passwordField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("testuser@example.com")
        
        passwordField.tap()
        passwordField.typeText("Test1234!")
        
        loginButton.tap()
        
        // Verifikasi login berhasil
        XCTAssertTrue(app.staticTexts["Welcome, Test User!"].waitForExistence(timeout: 5))
    }
    
    func testContentCreationFlow() throws {
        // Membuat konten baru
        app.buttons["createNewButton"].tap()
        
        let titleField = app.textFields["titleField"]
        let contentField = app.textViews["contentField"]
        let publishButton = app.buttons["publishButton"]
        
        titleField.tap()
        titleField.typeText("Test Content Title")
        
        contentField.tap()
        contentField.typeText("This is a test content created through UI automation")
        
        publishButton.tap()
        
        // Verifikasi konten terpublikasi
        XCTAssertTrue(app.staticTexts["Test Content Title"].exists)
    }
    
    func testNavigationBetweenTabs() throws {
        // Test navigasi antar tab
        let tabBar = app.tabBars["MainTabBar"]
        
        tabBar.buttons["Home"].tap()
        XCTAssertTrue(app.collectionViews["homeFeed"].exists)
        
        tabBar.buttons["Explore"].tap()
        XCTAssertTrue(app.searchFields["searchField"].exists)
        
        tabBar.buttons["Notifications"].tap()
        XCTAssertTrue(app.staticTexts["Notifications"].exists)
        
        tabBar.buttons["Profile"].tap()
        XCTAssertTrue(app.buttons["Settings"].exists)
    }
    
    func testPullToRefresh() throws {
        // Test pull-to-refresh
        let homeFeed = app.collectionViews["homeFeed"]
        let firstCell = homeFeed.cells.firstMatch
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let end = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 1.0))
        
        start.press(forDuration: 0.1, thenDragTo: end)
        XCTAssertTrue(app.activityIndicators.element.exists)
    }
    
    func testAppearanceModeSwitch() throws {
        // Test ganti light/dark mode
        app.tabBars.buttons["Profile"].tap()
        app.buttons["Settings"].tap()
        
        let appearanceSwitch = app.switches["appearanceSwitch"]
        let initialValue = appearanceSwitch.value as? String
        
        appearanceSwitch.tap()
        let newValue = appearanceSwitch.value as? String
        
        XCTAssertNotEqual(initialValue, newValue)
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testCriticalUserJourney() throws {
        // Simulasi alur pengguna penting
        try testLoginFlow()
        try testContentCreationFlow()
        
        app.tabBars.buttons["Home"].tap()
        app.collectionViews["homeFeed"].cells.firstMatch.tap()
        
        XCTAssertTrue(app.buttons["likeButton"].exists)
        app.buttons["likeButton"].tap()
        
        XCTAssertTrue(app.staticTexts["1 likes"].exists)
    }
    
    func testErrorHandling() throws {
        // Test handling error
        app.tabBars.buttons["Profile"].tap()
        app.buttons["Login"].tap()
        
        let loginButton = app.buttons["loginButton"]
        loginButton.tap()
        
        XCTAssertTrue(app.alerts["Error"].exists)
        app.alerts["Error"].buttons["OK"].tap()
    }
}