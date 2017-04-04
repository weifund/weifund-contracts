pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "campaigns/BraidCampaign.sol";
import "verifiers/OwnedVerifier.sol";


contract TokenUser {
  function () payable {}

  function approve(address _token, address _to, uint256 _amount) {
    Token(_token).approve(_to, _amount);
  }

  function transfer(address _token, address _to, uint256 _amount) {
    Token(_token).transfer(_to, _amount);
  }

  function transferFrom(address _token, address _from, address _to, uint256 _amount) {
    Token(_token).transferFrom(_from, _to, _amount);
  }
}

contract Beneficiary {
  function () payable {}

  function stopCampaign(address _campaign) {
    BraidCampaign campaign = BraidCampaign(_campaign);
    campaign.stopCampaign();
  }

  function changePrice(address _campaign, uint256 _price) {
    BraidCampaign campaign = BraidCampaign(_campaign);
    campaign.changePrice(_price);
  }
}

contract Contributor is TokenUser {
  uint256[] defaultArray;

  function () payable {}

  function contributeMsgValue(address _campaign, uint256 _value) {
    BraidCampaign campaign = BraidCampaign(_campaign);
    campaign.contributeMsgValue.value(_value)(defaultArray);
  }

  function contributeMsgValueFallback(address _campaign, uint256 _value) {
    if(!_campaign.call.value(_value)()) {
      throw;
    }
  }
}


contract TestBraidCampaign_deployment is Test {
  BraidCampaign campaign;
  OwnedVerifier verifier;
  Beneficiary beneficiary;
  address[] founders;
  uint256[] founderBalances;
  uint256 expiry;
  uint256 freezePeriod;

  function setup() {
    founders.push(address(new OwnedVerifier(address(this))));
    founders.push(address(new OwnedVerifier(address(this))));
    founderBalances.push(32394 * 10**9);
    founderBalances.push(876 * 10**9);

    beneficiary = new Beneficiary();
    verifier = new OwnedVerifier(address(this));
    expiry = block.number + 4000;
    freezePeriod = block.number + 7000;
    campaign = new BraidCampaign(founders,
      founderBalances,
      address(beneficiary),
      verifier,
      expiry,
      700 * 10**9,
      1 ether,
      freezePeriod);
  }

  function test_deployment() {
    assertEq(campaign.earlySuccess(), false);
    assertEq(campaign.amountRaised(), uint256(0));
    assertEq(campaign.beneficiary(), address(beneficiary));
    assertEq(campaign.expiry(), expiry);
    assertEq(campaign.freezePeriod(), freezePeriod);
    assertEq(campaign.price(), uint256(1 ether));
    assertEq(campaign.created() > 0, true);
    assertEq(campaign.owner(), address(beneficiary));
    assertEq(campaign.enhancer(), address(campaign));
    assertEq(campaign.token(), address(campaign));
    assertEq(campaign.tokensIssued(), uint256(0));
    assertEq(campaign.tokenCap(), uint256(700 * 10**9));
    assertEq(campaign.totalContributions(), uint256(0));
    assertEq(campaign.stage(), uint256(0));
    assertEq(campaign.balanceOf(founders[0]), uint256(32394 * 10**9));
    assertEq(campaign.balanceOf(founders[1]), uint256(876 * 10**9));
    assertEq(campaign.totalSupply(), uint256(32394 + 876) * 10**9);
  }
}

