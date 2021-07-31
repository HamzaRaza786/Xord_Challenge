const { expect } = require("chai");
describe("Erc1484 testing", function () {
  it("Deployment should check if identity exists", async function () {
    const [owner,addr1,addr2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Erc1484");

    const hardhatToken = await Token.deploy();
     expect(hardhatToken.createIdentity(owner.address,[addr1.address],[addr2.address])).to.emit(
      hardhatToken,"IdentityCreated").withArgs(owner.address,1,owner.address,owner.address,[addr1.address],[addr2.address],false
    );
    expect(await hardhatToken.identityExists(1)).to.equal(true);
  });
});
describe("Erc1484 testing", function () {
  it("Deployment should check if identity exists", async function () {
    const [owner,addr1,addr2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Erc1484");

    const hardhatToken = await Token.deploy();
     expect(hardhatToken.createIdentity(owner.address,[addr1.address],[addr2.address])).to.emit(
      hardhatToken,"IdentityCreated").withArgs(owner.address,1,owner.address,owner.address,[addr1.address],[addr2.address],false
    );
    expect(await hardhatToken.hasIdentity(owner.address)).to.equal(true);
  });
});
describe("Erc1484 testing", function () {
  it("Deployment should check Ein", async function () {
    const [owner,addr1,addr2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Erc1484");

    const hardhatToken = await Token.deploy();
     expect(hardhatToken.createIdentity(owner.address,[addr1.address],[addr2.address])).to.emit(
      hardhatToken,"IdentityCreated").withArgs(owner.address,1,owner.address,owner.address,[addr1.address],[addr2.address],false
    );
    expect(await hardhatToken.getEIN(owner.address)).to.equal(1);
  });
});
describe("Erc1484 testing", function () {
  it("Deployment should check for associated Address", async function () {
    const [owner,addr1,addr2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Erc1484");

    const hardhatToken = await Token.deploy();
     expect(hardhatToken.createIdentity(owner.address,[addr1.address],[addr2.address])).to.emit(
      hardhatToken,"IdentityCreated").withArgs(owner.address,1,owner.address,owner.address,[addr1.address],[addr2.address],false
    );
    await hardhatToken.createIdentity(owner.address,[addr1.address],[addr2.address]);
    expect(await hardhatToken.isAssociatedAddressFor(2,owner.address)).to.equal(true);
  });
});
describe("Erc1484 testing", function () {
  it("Check for Provider", async function () {
    const [owner,addr1,addr2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Erc1484");

    const hardhatToken = await Token.deploy();
     expect(hardhatToken.createIdentity(owner.address,[addr1.address],[addr2.address])).to.emit(
      hardhatToken,"IdentityCreated").withArgs(owner.address,1,owner.address,owner.address,[addr1.address],[addr2.address],false
    );
    await hardhatToken.createIdentity(owner.address,[addr1.address],[addr2.address]);
    expect(await hardhatToken.isProviderFor(2,addr1.address)).to.equal(true);
  });
});
describe("Erc1484 testing", function () {
  it("Check for Resolver", async function () {
    const [owner,addr1,addr2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Erc1484");

    const hardhatToken = await Token.deploy();
     expect(hardhatToken.createIdentity(owner.address,[addr1.address],[addr2.address])).to.emit(
      hardhatToken,"IdentityCreated").withArgs(owner.address,1,owner.address,owner.address,[addr1.address],[addr2.address],false
    );
    await hardhatToken.createIdentity(owner.address,[addr1.address],[addr2.address]);
    expect(await hardhatToken.isResolverFor(2,addr2.address)).to.equal(true);
  });
});
describe("Erc1484 testing", function () {
  it("Check Identity Delegated", async function () {
    const [owner,addr1,addr2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Erc1484");

    const hardhatToken = await Token.deploy();
    // let c = ethers.utils.id(
    //   ethers.utils.defaultAbiCoder.encode(["address","string","address","address","address[]","address[]",
    //   "uint"],[hardhatToken.address,
    //       "I authorize the creation of an Identity on my behalf.",
    //       owner.address,owner.address,[addr1.address],[addr2.address],1]
    //   ));
     let c0 = await ethers.utils.arrayify(ethers.utils.id("Hello How are you?"));
    let sig = await owner.signMessage(c0);
  let sig2 = await ethers.utils.splitSignature(sig);
  await expect( hardhatToken.createIdentityDelegated(owner.address,owner.address,[addr1.address],[addr2.address],sig2.v,sig2.r,sig2.s,1)).to.emit(
      hardhatToken,"IdentityCreated").withArgs(owner.address,1,owner.address,owner.address,[addr1.address],[addr2.address],true);
    await hardhatToken.createIdentity(owner.address,[addr1.address],[addr2.address]);
    expect(await hardhatToken.isResolverFor(2,addr2.address)).to.equal(true);
  });
});
describe("Erc1484 testing", function () {

  let Token 
  let hardhatToken
  let c0 
  let sig 
  let sig2 
  let owner;
  let addr1;
  let addr2;
  beforeEach(async function(){
     [owner,addr1,addr2] = await ethers.getSigners();

     Token = await ethers.getContractFactory("Erc1484");

     hardhatToken = await Token.deploy();
      c0 = await ethers.utils.arrayify(ethers.utils.id("Hello How are you?"));
     sig = await owner.signMessage(c0);
     sig2 = await ethers.utils.splitSignature(sig);
  await expect( hardhatToken.createIdentityDelegated(owner.address,owner.address,[addr1.address],[addr2.address],sig2.v,sig2.r,sig2.s,1)).to.emit(
      hardhatToken,"IdentityCreated").withArgs(owner.address,1,owner.address,owner.address,[addr1.address],[addr2.address],true);
    await hardhatToken.createIdentity(owner.address,[addr1.address],[addr2.address]);
  })
  it("Check Associated Address", async function () {
   
    await expect( hardhatToken.addAssociatedAddress(owner.address,owner.address,sig2.v,sig2.r,sig2.s,1)).to.emit(
      hardhatToken,"AssociatedAddressAdded").withArgs(owner.address,2,owner.address,owner.address);
  });
  it("Check Associated Address Delegated", async function () {
    c1 = await ethers.utils.arrayify(ethers.utils.id("Hello How are you?"));
     sig3 = await addr2.signMessage(c1);
     sig4 = await ethers.utils.splitSignature(sig3);
    await expect( hardhatToken.addAssociatedAddressDelegated(owner.address,addr2.address,[sig2.v,sig4.v],[sig2.r,sig4.r],[sig2.s,sig4.s],[1,2])).to.emit(
      hardhatToken,"AssociatedAddressAdded").withArgs(owner.address,2,owner.address,addr2.address);
  });
  it("Remove Associated Address", async function () {
   
    await expect( hardhatToken.removeAssociatedAddress()).to.emit(
      hardhatToken,"AssociatedAddressRemoved").withArgs(owner.address,2,owner.address);
  });
  it("Remove Associated Address thru Delegation", async function () {
   
    await expect( hardhatToken.removeAssociatedAddressDelegated(owner.address,sig2.v,sig2.r,sig2.s,1)).to.emit(
      hardhatToken,"AssociatedAddressRemoved").withArgs(owner.address,2,owner.address);
  });
  it("Add providers", async function () {
   
    await expect( hardhatToken.addProviders([addr2.address])).to.emit(
      hardhatToken,"ProviderAdded").withArgs(owner.address,2,addr2.address,false);
  });
  it("Add providers For", async function () {
   
    await expect( hardhatToken.connect(addr1).addProvidersFor(2,[addr2.address])).to.emit(
      hardhatToken,"ProviderAdded").withArgs(addr1.address,2,addr2.address,true);
  });
  it("Remove providers", async function () {
   
    await expect( hardhatToken.removeProviders([addr1.address])).to.emit(
      hardhatToken,"ProviderRemoved").withArgs(owner.address,2,addr1.address,false);
  });
  it("Remove providers For", async function () {
   
    await expect( hardhatToken.connect(addr1).removeProvidersFor(2,[addr1.address])).to.emit(
      hardhatToken,"ProviderRemoved").withArgs(addr1.address,2,addr1.address,true);
  });

  it("Add Resolvers", async function () {
   
    await expect( hardhatToken.addResolvers([addr1.address])).to.emit(
      hardhatToken,"ResolverAdded").withArgs(owner.address,2,addr1.address);
  });
  it("Add Resolvers For", async function () {
   
    await expect( hardhatToken.addResolversFor(2,[addr1.address])).to.emit(
      hardhatToken,"ResolverAdded").withArgs(owner.address,2,addr1.address);
  });
  it("Remove resolvers", async function () {
   
    await expect( hardhatToken.removeResolvers([addr2.address])).to.emit(
      hardhatToken,"ResolverRemoved").withArgs(owner.address,2,addr2.address);
  });
  it("Remove resolvers For", async function () {
   
    await expect( hardhatToken.removeResolversFor(2,[addr2.address])).to.emit(
      hardhatToken,"ResolverRemoved").withArgs(owner.address,2,addr2.address);
  });
  it("triggerRecoveryAddressChange", async function () {
   
    await expect( hardhatToken.triggerRecoveryAddressChange(addr1.address)).to.emit(
      hardhatToken,"RecoveryAddressChangeTriggered").withArgs(owner.address,2,owner.address,addr1.address);
  });
  it("triggerRecoveryAddressChangeFor", async function () {
   
    await expect( hardhatToken.triggerRecoveryAddressChangeFor(2,addr1.address)).to.emit(
      hardhatToken,"RecoveryAddressChangeTriggered").withArgs(owner.address,2,owner.address,addr1.address);
  });
  it("triggerRecovery", async function () {
    await expect( hardhatToken.triggerRecovery(2,addr1.address,sig2.v,sig2.r,sig2.s,1)).to.emit(
      hardhatToken,"RecoveryTriggered").withArgs(owner.address,2,[owner.address],addr1.address);
  });
  it("triggerRecovery", async function () {
    await expect( hardhatToken.triggerRecovery(2,addr1.address,sig2.v,sig2.r,sig2.s,1)).to.emit(
      hardhatToken,"RecoveryTriggered").withArgs(owner.address,2,[owner.address],addr1.address);
  });
  it("triggerDestruction", async function () {
    await expect( hardhatToken.triggerDestruction(2,[],[],true)).to.emit(
      hardhatToken,"IdentityDestroyed").withArgs(owner.address,2,owner.address,true);
  });
});
