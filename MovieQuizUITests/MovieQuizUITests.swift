//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Mike Somov on 04.12.2024.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        
        try super.tearDownWithError()
        app.terminate()
        app = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testYesButton() {
        sleep(3)

        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        _ = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        _ = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPoster, secondPoster)
    }
    
    func testAlertPresenter() {
        sleep(3)
        app.buttons["Yes"].tap()
        
        sleep(3)
        app.buttons["No"].tap()
        
        sleep(3)
        app.buttons["Yes"].tap()
        
        sleep(3)
        app.buttons["No"].tap()
        
        sleep(3)
        app.buttons["Yes"].tap()
        
        sleep(3)
        app.buttons["No"].tap()
        
        sleep(3)
        app.buttons["Yes"].tap()
        
        sleep(3)
        app.buttons["No"].tap()
        
        sleep(3)
        app.buttons["Yes"].tap()
        
        sleep(3)
        app.buttons["No"].tap()
        
        sleep(5)
        
        let alert = app.alerts["GameResultAlert"]
        
        sleep(3)
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз")
    }
}
