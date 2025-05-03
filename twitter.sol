// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Twitter {
    struct Tweet {
        uint256 tweetId;
        address author;
        string tweetContent;
        uint timestamp;
    }
    struct Message {
        uint256 messageId;
        string messageContent;
        address sender;
        address receiver;
        uint timestamp;
    }

    Tweet[] public allTweets;
    mapping(uint => Tweet) public tweets; // store all tweets
    mapping(address => Tweet) public tweetsOf; // store tweet of each user
    mapping(address => mapping(address => Message)) conversations;
    mapping(address => mapping(address => bool)) public operators;
    uint256 public tweetId;
    uint256 public messageId;

    //  mapping(address)

    // _tweet(address _from, string memory _content): Internal function to handle the tweeting logic.
    function _tweet(address _from, string memory _content) internal {
        Tweet memory newTweet = Tweet(
            tweetId,
            _from,
            _content,
            block.timestamp
        );
        allTweets.push(newTweet);
        tweetId++;
    }

    // _sendMessage(address _from, address _to, string memory _content): Internal function to handle messaging logic.

    function _sendMessage(
        address _from,
        address _to,
        string memory _content
    ) internal {}

    // tweet(string memory _content): Allows a user to post a tweet.
    function tweet(string memory _content) public {
        require(msg.sender != address(0), "address doesn't exits");
        require(bytes(_content).length > 0, "tweet cannot be empty");
        _tweet(msg.sender, _content);
    }

    // tweet(address _from, string memory _content): Allows an operator to post a tweet on behalf of a user.
    function tweetOnBehalf(address _from, string memory _content) public {}

    // sendMessage(string memory _content, address _to): Allows a user to send a message.
    function sendMessage(string memory _content, address _to) public {}

    // sendMessage(address _from, address _to, string memory _content): Allows an operator to send a message on behalf of a user.
    function sendMessage(
        address _from,
        address _to,
        string memory _content
    ) public {}

    // follow(address _followed): Allows a user to follow another user.
    function follow(address _followed) public {}

    // allow(address _operator): Allows a user to authorize an operator.
    function allow(address _operator) public {}

    // disallow(address _operator): Allows a user to revoke an operator's authorization.
    function disallow(address _operator) public {}

    // getLatestTweets(uint count): Returns the latest tweets across all users.
    function getLatestTweets(uint _count) public {}

    // getLatestTweetsOf(address user, uint count): Returns the latest tweets of a specific user.
    function getLatestTweetsOf(address _user, uint _count) public {}

    // following: A mapping to store the list of users that each user follows.
}
