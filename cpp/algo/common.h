#pragma once

#include <cstdint>
#include <glog/logging.h>
#include <iostream>
#include <memory>
#include <queue>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

namespace asr {

template <typename T> class option;

template <typename T> class option {
public:
  option(const T &v) : m_is_none(false), m_v(v) {}
  option(const option<void> &v) : m_is_none(true), m_v() {}

  option &operator=(const option<T> &v) {
    if (&v == this)
      return *this;
    m_is_none = false;
    m_v = v.value();
    return *this;
  }

  T &value() { return m_v; }

  const T &value() const { return m_v; }
  bool is_none() const { return m_is_none; }

protected:
  bool m_is_none;
  T m_v;
};

template <> class option<void> {};

extern option<void> none;

} // namespace asr
