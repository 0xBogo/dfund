pragma solidity ^0.5.0;

import "../IERC20.sol";

interface RequestFactoryInterface {
    function createLendingRequest(uint256, uint256, string calldata, address payable) external returns(address);
    function createBorrowingOffer(uint256, uint256, string calldata, address payable) external returns(address);
}

interface LendingRequestInterface {
    function deposit(address payable) external payable returns(bool, bool);
    function withdraw(address) external;
    function cleanUp() external;
    function cancelRequest() external;
    function asker() external view returns(address payable);
    function lender() external view returns(address payable);
    function withdrawnByLender() external view returns(bool);
    function getRequestParameters() external view returns(address payable, address payable, address, uint256, uint256, uint256, string memory);
    function getRequestState() external view returns(bool, bool, bool, bool);
}

contract RequestManagement {
    event OfferCreated();
    event RequestCreated();
    event RequestGranted();
    event DebtPaid();
    event Withdraw();

    mapping(address => uint256) private requestIndex;
    mapping(address => uint256) private userRequestCount;
    mapping(address => bool) private validRequest;

    address private requestFactory;
    address[] private lendingRequests;
    address[] private borrowingOffers;

    mapping(address => uint256) public ratings;

    constructor(address _factory) public {
        requestFactory = _factory;
    }

    /**
     * @notice Creates a lending request for the amount you specified
     * @param _amount the amount you want to borrow in Wei
     * @param _paybackAmount the amount you are willing to pay back - has to be greater than _amount
     * @param _purpose the reason you want to borrow ether
     */
    function ask (uint256 _amount, uint256 _paybackAmount, string memory _purpose) public {
        // validate the input parameters
        // require(_tokenAddress != address(0), "token address is required.");
        require(_amount > 0, "invalid amount");
        require(_paybackAmount > _amount, "invalid payback");
        // require(lendingRequests[msg.sender].length < 5, "too many requests");
        require(userRequestCount[msg.sender] < 5, "too many requests");

        // create new lendingRequest
        address request = RequestFactoryInterface(requestFactory).createLendingRequest(
            // _tokenAddress,
            _amount,
            _paybackAmount,
            _purpose,
            msg.sender
        );

        // update number of requests for asker
        userRequestCount[msg.sender]++;
        // add created lendingRequest to management structures
        requestIndex[request] = lendingRequests.length;
        lendingRequests.push(request);
        // mark created lendingRequest as a valid request
        validRequest[request] = true;

        emit RequestCreated();
    }

    /**
     * @notice Creates a borrow offer for the amount you specified
     * @param _amount the amount you want to borrow in Wei
     * @param _paybackAmount the amount you are willing to pay back - has to be greater than _amount
     * @param _purpose the reason you want to borrow ether
     */
    function createOffer (uint256 _amount, uint256 _paybackAmount, string memory _purpose, address _collateralToken, uint256 _collateralAmount, uint256 _duration) public {
        // validate the input parameters
        // require(_tokenAddress != address(0), "token address is required.");
        require(_amount > 0, "invalid amount");
        require(_paybackAmount > _amount, "invalid payback");
        // require(lendingRequests[msg.sender].length < 5, "too many requests");
        require(userRequestCount[msg.sender] < 5, "too many requests");

        // create new lendingRequest
        address offer = RequestFactoryInterface(requestFactory).createBorrowingOffer(
            _amount,
            _paybackAmount,
            _purpose,
            msg.sender
    
            // _collateralToken
            // _collateralAmount
            // _duration
        );

        // update number of requests for asker
        userRequestCount[msg.sender]++;
        // add created lendingRequest to management structures
        requestIndex[offer] = borrowingOffers.length;
        borrowingOffers.push(offer);
        // mark created lendingRequest as a valid request
        validRequest[offer] = true;

        ratings[msg.sender]++;

        emit OfferCreated();
    }

    /**
     * @notice Lend or payback the ether amount of the lendingRequest (costs ETHER)
     * @param _lendingRequest the address of the lendingRequest you want to deposit ether in
     */
    function deposit(address payable _lendingRequest) public payable {
        // validate input
        require(validRequest[_lendingRequest], "invalid request");
        require(msg.value > 0, "invalid value");

        (bool lender, bool asker) = LendingRequestInterface(_lendingRequest).deposit.value(msg.value)(msg.sender);
        require(lender || asker, "Deposit failed");

        if (lender) {
            emit RequestGranted();
        } else if (asker) {
            emit DebtPaid();
        }
    }

    function wrappedDeposit(address payable _lendingRequest, address tokenAddress, uint256 askAmount) public payable {
        // validate input
        require(validRequest[_lendingRequest], "invalid request");
        require(msg.value > 0, "invalid value");

        deposit(_lendingRequest);

        IERC20(tokenAddress).transfer(_lendingRequest, askAmount);

        // (bool lender, bool asker) = LendingRequestInterface(_lendingRequest).deposit.value(msg.value)(msg.sender);
        // require(lender || asker, "Deposit failed");

        // if (lender) {
        //     emit RequestGranted();
        // } else if (asker) {
        //     emit DebtPaid();
        // }
    }

    /**
     * @notice withdraw Ether from the lendingRequest
     * @param _lendingRequest the address of the lendingRequest to withdraw from
     */
    function withdraw(address payable _lendingRequest) public {
        // validate input
        require(validRequest[_lendingRequest], "invalid request");

        LendingRequestInterface(_lendingRequest).withdraw(msg.sender);

        // if paybackAmount was withdrawn by lender reduce number of openRequests for asker
        if(LendingRequestInterface(_lendingRequest).withdrawnByLender()) {
            address payable asker = LendingRequestInterface(_lendingRequest).asker();
            // call selfdestruct of lendingRequest
            LendingRequestInterface(_lendingRequest).cleanUp();
            // remove lendingRequest from managementContract
            removeRequest(_lendingRequest, asker);
        }

        emit Withdraw();
    }

     function withdrawForOffer(address payable _lendingRequest) public {
        // validate input
        require(validRequest[_lendingRequest], "invalid request");

        LendingRequestInterface(_lendingRequest).withdraw(msg.sender);

        // if paybackAmount was withdrawn by lender reduce number of openRequests for asker
        if(LendingRequestInterface(_lendingRequest).withdrawnByLender()) {
            address payable lender = LendingRequestInterface(_lendingRequest).lender();
            // call selfdestruct of lendingRequest
            LendingRequestInterface(_lendingRequest).cleanUp();
            // remove lendingRequest from managementContract
            removeOfferRequest(_lendingRequest, lender);
        }

        emit Withdraw();
    }

    function withdrawCollateral(address payable _lendingRequest) public {
        require(validRequest[_lendingRequest], "invalid request");

        // address asker = LendingRequestInterface(_lendingRequest).withdrawCollateral(msg.sender);
        // if (asker != address(0)) {
        //     ratings[asker]--;
        // }
    }

    /**
     * @notice cancels the request
     * @param _lendingRequest the address of the request to cancel
     */
    function cancelRequest(address payable _lendingRequest) public {
        // validate input
        require(validRequest[_lendingRequest], "invalid Request");

        LendingRequestInterface(_lendingRequest).cancelRequest();
        removeRequest(_lendingRequest, msg.sender);

        emit Withdraw();
    }

    /**
     * @notice gets the lendingRequests for the specified user
     * @return all lendingRequests
     */
    function getRequests() public view returns(address[] memory) {
        return lendingRequests;
    }

    /**
     * @notice gets the borrowingOffers for the specified user
     * @return all borrowingOffers
     */
    function getOffers() public view returns(address[] memory) {
        return borrowingOffers;
    }

    /**
     * @notice gets askAmount, paybackAmount and purpose to given proposalAddress
     * @param _lendingRequest the address to get the parameters from
     * @return asker address of the asker
     * @return lender address of the lender
     * @return askAmount of the proposal
     * @return paybackAmount of the proposal
     * @return contractFee the contract fee for the lending request
     * @return purpose of the proposal
     * @return lent wheather the money was lent or not
     * @return debtSettled wheather the debt was settled by the asker
     */
    function getRequestParameters(address payable _lendingRequest)
        public
        view
        returns (address asker, address lender, address tokenAddress, uint256 askAmount, uint256 paybackAmount, uint256 contractFee, string memory purpose) {
        (asker, lender, tokenAddress, askAmount, paybackAmount, contractFee, purpose) = LendingRequestInterface(_lendingRequest).getRequestParameters();
    }

    function getRequestState(address payable _lendingRequest)
        public
        view
        returns (bool verifiedAsker, bool lent, bool withdrawnByAsker, bool debtSettled) {
        return LendingRequestInterface(_lendingRequest).getRequestState();
    }

    /**
     * @notice removes the lendingRequest from the management structures
     * @param _request the lendingRequest that will be removed
     */
    function removeRequest(address _request, address _sender) private {
        // validate input
        require(validRequest[_request], "invalid request");

        // update number of requests for asker
        userRequestCount[_sender]--;
        // remove _request from the management contract
        uint256 idx = requestIndex[_request];
        if(lendingRequests[idx] == _request) {
            requestIndex[lendingRequests[lendingRequests.length - 1]] = idx;
            lendingRequests[idx] = lendingRequests[lendingRequests.length - 1];
            lendingRequests.pop();
        }
        // mark _request as invalid lendingRequest
        validRequest[_request] = false;
    }

    function removeOfferRequest(address _request, address _sender) private {
        // validate input
        require(validRequest[_request], "invalid request");

        // update number of requests for asker
        userRequestCount[_sender]--;
        // remove _request from the management contract
        uint256 idx = requestIndex[_request];
        if(borrowingOffers[idx] == _request) {
            requestIndex[borrowingOffers[borrowingOffers.length - 1]] = idx;
            borrowingOffers[idx] = borrowingOffers[borrowingOffers.length - 1];
            borrowingOffers.pop();
        }
        // mark _request as invalid lendingRequest
        validRequest[_request] = false;
    }
}
