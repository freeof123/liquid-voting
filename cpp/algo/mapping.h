#pragma once
#include "common.h"
#include <unordered_map>

namespace asr {

template <typename Key, typename Value> class Mapping {
public:
  Mapping() {}
  Mapping(const Value &default_value) : m_default_value(default_value) {}

  void insert(const Key &k, const Value &v) {
    m_data.insert(std::make_pair(k, v));
  }

  void set_default_value(const Value &v) {
    m_default_value = v;
  }

  void remove(const Key &k) { m_data.erase(k); }

  Value operator[](const Key &k) const {
    auto it = m_data.find(k);
    if (it == m_data.end()) {
      return m_default_value;
    }
    return it->second;
  }

  Value &operator[](const Key &k) {
    return m_data[k];
  }

protected:
  std::unordered_map<Key, Value> m_data;
  Value m_default_value;
};
} // namespace asr
