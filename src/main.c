#include "board.h"
#include "c_func.h"
#include "asm_func.h"

#include <stdlib.h>
#include <stdnoreturn.h>

// Variables para contar ciclos
volatile uint32_t * DWT_CTRL   = (uint32_t *)0xE0001000;
volatile uint32_t * DWT_CYCCNT = (uint32_t *)0xE0001004;

volatile uint32_t ciclos_c=0,ciclos_asm=0, ciclos_no_usat=0;

// Variable que se incrementa cada vez que se llama al handler de interrupcion
// del SYSTICK.
static volatile uint32_t s_ticks = 0;


// Inicia soporte de la placa y periodo de la interrupcion del SYSTICK
// cada 1 milisegundo.
static void Inicio (void)
{
	Board_Init ();
	SystemCoreClockUpdate ();
	SysTick_Config (SystemCoreClock / 1000);

	*DWT_CTRL  |= 1;
}


// Segun la configuracion realizada en Inicio(), este handler de interrupcion
// se ejecutara cada 1 milisegundo.
void SysTick_Handler (void)
{
	++ s_ticks;
}


static void Suma (void)
{
	const uint32_t A = 20;
	const uint32_t B = 30;

	const uint64_t A64 = 0x20000000AABBCCDD;
	const uint64_t B64 = 0x30EEFF0011223344;

	const uint32_t SumResult_C = c_sum (A, B);
	const uint32_t SumResult_Asm = asm_sum (A, B);

	const uint64_t SumResult_Asm64 = asm_sum64 (A64, B64);
	const uint64_t SumResult_C64 = c_sum64 (A64 ,B64);

	// Actividad de debug: SumResult_C y SumResult_Asm deberian contener el
	// mismo valor.
	__BKPT (0);

	(void) SumResult_C;
	(void) SumResult_Asm;
}


static void LlamandoAMalloc (void)
{
	// De donde saca memoria malloc?
	// (se vera en clase)
	void * ptr = malloc (2048);

	(void) ptr;
}


static void PrivilegiosSVC (void)
{
	// Obtiene valor del registro de 32 bits del procesador llamado "control".
	// El registro guarda los siguientes estados:
	// bit 2: Uso de FPU en el contexto actual. Usado=1, no usado=0.
	// bit 1: Mapeo del stack pointer(sp). MSP=0, PSP=1.
	// bit 0: Modo de ejecucion en Thread. Privilegiado=0, No privilegiado=1.
	//        Recordar que este valor solo se usa en modo Thread. Las
	//        interrupciones siempre se ejecutan en modo Handler con total
	//        privilegio.
	uint32_t x = __get_CONTROL ();

	// Actividad de debug: Ver registro "control" y valor de variable "x".
	__BKPT (0);

	x |= 1;
	// bit 0 a modo No privilegiado.
	__set_CONTROL (x);

	// En este punto se estaria ejecutando en modo No privilegiado.
	// Lectura del registro "control" para confirmar.
	x = __get_CONTROL ();

	// Actividad de debug: Ver registro "control" y valor de variable "x".
	__BKPT (0);

	x &= ~1u;
	// Se intenta volver a modo Privilegiado (bit 0, valor 0).
	__set_CONTROL (x);

	// Confirma que esta operacion es ignorada por estar ejecutandose en modo
	// Thread no privilegiado.
	x = __get_CONTROL ();

	// Actividad de debug: Ver registro "control" y valor de variable "x".
	__BKPT (0);

	// En este punto, ejecutando en modo Thread no privilegiado, la unica forma
	// de volver a modo privilegiado o de realizar cualquier cambio que requiera
	// modo privilegiado, es pidiendo ese servicio a un hipotetico sistema
	// opertivo de tiempo real.
	// Para esto se invoca por software a la interrupcion SVC (Supervisor Call)
	// utilizando la instruccion "svc".
	// No hay intrinsics para realizar esta tarea. Para utilizar la instruccion
	// es necesario implementar una funcion en assembler. Ver el archivo suma.S.
	asm_svc ();

	// El sistema operativo (el handler de SVC) deberia haber devuelto el modo
	// de ejecucion de Thread a privilegiado (bit 0 en valor 0).
	x = __get_CONTROL ();

	// Fin del ejemplo de SVC
}


