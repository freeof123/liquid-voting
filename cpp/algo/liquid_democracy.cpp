#include "liquid_democracy.h"

namespace asr {
sequence_t virtual_sid = 0;

void LiquidDemocracy::assign_voting_power(voter_id_t id, vpower_t power) {
  if (m_powers.find(id) != m_powers.end()) {
    LOG(INFO) << "ignore " << id;
    return;
  }
  m_powers[id] = power;
  m_v_to_children[id] = std::vector<voter_id_t>();
}

void LiquidDemocracy::delegate(voter_id_t from, voter_id_t to) {
  if (from == to) {
    return;
  }
  if (check_circle(from, to)) {
    return;
  }

  if (m_v_to_parents.find(from) != m_v_to_parents.end()) {
    voter_id_t old = m_v_to_parents[from];

    std::vector<voter_id_t> &children = m_v_to_children[old];
    for (std::vector<voter_id_t>::iterator it = children.begin();
         it != children.end(); ++it) {
      if (*it == from) {
        children.erase(it);
        break;
      }
    }
  }
  m_v_to_parents[from] = to;
  if (m_v_to_children.find(to) == m_v_to_children.end()) {
    m_v_to_children[to] = std::vector<voter_id_t>();
  }
  m_v_to_children[to].push_back(from);
}

bool LiquidDemocracy::check_circle(voter_id_t from, voter_id_t to) const {
  std::unordered_set<voter_id_t> visited;
  visited.insert(from);
  visited.insert(to);
  voter_id_t next = to;
  while (m_v_to_parents.find(next) != m_v_to_parents.end()) {
    next = m_v_to_parents.find(next)->second;

    if (visited.find(next) != visited.end()) {
      return true;
    }
    visited.insert(next);
  }
  return false;
}

void LiquidDemocracy::undelegate(voter_id_t from, voter_id_t to) {
  std::vector<voter_id_t> &children = m_v_to_children[to];
  for (std::vector<voter_id_t>::iterator it = children.begin();
       it != children.end(); ++it) {
    if (*it == from) {
      children.erase(it);
      break;
    }
  }

  m_v_to_parents.erase(from);
}

option<voter_id_t> LiquidDemocracy::parent(voter_id_t voter) const {
  if (m_v_to_parents.find(voter) == m_v_to_parents.end()) {
    return none;
  }
  return m_v_to_parents.find(voter)->second;
}

uint64_t LiquidDemocracy::voter_number() const { return m_powers.size(); }

std::vector<voter_id_t> LiquidDemocracy::all_voters() const {
  std::vector<voter_id_t> vs;
  for (auto kv : m_powers) {
    vs.push_back(kv.first);
  }
  return vs;
}

const std::vector<voter_id_t> &
LiquidDemocracy::children(voter_id_t voter) const {
  return m_v_to_children.find(voter)->second;
}

vpower_t LiquidDemocracy::power(voter_id_t voter) const {
  return m_powers.find(voter)->second;
}

LiquidVote::LiquidVote(const LiquidDemocracy &democracy)
    : m_democracy(democracy) {}

void LiquidVote::add_option(option_id_t option_id) { m_ballots[option_id] = 0; }

vpower_t LiquidVote::get_ballots(option_id_t option_id) const {
  return m_ballots.find(option_id)->second;
}

} // namespace asr

std::ostream &operator<<(std::ostream &os, const asr::LiquidDemocracy &dt) {
  os << "\ndelegation graph: \n";
  for (auto kv : dt.delegate_graph()) {
    os << "\t" << kv.first << " -> " << kv.second;
  }
  return os;
}
std::ostream &operator<<(std::ostream &os, const asr::NaiveLiquidVote &dt) {
  os << "\nvote status: \n";
  for (auto kv : dt.vote_status()) {
    os << "\t" << kv.first << " -> " << kv.second;
  }
  return os;
}
