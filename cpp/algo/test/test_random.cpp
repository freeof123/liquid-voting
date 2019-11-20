#include "../fast_liquid_vote.h"
#include "../liquid_democracy.h"
#include <cstdlib>
#include <gtest/gtest.h>
#include <iostream>

using namespace asr;

TEST(random, simple) {
  LiquidDemocracy d;
  size_t voter_num = 1000;
  for (uint64_t i = 1; i <= voter_num; ++i) {
    d.assign_voting_power(i, i);
    // if (i > 1) {
    // d.delegate(i, i - 1);
    //}
  }

  for (int i = 0; i < voter_num * 2; ++i) {
    uint64_t i1 = rand() % (voter_num - 1) + 1;
    uint64_t i2 = rand() % (voter_num - 1) + 1;
    if (i1 == i2)
      continue;
    d.delegate(i1, i2);
  }
  // LOG(INFO) << d;

  NaiveLiquidVote lv(d);
  FastLiquidVote flv(d);
  flv.init();

  size_t opt_num = 4;
  for (size_t i = 1; i <= opt_num; ++i) {
    lv.add_option(i);
    flv.add_option(i);
  }

  size_t vote_op_num = 256;

  std::unordered_set<voter_id_t> voted;
  for (int i = 0; i < vote_op_num; ++i) {
    uint64_t i1 = rand() % (voter_num - 1) + 1;
    uint64_t i2 = rand() % (opt_num - 1) + 1;
    if (voted.find(i1) != voted.end()) {
      continue;
    }
    lv.vote(i1, i2);
    flv.vote(i1, i2);
    voted.insert(i1);

    bool uneq = false;
    for (size_t i = 1; i <= opt_num; ++i) {
      vpower_t b1 = lv.get_ballots(i);
      vpower_t b2 = flv.get_ballots(i);
      // LOG(INFO) << i << ": " << b1 << ", " << b2;
      if (b1 != b2) {
        uneq = true;
        EXPECT_TRUE(false);
      }
    }
    // LOG(INFO) << lv;
    if (uneq) {
      LOG(INFO) << "------------------";
    }
  }
}
