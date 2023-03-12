// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract TokenPool {
    IERC20 private Token;
    uint public threshold;
    uint public minAmount;
    uint public maxAmount;
    address public owner;
    uint public decimals;
    mapping(address=>uint) public contributors;
    address[] public contributorsAddresses;
    uint public tax;
    address public winner;
    


    constructor(address tokenAddr, uint threshhold, uint min, uint max, uint tokenDecimals, uint totalTax){
        owner = msg.sender; // smart contract is owner
        threshold = threshhold;
        Token = IERC20(tokenAddr);
        minAmount = min;
        decimals = tokenDecimals;
        maxAmount = max;
        tax = totalTax * 100;
    }
    function changeMinMax(uint Newmin, uint Newmax) external{
        require(msg.sender == owner, "You can not call this function");
        minAmount = Newmin;
        maxAmount = Newmax;
    }
    function changeThreshold(uint newThreshold) external{
        require(msg.sender == owner, "You can not call this function");
        threshold = newThreshold;
    }
    function changetokenDecimals(uint newDecimals) external{
        require(msg.sender == owner, "You can not call this function");
        decimals = newDecimals;
    }
    function changetotalTax(uint newTax) external{
        require(msg.sender == owner, "You can not call this function");
        tax = newTax * 100; 
    }

    function getWinner() view external returns(address){
        return winner;
    }

    function getTax() view external returns(uint){
        return tax;
    }

    function getThreshold() view external returns(uint){
        return threshold;
    }

    function getPoolBalance() external view returns(uint){
        return Token.balanceOf(address(this));
    }


    function becomeContributor(address addr, uint amount) external{
        require(msg.sender == owner, "You can not call this function");
        require(amount <= maxAmount && amount >= minAmount, "Invalid amount 1");
        require(contributors[addr] + amount <=  maxAmount, "Invalid amount 2");
        require(amount * 10 ** 18 <= threshold * 10 ** 18 - Token.balanceOf(address(this)), "Please invest lesser since pool is about to hit threshold");
        Token.transferFrom(addr, address(this), amount * 10 ** decimals);  
        if(contributors[addr] == 0){
            contributorsAddresses.push(addr);
        }
        contributors[addr] += amount;
        if(Token.balanceOf(address(this)) >=  threshold * 10 ** decimals){
            chooseWinnerProbability();
        }
    }
    function chooseWinnerProbability() internal {
        require(msg.sender == owner, "You can not call this function");
        require(threshold * 10 ** 18 == Token.balanceOf(address(this)) , "threshold is not matched");
        uint[] memory userProbabilities = new uint[](contributorsAddresses.length);
        uint winningProbability;
        uint accumulatedProbability = 0;

        for (uint256 i = 0; i < contributorsAddresses.length; i++) {
            address userAddress = contributorsAddresses[i];
            uint256 investment = contributors[userAddress];
            uint256 probability = investment*10**18;
            probability = probability/threshold;
            userProbabilities[i] = probability;
            winningProbability = winningProbability + probability;
        }

        uint256 winnerNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % winningProbability;
        for (uint256 i = 0; i < contributorsAddresses.length; i++) {
            address userAddress = contributorsAddresses[i];
            uint256 probability = userProbabilities[i];
            accumulatedProbability = accumulatedProbability + probability;

            if (accumulatedProbability > winnerNumber) {
                winner = userAddress;
                uint totalPrize = Token.balanceOf(address(this));
                uint taxAmount = (totalPrize * tax) / 10000;
                uint netPrize = totalPrize - taxAmount;

                // Transfer the net prize amount to the winner and the tax amount to the owner
                Token.transfer(owner, taxAmount);
                Token.transfer(winner, netPrize);
                return;
            }
        }
    }

    
    

    
}

contract FundRaising {
    IERC20 private Token;
    address public owner;
    mapping(address=>address) public tokenToPoolAddress;
    address[] public livePools;
    address[] public deadPools;
    constructor(address tokenAddress){
        owner = msg.sender;
        createFundRaisingPool(tokenAddress, 600, 1, 100, 18, 10);

    }

    function createFundRaisingPool(address tokenAddr, uint threshhold, uint min, uint max, uint tokenDecimals, uint totalTax) public{
        require(msg.sender == owner, "you can not call this function");
        TokenPool tokenpool = new TokenPool(tokenAddr, threshhold, min, max, tokenDecimals, totalTax);
        tokenToPoolAddress[tokenAddr] = address(tokenpool);
        livePools.push(address(tokenpool));
    }

    function addFundsToPool(address poolAddress, uint amount) public{
        TokenPool(poolAddress).becomeContributor(msg.sender, amount);
    }

    // ----------------------// editing rules // --------------------------------- //

    function changeMinMax(address poolAddress, uint Newmin, uint Newmax) public{
        require(msg.sender == owner, "You can not call this function");
        TokenPool(poolAddress).changeMinMax(Newmin, Newmax);
    }
    function changeThreshold(address poolAddress, uint newThreshold) public{
        require(msg.sender == owner, "You can not call this function");
        TokenPool(poolAddress).changeThreshold(newThreshold);
    }
    function changetokenDecimals(address poolAddress, uint newDecimals) public{
        require(msg.sender == owner, "You can not call this function");
        TokenPool(poolAddress).changetokenDecimals(newDecimals);
    }
    function changetotalTax(address poolAddress, uint newTax) public{
        require(msg.sender == owner, "You can not call this function");
        TokenPool(poolAddress).changetotalTax(newTax);
    }

    // -----------------------// getting information // -----------------------------------// 

    function getPoolAddress(address tokenaddress) view public returns(address){  // using token address you can get pool address
        return tokenToPoolAddress[tokenaddress];
    }

    function getPoolBalance(address poolAddress) view public returns(uint){ 
        return TokenPool(poolAddress).getPoolBalance();
    }

    function getWinnerAddress(address poolAddress) view public returns(address){
        return TokenPool(poolAddress).getWinner();
    }

    function getTax(address poolAddress) view public returns(uint){
        return TokenPool(poolAddress).getTax();
    }

    function getThreshold(address poolAddress) view public returns(uint){
        return TokenPool(poolAddress).getThreshold();
    }

    //




}