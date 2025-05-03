// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Twitter {
    struct Tweet {
        uint256 tweetId;
        address author;
        string tweetContent;
        uint256 createdAt;
    }
    struct Message {
        uint256 messageId;
        string messageContent;
        address sender;
        address receiver;
        uint256 createdAt;
    }

    mapping(uint256 => Tweet) tweets; // store all tweets
    mapping(address => uint256[]) tweetsOf; // store tweet of each user
    mapping(address => Message[]) conversations;
    mapping(address => mapping(address => bool)) operators;

    mapping(address => address[]) public following;

    uint256 nextTweetId = 0;
    uint256 nextMessageId = 0;

    // _tweet(address _from, string memory _content): Internal function to handle the tweeting logic.
    function _tweet(address _from, string memory _content) internal {
        tweets[nextTweetId] = Tweet(
            nextTweetId,
            _from,
            _content,
            block.timestamp
        );
        tweetsOf[_from].push(nextTweetId);
        nextTweetId++;
    }

    // _sendMessage(address _from, address _to, string memory _content): Internal function to handle messaging logic.
    function _sendMessage(
        address _from,
        address _to,
        string memory _content
    ) internal {
        conversations[_from].push(
            Message(nextMessageId, _content, _from, _to, block.timestamp)
        );

        nextMessageId++;
    }

    // tweet(string memory _content): Allows a user to post a tweet.
    function tweet(string memory _content) public emptyContent(_content) {
        _tweet(msg.sender, _content);
    }

    modifier isAuthorized(address _from) {
        require(operators[_from][msg.sender] == true, "Unauthorized");
        _;
    }
    modifier emptyContent(string memory _content) {
        require(bytes(_content).length > 0, "Content can't be empty");
        _;
    }
    modifier invalidAddress(address _to) {
        require(_to != address(0), "operator address is invalid");
        _;
    }

    // tweet(address _from, string memory _content): Allows an operator to post a tweet on behalf of a user.
    function tweetOnBehalf(
        address _from,
        string memory _content
    ) public isAuthorized(_from) {
        _tweet(_from, _content);
    }

    // sendMessage(string memory _content, address _to): Allows a user to send a message.
    function sendMessage(
        string memory _content,
        address _to
    ) public invalidAddress(_to) {
        _sendMessage(msg.sender, _to, _content);
    }

    // sendMessage(address _from, address _to, string memory _content): Allows an operator to send a message on behalf of a user.
    function sendMessageOnBehalf(
        address _from,
        address _to,
        string memory _content
    ) public isAuthorized(_from) {
        _sendMessage(_from, _to, _content);
    }

    // follow(address _followed): Allows a user to follow another user.
    function follow(address _address) public invalidAddress(_address) {
        following[msg.sender].push(_address);
    }

    // unfollow function

    function unfollow(address _address) public invalidAddress(_address) {
        address[] storage followingList = following[msg.sender];

        for (uint256 i = 0; i < followingList.length; i++) {
            if (followingList[i] == _address) {
                for (uint256 j = i; j < followingList.length - 1; j++) {
                    followingList[j] = followingList[j + 1];
                }
                followingList.pop(); // Remove the last duplicate
                break; // Exit after removing the address
            }
        }
    }

    // allow(address _operator): Allows a user to authorize an operator.
    function allow(address _operator) public invalidAddress(_operator) {
        operators[msg.sender][_operator] = true;
    }

    // disallow(address _operator): Allows a user to revoke an operator's authorization.
    function disallow(address _operator) public invalidAddress(_operator) {
        operators[msg.sender][_operator] = false;
    }

    // getLatestTweets(uint count): Returns the latest tweets across all users.
    function getLatestTweets(
        uint256 _count
    ) public view returns (Tweet[] memory) {
        Tweet[] memory latestTweets = new Tweet[](_count);

        require(_count <= nextTweetId, "Cannot surpass tweetsLenght");
        uint256 start = nextTweetId - _count;
        for (uint256 i = 0; i < latestTweets.length; i++) {
            latestTweets[i] = tweets[start + i];
        }
        return latestTweets;
    }

    // getLatestTweetsOf(address user, uint count): Returns the latest tweets of a specific user.
    function getLatestTweetsOf(
        address _user,
        uint256 _count
    ) public view returns (Tweet[] memory) {
        uint256[] storage userTweetIds = tweetsOf[_user];
        require(
            _count <= userTweetIds.length,
            "Count exceeds user's tweet count"
        );

        Tweet[] memory latestTweetsOf = new Tweet[](_count);

        uint256 start = userTweetIds.length - _count;
        for (uint256 i = 0; i < _count; i++) {
            uint256 tweetId = userTweetIds[start + i];
            latestTweetsOf[i] = tweets[tweetId];
        }
        return latestTweetsOf;
    }

    function getMessagesOf(
        address _user
    ) public view returns (Message[] memory) {
        Message[] storage messagesReference = conversations[_user];
        Message[] memory messagesOf = new Message[](messagesReference.length);

        for (uint256 i = 0; i < messagesOf.length; i++) {
            messagesOf[i] = messagesReference[i];
        }
        return messagesOf;
    }

    function getFollowingList() public view returns (address[] memory) {
        address[] storage addressReference = following[msg.sender];
        address[] memory addresses = new address[](addressReference.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            addresses[i] = addressReference[i];
        }
        return addresses;
    }
}
