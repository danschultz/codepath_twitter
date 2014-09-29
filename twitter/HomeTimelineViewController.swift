//
//  ViewController.swift
//  twitter
//
//  Created by Dan Schultz on 9/25/14.
//  Copyright (c) 2014 Dan Schultz. All rights reserved.
//

import UIKit

class HomeTimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tweetsTableView: UITableView!
    var refreshControl: UIRefreshControl?
    
    var tweets: [Tweet]?
    
    private var selectedTweet: Tweet?
    
    private var twitterClient = TwitterClient.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        tweetsTableView.dataSource = self
        tweetsTableView.delegate = self
        
        var refreshControl = UIRefreshControl()
        tweetsTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "handleRefreshRequest:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    func reloadTweets() {
        if let lastTweet = tweets?.first {
            twitterClient.homeTimelineAfterTweetWithId(lastTweet.id) { (tweets, error) in
                if (tweets != nil) {
                    for tweet in tweets.reverse() {
                        self.tweets?.insert(tweet, atIndex: 0)
                    }
                    
                    self.tweetsTableView.reloadData()
                }
                
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Actions
    func handleRefreshRequest(sender: UIRefreshControl) {
        reloadTweets()
    }

    // MARK: - Table View Shiz
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets != nil ? tweets!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as TweetTableViewCell
        if let loadedTweets = tweets {
            cell.tweet = loadedTweets[indexPath.row]
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let loadedTweets = tweets {
            selectedTweet = loadedTweets[indexPath.row]
            performSegueWithIdentifier("HomeTimelineToTweet", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if (segue.identifier == "HomeTimelineToTweet") {
            var tweetViewController = segue.destinationViewController as TweetViewController
            tweetViewController.tweet = selectedTweet
        }
    }
}

