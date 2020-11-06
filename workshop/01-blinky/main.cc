// Copyright 2020 The Pigweed Authors
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not
// use this file except in compliance with the License. You may obtain a copy of
// the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations under
// the License.

#include "pw_board_led/led.h"
#include "pw_log/log.h"

namespace {

// This is a bad spin delay. It's not accurate, and doesn't correspond with any
// real time unit. pw_chrono is coming soon, and will make it easier to do this
// correctly!
void Delay(size_t ticks) {
  for (volatile size_t i = 0; i < ticks; i++) {
    // Do nothing.
  }
}

}  // namespace

int main() {
  pw::board_led::Init();
  while (true) {
    PW_LOG_INFO("Blink High!");
    pw::board_led::TurnOn();
    Delay(1000000);
    PW_LOG_INFO("Blink Low!");
    pw::board_led::TurnOff();
    Delay(1000000);
  }

  return 0;
}
