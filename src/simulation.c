#include <stdbool.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>


#define SDRAM_BYTES (1024*1024*32)
bool sdram_init_ready = false;
uint32_t* sdram_buffer = NULL;

static uint32_t applyMask(uint32_t old_data, uint32_t new_data, uint8_t mask) {
  uint32_t b0 = (mask & 1 ? new_data : old_data) & 0x000000FF;
  uint32_t b1 = (mask & 2 ? new_data : old_data) & 0x0000FF00;
  uint32_t b2 = (mask & 4 ? new_data : old_data) & 0x00FF0000;
  uint32_t b3 = (mask & 8 ? new_data : old_data) & 0xFF000000;
  return b0 | b1 | b2 | b3;
}

extern void simWriteSDRAM(uint32_t addr, uint32_t data, uint8_t mask) {
  if ( !sdram_init_ready ) {
    sdram_buffer = (uint32_t*)malloc(SDRAM_BYTES);
    sdram_init_ready = true;
  }
  sdram_buffer[addr] = applyMask(sdram_buffer[addr], data, mask);
}

extern uint32_t simReadSDRAM(uint32_t addr) {
  if ( !sdram_init_ready ) {
    sdram_buffer = (uint32_t*)malloc(SDRAM_BYTES);
    sdram_init_ready = true;
  }
  return sdram_buffer[addr];
}
