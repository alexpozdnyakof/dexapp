// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public nextTokenAddress;

    constructor(address _NextToken) ERC20("Next LP Token", "NTLP") {
      require(_NextToken != address(0), "Token address passed is a null address");
      nextTokenAddress = _NextToken;
    }

    function getReserve() public view returns (uint) {
      return ERC20(nextTokenAddress).balanceOf(address(this));
    }

    function addLiquidity(uint _amount) public payable returns (uint) {
      uint liquidity;
      uint ethBalance = address(this).balance;
      uint nextTokenReserve = getReserve();
      ERC20 nextToken = ERC20(nextTokenAddress);

      if(nextTokenReserve == 0) {
        nextToken.transferFrom(msg.sender, address(this), _amount);
        liquidity = ethBalance;
        _mint(msg.sender, liquidity);
      } else {
        uint ethReserve = ethBalance - msg.value;
        // (cryptoDevTokenAmount user can add) = (Eth Sent by the user * cryptoDevTokenReserve /Eth Reserve)
        uint nextTokenAmount = (msg.value * nextTokenReserve)/(ethReserve);
        require(_amount >= nextTokenAmount, "Amount of tokens sent is less than the minimum tokens required"");

        nextToken.transferFrom(msg.sender, address(this), nextTokenAmount);
        liquidity = (totalSupply() * msg.value)/ ethReserve;
        _mint(msg.sender, liquidity);
      }
      return liquidity;
    }

}