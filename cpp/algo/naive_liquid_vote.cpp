#include "liquid_democracy.h"
#include <glog/logging.h>

namespace asr {

NaiveLiquidVote::NaiveLiquidVote(const LiquidDemocracy &democracy)
    : LiquidVote(democracy) {}

void NaiveLiquidVote::vote(voter_id_t voter, option_id_t option_id) {
  vpower_t p = get_total_power(voter);
  if (m_voted.find(voter) != m_voted.end()) {
    option_id_t old = m_voted[voter];
    if (old == option_id)
      return;
    m_ballots[old] -= p;
  }
  m_ballots[option_id] += p;
  m_voted[voter] = option_id;
  option<voter_id_t> parent = get_voted_parent(voter);
  if (parent.is_none()) {
    return;
  }
  if (m_voted.find(parent.value()) != m_voted.end()) {
    option_id_t option = m_voted[parent.value()];
    m_ballots[option] -= p;
  }
}

vpower_t NaiveLiquidVote::get_total_power(voter_id_t voter) {
  std::vector<voter_id_t> to_visit;
  to_visit.push_back(voter);
  vpower_t ret = 0;
  while (!to_visit.empty()) {
    voter_id_t last = to_visit.back();
    ret += m_democracy.power(last);

    to_visit.pop_back();
    const std::vector<voter_id_t> &children = m_democracy.children(last);
    for (auto c : children) {
      if (m_voted.find(c) == m_voted.end()) {
        to_visit.push_back(c);
      }
    }
  }
  return ret;
}

option<voter_id_t> NaiveLiquidVote::get_voted_parent(voter_id_t voter) {
  voter_id_t next = voter;
  while (!m_democracy.parent(next).is_none()) {
    next = m_democracy.parent(next).value();
    if (m_voted.find(next) != m_voted.end()) {
      break;
    }
  }
  if (next == voter) {
    return none;
  } else {
    return next;
  }
}

} // namespace asr