contract TestBraidCampaign_contribution is Test {
  BraidCampaign campaign;
  OwnedVerifier verifier;
  Beneficiary beneficiary;
  address[] founders;
  uint256[] founderBalances;
  uint256[] emptyArray;
  uint256 expiry;
  uint256 freezePeriod;

  function setup() {
    founders.push(address(new OwnedVerifier(address(this))));
    founders.push(address(new OwnedVerifier(address(this))));
    founderBalances.push(32394);
    founderBalances.push(876);

    beneficiary = new Beneficiary();
    verifier = new OwnedVerifier(address(this));
    expiry = block.number + 4000;
    freezePeriod = block.number + 7000;
    campaign = new BraidCampaign(founders,
      founderBalances,
      address(beneficiary),
      verifier,
      expiry,
      60 * 10**9,
      1 ether,
      freezePeriod);
  }

  function test_0_accountShouldHaveBalance() {
    assertEq(this.balance > uint256(10 ether), true);
  }

  function test_1_shouldThrow_unapproved_invalidContribution() {
    campaign.contributeMsgValue.value(uint256(10 ether))(emptyArray);
  }

  function test_2_shouldThrow_unapproved_FallbackInvalidContribution() {
    if(!campaign.call.value(uint256(10 ether))()) {
      throw;
    }
  }

  function test_3_approved_validContribution() {
    // approve contrbutor
    verifier.setApproval(address(this), true);
    assertEq(verifier.approved(address(this)), true);

    // contirbute message value
    assertEq(beneficiary.balance, uint256(0));
    campaign.contributeMsgValue.value(uint256(10 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(10 * 10**9));
    assertEq(beneficiary.balance, uint256(10 ether));
  }

  function test_4_shouldThrow_tooLittleEther() {
    campaign.contributeMsgValue.value(uint256(0.5 ether))(emptyArray);
  }

  function test_4_shouldThrow_tooMuchEther() {
    campaign.contributeMsgValue.value(uint256(80 ether))(emptyArray);
  }
}


contract TestBraidCampaign_earlySuccess is Test {
  BraidCampaign campaign;
  OwnedVerifier verifier;
  Beneficiary beneficiary;
  address[] founders;
  uint256[] founderBalances;
  uint256[] emptyArray;
  uint256 expiry;
  uint256 freezePeriod;

  function setup() {
    founders.push(address(new OwnedVerifier(address(this))));
    founders.push(address(new OwnedVerifier(address(this))));
    founderBalances.push(32394);
    founderBalances.push(876);

    beneficiary = new Beneficiary();
    verifier = new OwnedVerifier(address(this));
    expiry = block.number + 4000;
    freezePeriod = block.number + 7000;
    campaign = new BraidCampaign(founders,
      founderBalances,
      address(beneficiary),
      verifier,
      expiry,
      700 * 10**9,
      1 ether,
      freezePeriod);

    if (!beneficiary.send(2 ether)) {
      throw;
    }
  }

  function test_1_correctBeneficiary() {
    assertEq(campaign.beneficiary(), address(beneficiary));
    assertEq(campaign.owner(), address(beneficiary));
  }

  function test_3_approved_validContribution() {
    // approve contrbutor
    verifier.setApproval(address(this), true);
    assertEq(verifier.approved(address(this)), true);

    // contirbute message value
    assertEq(beneficiary.balance, uint256(2 ether));
    campaign.contributeMsgValue.value(uint256(10 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(10 * 10**9));
    assertEq(beneficiary.balance, uint256(12 ether));
  }

  function test_4_triggerEarlySuccess() {
    beneficiary.stopCampaign(address(campaign));
  }

  function test_5_shouldThrow_invalidContribution() {
    campaign.contributeMsgValue.value(uint256(10 ether))(emptyArray);
  }

  function test_5_shouldThrow_invalidContribution_fallback() {
    if(!campaign.call.value(uint256(10 ether))()) {
      throw;
    }
  }
}

contract TestBraidCampaign_changePrice is Test {
  BraidCampaign campaign;
  OwnedVerifier verifier;
  Beneficiary beneficiary;
  address[] founders;
  uint256[] founderBalances;
  uint256[] emptyArray;
  uint256 expiry;
  uint256 freezePeriod;

  function setup() {
    founders.push(address(new OwnedVerifier(address(this))));
    founders.push(address(new OwnedVerifier(address(this))));
    founderBalances.push(32394);
    founderBalances.push(876);

    beneficiary = new Beneficiary();
    verifier = new OwnedVerifier(address(this));
    expiry = block.number + 4000;
    freezePeriod = block.number + 7000;
    campaign = new BraidCampaign(founders,
      founderBalances,
      address(beneficiary),
      verifier,
      expiry,
      700 * 10**9,
      1 ether,
      freezePeriod);
  }

  function test_3_approved_validContribution() {
    // approve contrbutor
    verifier.setApproval(address(this), true);
    assertEq(verifier.approved(address(this)), true);

    // contirbute message value
    assertEq(beneficiary.balance, uint256(0 ether));
    campaign.contributeMsgValue.value(uint256(10 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(10 * 10**9));
    assertEq(beneficiary.balance, uint256(10 ether));
  }

  function test_4_triggerPriceChange() {
    assertEq(campaign.price(), uint256(1 ether));
    beneficiary.changePrice(address(campaign), uint256(2 ether));
    assertEq(campaign.price(), uint256(2 ether));
  }

  function test_5_approved_validContribution() {
    // contirbute message value
    assertEq(beneficiary.balance, uint256(10 ether));
    campaign.contributeMsgValue.value(uint256(10 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(15 * 10**9));
    assertEq(beneficiary.balance, uint256(20 ether));
  }
}


contract TestBraidCampaign_capReach is Test {
  BraidCampaign campaign;
  OwnedVerifier verifier;
  Beneficiary beneficiary;
  address[] founders;
  uint256[] founderBalances;
  uint256[] emptyArray;
  uint256 expiry;
  uint256 freezePeriod;

  function setup() {
    beneficiary = new Beneficiary();
    verifier = new OwnedVerifier(address(this));
    expiry = block.number + 4000;
    freezePeriod = block.number + 7000;
    campaign = new BraidCampaign(founders,
      founderBalances,
      address(beneficiary),
      verifier,
      expiry,
      40 * 10**9,
      1 ether,
      freezePeriod);
  }

  function test_1_approved_validContribution() {
    // approve contrbutor
    verifier.setApproval(address(this), true);
    assertEq(verifier.approved(address(this)), true);

    // contirbute message value
    assertEq(beneficiary.balance, uint256(0 ether));
    campaign.contributeMsgValue.value(uint256(10 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(10) * 10**9);
    assertEq(beneficiary.balance, uint256(10 ether));

    assertEq(campaign.amountRaised(), uint256(10 ether));
    assertEq(campaign.stage(), uint256(0));
    assertEq(campaign.totalContributions(), uint256(1));
    assertEq(campaign.tokensIssued(), uint256(10 * 10**9));
    assertEq(campaign.totalSupply(), uint256(10 * 10**9));
  }

  function test_2_approved_validContribution() {
    // contirbute message value
    assertEq(beneficiary.balance, uint256(10 ether));
    campaign.contributeMsgValue.value(uint256(10 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(20 * 10**9));
    assertEq(beneficiary.balance, uint256(20 ether));

    assertEq(campaign.amountRaised(), uint256(20 ether));
    assertEq(campaign.stage(), uint256(0));
    assertEq(campaign.totalContributions(), uint256(2));
    assertEq(campaign.tokensIssued(), uint256(20 * 10**9));
    assertEq(campaign.totalSupply(), uint256(20 * 10**9));
  }

  function test_3_triggerPriceChange() {
    assertEq(campaign.price(), uint256(1 ether));
    beneficiary.changePrice(address(campaign), uint256(2 ether));
    assertEq(campaign.price(), uint256(2 ether));
  }

  function test_4_approved_validContribution() {
    // contirbute message value
    assertEq(beneficiary.balance, uint256(20 ether));
    campaign.contributeMsgValue.value(uint256(20 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(30 * 10**9));
    assertEq(beneficiary.balance, uint256(40 ether));

    assertEq(campaign.amountRaised(), uint256(40 ether));
    assertEq(campaign.stage(), uint256(0));
    assertEq(campaign.totalContributions(), uint256(3));
    assertEq(campaign.tokensIssued(), uint256(30 * 10**9));
    assertEq(campaign.totalSupply(), uint256(30 * 10**9));
  }

  function test_5_approved_validContribution() {
    // contirbute message value
    assertEq(beneficiary.balance, uint256(40 ether));
    campaign.contributeMsgValue.value(uint256(20 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(40 * 10**9));
    assertEq(beneficiary.balance, uint256(60 ether));

    assertEq(campaign.amountRaised(), uint256(60 ether));
    assertEq(campaign.stage(), uint256(2));
    assertEq(campaign.totalContributions(), uint256(4));
    assertEq(campaign.tokensIssued(), uint256(40 * 10**9));
    assertEq(campaign.totalSupply(), uint256(40 * 10**9));
  }

  function test_6_capReached() {
    assertEq(beneficiary.balance, uint256(60 ether));
    assertEq(campaign.balanceOf(address(this)), uint256(40 * 10**9));

    assertEq(campaign.amountRaised(), uint256(60 ether));
    assertEq(campaign.stage(), uint256(2));
    assertEq(campaign.totalContributions(), uint256(4));
    assertEq(campaign.tokensIssued(), uint256(40 * 10**9));
    assertEq(campaign.totalSupply(), uint256(40 * 10**9));
  }

  function test_7_invalidThrow_contribution() {
    campaign.contributeMsgValue.value(uint256(23 ether))(emptyArray);
  }

  function test_8_invalidThrow_contribution_fallback() {
    if(!campaign.call.value(uint256(10 ether))()){
      throw;
    }
  }
}

contract TestBraidCampaign_expiryReach is Test {
  BraidCampaign campaign;
  OwnedVerifier verifier;
  Beneficiary beneficiary;
  address[] founders;
  uint256[] founderBalances;
  uint256[] emptyArray;
  uint256 expiry;
  uint256 freezePeriod;

  function setup() {
    beneficiary = new Beneficiary();
    verifier = new OwnedVerifier(address(this));
    expiry = block.number + 3000;
    freezePeriod = block.number + 6000;
    campaign = new BraidCampaign(founders,
      founderBalances,
      address(beneficiary),
      verifier,
      expiry,
      40 * 10**9,
      1 ether,
      freezePeriod);
  }

  function test_1_approved_validContribution() {
    // approve contrbutor
    verifier.setApproval(address(this), true);
    assertEq(verifier.approved(address(this)), true);

    // contirbute message value
    assertEq(beneficiary.balance, uint256(0 ether));
    campaign.contributeMsgValue.value(uint256(10 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(10 * 10**9));
    assertEq(beneficiary.balance, uint256(10 ether));

    assertEq(campaign.amountRaised(), uint256(10 ether));
    assertEq(campaign.stage(), uint256(0));
    assertEq(campaign.totalContributions(), uint256(1));
    assertEq(campaign.tokensIssued(), uint256(10 * 10**9));
    assertEq(campaign.totalSupply(), uint256(10 * 10**9));
  }

  function test_2_approved_validContribution() {
    // contirbute message value
    assertEq(beneficiary.balance, uint256(10 ether));
    campaign.contributeMsgValue.value(uint256(10 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(20 * 10**9));
    assertEq(beneficiary.balance, uint256(20 ether));

    assertEq(campaign.amountRaised(), uint256(20 ether));
    assertEq(campaign.stage(), uint256(0));
    assertEq(campaign.totalContributions(), uint256(2));
    assertEq(campaign.tokensIssued(), uint256(20 * 10**9));
    assertEq(campaign.totalSupply(), uint256(20 * 10**9));
  }

  function test_3_increaseBlockBy5000_invalidExpiredContribution() {
    assertEq(campaign.stage(), uint256(2));
  }

  function test_4_shouldThrow_invalidExpiredContribution() {
    if(!campaign.call.value(uint256(12 ether))()) {
      throw;
    }
  }

  function test_5_shouldThrow_invalidExpiredContribution() {
    campaign.contributeMsgValue.value(uint256(10 ether))(emptyArray);
  }
}

contract TestBraidCampaign_fundingCap_edgeCase is Test {
  BraidCampaign campaign;
  OwnedVerifier verifier;
  Beneficiary beneficiary;
  address[] founders;
  uint256[] founderBalances;
  uint256[] emptyArray;
  uint256 expiry;
  uint256 freezePeriod;

  function setup() {
    beneficiary = new Beneficiary();
    verifier = new OwnedVerifier(address(this));
    expiry = block.number + 3000;
    freezePeriod = block.number + 6000;
    campaign = new BraidCampaign(founders,
      founderBalances,
      address(beneficiary),
      verifier,
      expiry,
      20 * 10**9,
      1 ether,
      freezePeriod);
  }

  function test_1_approved_validContribution_withEdge() {
    // approve contrbutor
    verifier.setApproval(address(this), true);
    assertEq(verifier.approved(address(this)), true);

    // contirbute message value
    assertEq(beneficiary.balance, uint256(0 ether));
    campaign.contributeMsgValue.value(uint256(10.5 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(10 * 10**9));
    assertEq(beneficiary.balance, uint256(10.5 ether));

    assertEq(campaign.amountRaised(), uint256(10.5 ether));
    assertEq(campaign.stage(), uint256(0));
    assertEq(campaign.totalContributions(), uint256(1));
    assertEq(campaign.tokensIssued(), uint256(10 * 10**9));
    assertEq(campaign.totalSupply(), uint256(10 * 10**9));
  }

  function test_2_approved_validContribution_toCap() {
    // contirbute message value
    assertEq(beneficiary.balance, uint256(10.5 ether));
    campaign.contributeMsgValue.value(uint256(10 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(20 * 10**9));
    assertEq(beneficiary.balance, uint256(20.5 ether));

    assertEq(campaign.amountRaised(), uint256(20.5 ether));
    assertEq(campaign.stage(), uint256(2));
    assertEq(campaign.totalContributions(), uint256(2));
    assertEq(campaign.tokensIssued(), uint256(20 * 10**9));
    assertEq(campaign.totalSupply(), uint256(20 * 10**9));
  }
}

contract TestBraidCampaign_tokenManagement_postCampaign is Test {
  BraidCampaign campaign;
  OwnedVerifier verifier;
  Beneficiary beneficiary;
  TokenUser tokenUser;
  TokenUser tokenUser2;
  address[] founders;
  uint256[] founderBalances;
  uint256[] emptyArray;
  uint256 expiry;
  uint256 freezePeriod;

  function setup() {
    tokenUser = new TokenUser();
    tokenUser2 = new TokenUser();
    beneficiary = new Beneficiary();
    verifier = new OwnedVerifier(address(this));
    expiry = block.number + 3000;
    freezePeriod = block.number + 6000;
    campaign = new BraidCampaign(founders,
      founderBalances,
      address(beneficiary),
      verifier,
      expiry,
      40 * 10**9,
      1 ether,
      freezePeriod);
  }

  function test_1_approved_validContribution() {
    // approve contrbutor
    verifier.setApproval(address(this), true);
    assertEq(verifier.approved(address(this)), true);

    // contirbute message value
    assertEq(beneficiary.balance, uint256(0 ether));
    campaign.contributeMsgValue.value(uint256(40 ether))(emptyArray);
    assertEq(campaign.balanceOf(address(this)), uint256(40 * 10**9));
    assertEq(beneficiary.balance, uint256(40 ether));

    assertEq(campaign.amountRaised(), uint256(40 ether));
    assertEq(campaign.stage(), uint256(2));
    assertEq(campaign.totalContributions(), uint256(1));
    assertEq(campaign.tokensIssued(), uint256(40 * 10**9));
    assertEq(campaign.totalSupply(), uint256(40 * 10**9));
  }

  function test_2_shouldThrow_invalidTransfer() {
    campaign.transfer(address(beneficiary), 20 * 10**9);
  }

  function test_3_shouldThrow_invalidTransferFrom() {
    campaign.transferFrom(address(this), address(beneficiary), 20 * 10**9);
  }

  function test_4_shouldThrow_invalidApprove() {
    campaign.approve(address(beneficiary), 20 * 10**9);
  }

  function test_5_shouldThrow_invalidContribution() {
    campaign.contributeMsgValue.value(uint256(40 ether))(emptyArray);
  }

  function test_6_shouldThrow_invalidContribution() {
    if(!campaign.call.value(uint256(40 ether))()) {
      throw;
    }
  }

  function test_7_increaseBlockBy6000_goodTransfer() {
    assertEq(campaign.balanceOf(beneficiary), uint256(0));
    campaign.transfer(address(beneficiary), 21 * 10**9);
    assertEq(campaign.balanceOf(beneficiary), uint256(21 * 10**9));
  }

  function test_8_goodTransferFrom() {
    assertEq(block.number > campaign.freezePeriod(), true);
    assertEq(campaign.balanceOf(tokenUser), uint256(0 * 10**9));
    assertEq(campaign.balanceOf(tokenUser2), uint256(0 * 10**9));
    campaign.approve(address(tokenUser), 12 * 10**9);
    tokenUser.transferFrom(address(campaign), address(this), address(tokenUser2), 5 * 10**9);
    assertEq(campaign.balanceOf(tokenUser), uint256(0 * 10**9));
    assertEq(campaign.balanceOf(tokenUser2), uint256(5 * 10**9));
    assertEq(campaign.balanceOf(beneficiary), uint256(21 * 10**9));
    tokenUser.transferFrom(address(campaign), address(this), address(tokenUser), 7 * 10**9);
    assertEq(campaign.balanceOf(tokenUser), uint256(7 * 10**9));
  }
}

contract TestBraidCampaign_fullCampaign_withSuccessTransfers is Test {
  BraidCampaign campaign;
  OwnedVerifier verifier;
  Beneficiary beneficiary;
  Contributor contributor1;
  Contributor contributor2;
  Contributor contributor3;
  Contributor contributor4;
  Contributor contributor5;
  Contributor contributor6;
  TokenUser tokenUser;
  TokenUser tokenUser2;
  address[] founders;
  uint256[] founderBalances;
  uint256[] emptyArray;
  uint256 expiry;
  uint256 freezePeriod;

  function setup() {
    contributor1 = new Contributor();
    if (!contributor1.send(uint256(5000 ether))) { throw; }
    contributor2 = new Contributor();
    if (!contributor2.send(uint256(5000 ether))) { throw; }
    contributor3 = new Contributor();
    if (!contributor3.send(uint256(5000 ether))) { throw; }
    contributor4 = new Contributor();
    if (!contributor4.send(uint256(5000 ether))) { throw; }
    contributor5 = new Contributor();
    if (!contributor5.send(uint256(5000 ether))) { throw; }
    contributor6 = new Contributor();
    if (!contributor6.send(uint256(5000 ether))) { throw; }

    tokenUser = new TokenUser();
    tokenUser2 = new TokenUser();
    beneficiary = new Beneficiary();
    verifier = new OwnedVerifier(address(this));
    expiry = block.number + 3000;
    freezePeriod = block.number + 6000;
    campaign = new BraidCampaign(founders,
      founderBalances,
      address(beneficiary),
      verifier,
      expiry,
      20000 * 10**9,
      1 ether,
      freezePeriod);
  }

  function test_1_contribution() {
    // approve contrbutor
    verifier.setApproval(address(contributor1), true);
    assertEq(verifier.approved(address(contributor1)), true);
    assertEq(campaign.price(), uint256(1 ether));

    contributor1.contributeMsgValue(address(campaign), uint256(1000 ether));
    assertEq(campaign.balanceOf(address(contributor1)), uint256(1000) * 10**9);
    assertEq(beneficiary.balance, uint256(1000 ether));
  }

  function test_2_contribution() {
    verifier.setApproval(address(contributor2), true);
    assertEq(verifier.approved(address(contributor2)), true);

    contributor2.contributeMsgValue(address(campaign), uint256(5000 ether));
    assertEq(campaign.balanceOf(address(contributor2)), uint256(5000) * 10**9);
    assertEq(beneficiary.balance, uint256(6000 ether));
  }

  function test_3_contribution() {
    verifier.setApproval(address(contributor3), true);
    assertEq(verifier.approved(address(contributor3)), true);

    contributor3.contributeMsgValue(address(campaign), uint256(2001.5 ether));
    assertEq(campaign.balanceOf(address(contributor3)), uint256(2001) * 10**9);
    assertEq(beneficiary.balance, uint256(8001.5 ether));
  }

  function test_4_contribution() {
    verifier.setApproval(address(contributor4), true);
    assertEq(verifier.approved(address(contributor4)), true);

    contributor4.contributeMsgValueFallback(address(campaign), uint256(10 ether));
    assertEq(campaign.balanceOf(address(contributor4)), uint256(10) * 10**9);
    assertEq(beneficiary.balance, uint256(8011.5 ether));
  }

  function test_5_priceChange() {
    beneficiary.changePrice(address(campaign), uint256(.5 ether));
    assertEq(campaign.price(), uint256(.5 ether));
  }

  function test_6_contribution() {
    verifier.setApproval(address(contributor5), true);
    assertEq(verifier.approved(address(contributor5)), true);

    contributor5.contributeMsgValueFallback(address(campaign), uint256(5000 ether));
    assertEq(campaign.balanceOf(address(contributor5)), uint256(10000) * 10**9);
    assertEq(beneficiary.balance, uint256(13011.5 ether));
  }

  function test_7_contribution_secondContribution() {
    contributor3.contributeMsgValueFallback(address(campaign), uint256(500 ether));
    assertEq(campaign.balanceOf(address(contributor3)), uint256(2001 + 1000) * 10**9);
    assertEq(beneficiary.balance, uint256(13511.5 ether));
  }

  function test_8_priceChange_secondChange() {
    beneficiary.changePrice(address(campaign), uint256(2 ether));
    assertEq(campaign.price(), uint256(2 ether));
  }

  function test_9_contribution() {
    contributor1.contributeMsgValueFallback(address(campaign), uint256(100 ether));
    assertEq(campaign.balanceOf(address(contributor1)), uint256(1000 + 50) * 10**9);
    assertEq(beneficiary.balance, uint256(13611.5 ether));
  }

  function test_9b_invalid_shouldThrow_contribution_notApproved() {
    contributor6.contributeMsgValueFallback(address(campaign), uint256(100 ether));
  }

  function test_9c_invalid_shouldThrow_contribution_tooLittle() {
    contributor1.contributeMsgValueFallback(address(campaign), uint256(.2 ether));
  }

  function test_9d_contribution_hitCap() {
    uint256 leftOverTokens = uint256(campaign.tokenCap() - campaign.tokensIssued());
    uint256 remainingContributionToCap = (leftOverTokens / 10**9) * campaign.price();
    contributor1.contributeMsgValueFallback(address(campaign), remainingContributionToCap);
    assertEq(campaign.balanceOf(address(contributor1)), uint256(((1000 + 50) * 10**9) + leftOverTokens));
    assertEq(beneficiary.balance, uint256(13611.5 ether) + remainingContributionToCap);
    assertEq(campaign.amountRaised(), uint256(13611.5 ether) + remainingContributionToCap);
    assertEq(campaign.stage(), uint256(2));
  }

  function test_9e_invalid_shouldThrow_contribution_postCap() {
    contributor4.contributeMsgValue(address(campaign), uint256(100 ether));
  }

  function test_9g_invalidTransferAttempt_shouldThrow() {
    contributor1.transfer(address(campaign), address(tokenUser), 30);
  }

  function test_9h_invalidTransferFromAttempt_shouldThrow() {
    contributor2.approve(address(campaign), address(tokenUser), 30);
  }

  function test_9k_0_invalidTransferFromAttempt_shouldThrow() {
    contributor2.transferFrom(address(campaign), address(tokenUser), address(tokenUser2), 30);
  }

  function test_9k_1_validTransferAndApprove_increaseBlockBy6000() {
    assertEq(block.number > campaign.freezePeriod(), true);
    assertEq(campaign.stage(), uint256(2));
    assertEq(campaign.balanceOf(address(tokenUser)), uint256(0 * 10**9));
    contributor1.transfer(address(campaign), address(tokenUser), 30 * 10**9);
    assertEq(campaign.balanceOf(address(tokenUser)), uint256(30 * 10**9));
    contributor2.approve(address(campaign), address(tokenUser2), 50 * 10**9);
    tokenUser2.transferFrom(address(campaign), address(contributor2), address(tokenUser), 10 * 10**9);
    assertEq(campaign.balanceOf(address(tokenUser)), uint256(40 * 10**9));
  }
}
