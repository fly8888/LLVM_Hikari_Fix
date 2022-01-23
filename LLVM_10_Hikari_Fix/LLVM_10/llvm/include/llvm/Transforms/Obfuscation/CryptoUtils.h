#ifndef LLVM_CryptoUtils_H
#define LLVM_CryptoUtils_H

#include "llvm/Support/ManagedStatic.h"

#include <stdint.h>
#include <cstdio>
#include <string>
#include <random>
#include <map>
namespace llvm {

class CryptoUtils;
extern ManagedStatic<CryptoUtils> cryptoutils;
class CryptoUtils {
public:
  CryptoUtils();
  ~CryptoUtils();
  void prng_seed(std::uint_fast64_t seed);
  void prng_seed();
  template <typename T>
  T get(){
    std::uint_fast64_t num=get_raw();
    return static_cast<T>(num);
  };
  //Return a value in [0,max)
  uint32_t get_range(uint32_t max){
    return get_range(0,max);
  }
  uint32_t get_range(uint32_t min,uint32_t max);
  uint32_t get_uint32_t(){
    return get<uint32_t>();
  };
  uint64_t get_uint64_t(){
    return get<uint64_t>();
  };
  uint32_t get_uint8_t(){
    return get<uint8_t>();
  };
  uint32_t get_uint16_t(){
    return get<uint16_t>();
  };
  // Scramble32 originally uses AES to generates the mapping relationship between a BB and its switchvar
  // Hikari updates this by doing this using mt19937_64 in C++ STLs which is a faster but less cryprographically secured
  // This method try to find the corresponding value from the VMap first, if not then use RNG to generate,fill and return the value
  uint32_t scramble32(uint32_t in,std::map<uint32_t/*IDX*/,uint32_t/*VAL*/>& VMap);
  private:
    std::mt19937_64* eng=nullptr;
    std::uint_fast64_t get_raw();
};
}

#endif // LLVM_CryptoUtils_H