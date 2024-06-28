// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../utils/AutomaticValidatorTransferApproval.sol";
import "../utils/CreatorTokenBase.sol";
import "../token/erc20/ERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {TOKEN_TYPE_ERC20} from "@limitbreak/permit-c/Constants.sol";

/**
 * @title ERC20C
 * @author Limit Break, Inc.
 * @notice Extends OpenZeppelin's ERC20 implementation with Creator Token functionality, which
 *         allows the contract owner to update the transfer validation logic by managing a security policy in
 *         an external transfer validation security policy registry.  See {CreatorTokenTransferValidator}.
 */
abstract contract ERC20C is ERC165, ERC20, CreatorTokenBase, AutomaticValidatorTransferApproval {

    /**
     * @notice Overrides behavior of allowance such that if a spender is not explicitly approved,
     *         the contract owner can optionally auto-approve the 20-C transfer validator for transfers.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256 _allowance) {
        _allowance = super.allowance(owner, spender);

        if (_allowance == 0) {
            if (autoApproveTransfersFromValidator) {
                if (spender == address(getTransferValidator())) {
                    _allowance = type(uint256).max;
                }
            }
        }
    }

    /**
     * @notice Indicates whether the contract implements the specified interface.
     * @dev Overrides supportsInterface in ERC165.
     * @param interfaceId The interface id
     * @return true if the contract implements the specified interface, false otherwise
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return 
        interfaceId == type(IERC20).interfaceId || 
        interfaceId == type(IERC20Metadata).interfaceId || 
        interfaceId == type(ICreatorToken).interfaceId || 
        interfaceId == type(ICreatorTokenLegacy).interfaceId || 
        super.supportsInterface(interfaceId);
    }

    /**
     * @notice Returns the function selector for the transfer validator's validation function to be called 
     * @notice for transaction simulation. 
     */
    function getTransferValidationFunction() external pure returns (bytes4 functionSignature, bool isViewFunction) {
        functionSignature = bytes4(keccak256("validateTransfer(address,address,address,uint256,uint256)"));
        isViewFunction = false;
    }

    function _validateTransfer(
        address caller, 
        address from, 
        address to, 
        uint256 tokenId, 
        uint256 amount, 
        uint256 value
    ) internal virtual override {
        _preValidateTransfer(caller, from, to, tokenId, amount, value);
    }

    function _tokenType() internal pure override returns(uint16) {
        return uint16(TOKEN_TYPE_ERC20);
    }
}