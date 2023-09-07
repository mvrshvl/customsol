pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./TradingPriceAbstract.sol";

contract HighOrderContract is TradingPriceAbstract {
    function Main(Token[] memory _tokens, address _to, SubscribeParams[] memory _params, uint _finalizedBlock) public returns (Action[] memory actions) {
        return actions;
    }

    function CustomMain(bytes calldata _event, address _eventEmitter, string calldata _eventName, uint _finalizedBlock) public returns (CustomAction[] memory actions) {
        if (keccak256(abi.encodePacked(_eventName)) == keccak256(abi.encodePacked("sync"))) {
            Sync memory syncEvent = abi.decode(_event, (Sync));

            address token1 = address(0x6794c68f9448d2f623cBC69BB0AFdA7A9674F4b0);
            address token2 = address(0xC6f74A7587391843Ee5f918c9b6E9cc98CF1FA77);

            uint amountOut = getAmountOut(10**8, syncEvent.reserve1, syncEvent.reserve0);
            uint price = amountOut / 10**6;

            if (price < 35000) {
                return actions;
            }

            actions = new CustomAction[](2);

            address router = address(0x5517E0d48Fb4aD2800402273504640C2D154B8eC);
            address recipient = address(0x12A9C85D7E2a2404830EE21fe51D732f98bAACe7);

            string memory methodApproveSignature = "approve(address,uint256)";

            bytes memory inputApprove = abi.encode(router, 10**6);

            address contractToCall = token2;

            uint64 chainID = 1905;

            CustomNotification memory approveNotification = CustomNotification("Approve", "Approve 1 T2");

            actions[0] = CustomAction("Approve", contractToCall, methodApproveSignature, inputApprove, chainID, approveNotification);

            address[] memory path = new address[](2);
            path[0] = token2;
            path[1] = token1;

            actions[1] = CustomAction("Swap",
                router,
                "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
                abi.encode(10**6, 1, path, recipient, 9223372036854775807),
                chainID,
                CustomNotification("Sell", string(abi.encodePacked("Sell Token2 at the price of", uintToString(price)))));
        }

        return actions;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn * 997;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function uintToString(uint _value) internal pure returns (string memory str)
    {
        uint256 j = _value;
        uint256 length;

        while (j != 0) {
            length++;
            j /= 10;
        }

        bytes memory bstr = new bytes(length);
        uint256 k = length;

        while (_value != 0)
        {
            k = k-1;
            uint8 temp = (48 + uint8(_value - _value / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _value /= 10;
        }
        str = string(bstr);
    }
}
