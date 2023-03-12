# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a fundraising contract and a test for that contract.

Try running some of the following tasks:
npm i to install and the pre req packages
npx harhat test for ruinning test 
test:
once you run the test
1) CollieCoin(ERC20 token) will be deployed
2) Fundraising Contract will be deployed with pool of CollieCoin(you can create as many pool as you want) with below limitations
  -> threshold = 600$
  -> max invest = 100$
  -> min invest = 1$
  -> tax = 10%
3) test will first mint 100 CollieCoins to each user(6 users)
4) 6 of em will contribute 100$
5) once threshold will hit the pool balance
6) winner will be decided using 1/threshold method you told me on fiverr.
7) tax will be sent to the main smart contract: 60$
8) winning amount will be sent to the winner: 540$
```shell
npm i
npx hardhat test
```
