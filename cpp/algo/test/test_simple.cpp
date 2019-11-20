
#include "../fast_liquid_vote.h"
#include "../liquid_democracy.h"
#include <gtest/gtest.h>
#include <iostream>

using namespace asr;

TEST(simple, naive) {
  LiquidDemocracy d;
  for (uint64_t i = 1; i < 100; ++i) {
    d.assign_voting_power(i, i);
    if (i > 1) {
      d.delegate(i, i - 1);
    }
  }

  NaiveLiquidVote lv(d);
  lv.add_option(1);
  lv.vote(1, 1);
  vpower_t ballots = lv.get_ballots(1);
  EXPECT_TRUE(ballots == 4950);
}

TEST(simple, fast) {
  LiquidDemocracy d;
  for (uint64_t i = 1; i < 100; ++i) {
    d.assign_voting_power(i, i);
    if (i > 1) {
      d.delegate(i, i - 1);
    }
  }

  FastLiquidVote lv(d);
  lv.init();
  lv.add_option(1);
  lv.vote(1, 1);
  vpower_t ballots = lv.get_ballots(1);
  std::cout << "ballots: " << ballots << std::endl;
  EXPECT_TRUE(ballots == 4950);
}

