;******************************************************************************
;* File Name:   Mischer.s                                                     *
;* Autor: 		Daniel Schuster 											  *
;*				Phillip Gössl											      *
;* Version: 	V1.00                                                         *
;* Date: 		2019-12-11                                                    *
;* Description: Steuerung für einen Mischer						              *
;******************************************************************************
				AREA BLINKEN, CODE, READONLY
				INCLUDE STM32_F103RB_MEM_MAP.INC
				EXPORT __main

; -------------------------- D E F I N I T I O N E N---------------------------
Kuehlung		EQU 	PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+8*4 	; Kühlung (Leitung PB8)
RW				EQU		PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+9*4 	; Rührwerk (Leitung PB9)
MRZ				EQU		PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+10*4	 ; Misch-Reaktionszeit Aktiv (Leitung PB10)
VA1				EQU		PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+11*4	 ; Ablaufventil (Leitung PB11)
VE1				EQU		PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+12*4 	; Zulauf 1 (Leitung PB12)
VE2				EQU		PERIPH_BB_BASE+(GPIOB_ODR - PERIPH_BASE)*0x20+13*4 	; Zulauf 2 (Leitung PB13)
	
HS				EQU		PERIPH_BB_BASE+(GPIOA_IDR - PERIPH_BASE)*0x20+0*4  ; Hauptschalter (Leitung PA0)
O1				EQU		PERIPH_BB_BASE+(GPIOA_IDR - PERIPH_BASE)*0x20+1*4  ; Füllstand 1 (Leitung PA1)
O2				EQU		PERIPH_BB_BASE+(GPIOA_IDR - PERIPH_BASE)*0x20+2*4  ; Füllstand 2 (Leitung PA2)
O3				EQU		PERIPH_BB_BASE+(GPIOA_IDR - PERIPH_BASE)*0x20+3*4  ; Füllstand 3 (Leitung PA3)

;******************************************************************************
;*                        M A I N  P r o g r a m m:                           *
;******************************************************************************
__main			PROC
				BL	 	init_ports
_main_again		LDR		R0,=HS         ; Output value auf LED = 0
				LDR 	R1,=VE2       ; Ausgabe Bit0 von value auf LED0
				STR		R0,[R1]
				BL 		wait_5s	   ; Warte 5s
				B		_main_again				
				ENDP

;******************************************************************************
;*            U N T E R P R O G R A M M:    init_ports                        *
;*                                                                            *
;* Aufgabe:   Initialisiert Portleitungen für LED / Schalterplatine           *
;* Input:     keine                                                           *
;* return:	  keine                                                           *
;******************************************************************************
init_ports		PROC
				push 	{R0,R1,R2,LR}	  	 ; save link register to Stack
				MOV	R2, #0x08	 	 		; enable clock for GPIOB	(APB2 Peripheral clock enable register)
				LDR R1,	=RCC_APB2ENR
				LDR	R0, [R1]
				ORR	R0,	R0, R2
				STR R0, [R1]

				LDR R1,	=GPIOB_CRH	 		; set Port Pins PB8 (LED0) to Push Pull Output Mode (50MHz)
				LDR	R0, [R1]
				LDR	R2, =0xFF000000	 
				AND	R0,	R0, R2
				LDR	R2, =0x00333333
				ORR	R0,	R0, R2
				STR R0, [R1]
				
				LDR R1,	=GPIOA_CRL	 ; set Port Pins PA0 to Pull Up/Down Input mode (50MHz) - Schalter S0
				LDR R0,	[R1]	   
				LDR R2, =0xFFFFFFF0  
				AND	R0,	R0, R2
				LDR R2, =0x8
				ORR	R0,	R0, R2
				STR R0, [R1]
				
				LDR R1,	=GPIOA_ODR	 ; GPIOA Output Register Bit 0 auf "1" sodass Input Pull Up aktiviert ist!!	
				LDR R0,	[R1]	
				LDR R2, =0x1  
				ORR	R0,	R0, R2
				STR R0, [R1]
				
				POP 	{R0,R1,R2,PC}	   ;restore link register to Programm Counter and return
				ENDP
				
;******************************************************************************
;*            U N T E R P R O G R A M M:    wait_5s                        *
;*                                                                            *
;* Aufgabe:   Wartet 5s                                                    *
;* Input:                                                                     *
;* return:	 	                                                              *
;******************************************************************************
wait_5s		PROC
				push 	{R0-R2,LR}	   ; save link register to Stack
                MOV     R0,#0x1770	   ; wait 500ms
                MOV     R1,#0
wait_ms_loop	MOV		R2,#0x6A4			
wait_ms_loop1	SUB 	R2,R2,#1
				CMP		R2,R1
				BNE		wait_ms_loop1
				SUB 	R0,R0,#1
				CMP		R0,R1
				BNE		wait_ms_loop
				POP 	{R0-R2,PC}	   ;restore link register to Programm Counter and return
				ENDP
				
				ALIGN

				END




