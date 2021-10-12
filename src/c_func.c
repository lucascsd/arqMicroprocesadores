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
	uint16_t sumaAux = 0;
	uint16_t vectorAux[VENTANA];
	uint32_t posicion = 0;
	uint32_t indexWindow;


	for ( uint32_t index = 0; index < longitudVectorIn; index++ )
	{

		sumaAux += vectorIn[index];

		if (index >= VENTANA){

			sumaAux -= vectorIn[posicion];
			posicion++;

		}

		vectorOut[index] = sumaAux / ( index + 1 - posicion );
	}

//
//	uint16_t sumaAux;
//	uint32_t posicion;
//
//	for (uint32_t index = 0; index < longitudVectorIn; index++)
//	{
//
//		sumaAux = 0;
//
//		for ( uint32_t x = index; x < index + VENTANA; x++ )
//		{
//
//			posicion = x % longitudVectorIn;
//			sumaAux = sumaAux + vectorIn[posicion];
//
//		}
//
//		vectorOut[index]= sumaAux / VENTANA;
//
//	}

}

void c_pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud)
{
	for ( uint32_t index = 0; index < longitud; index++)
	{
		vectorOut[index] = vectorIn[index] >> 16;
	}
}

int32_t c_max (int32_t * vectorIn, uint32_t longitud)
{
	int32_t posicionMax, vectorAux;

	posicionMax = 0;
	vectorAux = vectorIn[0];

	for (uint8_t index = 0; index < longitud; index++)
	{
		if ( vectorAux < vectorIn[index] )
			posicionMax = index;
	}

	return posicionMax;
}

void c_invertir (uint16_t * vector, uint32_t longitud)
{
	uint16_t vectorAux = 0;
	uint8_t pos = 0;

	for ( uint8_t index = 0; index < longitud/2; index++)
	{
		vectorAux = vector[index];
		pos = longitud - index - 1;
		vector[index] = vector[pos];
		vector[pos] = vectorAux;

	}
}

void c_eco ( int16_t * vectorIn, int16_t * vectorOut, uint16_t longitud, uint16_t tiempoEco  )
{

  /*
  44100 muestras  -------------------  1000ms
    x = 882    -------------------  20ms
  */
  uint32_t N_eco = ( tiempoEco * 44100 ) / 1000;
  /*
  for ( uint8_t index = 0; index < N_eco; index++ )
    vectorOut[index] = vectorIn[index];
  for ( uint8_t index = N_eco; index < longitud; index++ )
    vectorOut[index] = vectorIn[index] + vectorIn[index - N_eco]/2;
  */
  for ( uint16_t index = 0; index < longitud; index++ )
  {
    if ( index >= N_eco )
      vectorOut[index] = vectorIn[index] + vectorIn[index - N_eco]/2;
    else
      vectorOut[index] = vectorIn[index];
  }
}
