pragma solidity ^0.8.0;

import "./TradingPriceAbstract.sol";

contract HighOrderContract is TradingPriceAbstract {
	uint state = 0;
	uint last = 0;
	
    function Main(Token[] memory _tokens, address _to, SubscribeParams[] memory _params, uint _finalizedBlock) public virtual override returns (Action[] memory actions) {
         Notification memory notification = Notification("Buy", _params[0], "Buy info");
  
         actions = new Action[](1);
         actions[0] = Action("SwapV2", _tokens[0], _tokens[1], 10000000, _to, _tokens[0].chainID, notification);
         return actions;
    }
   
    function CustomMain(bytes calldata _event, address _eventEmitter, string calldata _eventName, uint _finalizedBlock, uint _blockNumber, bytes memory _txHash) public virtual override returns (CustomAction[] memory actions) {
        return actions;
    }

}
