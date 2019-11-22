const LiquidDemocracy = artifacts.require("LiquidDemocracy");
const { BN, constants, expectEvent, expectRevert } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

contract('TestDemocracy', (accounts) => {

	let democracy = {};

	context('init', async () => {
		democracy = await LiquidDemocracy.deployed();
		assert.ok(democracy)
	})


	context("delegate", () => {
    it('assign', async() =>{
      total_fee = 0;
      //for(i = 0; i < accounts.length; ++i){
        //const t = await democracy.setWeight(accounts[0], 100);
      for(i = 0; i < 10; ++i){
        const t = await democracy.setWeight(accounts[i], 1);
        //console.log(t);
        const gasUsed = t.receipt.gasUsed;
        total_fee += gasUsed;
      }
      console.log('gas used: ', total_fee);
    }),
		//it('delegate circle', async () => {
      //for(i = 0; i < 5; ++i){
				//await democracy.delegate(accounts[i + 1], {from:accounts[i]});
      //}
      //await expectRevert(democracy.delegate(accounts[0], {from:accounts[5]}), "cannot be circle");
		//});
	})
});
