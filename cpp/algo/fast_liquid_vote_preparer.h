#pragma once
#include "liquid_democracy.h"

namespace asr {
struct Node {
  voter_id_t address;
  // address_t address;
  vpower_t stake;
  sequence_t index;     // preorder index
  sequence_t endpoint;  // maximum preorder index among the node’s children
                        // (include multi-level).
  uint64_t leftbracket; // The first index where the node appears in the bracket
                        // sequence.
  uint64_t rightbracket; // The second index where the node appears in the
                         // bracket sequence.
  vpower_t power; // Node’s total voting power (including its children’s).

  option_id_t candidate; // used for onchain.
  bool exists;           // used for onchain.

};

typedef std::shared_ptr<Node> node_t;

class FastLiquidVotePreparer {
public:
  FastLiquidVotePreparer(const LiquidDemocracy &democracy);

  void preorder();

  node_t get_voter_info(voter_id_t voter) const;

protected:
  std::vector<voter_id_t> get_all_voters_without_delegation() const;

  void preorder_node(const node_t &node, sequence_t &n, uint64_t &n0);

protected:
  // std::unordered_map<voter_id_t, sequence_t> m_voter_sids;
  const LiquidDemocracy &m_democracy;
  std::unordered_map<voter_id_t, node_t> m_voter_nodes;
  std::unordered_map<sequence_t, node_t> m_seq_nodes;
};
} // namespace asr

std::ostream &operator<<(std::ostream &os, const asr::Node &dt);