// Handler de la interrupcion "SVC" (Supervisor Call).
// Usado por el ejemplo "EjemploPrivilegiosSVC".
void SVC_Handler (void)
{
	// Se obtiene el valor del registro "control". El bit 0 indica el nivel
	// de privilegio en modo "Thread". Deberia ser 1: No privilegiado.
	uint32_t x = __get_CONTROL ();

	// Borra el bit 0. Nuevo valor 0: privilegiado.
	x &= ~1u;

	// Asigna el nuevo valor al registro "control". Esta operacion deberia
	// ejecutarse ya que todo manejador de interrupciones se ejecuta en modo
	// "Handler" con total privilegio.
	__set_CONTROL (x);
}


noreturn void LoopInfinito (void)
{
	while (1)
	{
		// Procesador en modo espera hasta que ocurra una interrupcion
		// (Bajo consumo)
		__WFI();
	}
}

void zeros_main ( void )
{
	uint32_t vector[8] = {(uint32_t)-1, (uint32_t)-2, (uint32_t)-3, (uint32_t)-4,
			(uint32_t)-5, (uint32_t)-6, (uint32_t)-7, (uint32_t)-8};
	//zeros ( vector, 8);
	asm_zeros ( vector, 8);

	uint32_t vectorAux[8] = { 2, 3, 4, 5, 6, 7, 8, 9 };

	for ( uint32_t i = 0; i < 8; i++) vectorAux[i] = vector[i];

}

void productoEscalar ( void )
{
	uint32_t vectorIn[] = { 43, 43, 23, 102, 32, 90, 12, 32, 43, 48};
	uint32_t longitud  = sizeof ( vectorIn ) / sizeof ( uint32_t );
	uint32_t C_vectorOut[longitud];
	uint32_t vectorOut[longitud];
	uint32_t escalar;
	uint32_t ciclos_c=0,ciclos_asm=0;

	escalar = 3;
	*DWT_CYCCNT = 0;
	c_productoEscalar32( vectorIn, C_vectorOut, longitud, escalar);
	ciclos_c = *DWT_CYCCNT;

	escalar = 3;
	*DWT_CYCCNT = 0;
	asm_productoEscalar32( vectorIn, vectorOut, longitud, escalar);
	ciclos_asm = *DWT_CYCCNT;

}

void productoEscalar16 ( void )
{
	uint16_t vectorIn[] = { 43, 256, 23, 65535 };	// 86 ( 0101 0110 ), 512 ( 10 0000 0000 ), 23 ( 0001 0111 ), 102 ( 0110 0110 )
	uint32_t longitud  = sizeof ( vectorIn ) / sizeof ( uint16_t );
	uint16_t C_vectorOut[longitud];
	uint16_t vectorOut[longitud];
	uint16_t escalar;

	escalar = 2;
	c_productoEscalar16( vectorIn, C_vectorOut, longitud, escalar);

	escalar = 2;
	asm_productoEscalar16( vectorIn, vectorOut, longitud, escalar);

}

void productoEscalar12 ( void )
{
	uint16_t vectorIn[] = { 43, 256, 23, 100, 56, 878, 2, 35, 38, 98, 365, 12, 61, 4, 32,
								42, 1256, 53, 130, 56, 78, 42, 75, 38, 8, 265, 128, 63, 1, 320};
	uint32_t longitud  = sizeof ( vectorIn ) / sizeof ( uint16_t );
	uint16_t C_vectorOut[longitud];
	uint16_t U_vectorOut[longitud];
	uint16_t vectorOut[longitud];
	uint16_t escalar;

	escalar = 15;
	*DWT_CYCCNT = 0;
	c_productoEscalar12( vectorIn, C_vectorOut, longitud, escalar);
	ciclos_c = *DWT_CYCCNT;
	__BKPT (0);

	escalar = 15;
	*DWT_CYCCNT = 0;
	asm_productoEscalar12( vectorIn, vectorOut, longitud, escalar);
	ciclos_asm = *DWT_CYCCNT;
	__BKPT (0);

	escalar = 15;
	*DWT_CYCCNT = 0;
	asm_productoEscalarNoUSAT12( vectorIn, U_vectorOut, longitud, escalar);
	ciclos_no_usat = *DWT_CYCCNT;
	__BKPT (0);
}

