#pragma once

#include <stdint.h>


uint32_t c_sum (uint32_t firstOperand, uint32_t secondOperand);
uint64_t c_sum64 (uint64_t firstOperand64, uint64_t secondOperand64);
void zeros( uint32_t *vector, uint32_t longitud);
void c_productoEscalar32( uint32_t *vectorIn, uint32_t *vectorOut, uint32_t longitud, uint32_t escalar);
