
#include "FreeRTOS.h"
#include "pw_assert/check.h"
#include "pw_malloc/malloc.h"
#include "pw_preprocessor/compiler.h"
#include "pw_string/util.h"
#include "pw_sys_io_stm32cube/init.h"
#include "pw_system/init.h"
#include "stm32l4xx.h"
#include "task.h"

std::array<char, configMAX_TASK_NAME_LEN> temp_thread_name_buffer;

// Implement all initialization that is required for sys_io to work on this
// target.
extern "C" int pw_stm32cube_Init() {
  return 0;
}


extern "C" unsigned long getRunTimeCounterValue(void) { return uwTick; }

// Required for configCHECK_FOR_STACK_OVERFLOW.
extern "C" void vApplicationStackOverflowHook(TaskHandle_t, char* pcTaskName) {
  pw::string::Copy(pcTaskName, temp_thread_name_buffer);
  PW_CRASH("Stack OVF for task %s", temp_thread_name_buffer.data());
}
// This `main()` stub prevents another main function from being linked since
// this target deliberately doesn't run `main()`.
extern "C" int main() {}
