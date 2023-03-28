pragma solidity ^0.8.17;

import "../lib/forge-std/src/Test.sol";
import "../src/OpenERC2612Token.sol";
import "../src/SigUtils.sol";

contract ERC20Test is Test {
    OpenERC2612Token internal ERC2612;
    SigUtils internal sigUtils;

    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;

    address internal owner;
    address internal spender;

    function setUp() public {
        ERC2612 = new OpenERC2612Token();
        sigUtils = new SigUtils(ERC2612.DOMAIN_SEPARATOR());

        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);

        ERC2612.transfer(owner, 100);
    }

    function test_Permit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 100,
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        ERC2612.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        assertEq(ERC2612.allowance(owner, spender), 100);
        assertEq(ERC2612.nonces(owner), 1);
        vm.prank(spender);
        ERC2612.transferFrom(owner,spender,100);
        assertEq(ERC2612.balanceOf(spender), 100);
    }

}