void filtroVentana( void )
{
	uint16_t vectorIn[] = { 43, 256, 23, 100, 56, 878, 2, 35, 38, 98, 365, 12, 61, 4, 32,
			42, 1256, 53, 130, 56, 78, 42, 75, 38, 8, 265, 128, 63, 1, 320};
	uint32_t longitudVectorIn  = sizeof ( vectorIn ) / sizeof ( uint16_t );
	uint16_t vectorOut[longitudVectorIn];

	for ( uint32_t i = 0; i < longitudVectorIn; i++ ) vectorOut[i] = 0;

	*DWT_CYCCNT = 0;
	c_filtroVentana10( vectorIn, vectorOut, longitudVectorIn );
	ciclos_c = *DWT_CYCCNT;
	__BKPT (0);

	for ( uint32_t i = 0; i < longitudVectorIn; i++ ) vectorOut[i] = 0;
	__BKPT (0);
	*DWT_CYCCNT = 0;
	asm_filtroVentana10( vectorIn, vectorOut, longitudVectorIn );
	ciclos_asm = *DWT_CYCCNT;
	__BKPT (0);
}

void corrimiento ( void )
{
	int32_t vectorIn[] = { 0x00300000, 0x00561000, 0x12300000, 0x81000000, 0x94650000, 0x08780000, 0xA1290000, 0xFFF01350,
			0x5050F1F1, 0xFF320122 };
	uint32_t longitudVectorIn  = sizeof ( vectorIn ) / sizeof ( int32_t );
	int16_t vectorOut[longitudVectorIn];
	int16_t vectorOutAsm[longitudVectorIn];
	*DWT_CYCCNT = 0;
	c_pack32to16 ( vectorIn, vectorOut, longitudVectorIn );
	ciclos_c = *DWT_CYCCNT;
	__BKPT (0);

	*DWT_CYCCNT = 0;
	asm_pack32to16 ( vectorIn, vectorOutAsm, longitudVectorIn );
	ciclos_c = *DWT_CYCCNT;
	__BKPT (0);

}

void maximoValor ( void )
{
	int32_t vectorIn[] = { 0x00300000, 0x00561000, 0x12300000, 0x81000000, 0x94650000, 0x08780000, 0xA1290000, 0xFFF01350,
			0x5050F1F1, 0xFF320122 };
	uint32_t longitudVectorIn  = sizeof ( vectorIn ) / sizeof ( int32_t );
	int32_t vectorMax = 0;
	int32_t vectorMaxAsm = 0;

	*DWT_CYCCNT = 0;
	vectorMax = c_max ( vectorIn, longitudVectorIn );
	ciclos_c = *DWT_CYCCNT;
	__BKPT (0);

	*DWT_CYCCNT = 0;
	vectorMaxAsm = asm_max ( vectorIn, longitudVectorIn );
	ciclos_c = *DWT_CYCCNT;
	__BKPT (0);

}

void invertir ()
{
	uint16_t vectorIn[] = { 0xA030, 0x0056, 0x1230, 0x8100, 0x9465, 0x0878, 0xA129, 0xFFF0,
			0xF1F1, 0xFF32, 0xF013 };
	uint16_t vectorOut[] = { 0xA030, 0x0056, 0x1230, 0x8100, 0x9465, 0x0878, 0xA129, 0xFFF0,
			0xF1F1, 0xFF32, 0xF013 };
	uint32_t longitudVectorIn  = sizeof ( vectorIn ) / sizeof ( uint16_t );

	*DWT_CYCCNT = 0;
	c_invertir ( vectorIn, longitudVectorIn );
	ciclos_c = *DWT_CYCCNT;
	__BKPT (0);

	*DWT_CYCCNT = 0;
	asm_invertir ( vectorIn, longitudVectorIn );
	ciclos_c = *DWT_CYCCNT;
	__BKPT (0);


}

void eco ()
{
	uint16_t longitud = 4096;
	int16_t vectorIn[longitud];
	int16_t vectorOut[longitud];
	uint16_t tiempoEco = 20;

	for (uint16_t i = 0; i < longitud; i++) vectorIn[i] = (i*2) + 10;

	*DWT_CYCCNT = 0;
	c_eco ( vectorIn, vectorOut, longitud, tiempoEco  );
	ciclos_c = *DWT_CYCCNT;
	__BKPT (0);

}

int main (void)
{

	Inicio ();

/*
	zeros_main ();

	Suma ();

	productoEscalar ();

	productoEscalar16 ();

	productoEscalar12 ();

	filtroVentana();
*/
//	corrimiento();

//	maximoValor();

//	invertir();

	eco();

	//   PrivilegiosSVC ();

	//    LlamandoAMalloc ();

	LoopInfinito ();
}
