#include "c_func.h"

/* Funcion que realiza la suma de 32 bits */
uint32_t c_sum (uint32_t firstOperand, uint32_t secondOperand)
{
	return (firstOperand + secondOperand);
}

/* Funcion que realiza la suma de 64 bits */
uint64_t c_sum64 (uint64_t firstOperand64, uint64_t secondOperand64)
{
	return (firstOperand64 + secondOperand64);
}

/* Funcion que pone todos los elementos de un arreglo a 0 */
void zeros( uint32_t *vector, uint32_t longitud)
{
	for (uint32_t i = 0; i < longitud; i++)
	{
		vector[i] = 0;
	}
}

/* Funcion que realiza el producto escalar */
void c_productoEscalar32( uint32_t *vectorIn, uint32_t *vectorOut, uint32_t longitud, uint32_t escalar)
{

	for ( uint8_t i = 0; i < longitud; i++)
		vectorOut[i] = escalar * vectorIn[i];

}

/* Funcion que realiza el producto escalar con valores de 16 bits*/
void c_productoEscalar16( uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitud, uint16_t escalar)
{

	for ( uint32_t i = 0; i < longitud; i++)
		vectorOut[i] = escalar * vectorIn[i];

}

void c_productoEscalar12 ( uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar)
{
	for ( uint32_t i = 0; i < longitud; i++)
	{
		vectorOut[i] = escalar * vectorIn[i];
		if ( vectorOut[i] > 0x0FFF )
			vectorOut[i] = 0x0FFF;
	}
}

void c_filtroVentana10( uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn )
{
	uint32_t sumaAux, posicion;

	for ( uint32_t index = 0; index < longitudVectorIn; index++ )
	{

		sumaAux = 0;
		posicion = index;

		for ( uint32_t indexWindow = posicion; indexWindow > posicion + 10; indexWindow++)
		{
			sumaAux = sumaAux + vectorIn[indexWindow];
		}
		vectorOut[index] = sumaAux/10;
	}
}
