#include <stdbool.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>


#define SDRAM_BYTES (1024*1024*32)
bool sdram_init_ready = false;
uint32_t* sdram_buffer = NULL;

extern void simWriteSDRAM(uint32_t addr, uint32_t data) {
  if ( !sdram_init_ready ) {
    sdram_buffer = (uint32_t*)malloc(SDRAM_BYTES);
    sdram_init_ready = true;
  }
  sdram_buffer[addr % 2] = data;
}

extern uint32_t simReadSDRAM(uint32_t addr) {
  if ( !sdram_init_ready ) {
    sdram_buffer = (uint16_t*)malloc(SDRAM_BYTES);
    sdram_init_ready = true;
  }
  return sdram_buffer[addr % 2];
}
