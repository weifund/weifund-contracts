/*
This file is part of WeiFund.

WeiFund is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "campaigns/StandardCampaign.sol";
import "campaigns/tests/CampaignUser.sol";
import "enhancers/Model1Enhancer.sol";
import "tokens/IssuedToken.sol";
import "enhancers/EmptyEnhancer.sol";


contract TestModel1Enhancer_deployment is Test {
  address[] addrs;
  uint256[] amounts;

  function test_noFundersDeployment() {
    IssuedToken token = new IssuedToken(addrs, amounts, 0, 0, address(this), "Nick Tokens", 10, "NT");
    Model1Enhancer target = new Model1Enhancer(
      600000,
      0.125 ether,
      10150,
      address(token),
      addrs,
      amounts,
      address(this),
      address(0));

    assertEq(target.tokenCap(), 600000);
    assertEq(target.price(), 0.125 ether);
    assertEq(target.token(), address(token));
  }

  address[] funders;
  uint256[] funderAmounts;

  function test_withFundersDeployment() {
    IssuedToken token = new IssuedToken(addrs, amounts, 0, 0, address(this), "Nick Tokens", 10, "NT");

    funders.push(address(this));
    funders.push(address(0));
    funders.push(address(token));

    funderAmounts.push(23879234);
    funderAmounts.push(1);
    funderAmounts.push(89234);

    Model1Enhancer target = new Model1Enhancer(
      600000,
      0.125 ether,
      10150,
      address(token),
      funders,
      funderAmounts,
      address(this),
      address(0));

    assertEq(target.tokenCap(), 600000);
    assertEq(target.price(), 0.125 ether);
    assertEq(target.token(), address(token));

    assertEq(target.balances(address(this)), uint(23879234));
    assertEq(target.balances(address(0)), uint(1));
    assertEq(target.balances(address(token)), uint(89234));
    assertEq(target.tokensIssued(), uint(23879234 + 1 + 89234));
  }
}


contract TestModel1Enhancer_atStageOperational is Test {
  Model1Enhancer target;
  IssuedToken token;
  StandardCampaign campaign;
  CampaignUser user;

  address[] addrs;
  uint256[] amounts;
  uint256[] defaultValues;

  address[] funders;
  uint256[] funderAmounts;

  function setup() {
    user = new CampaignUser();

    // build initial token
    token = new IssuedToken(addrs, amounts, 0, 0, address(this), "Nick Tokens", 10, "NT");

    // setup initial funder amounts
    funders.push(address(user));
    funders.push(address(token));
    funderAmounts.push(238);
    funderAmounts.push(8923);

    // setup model 1 enhancer
    target = new Model1Enhancer(
      600000,
      uint(0.125 ether),
      10150,
      address(token),
      funders,
      funderAmounts,
      address(this),
      address(0));

    // set issuer
    token.setIssuer(address(target));

    // build campaign with enhancer
    campaign = new StandardCampaign(
      "Some Campaign",
      block.number + 10000,
      uint256(10000 * (1 ether)),
      uint256(125000 * (1 ether)),
      address(this),
      address(this),
      address(target));

    // set campaign
    target.setCampaign(address(campaign));
  }

  function test_a1_deployment() {
    assertEq(target.campaign(), address(campaign), "campaign addr is right");
    assertEq(token.issuer(), address(target), "token issuer is right");
    assertEq(campaign.enhancer(), address(target), "enhancer is right");
    assertEq(campaign.owner(), address(this), "campaign owner is right");
    assertEq(token.owner(), address(this), "token owner is right");
    assertEq(target.owner(), address(this), "target owner is right");
    assertEq(campaign.fundingGoal(), uint256(10000 * (1 ether)), "funding goal");
    assertEq(campaign.fundingCap(), uint256(125000 * (1 ether)), "funding cap");
    assertEq(target.price(), uint(0.125 ether), "token price");
    assertEq(target.freezePeriod(), uint(10150), "freeze period");
    assertEq(target.tokenCap(), 600000, "token cap");
    assertEq(target.token(), address(token), "target token is right");
    assertEq(target.balances(address(user)), 238, "balance 1 is right");
    assertEq(target.balances(address(token)), 8923, "balance 1 is right");
    assertEq(target.tokensIssued(), (238 + 8923), "total tokens issued");
    assertEq(target.token(), address(token), "target token is right");
    assertEq(campaign.stage(), 0, "stage is zero");
  }

  function test_a2_validContribution() {
    uint amount = uint256(10 * (1 ether));
    uint tokenAmount = target.calcTokenAmount(amount);
    uint contid = campaign.contributeMsgValue.gas(3000000).value(amount)(defaultValues);
    var (csender, camount, ccreated) = campaign.contributions(contid);
    assertEq(csender, address(this));
    assertEq(camount, amount, "amount cont.");
    assertEq(ccreated > 0, true);
    assertEq(campaign.totalContributions(), 1, "total cont.");
    assertEq(campaign.totalContributionsBySender(address(this)), 1, "cont by sender");
    assertEq(campaign.balance, amount, "camp balance");
    assertEq(tokenAmount > 0, true, "token cal amount greater than zero");
    assertEq(target.balances(csender), tokenAmount, "tokens issued properly");
    assertEq(target.tokensIssued(), tokenAmount + (238 + 8923), "tokens issued");
    assertEq(campaign.stage(), 0, "stage still operational");
  }

  function makeValidContribution(uint _amount, uint _expectedStage) {
    makeValidContribution(_amount, _expectedStage, address(new CampaignUser()));
  }

  function makeValidContribution(uint amount, uint expectedStage, address _contUser) {
    CampaignUser contUser = CampaignUser(_contUser);

    if (!contUser.send(amount + 300000)) {
      throw;
    }
    uint previousCampaignBalance = campaign.balance;
    uint previousContributionCount = campaign.totalContributions();
    uint previoudBalance = target.balances(address(contUser));
    uint previousTokensIssued = target.tokensIssued();
    uint tokenAmount = target.calcTokenAmount(amount);
    uint contid = contUser.contributeMsgValue(address(campaign), amount);
    // uint contid = campaign.contributeMsgValue.gas(3000000).value(amount)(defaultValues);
    var (csender, camount, ccreated) = campaign.contributions(contid);
    assertEq(csender, address(contUser));
    assertEq(camount, amount, "amount cont.");
    assertEq(ccreated > 0, true);
    assertEq(campaign.totalContributions(), previousContributionCount + 1, "total cont.");
    assertEq(campaign.balance, previousCampaignBalance + amount, "camp balance");
    assertEq(tokenAmount > 0, true, "token cal amount greater than zero");
    assertEq(target.balances(csender), previoudBalance + tokenAmount, "tokens issued properly balance");
    assertEq(target.tokensIssued(), previousTokensIssued + tokenAmount, "tokens issued properly");
    assertEq(campaign.stage(), expectedStage, "stage still operational");
  }

  function test_a3_makeValidContributions_increaseBlockBy223() {
    makeValidContribution((10 * 1 ether), 0);
    makeValidContribution((100 * 1 ether), 0);
    makeValidContribution((2234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((423 * 1 ether), 0);
    makeValidContribution((4234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((87 * 1 ether), 0);
    makeValidContribution((9 * 1 ether), 0);
    makeValidContribution((7 * 1 ether), 0);
    makeValidContribution((11 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((2 * 1 ether), 0);
    makeValidContribution((132 * 1 ether), 0);
    makeValidContribution((42 * 1 ether), 0);
    makeValidContribution((53 * 1 ether), 0);
    makeValidContribution((890 * 1 ether), 0);
    makeValidContribution((1000 * 1 ether), 0);
    makeValidContribution((53 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((987 * 1 ether), 0);
    makeValidContribution((107 * 1 ether), 0);

    log_uint(this.balance / (1 ether), "balance in ether");
    log_uint(target.tokensIssued(), "tokens issued");
  }

  function test_a4_makeValidContributions_increaseBlockBy1145() {
    makeValidContribution((10 * 1 ether), 0);
    makeValidContribution((100 * 1 ether), 0);
    makeValidContribution((2234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((423 * 1 ether), 0);
    makeValidContribution((4234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((87 * 1 ether), 0);
    makeValidContribution((9 * 1 ether), 0);
    makeValidContribution((7 * 1 ether), 0);
    makeValidContribution((11 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((2 * 1 ether), 0);
    makeValidContribution((132 * 1 ether), 0);
    makeValidContribution((42 * 1 ether), 0);
    makeValidContribution((53 * 1 ether), 0);
    makeValidContribution((890 * 1 ether), 0);
    makeValidContribution((1000 * 1 ether), 0);
    makeValidContribution((53 * 1 ether), 0);
    makeValidContribution((2424 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((987 * 1 ether), 0);
    makeValidContribution((107 * 1 ether), 0);

    log_uint(this.balance / (1 ether), "balance in ether");
    log_uint(target.tokensIssued(), "tokens issued");
  }

  function test_a4_makeValidContributions_increaseBlockBy8585() {
    makeValidContribution((3354 * 1 ether), 0);
    makeValidContribution((3 * 1 ether), 0);
    makeValidContribution((545 * 1 ether), 0);
    makeValidContribution((233 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((423 * 1 ether), 0);
    makeValidContribution((4234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((87 * 1 ether), 0);
    makeValidContribution((32 * 1 ether), 0);
    makeValidContribution((72 * 1 ether), 0);
    makeValidContribution((11 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((2 * 1 ether), 0);
    makeValidContribution((1132 * 1 ether), 0);
    makeValidContribution((42 * 1 ether), 0);
    makeValidContribution((535 * 1 ether), 0);
    makeValidContribution((890 * 1 ether), 0);
    makeValidContribution((1000 * 1 ether), 0);
    makeValidContribution((534 * 1 ether), 0);
    makeValidContribution((2424 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((3987 * 1 ether), 0);
    makeValidContribution((107 * 1 ether), 0);

    log_uint(this.balance / (1 ether), "balance in ether");
    log_uint(target.tokensIssued(), "tokens issued");
  }

  function test_a5_multipleContributionsOneUser() {
    CampaignUser campUser = new CampaignUser();
    uint amountEther = (1 * 1 ether) + (3242 * 1 ether);

    makeValidContribution((1 * 1 ether), 0, address(campUser));
    makeValidContribution((3242 * 1 ether), 0, address(campUser));

    assertEq(target.balances(campUser), target.calcTokenAmount(amountEther), "token balance correct");
  }

  function test_a22_invalidContribution_zeroValue_shouldThrow() {
    campaign.contributeMsgValue.value(0)(defaultValues);
  }

  function test_a222_invalidContribution_tooLittle_shouldThrow() {
    campaign.contributeMsgValue.value(0)(defaultValues);
  }

  function test_a23_invalidContribution_overCap_shouldThrow() {
    campaign.contributeMsgValue.value(uint256(200000 * (1 ether)))(defaultValues);
  }

  function test_a234_invalidPayout_shouldThrow() {
    user.payoutToBeneficiary(address(campaign));
  }

  function test_a234_invalidTokenClaim_shouldThrow() {
    target.claim();
  }
}

contract TestModel1Enhancer_atStageFailure is Test {
  Model1Enhancer target;
  IssuedToken token;
  StandardCampaign campaign;
  CampaignUser user;

  address[] addrs;
  uint256[] amounts;
  uint256[] defaultValues;

  address[] funders;
  uint256[] funderAmounts;

  function setup() {
    user = new CampaignUser();

    // build initial token
    token = new IssuedToken(addrs, amounts, 0, 0, address(this), "Nick Tokens", 10, "NT");

    // setup initial funder amounts
    funders.push(address(token));
    funderAmounts.push(8923);

    // setup model 1 enhancer
    target = new Model1Enhancer(
      600000,
      uint(0.125 ether),
      10150,
      address(token),
      funders,
      funderAmounts,
      address(this),
      address(0));

    // set issuer
    token.setIssuer(address(target));

    // build campaign with enhancer
    campaign = new StandardCampaign(
      "Some Campaign",
      block.number + 1000,
      uint256(10000 * (1 ether)),
      uint256(125000 * (1 ether)),
      address(this),
      address(this),
      address(target));

    // set campaign
    target.setCampaign(address(campaign));
  }

  function test_a1_contribution() {
    uint amount = uint256(10 * (1 ether));
    uint tokenAmount = target.calcTokenAmount(amount);
    uint contid = campaign.contributeMsgValue.gas(3000000).value(amount)(defaultValues);

    assertEq(contid, 0, "contribution id");
    assertEq(campaign.balance, amount, "stage operational");
    assertEq(campaign.stage(), 0, "stage operational");
  }

  function test_a2_contribution() {
    uint amount = uint256(242 * (1 ether));
    if (!user.send(amount)) {
      throw;
    }
    uint tokenAmount = target.calcTokenAmount(amount);
    uint contid = user.contributeMsgValue(address(campaign), amount);
    assertEq(contid, 1, "contribution id");
    assertEq(target.balances(address(user)), tokenAmount);
    assertEq(campaign.stage(), 0, "stage operational");
  }

  function test_b2_expiry_increaseBlockBy2000() {
    assertEq(campaign.stage(), 1, "stage failure");
  }

  function test_b3_attemptValidRefund() {
    assertEq(campaign.stage(), 1, "stage failure");
    uint prevUserBlanace = user.balance;
    address claimAddress = user.claimRefundOwed(address(campaign), 1);
    BalanceClaim claimB = BalanceClaim(claimAddress);

    assertEq(claimAddress != address(0), true);
    assertEq(claimB.owner(), address(user), "claim is owed to owner");
    assertEq(claimB.balance, uint256(242 * (1 ether)), "user balance claim balance right");

    user.claimBalance(claimAddress);

    assertEq(claimB.balance, 0, "claim balance is zero");
    assertEq(user.balance, prevUserBlanace + uint256(242 * (1 ether)), "user balance increased");
  }

  function test_b4_attemptValidRefund() {
    assertEq(campaign.stage(), 1, "stage failure");

    uint prevThisBlanace = this.balance;

    address claimAddress = campaign.claimRefundOwed(0);
    BalanceClaim claimC = BalanceClaim(claimAddress);
    claimC.claimBalance();

    assertEq(claimC.balance, 0, "claim balance is zero");
    assertEq(this.balance, prevThisBlanace + uint256(10 * (1 ether)), "user balance increased");
  }

  function test_b4_invalidTokenClaim_shouldThrow() {
    target.claim();
  }

  function test_b4_invalidContribution_shouldThrow() {
    uint amount = uint256(10 * (1 ether));
    uint tokenAmount = target.calcTokenAmount(amount);
    uint contid = campaign.contributeMsgValue.gas(3000000).value(amount)(defaultValues);
  }

  function test_b4_invalidContribution_noGas_shouldThrow() {
    uint contid = campaign.contributeMsgValue.value(24323)(defaultValues);
  }

  function test_b4_invalidContribution_zeroValue_shouldThrow() {
    uint contid = campaign.contributeMsgValue.gas(3000000).value(0)(defaultValues);
  }

  function test_b4_invalidContribution_overCap_shouldThrow() {
    uint contid = campaign.contributeMsgValue.gas(3000000).value(campaign.fundingCap())(defaultValues);
  }

  function test_b4_beneficiaryPayout_shouldThrow() {
    user.payoutToBeneficiary(address(campaign));
  }
}

contract TestModel1Enhancer_atStageSuccess is Test {
  Model1Enhancer target;
  IssuedToken token;
  StandardCampaign campaign;
  CampaignUser user;
  CampaignUser beneficiary;
  CampaignUser campUser;

  address[] addrs;
  uint256[] amounts;
  uint256[] defaultValues;

  address[] funders;
  uint256[] funderAmounts;

  function setup() {
    user = new CampaignUser();
    campUser = new CampaignUser();
    beneficiary = new CampaignUser();

    // build initial token
    token = new IssuedToken(addrs, amounts, 0, 0, address(this), "Nick Tokens", 10, "NT");

    // setup initial funder amounts
    funders.push(address(user));
    funders.push(address(token));
    funderAmounts.push(238);
    funderAmounts.push(8923);

    // setup model 1 enhancer
    target = new Model1Enhancer(
      600000,
      uint(0.125 ether),
      10150,
      address(token),
      funders,
      funderAmounts,
      address(this),
      address(0));

    // set issuer
    token.setIssuer(address(target));

    // build campaign with enhancer
    campaign = new StandardCampaign(
      "Some Campaign",
      block.number + 10000,
      uint256(10000 * (1 ether)),
      uint256(125000 * (1 ether)),
      address(beneficiary),
      address(this),
      address(target));

    // set campaign
    target.setCampaign(address(campaign));

    // beneficiary
    if (!beneficiary.send(3000000)) {
      throw;
    }
  }

  function test_a1_deployment() {
    assertEq(campaign.beneficiary(), address(beneficiary), "campaign ben is right");
    assertEq(target.campaign(), address(campaign), "campaign addr is right");
    assertEq(token.issuer(), address(target), "token issuer is right");
    assertEq(campaign.enhancer(), address(target), "enhancer is right");
    assertEq(campaign.owner(), address(this), "campaign owner is right");
    assertEq(token.owner(), address(this), "token owner is right");
    assertEq(target.owner(), address(this), "target owner is right");
    assertEq(campaign.fundingGoal(), uint256(10000 * (1 ether)), "funding goal");
    assertEq(campaign.fundingCap(), uint256(125000 * (1 ether)), "funding cap");
    assertEq(target.price(), uint(0.125 ether), "token price");
    assertEq(target.freezePeriod(), uint(10150), "freeze period");
    assertEq(target.tokenCap(), 600000, "token cap");
    assertEq(target.token(), address(token), "target token is right");
    assertEq(target.balances(address(user)), 238, "balance 1 is right");
    assertEq(target.balances(address(token)), 8923, "balance 1 is right");
    assertEq(target.tokensIssued(), (238 + 8923), "total tokens issued");
    assertEq(target.token(), address(token), "target token is right");
    assertEq(campaign.stage(), 0, "stage is zero");
  }

  function test_a2_validContribution() {
    uint amount = uint256(10 * (1 ether));
    uint tokenAmount = target.calcTokenAmount(amount);
    uint contid = campaign.contributeMsgValue.gas(3000000).value(amount)(defaultValues);
    var (csender, camount, ccreated) = campaign.contributions(contid);
    assertEq(csender, address(this));
    assertEq(camount, amount, "amount cont.");
    assertEq(ccreated > 0, true);
    assertEq(campaign.totalContributions(), 1, "total cont.");
    assertEq(campaign.totalContributionsBySender(address(this)), 1, "cont by sender");
    assertEq(campaign.balance, amount, "camp balance");
    assertEq(tokenAmount > 0, true, "token cal amount greater than zero");
    assertEq(target.balances(csender), tokenAmount, "tokens issued properly");
    assertEq(target.tokensIssued(), tokenAmount + (238 + 8923), "tokens issued");
    assertEq(campaign.stage(), 0, "stage still operational");
  }

  function makeValidContribution(uint _amount, uint _expectedStage) {
    makeValidContribution(_amount, _expectedStage, address(new CampaignUser()));
  }

  function makeValidContribution(uint amount, uint expectedStage, address _contUser) {
    CampaignUser contUser = CampaignUser(_contUser);

    if (!contUser.send(amount + 300000)) {
      throw;
    }
    uint previousCampaignBalance = campaign.balance;
    uint previousContributionCount = campaign.totalContributions();
    uint previoudBalance = target.balances(address(contUser));
    uint previousTokensIssued = target.tokensIssued();
    uint tokenAmount = target.calcTokenAmount(amount);
    uint contid = contUser.contributeMsgValue(address(campaign), amount);
    // uint contid = campaign.contributeMsgValue.gas(3000000).value(amount)(defaultValues);
    var (csender, camount, ccreated) = campaign.contributions(contid);
    assertEq(csender, address(contUser));
    assertEq(camount, amount, "amount cont.");
    assertEq(ccreated > 0, true);
    assertEq(campaign.totalContributions(), previousContributionCount + 1, "total cont.");
    assertEq(campaign.balance, previousCampaignBalance + amount, "camp balance");
    assertEq(tokenAmount > 0, true, "token cal amount greater than zero");
    assertEq(target.balances(csender), previoudBalance + tokenAmount, "tokens issued properly balance");
    assertEq(target.tokensIssued(), previousTokensIssued + tokenAmount, "tokens issued properly");
    assertEq(campaign.stage(), expectedStage, "stage still operational");
  }

  function test_a3_makeValidContributions_increaseBlockBy223() {
    makeValidContribution((10 * 1 ether), 0);
    makeValidContribution((100 * 1 ether), 0);
    makeValidContribution((2234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((423 * 1 ether), 0);
    makeValidContribution((4234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((87 * 1 ether), 0);
    makeValidContribution((9 * 1 ether), 0);
    makeValidContribution((7 * 1 ether), 0);
    makeValidContribution((11 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((2 * 1 ether), 0);
    makeValidContribution((132 * 1 ether), 0);
    makeValidContribution((42 * 1 ether), 0);
    makeValidContribution((53 * 1 ether), 0);
    makeValidContribution((890 * 1 ether), 0);
    makeValidContribution((1000 * 1 ether), 0);
    makeValidContribution((53 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((987 * 1 ether), 0);
    makeValidContribution((107 * 1 ether), 0);

    log_uint(this.balance / (1 ether), "balance in ether");
    log_uint(target.tokensIssued(), "tokens issued");
  }

  function test_a4_makeValidContributions_increaseBlockBy1145() {
    makeValidContribution((10 * 1 ether), 0);
    makeValidContribution((100 * 1 ether), 0);
    makeValidContribution((2234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((423 * 1 ether), 0);
    makeValidContribution((4234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((87 * 1 ether), 0);
    makeValidContribution((9 * 1 ether), 0);
    makeValidContribution((7 * 1 ether), 0);
    makeValidContribution((11 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((2 * 1 ether), 0);
    makeValidContribution((132 * 1 ether), 0);
    makeValidContribution((42 * 1 ether), 0);
    makeValidContribution((53 * 1 ether), 0);
    makeValidContribution((890 * 1 ether), 0);
    makeValidContribution((1000 * 1 ether), 0);
    makeValidContribution((53 * 1 ether), 0);
    makeValidContribution((2424 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((987 * 1 ether), 0);
    makeValidContribution((107 * 1 ether), 0);

    log_uint(this.balance / (1 ether), "balance in ether");
    log_uint(target.tokensIssued(), "tokens issued");
  }

  function test_a4_makeValidContributions_increaseBlockBy8585() {
    makeValidContribution((3354 * 1 ether), 0);
    makeValidContribution((3 * 1 ether), 0);
    makeValidContribution((545 * 1 ether), 0);
    makeValidContribution((233 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((423 * 1 ether), 0);
    makeValidContribution((4234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((87 * 1 ether), 0);
    makeValidContribution((32 * 1 ether), 0);
    makeValidContribution((72 * 1 ether), 0);
    makeValidContribution((11 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((2 * 1 ether), 0);
    makeValidContribution((1132 * 1 ether), 0);
    makeValidContribution((42 * 1 ether), 0);
    makeValidContribution((535 * 1 ether), 0);
    makeValidContribution((890 * 1 ether), 0);
    makeValidContribution((1000 * 1 ether), 0);
    makeValidContribution((534 * 1 ether), 0);
    makeValidContribution((2424 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((3987 * 1 ether), 0);
    makeValidContribution((107 * 1 ether), 0);

    log_uint(this.balance / (1 ether), "balance in ether");
    log_uint(target.tokensIssued(), "tokens issued");
  }

  function test_a5_multipleContributionsOneUser() {
    uint amountEther = (1 * 1 ether) + (3242 * 1 ether);

    makeValidContribution((1 * 1 ether), 0, address(campUser));
    makeValidContribution((3242 * 1 ether), 0, address(campUser));

    assertEq(target.balances(campUser), target.calcTokenAmount(amountEther), "token balance correct");
  }

  function test_a6_lastContribution_triggerEarlySuccess() {
    uint amount = target.price() * (target.tokenCap() - target.tokensIssued());
    makeValidContribution(amount, 2);
    assertEq(campaign.stage(), 2, "stage is 2 success");
  }

  function test_a7_attemptInvalidTokenClaim_freezePeriod_shouldThrow() {
    campUser.claimTokens(address(target));
  }

  function test_a7_attemptInvalidTokenClaim_fromThis_freezePeriod_shouldThrow() {
    target.claim();
  }

  function test_a8_validTokenClaim_increaseBlockBy13000() {
    assertEq(token.balanceOf(address(this)), 0, "token balance is zero");
    assertEq(target.claimed(address(this)), false, "claimed is false");
    target.claim();
    assertEq(token.balanceOf(address(this)), target.balances(address(this)), "token balance is now what was owed");
    assertEq(target.claimed(address(this)), true, "claimed is true");
    assertEq(campaign.stage(), 2, "stage is 2 success");
  }

  function test_a9_validTokenClaim_increaseBlockBy10() {
    assertEq(token.balanceOf(address(campUser)), 0, "token balance is zero");
    assertEq(target.claimed(address(campUser)), false, "claimed is false");
    campUser.claimTokens(address(target));
    assertEq(token.balanceOf(address(campUser)), target.balances(address(campUser)), "token balance is now what was owed");
    assertEq(target.claimed(address(campUser)), true, "claimed is true");
    assertEq(campaign.stage(), 2, "stage is 2 success");
    assertEq(campaign.beneficiary(), address(beneficiary), "ben is right");
  }

  function test_b1_attemptPayoutToBeneficiary() {
    assertEq(campaign.stage(), 2, "stage is 2 success");
    uint prevBalance = beneficiary.balance;
    assertEq(prevBalance, 3000000, "prev balance for some gas");
    assertEq(campaign.balance > 0, true, "campaign has balance");
    beneficiary.payoutToBeneficiary(address(campaign));
    assertEq(beneficiary.balance, campaign.amountRaised() + prevBalance, "beneficiary balance increased");
    assertEq(campaign.balance, 0, "camp balance is zero");
  }

  function test_b3_invalidContribution_increaseBlockBy10_shouldThrow() {
    campaign.contributeMsgValue.gas(3000000).value(0)(defaultValues);
  }

  function test_b3_invalidContribution2_increaseBlockBy10_shouldThrow() {
    campaign.contributeMsgValue.gas(3000000).value(2423243)(defaultValues);
  }

  function test_b3_invalidContribution3_increaseBlockBy10_shouldThrow() {
    campaign.contributeMsgValue.gas(3000000).value(campaign.fundingCap())(defaultValues);
  }

  function test_b3_invalidDoubleTokenClaim_increaseBlockBy10_shouldThrow() {
    campUser.claimTokens(address(target));
  }

  function test_b4_invalidDoubleTokenClaim_increaseBlockBy10_shouldThrow() {
    target.claim();
  }
}

contract TestModel1Enhancer_atStageSuccess_atFundingCap is Test {
  Model1Enhancer target;
  IssuedToken token;
  StandardCampaign campaign;
  CampaignUser user;
  CampaignUser beneficiary;
  CampaignUser campUser;

  address[] addrs;
  uint256[] amounts;
  uint256[] defaultValues;

  address[] funders;
  uint256[] funderAmounts;

  function setup() {
    user = new CampaignUser();
    campUser = new CampaignUser();
    beneficiary = new CampaignUser();

    // build initial token
    token = new IssuedToken(addrs, amounts, 0, 0, address(this), "Nick Tokens", 10, "NT");

    // setup initial funder amounts
    funders.push(address(user));
    funders.push(address(token));
    funderAmounts.push(238);
    funderAmounts.push(8923);

    // setup model 1 enhancer
    target = new Model1Enhancer(
      600000,
      uint(0.125 ether),
      10150,
      address(token),
      funders,
      funderAmounts,
      address(this),
      address(0));

    // set issuer
    token.setIssuer(address(target));

    // build campaign with enhancer
    campaign = new StandardCampaign(
      "Some Campaign",
      block.number + 10000,
      uint256(10000 * (1 ether)),
      uint256(125000 * (1 ether)),
      address(beneficiary),
      address(this),
      address(target));

    // set campaign
    target.setCampaign(address(campaign));

    // beneficiary
    if (!beneficiary.send(3000000)) {
      throw;
    }
  }

  function test_a1_deployment() {
    assertEq(campaign.beneficiary(), address(beneficiary), "campaign ben is right");
    assertEq(target.campaign(), address(campaign), "campaign addr is right");
    assertEq(token.issuer(), address(target), "token issuer is right");
    assertEq(campaign.enhancer(), address(target), "enhancer is right");
    assertEq(campaign.owner(), address(this), "campaign owner is right");
    assertEq(token.owner(), address(this), "token owner is right");
    assertEq(target.owner(), address(this), "target owner is right");
    assertEq(campaign.fundingGoal(), uint256(10000 * (1 ether)), "funding goal");
    assertEq(campaign.fundingCap(), uint256(125000 * (1 ether)), "funding cap");
    assertEq(target.price(), uint(0.125 ether), "token price");
    assertEq(target.freezePeriod(), uint(10150), "freeze period");
    assertEq(target.tokenCap(), 600000, "token cap");
    assertEq(target.token(), address(token), "target token is right");
    assertEq(target.balances(address(user)), 238, "balance 1 is right");
    assertEq(target.balances(address(token)), 8923, "balance 1 is right");
    assertEq(target.tokensIssued(), (238 + 8923), "total tokens issued");
    assertEq(target.token(), address(token), "target token is right");
    assertEq(campaign.stage(), 0, "stage is zero");
  }

  function test_a2_validContribution() {
    uint amount = uint256(10 * (1 ether));
    uint tokenAmount = target.calcTokenAmount(amount);
    uint contid = campaign.contributeMsgValue.gas(3000000).value(amount)(defaultValues);
    var (csender, camount, ccreated) = campaign.contributions(contid);
    assertEq(csender, address(this));
    assertEq(camount, amount, "amount cont.");
    assertEq(ccreated > 0, true);
    assertEq(campaign.totalContributions(), 1, "total cont.");
    assertEq(campaign.totalContributionsBySender(address(this)), 1, "cont by sender");
    assertEq(campaign.balance, amount, "camp balance");
    assertEq(tokenAmount > 0, true, "token cal amount greater than zero");
    assertEq(target.balances(csender), tokenAmount, "tokens issued properly");
    assertEq(target.tokensIssued(), tokenAmount + (238 + 8923), "tokens issued");
    assertEq(campaign.stage(), 0, "stage still operational");
  }

  function makeValidContribution(uint _amount, uint _expectedStage) {
    makeValidContribution(_amount, _expectedStage, address(new CampaignUser()));
  }

  function makeValidContribution(uint amount, uint expectedStage, address _contUser) {
    CampaignUser contUser = CampaignUser(_contUser);

    if (!contUser.send(amount + 300000)) {
      throw;
    }
    uint previousCampaignBalance = campaign.balance;
    uint previousContributionCount = campaign.totalContributions();
    uint previoudBalance = target.balances(address(contUser));
    uint previousTokensIssued = target.tokensIssued();
    uint tokenAmount = target.calcTokenAmount(amount);
    uint contid = contUser.contributeMsgValue(address(campaign), amount);
    // uint contid = campaign.contributeMsgValue.gas(3000000).value(amount)(defaultValues);
    var (csender, camount, ccreated) = campaign.contributions(contid);
    assertEq(csender, address(contUser));
    assertEq(camount, amount, "amount cont.");
    assertEq(ccreated > 0, true);
    assertEq(campaign.totalContributions(), previousContributionCount + 1, "total cont.");
    assertEq(campaign.balance, previousCampaignBalance + amount, "camp balance");
    assertEq(tokenAmount > 0, true, "token cal amount greater than zero");
    assertEq(target.balances(csender), previoudBalance + tokenAmount, "tokens issued properly balance");
    assertEq(target.tokensIssued(), previousTokensIssued + tokenAmount, "tokens issued properly");
    assertEq(campaign.stage(), expectedStage, "stage still operational");
  }

  function test_a3_makeValidContributions_increaseBlockBy223() {
    makeValidContribution((10 * 1 ether), 0);
    makeValidContribution((100 * 1 ether), 0);
    makeValidContribution((2234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((423 * 1 ether), 0);
    makeValidContribution((4234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((87 * 1 ether), 0);
    makeValidContribution((9 * 1 ether), 0);
    makeValidContribution((7 * 1 ether), 0);
    makeValidContribution((11 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((2 * 1 ether), 0);
    makeValidContribution((132 * 1 ether), 0);
    makeValidContribution((42 * 1 ether), 0);
    makeValidContribution((53 * 1 ether), 0);
    makeValidContribution((890 * 1 ether), 0);
    makeValidContribution((1000 * 1 ether), 0);
    makeValidContribution((53 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((987 * 1 ether), 0);
    makeValidContribution((107 * 1 ether), 0);

    log_uint(this.balance / (1 ether), "balance in ether");
    log_uint(target.tokensIssued(), "tokens issued");
  }

  function test_a4_makeValidContributions_increaseBlockBy1145() {
    makeValidContribution((10 * 1 ether), 0);
    makeValidContribution((100 * 1 ether), 0);
    makeValidContribution((2234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((423 * 1 ether), 0);
    makeValidContribution((4234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((87 * 1 ether), 0);
    makeValidContribution((9 * 1 ether), 0);
    makeValidContribution((7 * 1 ether), 0);
    makeValidContribution((11 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((2 * 1 ether), 0);
    makeValidContribution((132 * 1 ether), 0);
    makeValidContribution((42 * 1 ether), 0);
    makeValidContribution((53 * 1 ether), 0);
    makeValidContribution((890 * 1 ether), 0);
    makeValidContribution((1000 * 1 ether), 0);
    makeValidContribution((53 * 1 ether), 0);
    makeValidContribution((2424 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((987 * 1 ether), 0);
    makeValidContribution((107 * 1 ether), 0);

    log_uint(this.balance / (1 ether), "balance in ether");
    log_uint(target.tokensIssued(), "tokens issued");
  }

  function test_a4_makeValidContributions_increaseBlockBy8585() {
    makeValidContribution((3354 * 1 ether), 0);
    makeValidContribution((3 * 1 ether), 0);
    makeValidContribution((545 * 1 ether), 0);
    makeValidContribution((233 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((423 * 1 ether), 0);
    makeValidContribution((4234 * 1 ether), 0);
    makeValidContribution((23 * 1 ether), 0);
    makeValidContribution((87 * 1 ether), 0);
    makeValidContribution((32 * 1 ether), 0);
    makeValidContribution((72 * 1 ether), 0);
    makeValidContribution((11 * 1 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((2 * 1 ether), 0);
    makeValidContribution((1132 * 1 ether), 0);
    makeValidContribution((42 * 1 ether), 0);
    makeValidContribution((535 * 1 ether), 0);
    makeValidContribution((890 * 1 ether), 0);
    makeValidContribution((1000 * 1 ether), 0);
    makeValidContribution((534 * 1 ether), 0);
    makeValidContribution((2424 ether), 0);
    makeValidContribution((1 * 1 ether), 0);
    makeValidContribution((3987 * 1 ether), 0);
    makeValidContribution((107 * 1 ether), 0);

    log_uint(this.balance / (1 ether), "balance in ether");
    log_uint(target.tokensIssued(), "tokens issued");
  }

  function test_a5_multipleContributionsOneUser() {
    uint amountEther = (1 * 1 ether) + (3242 * 1 ether);

    makeValidContribution((1 * 1 ether), 0, address(campUser));
    makeValidContribution((3242 * 1 ether), 0, address(campUser));

    assertEq(target.balances(campUser), target.calcTokenAmount(amountEther), "token balance correct");
  }

  function test_a6_lastContribution_triggerEarlySuccess() {
    uint amount = target.price() * (target.tokenCap() - target.tokensIssued());
    makeValidContribution(amount, 2);
    assertEq(campaign.stage(), 2, "stage is 2 success");
  }

  function test_a7_attemptInvalidTokenClaim_freezePeriod_shouldThrow() {
    campUser.claimTokens(address(target));
  }

  function test_a7_attemptInvalidTokenClaim_fromThis_freezePeriod_shouldThrow() {
    target.claim();
  }

  function test_a8_validTokenClaim_increaseBlockBy13000() {
    assertEq(token.balanceOf(address(this)), 0, "token balance is zero");
    assertEq(target.claimed(address(this)), false, "claimed is false");
    target.claim();
    assertEq(token.balanceOf(address(this)), target.balances(address(this)), "token balance is now what was owed");
    assertEq(target.claimed(address(this)), true, "claimed is true");
    assertEq(campaign.stage(), 2, "stage is 2 success");
  }

  function test_a9_validTokenClaim_increaseBlockBy10() {
    assertEq(token.balanceOf(address(campUser)), 0, "token balance is zero");
    assertEq(target.claimed(address(campUser)), false, "claimed is false");
    campUser.claimTokens(address(target));
    assertEq(token.balanceOf(address(campUser)), target.balances(address(campUser)), "token balance is now what was owed");
    assertEq(target.claimed(address(campUser)), true, "claimed is true");
    assertEq(campaign.stage(), 2, "stage is 2 success");
    assertEq(campaign.beneficiary(), address(beneficiary), "ben is right");
  }

  function test_b1_attemptPayoutToBeneficiary() {
    assertEq(campaign.stage(), 2, "stage is 2 success");
    uint prevBalance = beneficiary.balance;
    assertEq(prevBalance, 3000000, "prev balance for some gas");
    assertEq(campaign.balance > 0, true, "campaign has balance");
    beneficiary.payoutToBeneficiary(address(campaign));
    assertEq(beneficiary.balance, campaign.amountRaised() + prevBalance, "beneficiary balance increased");
    assertEq(campaign.balance, 0, "camp balance is zero");
  }

  function test_b3_invalidContribution_increaseBlockBy10_shouldThrow() {
    campaign.contributeMsgValue.gas(3000000).value(0)(defaultValues);
  }

  function test_b3_invalidContribution2_increaseBlockBy10_shouldThrow() {
    campaign.contributeMsgValue.gas(3000000).value(2423243)(defaultValues);
  }

  function test_b3_invalidContribution3_increaseBlockBy10_shouldThrow() {
    campaign.contributeMsgValue.gas(3000000).value(campaign.fundingCap())(defaultValues);
  }

  function test_b3_invalidDoubleTokenClaim_increaseBlockBy10_shouldThrow() {
    campUser.claimTokens(address(target));
  }

  function test_b4_invalidDoubleTokenClaim_increaseBlockBy10_shouldThrow() {
    target.claim();
  }
}
