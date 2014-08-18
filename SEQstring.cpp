#include<string>

#include "SEQstring.hpp"

const char SEQstring::decode[17] = "*AC*G***T******N";
const char SEQstring::decode_r[17] = "*TG*C***A******N";

const int SEQstring::codes[16] = {-1, 0, 1, -1, 2, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, 4};
const int SEQstring::rcodes[16] = {-1, 3, 2, -1, 1, -1, -1, -1, 0, -1, -1, -1, -1, -1, -1, 4};

// toString will reset dir
std::string SEQstring::toString(char dir) {
  assert(dir == '+' || dir == '-');
  this->dir = dir;
  std::ostringstream strout;
  for (int i = 0; i < len; i++) strout<< baseAt(i);
  this->dir = 0;
  return strout.str();
}



