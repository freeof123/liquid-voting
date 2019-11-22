#pragma once
#include "fast_liquid_vote_preparer.h"
#include "liquid_democracy.h"
#include "mapping.h"

namespace asr {
class FastLiquidVote : public LiquidVote {
public:
  FastLiquidVote(const LiquidDemocracy &democracy);
  void init();

  virtual void vote(voter_id_t voter, option_id_t option_id);

protected:
  void actual_vote(node_t sid, option_id_t option_id);

  void update1(uint64_t L, uint64_t R, uint64_t l, uint64_t r, uint64_t k,
               uint64_t v);
  void update2(uint64_t L, uint64_t R, uint64_t l, uint64_t r, uint64_t k,
               uint64_t v);

protected:
  FastLiquidVotePreparer m_preparer;
  node_t m_default_node;
  Mapping<sequence_t, node_t>
      m_b; // Mapping from a node’s preorder index to the node.
  Mapping<sequence_t, sequence_t>
      m_nearest_parent; // Mapping from a node’s preorder index to its nearest
                        // voted parent’s preorder index.
  Mapping<uint64_t, sequence_t> m_lazy1;
  Mapping<uint64_t, sequence_t> m_lazy2;
  Mapping<uint64_t, sequence_t> m_score;
  std::unordered_map<voter_id_t, option_id_t> m_voted;
};

} // namespace asr

