#include "fast_liquid_vote.h"
#include "liquid_democracy.h"

namespace asr {
FastLiquidVote::FastLiquidVote(const LiquidDemocracy &democracy)
    : LiquidVote(democracy), m_preparer(democracy), m_default_node(new Node()),
      m_b(m_default_node) {
  m_b.set_default_value(m_default_node);
}

void FastLiquidVote::init() { m_preparer.preorder(); }

void FastLiquidVote::vote(voter_id_t voter, option_id_t option_id) {
  node_t n = m_preparer.get_voter_info(voter);

  n->candidate = option_id;
  actual_vote(n, option_id);
}

void FastLiquidVote::actual_vote(node_t node, option_id_t option_id) {
  // We ignore the merkel proof check part

  uint64_t n = m_democracy.voter_number();
  const auto &vs = m_democracy.all_voters();

  // m_b[node->index] = node;
  m_b.insert(node->index, node);
  update2(node->leftbracket, node->leftbracket, 1, 2 * n, 1, 0);
  update2(node->rightbracket, node->rightbracket, 1, 2 * n, 1, 0);
  uint64_t t =
      node->power - m_score[node->leftbracket] + m_score[node->rightbracket];

  m_ballots[node->candidate] += t;

  if (m_voted.find(node->address) != m_voted.end()) {
    option_id_t old = m_voted[node->address];
    LOG(INFO) << "remove for old: " << old << ", " << t;
    m_ballots[old] -= t;
  } else {
    update1(node->index, node->index, 1, n, 1, 0);
    node_t parent = m_b[m_nearest_parent[node->index]];
    if (parent && parent->exists) {
      m_ballots[parent->candidate] -= t;
      update1(node->index + 1, node->endpoint, 1, n, 1, node->index);
      update2(parent->leftbracket, node->leftbracket - 1, 1, 2 * n, 1, t);
    } else {
      update1(node->index + 1, node->endpoint, 1, n, 1, node->index);
      update2(1, node->leftbracket - 1, 1, 2 * n, 1, t);
    }
  }

  m_voted[node->address] = option_id;
}

void FastLiquidVote::update1(uint64_t L, uint64_t R, uint64_t l, uint64_t r,
                             uint64_t k, uint64_t v) {
  if (L > R) {
    return;
  }
  if (L == l && R == r) {
    if (v > m_lazy1[k]) {
      m_lazy1[k] = v;
    }
    if (L == R) {
      m_nearest_parent[L] = m_lazy1[k];
    }
  } else {
    uint64_t m = (l + r) / 2;
    if (m_lazy1[2 * k] < m_lazy1[k]) {
      m_lazy1[2 * k] = m_lazy1[k];
    }
    if (m_lazy1[2 * k + 1] < m_lazy1[k]) {
      m_lazy1[2 * k + 1] = m_lazy1[k];
    }
    if (L <= m) {
      update1(L, std::min(m, R), l, m, 2 * k, v);
    }
    if (R > m) {
      update1(std::max(m + 1, L), R, m + 1, r, 2 * k + 1, v);
    }
  }
}

void FastLiquidVote::update2(uint64_t L, uint64_t R, uint64_t l, uint64_t r,
                             uint64_t k, uint64_t v) {
  if (L > R) {
    return;
  }
  if (L == l && R == r) {
    m_lazy2[k] = m_lazy2[k] + v;
    if (L == R) {
      m_score[L] = m_lazy2[k];
    }
  } else {
    uint64_t m = (l + r) / 2;
    m_lazy2[2 * k] = m_lazy2[2 * k] + m_lazy2[k];
    m_lazy2[2 * k + 1] = m_lazy2[2 * k + 1] + m_lazy2[k];
    m_lazy2[k] = 0;
    if (L <= m) {
      update2(L, std::min(m, R), l, m, 2 * k, v);
    }
    if (R > m) {
      update2(std::max(m + 1, L), R, m + 1, r, 2 * k + 1, v);
    }
  }
}

} // namespace asr
