.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_sum
.global asm_sum64
.global asm_zeros
.global asm_productoEscalar32
.global asm_productoEscalar16
.global asm_productoEscalar12
.global asm_productoEscalarNoUSAT12
.global asm_filtroVentana10
.global asm_pack32to16
.global asm_max
.global asm_invertir
.global asm_eco
.global asm_eco_simd
.global asm_svc

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	uint64_t asm_sum64 (uint64_t firstOperand64, uint64_t secondOperand64);
@
@ Parametros recibidos:
@   r0, r1: firstOperand
@   r2, r3: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum64:
        add r0, r2  @ r0 = r0 + r2
        adc r1, r3  @ r0 = r1 + r3
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	void asm_zeros( uint32_t *vector, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vector
@   r1: longitud
@
@ Valor de retorno:
@   N/A
@
.thumb_func
    asm_zeros:

		mov		r2, 0

	.loop0:
		str		r2, [r0], 4	@Cargo valor 0 a la dirección que apunta r0 y apunto en la dirección +4
		subs	r1, 1		@Decremento valor de longitud directamente en el registro, no hace falta usar otro registro
		bne		.loop0		@Si no es igual a 0, itero.
       	bx		lr       	@ vuelve adonde fue llamada (especificamente, si "pc"
                    		@ es la direccion, en el codigo del programa, de la
                    		@ instruccion "bl asm_sum" usada para saltar a
                    		@ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    		@ el valor de retorno debe quedar en el registro r0.
                    		@ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	void asm_productoEscalar32( uint32_t *vectorIn, uint32_t *vectorOut
@								uint32_t longitud, uint32_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
@	r4: Valor a multiplicar apuntado por r0
@	r5: Resultado de la multiplicación apuntado por r0
@
@ Valor de retorno:
@   N/A
@
.thumb_func
    asm_productoEscalar32:

		push	{r4-r5}		/* Pusheo los valores de los registros r4 a r5 para no romper el contexto de quien llamó la funcion */
	.loop32:
		ldr		r4, [r0], 4	/* Cargo valor r4 a la dirección que apunta r0 y apunto en la dirección +4 */
		mul		r5, r4, r3	/* Multiplico r5 = r4 * r3 */
		str		r5, [r1], 4	/* Cargo valor r4 a la dirección que apunta r0 y apunto en la dirección +4 */
		subs	r2, 1		/* Decremento valor de longitud directamente en el registro, no hace falta usar otro registro */
		bne		.loop32		/* Si no es igual a 0, itero. */
		pop		{r4-r5}
       	bx		lr       @ vuelve adonde fue llamada (especificamente, si "pc"

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	void asm_productoEscalar16( uint16_t *vectorIn, uint16_t *vectorOut
@								uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
@	r4: Valor a multiplicar apuntado por r0
@	r5: Resultado de la multiplicación apuntado por r1
@
@ Valor de retorno:
@   N/A
@
.thumb_func
    asm_productoEscalar16:

		push	{r4-r5}		/* Pusheo los valores de los registros r4 a r5 para no romper el contexto de quien llamó la funcion */
	.loop16:
		ldrh	r4, [r0], 2			/* Cargo valor r4 a la dirección que apunta r0 y apunto en la dirección +4, ldr(h) hace la parte alta 0x0000 */
		mul		r5, r4, r3			/* Multiplico r5 = r4 * r3 */
@		and		r5, r5, 0x0000FFFF	/* Hago operación logica AND sobre la parte baja del registro para que solo sean 16 bits los devueltos */
		strh	r5, [r1], 2			/* Cargo valor r4 a la dirección que apunta r0 y apunto en la dirección +4, str(h) hace la parte alta 0x0000 */
		subs	r2, 1				/* Decremento valor de longitud directamente en el registro, no hace falta usar otro registro */
		bne		.loop16				/* Si no es igual a 0, itero. */
		pop		{r4-r5}
       	bx		lr       @ vuelve adonde fue llamada (especificamente, si "pc"

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	extern void asm_productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut,
@								uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
@	r4: Valor a multiplicar apuntado por r0
@	r5: Resultado de la multiplicación apuntado por r1 y luego de la saturación
@
@ Valor de retorno:
@   N/A
@
.thumb_func
    asm_productoEscalar12:

		push	{r4-r5}		/* Pusheo los valores de los registros r4 a r5 para no romper el contexto de quien llamó la funcion */
	.loopu12:
		ldrh	r4, [r0], 2			/* Cargo valor r4 a la dirección que apunta r0 y apunto en la dirección +4, ldr(h) hace la parte alta 0x0000 */
		mul		r5, r4, r3			/* Multiplico r5 = r4 * r3 */
		usat 	r5, 12, r5			/* Instrucción para logica saturada sin signo */
@		and		r5, r5, 0x0000FFFF	/* Hago operación logica AND sobre la parte baja del registro para que solo sean 16 bits los devueltos */
		strh	r5, [r1], 2			/* Cargo valor r4 a la dirección que apunta r0 y apunto en la dirección +4, str(h) hace la parte alta 0x0000 */
		subs	r2, 1				/* Decremento valor de longitud directamente en el registro, no hace falta usar otro registro */
		bne		.loopu12				/* Si no es igual a 0, itero. */
		pop		{r4-r5}
       	bx		lr

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	extern void asm_filtroVentana10( uint16_t * vectorIn, uint16_t * vectorOut,
@								uint32_t longitudVectorIn );
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitudVectorIn
@
@	r3: suma auxiliar
@	r4: posicion ventana
@	r5: arreglo auxiliar de suma
@	r6: x
@	r7: resultado
@ Valor de retorno:
@   N/A
@
.thumb_func
    asm_filtroVentana10:

		push	{r4-r7}		/* Pusheo los valores de los registros r4 a r5 para no romper el contexto de quien llamó la funcion */
		mov		r7, 0		/* index, Copio el valor 0 a r7 */
		mov		r6, 0
		mov		r5, 0
		mov		r4, 0		/* Posicion = 0 */
		mov		r3, 0		/* Posicion = 0 */
	.loopindex:
		ldrh	r5, [r0], 2			/* Cargo valor a r5 de la dirección que apunta r0 y apunto en la dirección +2, ldr(h) 								 hace la parte alta 0x0000 */
		add		r3, r3, r5			/* r3 = r3 + r5 */
		cmp		r7, 10
		blo		.suma10

	.Mayora10:
		ldrh	r5, [r0, -22]
		sub		r3, r3, r5			/* r3 = r3 - r5 */
		add		r4, #1				/* posicion + 1 */

	.suma10:
		add		r6, r7, #1			/* x = index + 1 */
		sub		r6, r4				/* r6 = r6 - r4 */
		udiv	r5, r3, r6			/* *vectorOut = sumaAux / x */
		strh	r5, [r1], 2			/* Cargo valor r3 a la dirección que apunta r0 y apunto en la dirección +4, str(h) hace la parte alta 0x0000 */
		add		r7, #1
		subs	r2, #1				/* Decremento valor de longitud directamente en el registro, no hace falta usar otro registro */
		bne		.loopindex			/* Si no es igual a 0, itero. */
		pop		{r4-r7}
       	bx		lr

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	extern void asm_productoEscalarSinSat12 (uint16_t * vectorIn, uint16_t * vectorOut,
@								uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
@	r4: Valor a multiplicar apuntado por r0
@	r5: Resultado de la multiplicación apuntado por r1 y luego de la saturación
@
@ Valor de retorno:
@   N/A
@
.thumb_func
    asm_productoEscalarNoUSAT12:

		push	{r4-r6}		/* Pusheo los valores de los registros r4 a r5 para no romper el contexto de quien llamó la funcion */
	.loop12:
		ldrh	r4, [r0], 2			/* Cargo valor r4 a la dirección que apunta r0 y apunto en la dirección +4, ldr(h) 								 hace la parte alta 0x0000 */
		mul		r5, r4, r3			/* Multiplico r5 = r4 * r3 */
@		usat 	r5, 12, r5			/* Instrucción para logica saturada sin signo */
		ands	r6, r5, 0xF000		/* Operación logica AND de los bits 13 a 16 */
		beq		.ovf_mult12
		mov		r5,#0xFFF
	.ovf_mult12:
		strh	r5, [r1], 2			/* Cargo valor r4 a la dirección que apunta r0 y apunto en la dirección +4, str(h) 									hace la parte alta 0x0000 */
		subs	r2, 1				/* Decremento valor de longitud directamente en el registro, no hace falta usar otro 								registro */
		bne		.loop12				/* Si no es igual a 0, itero. */
		pop		{r4-r6}
       	bx		lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	extern void asm_pack32to16 ( int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud );
@
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: Valor de entrada apuntado
@	r4: Valor a multiplicar apuntado por r0
@
@
@ Valor de retorno:
@   N/A
@
.thumb_func
    asm_pack32to16:

		push	{r4-r6}				/* Pusheo los valores de los registros r4 a r5 para no romper el contexto de quien llamó la funcion */
	.looplsr:
		ldr		r3, [r0], 4			/* Cargo valor en r3 que apunta r0 y apunto en la dirección +4, ldr(h) 								 hace la parte alta 0x0000 */
		mov		r4, r3, lsr #16		/* Muevo a r4 el contenido de r3 >> 16 */
		strh	r4, [r1], 2			/* Cargo valor en r4 a la dirección que apunta r0 y apunto en la dirección +2, str(h) 									hace la parte alta 0x0000 */
		subs	r2, 1				/* Decremento valor de longitud directamente en el registro, no hace falta usar otro 								registro */
		bne		.looplsr			/* Si no es igual a 0, itero. */
		pop		{r4-r6}
       	bx		lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@	extern int32_t asm_max (int32_t * vectorIn, uint32_t longitud);
@
@
@ Parametros recibidos:
@   r0: *vectorIn
@	r1: longitud
@	r2: Valor de entrada apuntado
@	r3: Maximo valor acumulado
@	r4: Guardo la longitud
@	r5: Guardo la poscion actual decremental
@
@ Valor de retorno:
@   N/A
@
.thumb_func
    asm_max:

		push	{r4-r6}				/* Pusheo los valores de los registros r4 a r5 para no romper el contexto de quien llamó la funcion */
		mov		r4, r1				/* Guardar la longitud */
		ldr		r2, [r0], #4		/* Cargo valor en r3 que apunta r0 y apunto en la dirección +4 */
		sub		r1, 1				/* Decremento valor de longitud directamente en el registro, no hace falta usar otro registro */
		mov		r3, r2				/* Maximo valor encontrado, en este caso es el primer valor */
	.loopmax:
		ldr		r2, [r0], 4			/* Cargo valor en r2 que apunta r0 y apunto en la dirección +4 */
		cmp		r3, r2				/* Comparo valorAux - vectorIn 		*/
		bgt		.loopmenor			/* Signed greater than 				*/
		mov		r3, r2				/* Maximo valor encontrado 			*/
		mov		r5, r1				/* Almaceno posicion actual			*/
	.loopmenor:
		subs	r1, 1				/* Decremento valor de longitud directamente en el registro, no hace falta usar otro registro */
		bne		.loopmax			/* Si no es igual a 0, itero. 		*/
		sub		r0, r4, r5			/* r0 = longitud - posicion actual	*/
		pop		{r4-r6}
       	bx		lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ 	void asm_invertir (uint16_t * vector, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vector
@  r1: longitud
@  r2: Valor copiado apuntado por el vector
@  r3: Vector nuevo
@  r4: copia de longitud
@  r5: *vectorOut
@  r6: auxiliar donde almaceno temporalmente variable
.thumb_func
	asm_invertir:
		push	{r4-r6}
		mov		r4, r1				/* r4 = Longitud			*/
		sub		r4, #1				/* Decremento longitud en 1 */
		lsl		r4, #1
		lsr		r1, #1		      	/* Longitud /2              */
		mov		r5, r0				/* Copio direcion a r5 		*/
		add		r5, r5, r4			/* r5 = r5 + longitud - 1	*/
	.loopinv:
		ldrh	r2, [r0], #2  		/* aux = *vector[i]           	*/
		mov		r6,	r2				/* vectorAux = aux						*/
		ldrh	r3, [r5], -2 		/* vectorAux = *vector[longitud-1-i]   */
    	mov 	r2, r3      		/* vector  = vectorAux         */
    	sub		r0, 2
    	strh	r2, [r0], #2  		/* *vector[i] = vector           */
    	add		r5, 2
    	strh	r6, [r5], -2  		/* *vector[i] = vector           */
    	subs	r1, #1
    	bne		.loopinv
    	pop		{r4-r6}
		bx		lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_eco ( int16_t * vectorIn, int16_t * vectorOut, uint16_t longitud, uint16_t tiempoEco  );
@
@ Parametros recibidos:
@  r0: *vectorIn
@  r1: *vectorOut
@  r2: longitud
@  r3: tiempo de Eco
@  r4: numero de muestras N_eco
@  r5: *vectorOut
@  r6: valor 44100
@  r7: vector[index - 882]/2
@  r8: valor 1000
.thumb_func
	asm_eco:
		push	{r4-r7}
		mov		r6, #44100
		mul		r4, r3, r6			/* N_eco = ( tiempoEco * 44100 ) 				*/
		mov		r6, #4096
		mov		r8, #1000
		udiv	r4, r4, r8			/* N_eco / 1000;				 				*/
		sub		r4, r6, r4			/* 4096 - 882 = 3214							*/
		mov		r8, #1764
//		neg		r8,	r8
	.loopEco:
		ldrh	r5, [r0], 2			/* *r0 = r5										*/
		cmp		r2, r4				/* CMP index vs N_eco							*/
		bge		.fnEco				/* Salto a funcion Eco cuando es menor e igual 	*/
		strh	r5, [r1], 2			/* Almaceno dato donde apunta r1				*/
		b		.loopDec
	.fnEco:
		ldrh	r7, [r0, r8]		/* vector[index - 882]/2						*/
		lsr		r7, #1				/* r7 dividido en 2								*/
		add		r5, r5, r7			/* r5 = r5 + r7									*/
		strh	r5, [r1], 2			/* Almaceno dato donde apunta r1				*/
	.loopDec:
		subs	r2, #1
    	bne		.loopEco
    	pop		{r4-r7}
		bx		lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_eco ( int16_t * vectorIn, int16_t * vectorOut, uint16_t longitud, uint16_t tiempoEco  );
@
@ Parametros recibidos:
@  r0: *vectorIn
@  r1: *vectorOut
@  r2: longitud
@  r3: tiempo de Eco
@  r4: numero de muestras N_eco
@  r5: *vectorOut
@  r6: valor 44100
@  r7: vector[index - 882]/2
@  r8: valor 1000
.thumb_func
	asm_eco_simd:
		push	{r4-r7}

    	pop		{r4-r7}
		bx		lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr
