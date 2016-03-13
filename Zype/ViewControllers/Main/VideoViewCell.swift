//
//  VideoViewCell.swift
//  Zype
//
//  Created by Pavel Pantus on 3/12/16.
//  Copyright © 2016 Pavel Pantus. All rights reserved.
//

import UIKit
import SDWebImage
import CocoaLumberjack

final class VideoViewCell: UITableViewCell {
    private var title: UILabel!
    private var videoID: String!
    private var imageContainer: UIView!
    private var bgImage: UIImageView!
    private var spinner: UIActivityIndicatorView!
    private var separator: UIView!
    private var centerConstraint: NSLayoutConstraint!
    private let padding: CGFloat = 16

    static let cellIdentifier = "VideoViewCell"
    static let preferredHeight: CGFloat = 250.0


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFontOfSize(20, weight: UIFontWeightRegular)
        title.numberOfLines = 2
        title.lineBreakMode = .ByCharWrapping
        title.textAlignment = .Left
        title.textColor = UIColor.whiteColor()

        imageContainer = UIView()
        imageContainer.clipsToBounds = true
        imageContainer.translatesAutoresizingMaskIntoConstraints = false

        bgImage = UIImageView(frame: CGRectZero)
        bgImage.accessibilityIdentifier = "bgImage"
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        bgImage.contentMode = .ScaleAspectFill

        imageContainer.addSubview(bgImage)

        spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidden = true

        separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.lightGrayColor()

        contentView.addSubview(imageContainer)
        contentView.addSubview(title)
        contentView.addSubview(spinner)
        contentView.addSubview(separator)

        do {
            let views = ["title": title, "bgImage": bgImage, "spinner": spinner, "separator": separator, "ic": imageContainer]
            let metrics: [String: AnyObject] = ["p": padding, "dp": 2 * padding, "lw": 0.5]

            imageContainer.addConstraint(NSLayoutConstraint(item: bgImage, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: imageContainer, attribute: .Width, multiplier: 1.0, constant: 0))
            imageContainer.addConstraint(NSLayoutConstraint(item: bgImage, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: imageContainer, attribute: .Height, multiplier: 1.0, constant: imageSizeConstant()))

            centerConstraint = NSLayoutConstraint(item: bgImage, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: imageContainer, attribute: .CenterY, multiplier: 1.0, constant: (imageSizeConstant() / 2))
            imageContainer.addConstraint(NSLayoutConstraint(item: bgImage, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: imageContainer, attribute: .CenterX, multiplier: 1.0, constant: 0))
            imageContainer.addConstraint(centerConstraint)

            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-p-[ic]-p-|", options: [], metrics: metrics, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-p-[ic]-p-|", options: [], metrics: metrics, views: views))

            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-dp-[title]-dp-|", options: [], metrics: metrics, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[title]-dp-|", options: [], metrics: metrics, views: views))

            contentView.addConstraint(NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0))
            contentView.addConstraint(NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0))

            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[separator]|", options: [], metrics: metrics, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[separator(lw)]|", options: [], metrics: metrics, views: views))
        }
    }

    func imageSizeConstant() -> CGFloat {
        return 0.6 * (VideoViewCell.preferredHeight - 2 * CGFloat(padding))
    }

    func setBackgroundOffset(offset: CGFloat) {
        if let centerConstraint = centerConstraint {
            let newConstant = centerConstraint.constant - (offset / 3)
            let shouldBeApplied =  newConstant > -(imageSizeConstant() / 2) && newConstant < (imageSizeConstant() / 2)

            if shouldBeApplied {
                centerConstraint.constant = newConstant
            }
        }
    }

    func setVideo(video: Video) {
        if video.identifier != videoID {
            videoID = video.identifier
            centerConstraint.constant = 0

            spinner.hidden = false;
            spinner.startAnimating()
            let thURL = NSURL(string: video.thumbnail ?? "")
            bgImage.sd_setImageWithURL(thURL, placeholderImage: UIImage(named: "placeholder")!) { (_, _, _, _) in
                self.spinner.stopAnimating()
                self.spinner.hidden = true
            }

            let attrStr = NSMutableAttributedString(string: video.title!)
            attrStr.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, video.title!.characters.count))
            title.attributedText = attrStr
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
