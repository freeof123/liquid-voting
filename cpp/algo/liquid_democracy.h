#pragma once
#include "common.h"

namespace asr {
typedef uint64_t option_id_t;
typedef uint64_t voter_id_t;
typedef uint64_t vpower_t;
typedef uint64_t sequence_t;

extern sequence_t virtual_sid;

class LiquidDemocracy {
public:
  void assign_voting_power(voter_id_t id, vpower_t power);
  void delegate(voter_id_t from, voter_id_t to);
  void undelegate(voter_id_t from, voter_id_t to);

  option<voter_id_t> parent(voter_id_t voter) const;
  const std::vector<voter_id_t> &children(voter_id_t voter) const;

  vpower_t power(voter_id_t voter) const;

  uint64_t voter_number() const;

  std::vector<voter_id_t> all_voters() const;

  inline const std::unordered_map<voter_id_t, voter_id_t> &
  delegate_graph() const {
    return m_v_to_parents;
  }

protected:
  bool check_circle(voter_id_t from, voter_id_t to) const;

protected:
  std::unordered_map<voter_id_t, vpower_t> m_powers;
  std::unordered_map<voter_id_t, voter_id_t> m_v_to_parents;
  std::unordered_map<voter_id_t, std::vector<voter_id_t>> m_v_to_children;
};

class LiquidVote {
public:
  LiquidVote(const LiquidDemocracy &delegation);

  void add_option(option_id_t option_id);

  virtual void vote(voter_id_t voter, option_id_t option_id) = 0;

  vpower_t get_ballots(option_id_t option_id) const;

protected:
  std::unordered_map<option_id_t, vpower_t> m_ballots;
  const LiquidDemocracy &m_democracy;
};

class NaiveLiquidVote : public LiquidVote {
public:
  NaiveLiquidVote(const LiquidDemocracy &delegation);
  virtual void vote(voter_id_t voter, option_id_t option_id);

  inline const std::unordered_map<voter_id_t, option_id_t> &
  vote_status() const {
    return m_voted;
  }

protected:
  vpower_t get_total_power(voter_id_t voter);

  option<voter_id_t> get_voted_parent(voter_id_t voter);

protected:
  std::unordered_map<voter_id_t, option_id_t> m_voted;
};

} // namespace asr

std::ostream &operator<<(std::ostream &os, const asr::LiquidDemocracy &dt);
std::ostream &operator<<(std::ostream &os, const asr::NaiveLiquidVote &dt);

