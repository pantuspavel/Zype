//
//  MainTableViewController.swift
//  Zype
//
//  Created by Pavel Pantus on 3/11/16.
//  Copyright © 2016 Pavel Pantus. All rights reserved.
//

import UIKit
import CocoaLumberjack
import CoreData

class MainTableViewController: UITableViewController {
    private var fetching = false
    private var full = false
    private var lastContentOffset: CGFloat = 0
    private var frc: NSFetchedResultsController! {
        didSet {
            frc.delegate = self

            do {
                try frc.performFetch()
            } catch let error as NSError {
                DDLogError("Main VC: Perform fetch failed with error: \(error)")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(VideoViewCell.self, forCellReuseIdentifier: VideoViewCell.cellIdentifier)
        tableView.allowsSelection = false
        tableView.separatorColor = UIColor.clearColor()

        frc = VideosModel.sharedInstance.createFRC()
        if VideosModel.sharedInstance.count() == 0 {
            fetchMore()
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true;
    }

    private func fetchMore() {
        if (fetching == false && full == false) {
            fetching = true
            var nextPage = 1
            if let objects = frc.fetchedObjects {
                nextPage = objects.count / 10 + 1
            }
            ServerAPI.selectVideos(page: nextPage) { (count, error) in
                self.fetching = false
                self.full = count == 0
            }
        }
    }

    func setCellImageOffset(cell: VideoViewCell, indexPath: NSIndexPath) {
        let cellFrame = self.tableView.rectForRowAtIndexPath(indexPath)
        let cellFrameInTable = self.tableView.convertRect(cellFrame, toView:self.tableView.superview)
        let cellOffset = cellFrameInTable.origin.y + cellFrameInTable.size.height
        let tableHeight = self.tableView.bounds.size.height + cellFrameInTable.size.height
        let cellOffsetFactor = cellOffset / tableHeight

        cell.setBackgroundOffset(lastContentOffset > tableView.contentOffset.y ? cellOffsetFactor : -cellOffsetFactor)
    }

    func configureCell(cell: VideoViewCell, atIndexPath: NSIndexPath) {
        cell.setVideo(frc.objectAtIndexPath(atIndexPath) as! Video)
    }

    // MARK: UIScrollViewDelegate

    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if let paths = self.tableView.indexPathsForVisibleRows {
            for indexPath in paths {
                 setCellImageOffset(tableView.cellForRowAtIndexPath(indexPath) as! VideoViewCell, indexPath: indexPath)
            }
        }
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = frc.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }

        return 0
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = frc.sections {
            return sections.count
        }

        return 0
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.item == frc.fetchedObjects!.count - 1
            && fetching == false && full == false) {
            fetchMore()
        }

        setCellImageOffset(cell as! VideoViewCell, indexPath: indexPath)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return VideoViewCell.preferredHeight
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(VideoViewCell.cellIdentifier, forIndexPath: indexPath) as! VideoViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
}

extension MainTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! VideoViewCell
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .None)
            }
            break;
        }
    }
}