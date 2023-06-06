// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable,Ownable{

    string _baseTokenURI;
    IWhitelist whitelist;
    bool public presaleStarted;
    //adding the timestamp for presale period to end.
    uint256 public presaleEnded;

    //checking for the tokens that are currently minted are less than 20
    uint256 public tokenIds;
    uint256 public maxTokenIds=20;

    //setting the price for the nft
    uint256 public _price=0.01 ether;

    //setting up the pause variable for pausing of the smart contract
    bool public _paused;

    modifier onlyWhenNotPaused{
        require(!_paused,"Contract currently paused");
        _;
    }


    constructor(string memory baseURI, address whitelistContract) ERC721("Crytpo Devs","CD"){
        _baseTokenURI=baseURI;
        whitelist=IWhitelist(whitelistContract);
    }

    //Only owner is modifier as you know it is the CONTROLLER in which it checks if the person who called the contract is the owner of the contract or not ..
    function startPresale() public onlyOwner{
        presaleStarted=true;
        presaleEnded=block.timestamp + 5 minutes;
    }
    function presaleMint() public payable onlyWhenNotPaused{
        //to check if the presale has started or not
        require(presaleStarted && block.timestamp < presaleEnded,"Presale ended");
        require(whitelist.whitelistedAddresses(msg.sender),"You are currently not in the whitelist");
        require(tokenIds<maxTokenIds,"Exceeded the current price");
        require(msg.value>=_price,"Ether sent is not sufficient to mint the nft tokens");

        //msg.value basically gives the total number of NFT's minted till now.
        tokenIds+=1;
        _safeMint(msg.sender,tokenIds);// it's from the erc721 standard where we can mint the nft's according to their rules.
    }

    function mint() public payable onlyWhenNotPaused{
        require(presaleStarted && block.timestamp >= presaleEnded,"Presale has not ended yet");
        require(tokenIds<maxTokenIds,"Exceeded the current price");
        require(msg.value>=_price,"Ether sent is not sufficient to mint the nft tokens");

        tokenIds+=1;
        _safeMint(msg.sender,tokenIds);// it's from the erc721 standard where we can mint the nft's according to their rules.
    }

    //this function is used to override the erc721 function which we can override.
    function _baseURI() internal view override returns (string memory){
        return _baseTokenURI;
    }



    //function to pause the smartContract for taking care of non malicious attack
    function setPaused(bool val)public onlyOwner{
        _paused=val;
    }

    //in here we require the function to withdraw the ether
    // from the smart contract

    function withdraw() public onlyOwner{
        address _owner= owner();               //the person who deployed the smart contract.
        uint256 amount =address(this).balance;
        (bool sent, )= _owner.call{value : amount}("");
        require(sent,"Failed to Withdraw");
    }
    //functions to receieve ether
    //recieve is used to recieve only the ether sent by the user and not the data which is sent.
    receive() external payable{

    }

    //fallback is used to recieve both the ether as well as the data.LOL

    fallback() external payable{

    }
}

