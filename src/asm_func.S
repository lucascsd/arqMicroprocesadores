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

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr
