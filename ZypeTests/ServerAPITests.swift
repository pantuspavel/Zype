//
//  ServerAPITests.swift
//  Zype
//
//  Created by Pavel Pantus on 3/12/16.
//  Copyright © 2016 Pavel Pantus. All rights reserved.
//

import XCTest
import OHHTTPStubs
import CocoaLumberjack
@testable import Zype

class ServerAPITests: XCTestCase {
    override func setUp() {
        super.setUp()

        OHHTTPStubs.onStubActivation { (request, stub) -> Void in
            DDLogInfo("\(request.URL!) stubbed by '\(stub.name!)'")
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()

        super.tearDown()
    }

    func testVideosSelect() {
        installSelectResponseStub()

        let expectation = expectationWithDescription("Video Select")

        ServerAPI.selectVideos(page: 1) { (count, error) in
            expectation.fulfill()
            XCTAssertNil(error)
            XCTAssertEqual(VideosModel.sharedInstance.count(), 2)
            XCTAssertEqual(count, 2)

            let videos = VideosModel.sharedInstance.videos()
            XCTAssertEqual(videos!.count, 2)

            let video0 = videos![0]
            XCTAssertEqual(video0.title, "Satellite Dish")
            XCTAssertEqual(video0.identifier, "5539359269702d0707401e00")
            XCTAssertEqual(video0.thumbnail, "http://t.zype.com/54be807269702d070cf27800/5539359269702d0707401e00/5539359269702d0707411e00/545bd6ca69702d05b9010000/00001.png")

            let video1 = videos![1]
            XCTAssertEqual(video1.title, "NYC 30 Rock")
            XCTAssertEqual(video1.identifier, "564e263a7a797056992f0000")
            XCTAssertEqual(video1.thumbnail, "http://t.zype.com/54be807269702d070cf27800/5539353c69702d0705601e00/5539353c69702d0705611e00/545bd6ca69702d05b9010000/00001.png")

            OHHTTPStubs.removeAllStubs()
        }

        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testBadResponse() {
        installBadResponseStub()

        let expectation = expectationWithDescription("Bad response")

        ServerAPI.selectVideos(page: 1) { (count, error) in
            expectation.fulfill()

            XCTAssertEqual(VideosModel.sharedInstance.count(), 0)
            XCTAssertEqual(count, 0)
            XCTAssertNotNil(error)
            XCTAssertTrue(error is NSError)
            XCTAssertEqual((error as! NSError).code, 0)

            OHHTTPStubs.removeAllStubs()
        }

        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testEmptyResponse() {
        installEmptyResponseStub()

        let expectation = expectationWithDescription("Empty response")

        ServerAPI.selectVideos(page: 1) { (count, error) in
            expectation.fulfill()

            XCTAssertEqual(VideosModel.sharedInstance.count(), 0)
            XCTAssertEqual(count, 0)
            XCTAssertNotNil(error)
            XCTAssertTrue(error is NSError)
            XCTAssertEqual((error as! NSError).code, 0)

            OHHTTPStubs.removeAllStubs()
        }

        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    // MARK: stubs

    func installEmptyResponseStub() {
        stub({ (request) -> Bool in
            true
        }) { (response) -> OHHTTPStubsResponse in
            let responseData : [String: AnyObject] = [:]
            return OHHTTPStubsResponse(JSONObject: responseData, statusCode: 200, headers: nil)
            }.name = "Empty Response Stub"
    }

    func installBadResponseStub() {
        stub({ (request) -> Bool in
            true
        }) { (response) -> OHHTTPStubsResponse in
            let responseData : [String: AnyObject] = ["response" : ["a": "b", "c": "d"]]
            return OHHTTPStubsResponse(JSONObject: responseData, statusCode: 200, headers: nil)
            }.name = "Bad Response Stub"
    }

    func installSelectResponseStub() {
        stub({ (request) -> Bool in
            true
        }) { (response) -> OHHTTPStubsResponse in
            let responseData : [String: AnyObject] =
                ["response": [  [   "_id": "564e263a7a797056992f0000",
                                    "title": "NYC 30 Rock",
                                    "thumbnails": [
                                        ["url": "http://t.zype.com/54be807269702d070cf27800/5539353c69702d0705601e00/5539353c69702d0705611e00/545bd6ca69702d05b9010000/00001.png"],
                                        ["url": "http://t.zype.com/54be807269702d070cf27800/5539353c69702d0705601e00/5539353c69702d0705611e00/545bdab169702d05bc010000/00001.png"]]],
                                [   "_id": "5539359269702d0707401e00",
                                    "title": "Satellite Dish",
                                    "thumbnails": [
                                        ["url": "http://t.zype.com/54be807269702d070cf27800/5539359269702d0707401e00/5539359269702d0707411e00/545bd6ca69702d05b9010000/00001.png"],
                                        ["url": "http://t.zype.com/54be807269702d070cf27800/5539359269702d0707401e00/5539359269702d0707411e00/545bdab169702d05bc010000/00001.png"]]]
                    ]]
            return OHHTTPStubsResponse(JSONObject: responseData, statusCode: 200, headers: nil)
            }.name = "Videos Select Stub"
    }
}

