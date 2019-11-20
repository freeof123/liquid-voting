#include "fast_liquid_vote_preparer.h"

namespace asr {

FastLiquidVotePreparer::FastLiquidVotePreparer(const LiquidDemocracy &democracy)
    : m_democracy(democracy) {}

void FastLiquidVotePreparer::preorder() {
  std::vector<voter_id_t> vs = get_all_voters_without_delegation();
  sequence_t n = 0;
  uint64_t n0 = 0;
  for (voter_id_t v : vs) {
    node_t t = std::make_shared<Node>();
    t->address = v;
    preorder_node(t, n, n0);
  }
}

void FastLiquidVotePreparer::preorder_node(const node_t &node, sequence_t &n,
                                           uint64_t &n0) {
  n = n + 1;
  n0 = n0 + 1;
  node->leftbracket = n0;
  node->index = n;
  node->stake = m_democracy.power(node->address);
  node->power = node->stake;
  node->exists = true;
  const std::vector<voter_id_t> &children = m_democracy.children(node->address);
  for (voter_id_t v : children) {
    node_t t = std::make_shared<Node>();
    t->address = v;
    preorder_node(t, n, n0);
    node->power += t->power;
  }
  node->endpoint = n;
  n0++;
  node->rightbracket = n0;
  m_voter_nodes.insert(std::make_pair(node->address, node));
}

node_t FastLiquidVotePreparer::get_voter_info(voter_id_t voter) const {
  auto it = m_voter_nodes.find(voter);
  if (it != m_voter_nodes.end()) {
    return it->second;
  }
  return nullptr;
}

std::vector<voter_id_t>
FastLiquidVotePreparer::get_all_voters_without_delegation() const {
  std::vector<voter_id_t> to_visit = m_democracy.all_voters();

  std::vector<voter_id_t> result;

  for (const voter_id_t &v : to_visit) {
    option<voter_id_t> p = m_democracy.parent(v);
    if (p.is_none()) {
      result.push_back(v);
    }
  }
  return result;
}

} // namespace asr

std::ostream &operator<<(std::ostream &os, const asr::Node &dt) {
  os << "\tid:" << dt.address << "\n";
  os << "\tindex:" << dt.index << "\n";
  os << "\tstake:" << dt.stake << "\n";
  os << "\tpower:" << dt.power << "\n";
  os << "\tcandidate:" << dt.candidate;
  os << "\tleft:" << dt.leftbracket;
  os << "\tright:" << dt.rightbracket;
  return os;
}
