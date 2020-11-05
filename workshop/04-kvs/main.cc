#include "pw_board_led/led.h"
#include "pw_kvs/fake_flash_memory.h"
#include "pw_kvs/key_value_store.h"
#include "pw_log/log.h"

constexpr size_t kSectorSizeBytes = 512;
constexpr size_t kSectorCount = 4;
constexpr size_t kKvsMaxEntries = 32;

// Use ram-backed (simulated) FlashMemory for storage.
pw::kvs::FakeFlashMemoryBuffer<kSectorSizeBytes, kSectorCount> example_memory;

// Use a single flash partition that covers the entire flash memory.
pw::kvs::FlashPartition example_partition(&example_memory);

// For KVS magic value always use a random 32 bit integer rather than a human
// readable 4 bytes. See pw_kvs/format.h for more information.
static constexpr pw::kvs::EntryFormat kvs_format = {.magic = 0xd253a8a9,
                                                    .checksum = nullptr};

pw::kvs::KeyValueStoreBuffer<kKvsMaxEntries, kSectorCount> kvs(
    &example_partition, kvs_format);

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

  unsigned kvs_value = 42;

  kvs.Init();

  while (true) {
    pw::board_led::TurnOn();
    Delay(2000000);

    PW_LOG_INFO("Write KVS value of %u", kvs_value);
    kvs.Put("example_key", kvs_value);

    PW_LOG_INFO("KVS has %u keys", static_cast<unsigned>(kvs.size()));

    pw::board_led::TurnOff();
    Delay(2000000);

    unsigned read_value = 0;
    kvs.Get("example_key", &read_value);
    PW_LOG_INFO("Read KVS value of %u", read_value);

    kvs_value++;
    if (kvs_value > 100) {
      kvs_value = 0;
    }
  }

  return 0;
}
