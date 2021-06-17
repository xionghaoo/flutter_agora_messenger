/**
 * build with command:
 * g++ -std=c++0x -O0 -I../../ RtmTokenBuilderSample.cpp  -lz -lcrypto -o RtmTokenBuilderSample
 */
#include "../src/RtmTokenBuilder.h"
#include <iostream>
#include <cstdint>
using namespace agora::tools;

int main(int argc, char const *argv[]) {

  std::string appID  = "cf309a3e129847bcb31703c7e6283721";
  std::string appCertificate = "de481a549db945a6a610ed88e4985c84";
  std::string user= "0000";
  uint32_t expirationTimeInSeconds = 3600;
  uint32_t currentTimeStamp = time(NULL);
  uint32_t privilegeExpiredTs = currentTimeStamp + expirationTimeInSeconds;
  std::string result =
    RtmTokenBuilder::buildToken(appID, appCertificate, user,
        RtmUserRole::Rtm_User, privilegeExpiredTs);
  std::cout << "Rtm Token:" << result << std::endl;
  return 0;
}
