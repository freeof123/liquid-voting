const LiquidDemocracy = artifacts.require("LiquidDemocracy");
const { BN, constants, expectEvent, expectRevert } = require('openzeppelin-test-helpers');
const { expect } = require('chai');
const { VNode, VGraph } = require("./Preparer.js");
const { assert } = require('console');

const SimpleVote = artifacts.require('SimpleVote');
const LiquidVote = artifacts.require('LiquidVote');
const SimpleVoteFactory = artifacts.require('SimpleVoteFactory');
const LiquidVoteFactory = artifacts.require('LiquidVoteFactory');
const LinkCutTreeFactory = artifacts.require("LinkCutTreeFactory");

contract('TestChain', (accounts) => {

    let democracy = {};
    let vcount = 100;
    let vg = {};
    let svote = {};
    let lvote = {};

    context('init', () => {
    it('init', async() =>{
        democracy = await LiquidDemocracy.deployed();
        assert(democracy);
    		lctf = await LinkCutTreeFactory.deployed();
	    	await democracy.initLCT(lctf.address);
        vg = VGraph.createNew();
    }),


    //context("delegate", () => {
        it('test constructing delegate graph', async () => {
            console.log("test constructing delegate graph------------");
            // 这段代码首先建立一张代理图,自下往上建立代理关系
            /*
                                1
                               / \
                              2   3
                            / | \  \
                           4  5  6  7
                                     \
                                      8
                                     /
                                    9
            */
            for (i = 1; i < vcount; ++i) {
                await democracy.setWeight(accounts[i], 1);
                n = VNode.createNew(accounts[i], 1, 0, 0, 0, 0, 0);
                vg.addNode(n);
            }
            var arr = [[2, 1], [3, 1], [4, 2], [5, 2], [6, 2], [7, 3], [8, 7], [9, 8]];
            for (var i = 0; i < arr.length; ++i) {
                var delegator = arr[i][0];
                var delegatee = arr[i][1];
                console.log("%d -> %d\n", delegator, delegatee);
                succ = false;
                try {
                    await democracy.delegate(accounts[delegatee], { from: accounts[delegator] });
                    succ = true;
                }
                catch (error) {
                    //console.log(error);
                    console.log('retry...');
                }
                vg.addEdge(accounts[delegator], accounts[delegatee]);
                expect(succ).to.equal(true);
            }
        })

            , it('test circle delegate 1 -------', async () => {
                console.log("test circle delegate 1 -------");
                /*
                                    1
                                   / \
                                  2   3
                                / | \  \
                               4  5  6  7
                                        |
                                        8
                                       /
                                      9
                */
                var arr2 = [[1, 2], [1, 4], [1, 5], [1, 6], [1, 3], [1, 7], [1, 8], [1, 9], [2, 4], [2, 5], [2, 6], [3, 7], [3, 8], [3, 9], [7, 8], [7, 9], [8, 9]];

                for (var i = 0; i < arr2.length; ++i) {
                    var delegator = arr2[i][0];
                    var delegatee = arr2[i][1];
                    succ = false;
                    console.log("%d -> %d\n", delegator, delegatee);
                    try {
                        await democracy.delegate(accounts[delegatee], { from: accounts[delegator] });
                        succ = true;
                    }
                    catch (error) {
                        //console.log(error);
                        console.log('retry...');
                    }
                    // console.assert(succ === false, "not equal");
                    expect(succ).to.equal(false);
                }
            })

            , it('test change delegate 1-------', async () => {
                console.log('test change delegate 1-------');
                /*
                                    1                    1
                                   / \             / / / | \ \ \ \
                                  2   3            2 3 4 5 6 7 8 9
                                / | \  \
                               4  5  6  7------->
                                        |
                                        8
                                       /
                                      9
                */
                var arr2 = [[4, 1], [5, 1], [6, 1], [7, 1], [8, 1], [9, 1]];
                for (var i = 0; i < arr2.length; ++i) {
                    var delegator = arr2[i][0];
                    var delegatee = arr2[i][1];
                    succ = false;
                    console.log("%d -> %d\n", delegator, delegatee);
                    try {
                        await democracy.delegate(accounts[delegatee], { from: accounts[delegator] });
                        succ = true;
                    }
                    catch (error) {
                        //console.log(error);
                        console.log('retry...');
                    }
                    // console.assert(succ == true, "not equal");
                    expect(succ).to.equal(true);
                }
            })

            , it('test change delegate 2 -------', async () => {
                console.log('test change delegate 2 -------');
                /*
                                    1                    1
                                   / \             / / / | \ \ \ \
                                  2   3            2 3 4 5 6 7 8 9
                                / | \  \
                               4  5  6  7  <-------
                                        |
                                        8
                                       /
                                      9
                */
                var arr2 = [[4, 2], [5, 2], [6, 2], [7, 3], [8, 7], [9, 8]];
                // var arr2 = [[4, 2]];
                for (var i = 0; i < arr2.length; ++i) {
                    var delegator = arr2[i][0];
                    var delegatee = arr2[i][1];
                    succ = false;
                    console.log("%d -> %d\n", delegator, delegatee);
                    try {
                        await democracy.delegate(accounts[delegatee], { from: accounts[delegator] });
                        succ = true;
                    }
                    catch (error) {
                        //console.log(error);
                        console.log('retry...');
                    }
                    console.assert(succ == true, "not equal");
                    expect(succ).to.equal(true);
                }
            })

            , it('test undelegate and recovery', async () => {
                console.log('test undelegate and recovery');
                /*
                         1
                        / \
                      2    3
                    / | \   \
                   4  5  6  7
                            |
                            8
                            /
                            9
    */
                var arr2 = [[1, 2], [2, 1], [8, 7], [9, 8], [4, 2], [5, 2], [6, 2], [7, 3]];
                var res = [false, true, true, true, true, true, true, true]
                for (var i = 0; i < arr2.length; ++i) {
                    var delegator = arr2[i][0];
                    var delegatee = arr2[i][1];
                    console.log("%d undelegate\n", delegator);
                    succ = false;
                    try {
                        await democracy.undelegate({ from: accounts[delegator] });
                        succ = true;
                    }
                    catch (error) {
                        //console.log(error);
                        console.log('retry...');
                    }
                    console.log("%d -> %d\n", delegator, delegatee);
                    try {
                        await democracy.delegate(accounts[delegatee], { from: accounts[delegator] });
                        succ = true;
                    }
                    catch (error) {
                        //console.log(error);
                        console.log('retry...');
                    }
                    // console.assert(succ === res[i], "not equal");
                    expect(succ).to.equal(res[i]);
                }
            })

            , it('test two trees delegate', async () => {
                console.log('test undelegate and recovery');
                /*
                         1             11
                        / \           /
                      2    3  ---->  10
                    / | \   \        |
                   4  5  6  7        12
                            |
                            8
                            /
                            9
    */
                // var arr2 = [[10, 11], [12, 10], [10, 7], [1, 11], [1, 10],  [1, 11], [11, 12], [7,4], [7,5], [7,6], [7,3],[12,1],[12,2],[12,3]];
                var arr2 = [[10, 11], [12, 10], [10, 7], [1, 11], [1, 10],  [2, 1], [5, 2], [7,2], [7,5], [7,6], [7,3],[12,1],[12,2],[12,3]];
                var res =  [true,     true,     true,    true,    false,    false,   false, true,  true,  true,  true,  true,  true, true];
                for (var i = 0; i < arr2.length; ++i) {
                    var delegator = arr2[i][0];
                    var delegatee = arr2[i][1];
                    console.log("%d -> %d\n", delegator, delegatee);
                    succ = false;
                    try {
                        await democracy.delegate(accounts[delegatee], { from: accounts[delegator] });
                        succ = true;
                    }
                    catch (error) {
                        console.log("this is error: ", error);
                        console.log('retry...');
                    }
                    // console.assert(succ === res[i], "not equal");
                    expect(succ).to.equal(res[i]);
                }
            })

    })
});
