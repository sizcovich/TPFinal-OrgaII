;Trabajo Final de la materia Organización del Computador II
;Alumnos: Sabrina Izcovich y Sebastián Vita
;Título: Reconocedor de Dígitos Manuscritos


;typedef struct Matriz {
;    int fila;
;    int columna;
;    double* Vector;
;} __attribute__((__packed__)) Matriz;

;Funciones exportadas
global matriz_cero
global matriz_identidad
global matriz_create
global matriz_delete
global matriz_multiplicar
global matriz_dividir
global matriz_copiar
global matriz_traspuesta
global matriz_traspuestaCuadrada
global matriz_mediaCero
global matriz_print
global matriz_cargar
global matriz_norma2
global matriz_rotacion


;Funciones externas
extern malloc
extern free
extern fopen
extern fclose
extern fprintf

;Definiciones
%define TAM_matriz 16
%define TAM_dato_int 4
%define TAM_dato_double 8
%define TAM_puntero 8
%define offset_fila 0
%define offset_columna 4
%define offset_vector 8

;Máscaras
section .rodata

flotante: DB '%f ', 10, 0
letraa: DB 'a', 0
inversor: DW 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF
UnoIdentidad: dd 1.0, 0.0, 0.0, 0.0
DosIdentidad: dd 0.0, 1.0, 0.0, 0.0
TresIdentidad: dd 0.0, 0.0, 1.0, 0.0
CuatroIdentidad: dd 0.0, 0.0, 0.0, 1.0
CeroATres: dd 0, 1, 2, 3
UnoACuatro: dd 1, 2, 3, 4
cuatros: dd 4, 4, 4, 4
unos: dd 1.0, 1.0, 1.0, 1.0
IntUnos: dd 1, 1, 1, 1

;Código
section .text

; ~ Matriz* matriz_create(const int row_count, const int column_count);
matriz_create:
                push rbp
                mov rbp, rsp
                push rbx
                push r15

                mov ebx, edi
                mov r15d, esi
                mov rdi, TAM_matriz ;tamaño a pedir
                call malloc ;petición de memoria
                mov dword[rax+offset_fila], ebx
                mov dword[rax+offset_columna], r15d
                mov ecx, ebx
                mov rbx, rax
                mov eax, r15d
                mul ecx ;filas * columnas
                shl rax, 2 ;multiplico por 4 porque es un vector de floats
                mov rdi, rax
                call malloc
                mov qword[rbx+offset_vector], rax
                mov rax, rbx

                pop r15
                pop rbx
                pop rbp
                ret


; ~ void delete_matriz(Matriz *self);
matriz_delete:
                push rbp
                mov rbp, rsp
                push rbx
                sub rsp, 8

                mov rbx, rdi
                mov rdi, [rbx+offset_vector] ;puntero a liberar
                call free ;liberación de memoria
                mov rdi, rbx
                call free

                add rsp, 8
                pop rbx
                pop rbp
                ret

; ~ void cero(Matriz *self);
matriz_cero:
                push rbp
                mov rbp, rsp
                push rbx
                push r15
               
                ;multiplicación fila por columna
                mov ecx, [rdi+offset_fila]
                mov eax, [rdi+offset_columna]
                mul ecx

                mov rdi, [rdi+offset_vector] ;rdi = puntero al vector
                pxor xmm0, xmm0
.ciclo:
                sub rax, 4             
                cmp rax, 0
                jl .me_pase ;si rax<0, faltan procesar entre 0 y 3 floats
                movdqu [rdi], xmm0
                je .fin ;si rax=0, proceso terminado
                add rdi, 16
                jmp .ciclo
.me_pase:
                imul rax, 4 ;cantidad de bytes a retroceder
                add rdi, rax
                movdqu [rdi], xmm0     
.fin:
                pop r15
                pop rbx
                pop rbp
                ret
               

; ~ void identidad(Matriz *self);
matriz_identidad:
                push rbp
                mov rbp, rsp
                push rbx
                push r14
                push r13
                push r12
               
                mov ecx, [rdi+offset_fila]
                mov r13d, 0 ; r13 = contador fila
                mov r8d, [rdi+offset_columna]
                mov r9d, r8d
                mov eax, r8d
                mov ebx, 4
                xor edx, edx
                div ebx ;cuántas iteraciones a realizar por columna
                mov r11d, edx
                mov eax, [rdi+offset_columna]
                sub eax, r11d
                mul ecx ;ecx = fila*columna
                shr eax, 2 ;cantidad de iteraciones
                mov r11d, r8d ;r11 = cantidad de columnas
                ;ecx = filas / eax = iteraciones / r8 = columnas / r11 = columnas

                mov r14, [rdi+offset_vector] ;puntero a la matriz
                ;r14 = vector
               
                movups xmm0, [UnoIdentidad] ;xmm0 = 1|0|0|0
                movups xmm1, [DosIdentidad] ;xmm1 = 0|1|0|0
                movups xmm2, [TresIdentidad] ;xmm2 = 0|0|1|0
                movups xmm3, [CuatroIdentidad] ;xmm3 = 0|0|0|1
                pxor xmm7, xmm7 ;xmm7 = 0|0|0|0
                xor r12, r12 ;contador de filas
                xor bl, bl ; bl = posición del registro en la que poner el 1
.ciclo:
                ; rax = iteraciones
                cmp eax, 0
                jle .fin
                ; no terminó
                       
                mov r11d, r12d
                cmp r11d, 0
                je .sigo
                cmp r13d, r9d ; si j>i, pongo todos ceros
                jge .filaDeCeros
.pongoCeros:
                ; se ubican los 0 cuando no hay que poner el 1
                movups [r14], xmm7
                add r14, 16
                dec eax
                sub r8d, 4
                dec r11d
                cmp r11d, 0 ;terminó con la fila?
                je .sigo
                jmp .pongoCeros
.sigo: 
                ;se pone el 1
                ;bl = flag que indica dónde poner el 1
                cmp bl, 0
                je .pongoUnoIdentidad
                cmp bl, 1
                je .pongoDosIdentidad
                cmp bl, 2
                je .pongoTresIdentidad
                xor bl, bl
                movups [r14], xmm3 ;[r14] = 0|0|0|1
                add r14, 16 ;avanza el puntero
                inc r12d
                dec eax
                sub r8d, 4
.continuo:
                ;se setean todos los registros una vez ubicado el 1
                cmp r8d, 3
                jle .finFila
                movups [r14], xmm7
                add r14, 16
                sub r8d, 4
                dec eax
                jmp .continuo
                               
.pongoUnoIdentidad:    
                cmp r8d, 3
                jle .unoConMenos
                movups [r14], xmm0
                add r14, 16
                inc bl
                dec eax
                sub r8d, 4
                jmp .continuo

.unoConMenos:
                ;caso en el que no entra un xmm
                movd [r14], xmm0
                add r14, 4
                inc bl
                dec r8d
                jmp .finFila

.pongoDosIdentidad:
                cmp r8d, 3
                jle .dosConMenos
                movups [r14], xmm1
                add r14, 16
                inc bl
                dec eax
                sub r8d, 4
                jmp .continuo

.dosConMenos:
                ;caso en el que no entra un xmm
                mov dword[r14], 0
                add r14, 4
                movd [r14], xmm0
                add r14, 4
                inc bl
                sub r8d, 2
                jmp .finFila

.pongoTresIdentidad:
                cmp r8d, 3
                jle .tresConMenos
                movups [r14], xmm2
                add r14, 16
                inc bl
                dec eax
                sub r8d, 4
                jmp .continuo          
               
.tresConMenos:
                ;caso en el que no entra un xmm
                mov dword[r14], 0
                add r14, 4
                mov dword[r14], 0
                add r14, 4
                movd [r14], xmm0
                add r14, 4
                inc bl
                sub r8d, 3
                jmp .finFila

.finFila:
                ;termina la fila, se verifica que haya quedado todo en 0
                cmp r8d, 0
                je .voyAlCiclo
                mov dword[r14], 0
                add r14, 4
                dec r8d
                jmp .finFila
                               
.voyAlCiclo:
                ;cambio de fila
                mov r8d, r9d ;se resetea la cantidad de columnas a procesar
                inc r13d               
                jmp .ciclo
               
.filaDeCeros:
                ;fila de ceros
                movups [r14], xmm7
                add r14, 16
                dec eax
                sub r8d, 4
                cmp r8d, 3
                jle .finFila
                jmp .filaDeCeros

.fin:    
                pop r12
                pop r13
                pop r14
                pop rbx
                pop rbp
                ret

;función para imprimir matrices ~ utilizado para las pruebas de ejecución
; ~ void matriz_print(Matriz* self, char *archivo)
matriz_print:
                push rbp
                mov rbp, rsp
                push rbx
                push r15
                push r13
                push r12
               
                mov r12, rdi ;r12 = *matriz
                mov r13, rsi ;r13 = *archivo
                mov rdi, r13 ; rdi = *archivo
                xor rbx, rbx
                mov rbx, letraa ;modo append
                mov rsi, rbx
                call fopen ;se abre archivo para imprimir
                mov rbx, rax ;se guarda el puntero al archivo
                mov eax, dword[r12+offset_fila]
                mov ecx, dword[r12+offset_columna]
                mul rcx ;fila*columna
                mov r15, rax ; r15 = cantidad de iteraciones
                mov r12, [r12+offset_vector] ;r12 = *vector

.ciclo:
                mov rdi, rbx
                mov esi, flotante
                xorpd xmm0, xmm0
                movq xmm0, [r12]
                call fprintf ;se imprime
               
                dec r15
                cmp r15, 0
                je .fin
                add r12, 4
                jmp .ciclo

.fin:
                mov rdi, rbx
                call fclose ;cierre de archivo

                pop r12
                pop r13
                pop r15
                pop rbx
                pop rbp
                ret

; ~ void matriz_cargar(Matriz* self, int i, int j, float valor)
matriz_cargar:
                push rbp
                mov rbp, rsp
                push rbx
                push r15
                push r13
                push r12
               
                ;puntero a dst + tamaño del dato * #filas * i + tamaño del dato * j
                xor r12, r12
                mov r12d, edx
                shl r12d, 2

                mov eax, dword[rdi+offset_fila] ;eax=cantidad de filas
                mov ecx, esi
                mul rcx
                mov r15, rax ;r15 = fila*i
                shl r15, 2
                mov r13, [rdi+offset_vector] ;r13 = vector

                add r13, r15
                add r13, r12

                movd r12d, xmm0
                mov dword [r13], r12d
.fin:
                pop r12
                pop r13
                pop r15
                pop rbx
                pop rbp
                ret

; ~ Matriz* multiplicar(Matriz *self, Matriz *b);
matriz_multiplicar:    
                push rbp
                mov rbp, rsp
                push rbx
                push r15
                push r14
                push r13
                push r12
                sub rsp, 8

                ;seteo de valores

                mov r15, rdi ; r15 = *A
                mov r14, rsi ; r14 = *B

                mov edi, [r15+offset_fila]
                mov esi, [r14+offset_columna]
                call matriz_create
                mov r11, rax ; r11 = *C
                mov r10, rax ; r10 = *C

                mov r13d, [r11+offset_fila] ; #filas de C
                mov r12d, [r11+offset_columna] ; #columnas de C
               
                mov rdi, r15
                mov rsi, r14
               
                mov ecx, [r15+offset_columna] ; rcx = #columnas de A
                mov r8d, ecx ; r8 = #columnas de A

                mov r15, [r15+offset_vector] ; r15=*A
                mov r14, [r14+offset_vector] ; r14=*B
                mov r11, [r11+offset_vector] ; r11=*C

                movdqu xmm1, [CeroATres] ; xmm1 = 3|2|1|0 (i|i|i|i)
                pxor xmm2, xmm2 ; xmm2 = 0|0|0|0 (j|j|j|j)
               
                movq xmm4, r14
                movddup xmm3, xmm4 ; xmm3 = r14|r14

                pxor xmm4, xmm4 ; xmm4 = 0|0|0|0

                movdqu xmm6, [cuatros] ; xmm6 = 4|4|4|4

                movups xmm13, [unos] ; xmm13 = 1|1|1|1

                movups xmm12, [unos] ; xmm12 = 1|1|1|1 (flags, si no se pasó es 1, si se pasó es 0)

                movdqu xmm14, [inversor]

                movdqu xmm15, [IntUnos] ; xmm15 = 1|1|1|1

                movd xmm5, r12d ; x|x|x|#columnas
                shufps xmm5, xmm5, 0h ; xmm5 = #columnas|#columnas|#columnas|#columnas
               

                xor rax, rax ; i = 0
                xor rbx, rbx ; j = 0
               
.nuevo_C:
                pxor xmm11, xmm11 ; xmm11 = 0|0|0|0 (C3|C2|C1|C0)

.calculo_C:
                sub rcx, 4             
                cmp rcx, 0
                jl .me_pase ;si rcx<0, falta procesar de 0 a 3 floats => retroceder

.calculo_B:
                ;cálculo de posición de memoria de B
                ;puntero a dst + tamaño del dato * #columnas * i + tamaño del dato * j

                ;tamaño del dato * j          
                movdqu xmm9, xmm2 ; j3|j2|j1|j0
                movdqu xmm10, xmm9 ; xmm10 = j3|j2|j1|j0
               
                punpckldq xmm9, xmm4 ; xmm9 = j2|j0
                punpckhdq xmm10, xmm4 ; xmm10 = j3|j1

                psllq xmm9, 2 ; xmm9 = j2*tamDato|j0*tamDato
                psllq xmm10, 2 ; xmm10 = j3*tamDato|j1*tamDato

                ;tamaño del dato * #columnas * i              
                movdqu xmm7, xmm1 ; xmm7 = i3|i2|i1|i0
                movdqu xmm8, xmm1 ; xmm8 = i3|i2|i1|i0         
                shufps xmm8, xmm8, 39h ; xmm8 = i0|i3|i2|i1

                pmuludq xmm7, xmm5 ; xmm7 = i2*#columnas|i0*#columnas
                pmuludq xmm8, xmm5 ; xmm8 = i3*#columnas|i1*#columnas
               
                psllq xmm7, 2 ; xmm7 = i2*#columnas*tamDato|i0*#columnas*tamDato
                psllq xmm8, 2 ; xmm8 = i3*#columnas*tamDato|i1*#columnas*tamDato
               
                ;sumo dst + i + j
                paddq xmm7, xmm9
                paddq xmm8, xmm10
                paddq xmm7, xmm3 ; xmm7 = B2|B0
                paddq xmm8, xmm3 ; xmm8 = B3|B1
               
.cargo_datos:
                ;cargado de valores de A
                movdqu xmm9, [r15] ; xmm9 = A3|A2|A1|A0
               
                ;cargado de valores de B
                pextrq r9, xmm8, 1h ; r9 = B3
                movd xmm10, [r9] ; xmm10 = 0|0|0|B3
                shufps xmm10, xmm10, 93h; xmm10 = 0|0|B3|0

                pextrq r9, xmm7, 1h ; r9 = B2
                movd xmm0, [r9] ; xmm0 = 0|0|0|B2
                xorps xmm10, xmm0 ; xmm10 = 0|0|B3|B2
                shufps xmm10, xmm10, 93h; xmm10 = 0|B3|B2|0

                pextrq r9, xmm8, 0; r9 = B1
                movd xmm0, [r9] ; xmm0 = 0|0|0|B1
                xorps xmm10, xmm0 ; xmm10 = x|B3|B2|B1
                shufps xmm10, xmm10, 93h; xmm10 = B3|B2|B1|0


                pextrq r9, xmm7, 0; r9 = B0
                movd xmm0, [r9] ; xmm10 = 0|0|0|B0
                xorps xmm10, xmm0 ; xmm10 = B3|B2|B1|B0

                ;si hay datos ya calculados se ponen en 0 para que no afecte la suma final
                mulps xmm9, xmm12 ; xmm9 = A3*flag|A2*flag|A1*flag|A0*flag

                mulps xmm9, xmm10 ; xmm9 = A3*B3|A2*B2|A1*B1|A0*B0
                addps xmm11, xmm9; xmm11 = suma3|suma2|suma1|suma0

.muevo_punteros:
                add r15, 16

                cmp ecx, 0
                je .avanzo_C ;si ecx = 0, terminó la fila de A
               
                paddd xmm1, xmm6 ; i3+4|i2+4|i1+4|i0+4 avanzo 4 filas
               
                jmp .calculo_C

.me_pase:
                ;creación de máscara para anular los datos ya calculados
                movd xmm12, r8d ; x|x|x|#columnas
                shufps xmm12, xmm12, 0h ; xmm12 = #columnas|#columnas|#columnas|#columnas
                pcmpgtd xmm12, xmm1 ; si i < #columnas pone 1's, sino 0's
                pand xmm12, xmm13 ; si i < #columnas pone 1, sino 0
                shufps xmm12, xmm12, 1Bh ; se acomoda la máscara (1|2|3|4 -> 4|3|2|1)

                ;modificación del índice de las filas
                movd xmm0, ecx ; x|x|x|contador
                shufps xmm0, xmm0, 0h ; xmm0 = contador|contador|contador|contador
                paddd xmm1, xmm0 ; se le resta a i la cantidad de celdas que se pasó.
               
                imul rcx, 4 ;cantidad de bytes a retroceder            
                add r15, rcx ;retrocede A

                xor rcx, rcx ; rcx = 0 para que ejecute un ciclo más y termine el ciclo
                jmp .calculo_B

.avanzo_C:
                ;guardado de C
                movups xmm9, xmm11 ; xmm9 = suma3|suma2|suma1|suma0
                psrldq xmm9, 8 ;xmm9 = 0|0|suma3|suma2
                addps xmm11, xmm9  ; xmm11 = x|x|suma3+suma1|suma2+suma0
                movups xmm9, xmm11 ; xmm9 = x|x|suma3+suma1|suma2+suma0
                psrldq xmm9, 4 ; xmm9 = x|x|x|suma3+suma1
                addps xmm11, xmm9 ; xmm11 = x|x|x|sumatoria
                movd [r11], xmm11 ; guardado c
       
                pxor xmm11, xmm11 ; se reinicia c
                ;se reinician los valores
                movups xmm12, [unos] ; xmm12 = 1|1|1|1 (flags, si se pasó es 1, si no es 0)
                mov ecx, r8d ; ecx = #columnas de A

                ;se mueven los punteros
                ;hay más columnas en B?
                add ebx, 1
                cmp ebx, r12d
                je .avanzar_una_fila

                ;hay más columnas en B
                movdqu xmm1, [CeroATres] ; xmm1 = 0|1|2|3 (i|i|i|i)
                paddd xmm2, xmm15 ; j0+1|j1+1|j2+1|j3+1 se avanza 1 columna
                add r11, 4 ;avanza c un float

                mov rdx, r8 ; #columnas de A
                imul rdx, 4
                sub r15, rdx ;retrocede A
                jmp .calculo_C

.avanzar_una_fila:
                ;hay más filas en A?
                add eax, 1
                cmp eax, r13d
                je .fin

                xor rbx, rbx ; reinicia la cantidad de columnas
                ;hay más filas en A
                movdqu xmm1, [CeroATres] ; xmm1 = 0|1|2|3 (i|i|i|i)
                pxor xmm2, xmm2 ; xmm2 = 0|0|0|0 (j|j|j|j)
                add r11, 4 ;avanza c un float
                jmp .calculo_C

.fin:  
                mov rax, r10 ; retorna el puntero a C
                add rsp, 8
                pop r12
                pop r13
                pop r14
                pop r15
                pop rbx
                pop rbp
                ret


; ~ void dividir(Matriz *self, const float v);
matriz_dividir:
                push rbp
                mov rbp, rsp
                push r15
                sub rsp, 8
               
                ;multiplica fila por columna
                mov ecx, [rdi+offset_fila]
                mov eax, [rdi+offset_columna]
                mul ecx

                mov rdi, [rdi+offset_vector] ;rdi = puntero al vector
                ;en xmm0 está v
                shufps xmm0, xmm0, 0h ; en xmm0 =  v|v|v|v
.ciclo:
                sub rax, 4             
                cmp rax, 0
                jl .me_pase ;si rax<0, faltan procesar de 0 a 3 floats
                movdqu xmm1, [rdi] ; e|e|e|e
                divps xmm1, xmm0 ; e/v|e/v|e/v|e/v             
                movdqu [rdi], xmm1
                je .fin ;si rax=0 significa que terminó
                add rdi, 16
                jmp .ciclo
.me_pase:
                ;si se pasó x lugares coloco x 1's para que no vuelva a dividir
                add rax, 4
                movdqu xmm3, [UnoACuatro] ; 1|2|3|4
                movd xmm2, eax  
                shufps xmm2, xmm2, 0h ;xmm2 = eax|eax|eax|eax
                addps xmm2, xmm3
                movdqu xmm3, [cuatros]
                pcmpgtd xmm2, xmm3 ; si es mayor a 0 pone 1's, sino 0's

                andps xmm0, xmm2
               
                movdqu xmm5, [inversor]
                pxor xmm2, xmm5 ; invierte la mascara
                movups xmm4, [unos]
                andps xmm4, xmm2 ; los 1's están donde no debería volver a dividirse

                pxor xmm0, xmm4 ; junta los 1's con los v's

                sub rax, 4
                imul rax, 4 ;cantidad de bytes a retroceder            
                add rdi, rax
                movdqu xmm1, [rdi] ; e|e|e|e
                divps xmm1, xmm0 ; e/v|e/v|e/v|e/v             
                movdqu [rdi], xmm1
.fin:
                add rsp, 8
                pop r15
                pop rbp
                ret

; ~ void copiar(Matriz *self, Matriz *b);
matriz_copiar:
                push rbp
                mov rbp, rsp
               
                ;multiplica fila por columna
                mov ecx, [rdi+offset_fila]
                mov eax, [rdi+offset_columna]
                mul ecx

                mov rdi, [rdi+offset_vector] ;puntero al vector destino
                mov rsi, [rsi+offset_vector] ;puntero al vector fuente
.ciclo:
                sub rax, 4             
                cmp rax, 0
                jl .me_pase ;si rax<0 falta procesar de 0 a 3 floats
                movdqu xmm1, [rsi]
                movdqu [rdi], xmm1
                je .fin ;si rax=0 significa que terminó
                add rdi, 16
                add rsi, 16
                jmp .ciclo
.me_pase:
                imul rax, 4 ;cantidad de bytes a retroceder            
                add rdi, rax
                add rsi, rax
                movdqu xmm1, [rsi]             
                movdqu [rdi], xmm1             
.fin:
                pop rbp
                ret

; ~ void traspuesta(Matriz *self, Matriz *res);
matriz_traspuesta:
                push rbp
                mov rbp, rsp
                push rbx
                push r15
                push r14
                push r13
                push r12
                sub rsp, 8
               
                mov r13d, [rsi+offset_fila] ;#filas
                mov r12d, [rsi+offset_columna] ;#columnas
               
                mov r15, [rdi+offset_vector] ;r15=puntero al vector fuente
                mov r14, [rsi+offset_vector] ;r14=puntero al vector destino

                movdqu xmm1, [CeroATres] ; xmm1 = 3|2|1|0 (i|i|i|i)
                pxor xmm2, xmm2 ; xmm2 = 0|0|0|0 (j|j|j|j)
               
                movq xmm14, r14
                movddup xmm3, xmm14 ; xmm3 = r14|r14

                pxor xmm4, xmm4 ; xmm4 = 0|0|0|0

                movdqu xmm6, [cuatros] ; xmm6 = 4|4|4|4

                movdqu xmm13, [IntUnos] ; xmm13 = 1|1|1|1

                movdqu xmm14, [inversor]

                movd xmm5, r13d ; x|x|x|#filas
                shufps xmm5, xmm5, 0h ; xmm5 = #filas|#filas|#filas|#filas
               
                movd xmm15, r12d ; x|x|x|#columnas
                shufps xmm15, xmm15, 0h ; xmm5 = #columnas|#columnas|#columnas|#columnas
               
                ;multiplica fila por columna
                mov ecx, r13d
                mov eax, r12d
                mul ecx

                mov r12d, 5
               
.ciclo:
                sub rax, 4             
                cmp rax, 0
                jl .me_pase ;si rax<0 falta procesar de 0 a 3 floats

.acomodo_i_j:
                movdqu xmm11, xmm5 ; xmm11 = #filas|#filas|#filas|#filas
                pcmpgtd xmm11, xmm1 ; #filas > i? 0xffff ffff else 0x0000 0000
                pxor xmm11, xmm14 ; invierte la mascara #filas <= i? 0xffff ffff else 0x0000 0000
                movdqu xmm12, xmm11 ; copia la máscara

                pand xmm11, xmm5 ; si #filas <= i, #filas, sino 0
                psubd xmm1, xmm11 ; si se pasó, se resta la cantidad de filas

                pand xmm12, xmm13 ; si #filas <= i, 1, sino 0
                paddd xmm2, xmm12 ; suma uno a la columna si corresponde

                ;hay que restar de nuevo las filas?
                movdqu xmm11, xmm5 ; xmm11 = #filas|#filas|#filas|#filas
                pcmpgtd xmm11, xmm1 ; #filas > i? 0xffff ffff else 0x0000 0000
               
                mov rcx, qword 0xFFFFFFFFFFFFFFFF
                pextrq rbx, xmm11, 0h
                cmp rbx, rcx
                jne .acomodo_i_j ; la máscara no quedó toda en 0, puede ser que haya que restar de nuevo
                pextrq rbx, xmm11, 1h
                cmp rbx, rcx
                jne .acomodo_i_j ; la máscara no quedó toda en 0, puede ser que haya que restar de nuevo

.calculo_dst:
                ;cálculo de la posición de memoria del destino
                ;puntero a dst + tamaño del dato * #columnas * i + tamaño del dato * j

                ;tamaño del dato * j          
                movdqu xmm9, xmm2 ; j3|j2|j1|j0
                shufps xmm9, xmm9, 0xD8 ; xmm9 = j3|j1|j2|j0           
                movdqu xmm10, xmm9 ; xmm10 = j3|j1|j2|j0
               
                punpckldq xmm9, xmm4 ; xmm9 = j2|j0
                punpckhdq xmm10, xmm4 ; xmm10 = j3|j1

                psllq xmm9, 2 ; xmm9 = j2*tamDato|j0*tamDato
                psllq xmm10, 2 ; xmm10 = j3*tamDato|j1*tamDato

                ;tamaño del dato * #columnas * i              
                movdqu xmm7, xmm1 ; xmm7 = i3|i2|i1|i0
                movdqu xmm8, xmm1 ; xmm8 = i3|i2|i1|i0         
                shufps xmm8, xmm8, 39h ; xmm8 = i0|i3|i2|i1

                pmuludq xmm7, xmm15 ; xmm7 = i2*#columnas|i0*#columnas
                pmuludq xmm8, xmm15 ; xmm8 = i3*#columnas|i1*#columnas
               
                psllq xmm7, 2 ; xmm7 = i2*#columnas*tamDato|i0*#columnas*tamDato
                psllq xmm8, 2 ; xmm8 = i3*#columnas*tamDato|i1*#columnas*tamDato
               
                ;suma dst + i + j
                paddq xmm7, xmm9
                paddq xmm8, xmm10
                paddq xmm7, xmm3 ; xmm7 = dst2|dst0
                paddq xmm8, xmm3 ; xmm8 = dst3|dst1
               
.muevo_datos:
                movdqu xmm0, [r15] ;carga los valores de la fuente

                pextrq rbx, xmm8, 1 ; rbx = dst3
                pextrd ecx, xmm0, 3 ; rcx = dato3
                mov dword [rbx], ecx

                sub r12d, 1
                cmp r12d, 0
                je .fin

                pextrq rbx, xmm7, 1 ; rbx = dst2
                pextrd ecx, xmm0, 2 ; rcx = dato2
                mov dword [rbx], ecx

                sub r12d, 1
                cmp r12d, 0
                je .fin

                pextrq rbx, xmm8, 0 ; rbx = dst1
                pextrd ecx, xmm0, 1 ; rcx = dato1
                mov dword [rbx], ecx

                sub r12d, 1
                cmp r12d, 0
                je .fin

                pextrq rbx, xmm7, 0 ; rbx = dst0
                pextrd ecx, xmm0, 0 ; rcx = dato0
                mov dword [rbx], ecx

                sub r12d, 1
                cmp r12d, 0
                je .fin

.muevo_punteros:
                cmp eax, 0
                je .fin ;si rax es 0 significa que terminó
               
                add r15, 16
               
                mov r12d, 5

                paddd xmm1, xmm6 ; i3+4|i2+4|i1+4|i0+4 avanza 4 filas
               
                jmp .ciclo

.me_pase:

                movd xmm11, eax ; x|x|x|contador
                shufps xmm11, xmm11, 0h ; xmm11 = contador|contador|contador|contador
                paddd xmm1, xmm11 ; le resta a i la cantidad de celdas que se pasó. j se actualiza arriba

                mov r12d, eax
                add r12d, 4 ;setea el código para ver cuántos debe procesar

                imul rax, 4 ;cantidad de bytes a retroceder            
                add r15, rax
               
                xor rax, rax ; lo pone en 0 para que salga
                jmp .acomodo_i_j

.fin:
                add rsp, 8
                pop r12
                pop r13
                pop r14
                pop r15
                pop rbx
                pop rbp
                ret


; ~ void traspuestaCuadrada(Matriz *self);
matriz_traspuestaCuadrada:
                push rbp
                mov rbp, rsp
                push rbx
                push r15
                push r14
                push r13
                push r12
                sub rsp, 8
               
                mov r13d, [rdi+offset_fila] ;#filas
               
                mov rdi, [rdi+offset_vector] ;rdi = puntero al vector destino (triángulo superior de la matriz)

                movdqu xmm1, [UnoACuatro] ; xmm1 = 4|3|2|1 (j|j|j|j)
                pxor xmm2, xmm2 ; xmm2 = 0|0|0|0 (i|i|i|i)
               
                movq xmm6, rdi
                movddup xmm3, xmm6 ; xmm3 = rdi|rdi

                pxor xmm4, xmm4 ; xmm4 = 0|0|0|0

                movdqu xmm6, [cuatros] ; xmm6 = 4|4|4|4

                movdqu xmm13, [IntUnos] ; xmm13 = 1|1|1|1

                movdqu xmm14, [inversor]

                mov r12d, 5

                movd xmm5, r13d ; x|x|x|#filas
                shufps xmm5, xmm5, 0h ; xmm5 = #filas|#filas|#filas|#filas
               
                ;multiplica fila por columna
                mov ecx, r13d
                mov eax, r13d
                mul ecx

                sub eax, r13d ; le resta los elementos de la diagonal
                shr eax, 1 ; lo divide por 2

.ciclo:
                sub eax, 4             
                cmp eax, 0
                jl .me_pase ;si rax<0, falta procesar de 0 a 3 floats

.acomodo_i_j:
                movdqu xmm11, xmm5 ; xmm11 = #filas|#filas|#filas|#filas
                pcmpgtd xmm11, xmm1 ; #filas > i? 0xffff ffff else 0x0000 0000
                pxor xmm11, xmm14 ; invierte la máscara #filas <= i? 0xffff ffff else 0x0000 0000
                movdqu xmm12, xmm11 ; copia la máscara

                pand xmm11, xmm5 ; si #filas <= i, #filas, sino 0
                psubd xmm1, xmm11 ; si se pasó, resta la cantidad de filas

                movdqu xmm11, xmm12 ; copia la máscara

                pand xmm12, xmm13 ; si #filas <= i, 1, sino 0
                paddd xmm2, xmm12 ; suma uno a la columna si corresponde
                paddd xmm1, xmm12 ; si #filas <= i, suma 1 a i, sino no
               
                pand xmm11, xmm2 ; si #filas <= i, j, sino 0
                paddd xmm1, xmm11 ; si #filas <= i, suma j a i, sino no

                ;se fija si hay que restar de nuevo las filas
                movdqu xmm11, xmm5 ; xmm11 = #filas|#filas|#filas|#filas
                pcmpgtd xmm11, xmm1 ; #filas > i? 0xffff ffff else 0x0000 0000
               
                mov rcx, qword 0xFFFFFFFFFFFFFFFF
                pextrq rbx, xmm11, 0h
                cmp rbx, rcx
                jne .acomodo_i_j ; la máscara no quedó toda en 0, puede ser que haya que restar de nuevo
                pextrq rbx, xmm11, 1h
                cmp rbx, rcx
                jne .acomodo_i_j ; la máscara no quedó toda en 0, puede ser que haya que restar de nuevo

.calculo_dst:
                ;cálculo de la posición de memoria del destino
                ;puntero a dst + tamaño del dato * #filas * i + tamaño del dato * j

                ;tamaño del dato * j          
                movdqu xmm9, xmm2 ; j3|j2|j1|j0
                shufps xmm9, xmm9, 0xD8 ; xmm9 = j3|j1|j2|j0           
                movdqu xmm10, xmm9 ; xmm10 = j3|j1|j2|j0
               
                punpckldq xmm9, xmm4 ; xmm9 = j2|j0
                punpckhdq xmm10, xmm4 ; xmm10 = j3|j1

                psllq xmm9, 2 ; xmm9 = j2*tamDato|j0*tamDato
                psllq xmm10, 2 ; xmm10 = j3*tamDato|j1*tamDato

                ;tamaño del dato * #filas * i         
                movdqu xmm7, xmm1 ; xmm7 = i3|i2|i1|i0
                movdqu xmm8, xmm1 ; xmm8 = i3|i2|i1|i0         
                shufps xmm8, xmm8, 39h ; xmm8 = i0|i3|i2|i1

                pmuludq xmm7, xmm5 ; xmm7 = i2*#filas|i0*#filas
                pmuludq xmm8, xmm5 ; xmm8 = i3*#filas|i1*#filas
               
                psllq xmm7, 2 ; xmm7 = i2*#filas*tamDato|i0*#filas*tamDato
                psllq xmm8, 2 ; xmm8 = i3*#filas*tamDato|i1*#filas*tamDato
               
                ;sumo dst + i + j
                paddq xmm7, xmm9
                paddq xmm8, xmm10
                paddq xmm7, xmm3 ; xmm7 = dst2|dst0
                paddq xmm8, xmm3 ; xmm8 = dst3|dst1
               
.calculo_src:
                ;cálculo de la posición de memoria del destino
                ;puntero a dst + tamaño del dato * #filas * i + tamaño del dato * j

                ;tamaño del dato * j          
                movdqu xmm9, xmm1 ; j3|j2|j1|j0
                shufps xmm9, xmm9, 0xD8 ; xmm9 = j3|j1|j2|j0           
                movdqu xmm10, xmm9 ; xmm10 = j3|j1|j2|j0
               
                punpckldq xmm9, xmm4 ; xmm9 = j2|j0
                punpckhdq xmm10, xmm4 ; xmm10 = j3|j1

                psllq xmm9, 2 ; xmm9 = j2*tamDato|j0*tamDato
                psllq xmm10, 2 ; xmm10 = j3*tamDato|j1*tamDato

                ;tamaño del dato * #filas * i         
                movdqu xmm11, xmm2 ; xmm11 = i3|i2|i1|i0
                movdqu xmm12, xmm2 ; xmm12 = i3|i2|i1|i0               
                shufps xmm12, xmm12, 39h ; xmm12 = i0|i3|i2|i1

                pmuludq xmm11, xmm5 ; xmm11 = i2*#filas|i0*#filas
                pmuludq xmm12, xmm5 ; xmm12 = i3*#filas|i1*#filas
               
                psllq xmm11, 2 ; xmm11 = i2*#filas*tamDato|i0*#filas*tamDato
                psllq xmm12, 2 ; xmm12 = i3*#filas*tamDato|i1*#filas*tamDato
               
                ;sumo dst + i + j
                paddq xmm11, xmm9
                paddq xmm12, xmm10
                paddq xmm11, xmm3 ; xmm11 = src2|src0
                paddq xmm12, xmm3 ; xmm12 = src3|src1

.muevo_datos:
               
                pextrq rbx, xmm7, 0 ; rbx = dst0
                pextrq rcx, xmm11, 0 ; rcx = src0
                mov r15d, dword[rbx] ; r15 = dato dst0
                mov r14d, dword[rcx] ; r14 = dato src0
                mov dword[rbx], r14d
                mov dword[rcx], r15d


                sub r12d, 1
                cmp r12d, 0
                je .fin

                pextrq rbx, xmm8, 0 ; rbx = dst1
                pextrq rcx, xmm12, 0 ; rcx = src1
                mov r15d, dword[rbx] ; r15 = dato dst1
                mov r14d, dword[rcx] ; r14 = dato src1
                mov dword[rbx], r14d
                mov dword[rcx], r15d

                sub r12d, 1
                cmp r12d, 0
                je .fin

                pextrq rbx, xmm7, 1h ; rbx = dst2
                pextrq rcx, xmm11, 1h ; rcx = src2
                mov r15d, dword[rbx] ; r15 = dato dst2
                mov r14d, dword[rcx] ; r14 = dato src2
                mov dword[rbx], r14d
                mov dword[rcx], r15d

                sub r12d, 1
                cmp r12d, 0
                je .fin

                pextrq rbx, xmm8, 1h ; rbx = dst3
                pextrq rcx, xmm12, 1h ; rcx = src3
                mov r15d, dword[rbx] ; r15 = dato dst3
                mov r14d, dword[rcx] ; r14 = dato src3
                mov dword[rbx], r14d
                mov dword[rcx], r15d

                sub r12d, 1
                cmp r12d, 0
                je .fin

.muevo_punteros:
                cmp eax, 0
                je .fin ;si rax es 0 significa que terminó
               
                mov r12d, 5

                paddd xmm1, xmm6 ; i3+4|i2+4|i1+4|i0+4 avanzo 4 filas
               
                jmp .ciclo

.me_pase:
                mov r12d, eax
                add r12d, 4 ;seteo del código para ver cuántos debe procesar

                xor rax, rax ; lo pone en 0 para que salga
                jmp .acomodo_i_j

.fin:
                add rsp, 8
                pop r12
                pop r13
                pop r14
                pop r15
                pop rbx
                pop rbp
                ret


; ~ void mediaCero(Matriz *self);
matriz_mediaCero:
                push rbp
                mov rbp, rsp
                push rbx
                push r15
                push r14
                push r13
                push r12
                sub rsp, 8

                mov r15, rdi ; r15 = self

                mov r14d, [r15+offset_fila] ; r14 = cantidad de filas de self
                mov r13d, [r15+offset_columna] ; r13 = cantidad de columnas de self

                mov r15, [r15+offset_vector]

                xor rcx, rcx ; contador de filas = 0
                xor rbx, rbx ; contador de columnas = 0

                pxor xmm0, xmm0

                movups xmm12, [unos] ; xmm12 = 1|1|1|1 (flags, si no se pasó es 1, sino es 0)
                pxor xmm13, xmm13 ; son flags como los de xmm12 pero se usa para no volver a calcular datos

                movd xmm2, r14d ; x|x|x|#filas
                shufps xmm2, xmm2, 0h ; xmm2 = #filas|#filas|#filas|#filas
                cvtdq2ps xmm2, xmm2 ; pasa la cantidad de filas a float

.suma:
                mov eax, r13d ; eax = #columnas
                mul ecx ; eax = #columnas * contador de filas
                shl rax, 2 ; rax = #columnas * contador de filas * tam del dato

                mov r12, rbx ; r12 = contador de columnas
                shl r12, 2 ; r12 = contador de columnas * tamaño del dato

                add r12, r15
                add r12, rax ; r12 = me posiciona en cont. fila, cont. columna de self

                movdqu xmm1, [r12] ; xmm1 = A3|A2|A1|A0
                mulps xmm1, xmm12 ; xmm1 = A3*flag|A2*flag|A1*flag|A0*flag
               
                addps xmm0, xmm1 ; xmm0 = suma3|suma2|suma1|suma0

                add ecx, 1
                cmp ecx, r14d
                jl .suma ; se fija si hay más filas para procesar

                ; en xmm0 está la suma de las imágenes
                divps xmm0, xmm2 ; suma3/#filas|suma2/#filas|suma1/#filas|suma0/#filas
               
                xor rcx, rcx ; contador de filas = 0
.resta:
                mov eax, r13d ; eax = #columnas
                mul ecx ; eax = #columnas * contador de filas
                shl rax, 2 ; rax = #columnas * contador de filas * tam del dato

                mov r12, rbx ; r12 = contador de columnas
                shl r12, 2 ; r12 = contador de columnas * tamaño del dato

                add r12, r15
                add r12, rax ; r12 = se posiciona en cont. fila, cont. columna de self

                movdqu xmm1, [r12] ; xmm1 = A3|A2|A1|A0
                movdqu xmm15, xmm1
                mulps xmm15, xmm13 ; xmm15 = A3*flag2|A2*flag2|A1*flag2|A0*flag2
                mulps xmm1, xmm12 ; xmm1 = A3*flag|A2*flag|A1*flag|A0*flag

                ;si no se pasó, xmm15 = 0 y en xmm1 está lo que hay que procesar. si sí, en xmm15 están los valores
                ;que no se quieren modificar y en xmm1 los que sí

                subps xmm1, xmm0 ; xmm1 = resta3|resta2|resta1|resta0

                ;junta xmm14 y xmm1 antes de guardarlo en la matriz
                addps xmm1, xmm15
                movdqu [r12], xmm1 ; guarda la resta

                add ecx, 1
                cmp ecx, r14d
                jl .resta ; se fija si hay más filas para procesar

                ;avanza las columnas
                xor rcx, rcx ; contador de filas = 0
                pxor xmm0, xmm0

                add ebx, 4
                cmp ebx, r13d
                je .fin ;avanza los 4 floats que procesó y si es igual es porque terminó

                add ebx, 4
                cmp ebx, r13d
                jg .me_pase ;avanza 4 floats más y si es mayor es porque hay menos de 4 float para procesar

                sub ebx, 4
                jmp .suma ;entran 4 floats entonces retrocede hasta el comienzo de estos

.me_pase:
                ;si se pasó x lugares coloca x 1's para no volver a dividir
                sub ebx, r13d
                movdqu xmm3, [UnoACuatro] ; 1|2|3|4
                movd xmm12, ebx  
                shufps xmm12, xmm12, 0h ;xmm12 = ebx|ebx|ebx|ebx
                paddd xmm12, xmm3
                movdqu xmm3, [cuatros]
                pcmpgtd xmm12, xmm3 ; si es mayor a 0 pone 1's, sino 0's
                shufps xmm12, xmm12, 1Bh ; acomoda la máscara (1|2|3|4 -> 4|3|2|1)
                movdqu xmm13, xmm12 ; copia la máscara

                movdqu xmm5, [inversor]
                pxor xmm12, xmm5 ; invierte la máscara
                movups xmm4, [unos]
                andps xmm12, xmm4 ; los 1's están donde falta procesar
                andps xmm13, xmm4 ; los 1's están donde NO falta procesar

                mov ebx, r13d
                sub ebx, 4 ; setea bien la cantidad de columnas

                jmp .suma

.fin:          
                add rsp, 8
                pop r12
                pop r13
                pop r14
                pop r15
                pop rbx
                pop rbp
                ret

; ~ double norma2(Matriz *self);
matriz_norma2:
                push rbp
                mov rbp, rsp
               
                mov eax, [rdi+offset_fila]

                mov rdi, [rdi+offset_vector] ;puntero al vector
                
                pxor xmm2, xmm2
.ciclo:
                sub rax, 4             
                cmp rax, 0
                jl .me_pase ;si rax es negativo es porque falta procesar de 0 a 3 floats
                movups xmm1, [rdi] ; e|e|e|e
                mulps xmm1, xmm1 ; e²|e²|e²|e²
                addps xmm2, xmm1 ; suma|suma|suma|suma
                je .raiz ;si rax es 0 significa que terminó
                add rdi, 16
                jmp .ciclo
.me_pase:
                ;si se pasó x lugares coloco x 1's para que no vuelva a dividir
                add rax, 4
                movdqu xmm3, [UnoACuatro] ; 1|2|3|4
                movd xmm6, eax  
                shufps xmm6, xmm6, 0h ;xmm6 = eax|eax|eax|eax
                addps xmm6, xmm3
                movdqu xmm3, [cuatros]
                pcmpgtd xmm6, xmm3 ; si es mayor a 0 pone 1's, sino 0's

                movups xmm4, [unos]
                andps xmm6, xmm4; los 1's están donde estan los valores que faltan calcular

                sub rax, 4
                imul rax, 4 ;cantidad de bytes a retroceder            
                add rdi, rax
                movups xmm1, [rdi] ; e|e|e|e
                mulps xmm1, xmm1 ; e²|e²|e²|e²
                mulps xmm1, xmm6
                addps xmm2, xmm1 ; suma|suma|suma|suma
               
.raiz:
                movups xmm1, xmm2 ; xmm1 = suma0|suma1|suma2|suma3
                psrldq xmm1, 8 ;xmm1 = 0|0|suma0|suma1
                addps xmm2, xmm1  ; xmm2 = x|x|suma0+suma2|suma1+suma3        
                movups xmm1, xmm2 ; xmm1 = x|x|suma0+suma2|suma1+suma3
                psrldq xmm1, 4 ; xmm1 = x|x|x|suma0+suma2
                addps xmm2, xmm1 ; xmm2 = x|x|x|sumatoria

                pxor xmm3, xmm3
                cvtps2pd xmm2, xmm2 ; xmm2 = x|sumatoria

                sqrtpd xmm2, xmm2 ;xmm2 = x|sqrt(sumatoria)
                movdqu xmm0, xmm2 ; rax = sqrt(sumatoria)

.fin:
                pop rbp
                ret

; ~ void matriz_rotacion(Matriz *self, Matriz *Q, int i, int j);
matriz_rotacion:
                push rbp
                mov rbp, rsp
                push rbx
                push r15
                push r14
                push r13
                push r12
                sub rsp, 8

                mov r15, [rdi+offset_vector] ; r15 = self
                mov r14, [rsi+offset_vector] ; r14 = Q

                push r15 ; guarda rdx para el mul

                mov r13d, [rdi+offset_columna] ; r13 = cantidad de columnas de self

                push rdx ; guarda rdx para el mul

                ;cálculo de la posición de memoria de jk para la matriz self y Q
                ;puntero a matriz + tamaño del dato * #columnas * j
                mov eax, r13d ; eax = #columnas
                mul ecx ; rax = #columnas * j
                shl rax, 2 ; rax = #columnas * j * tamaño del dato

                mov r10, rax ; r10 = #columnas * j * tamaño del dato
                mov r8, rax ; r8 = #columnas * j * tamaño del dato
                add r10, r15 ; r10 = jk para self
                add r8 , r14 ; r8 = jk para Q
               
                pop rdx
                push rdx ; guarda rdx para el mul

                ;cálculo de la posición de memoria de ik para la matriz self y Q
                ;puntero a matriz + tamaño del dato * #columnas * i
                mov eax, r13d ; eax = #columnas
                mul edx ; rax = #columnas * i
                shl rax, 2 ; rax = #columnas * i * tamaño del dato

                mov r9, rax ; r9 = #columnas * i * tamaño del dato
                mov rbx, rax ; rbx = #columnas * i * tamaño del dato
                add r9, r15 ; r9 = ik para self
                add rbx , r14 ; rbx = ik para Q

                ;cálculo de la posición de memoria de x1
                ;puntero a self + tamaño del dato * #columnas * j + tamaño del dato * j
                mov eax, r13d
                mul ecx ; rax = #columnas * j
                shl rax, 2 ; rax = #columnas * j * tamaño del dato

                mov r12d, ecx ; r12 = j
                shl r12, 2 ; r12 = j * tamaño elemento

                add r12, r15
                add r12, rax ; r12 = x1
               
                pop rdx
                push rdx ; guarda rdx para usar el mul

                ;cálculo de la posición de memoria de x2
                ;puntero a self + tamaño del dato * #columnas * i + tamaño del dato * j
                mov eax, r13d
                mul edx ; rax = #columnas * i
                shl rax, 2 ; rax = #columnas * i * tamaño del dato

                mov r11d, ecx ; r11 = j
                shl r11, 2 ; r11 = j * tamaño elemento

                add r11, r15
                add r11, rax ; r11 = x2

                pop rdx

                movd xmm0, [r12] ; xmm0 = 0|0|0|x1
                shufps xmm0, xmm0, 93h; xmm0 = 0|0|x1|0
                movd xmm1, [r11] ; xmm1 = 0|0|0|x2
                xorps xmm0, xmm1 ; xmm0 = 0|0|x1|x2

                movups xmm1, xmm0 ; xmm1 = 0|0|x1|x2

                mulps xmm0, xmm1 ; xmm0 = x|x|x1²|x2²
                movups xmm2, xmm0 ; xmm2 = x|x|x1²|x2²

                psrldq xmm2, 4 ;xmm2 = 0|0|0|x1²

                addps xmm0, xmm2 ; xmm0 = x|x|x|x1²+x2²

                sqrtps xmm0, xmm0 ; xmm0 = x|x|x|sqrt(x1²+x2²)
                shufps xmm0, xmm0, 0h ; xmm0 = sqrt(x1²+x2²)|sqrt(x1²+x2²)|sqrt(x1²+x2²)|sqrt(x1²+x2²)
                divps xmm1, xmm0 ; xmm1 = 0|0|coseno|seno

                pextrd r12d, xmm1, 0 ; r12 = seno
                movd xmm0, r12d ; xmm0 = x|x|x|seno
                shufps xmm0, xmm0, 0h ; xmm0 = seno|seno|seno|seno

                pextrd r12d, xmm1, 1 ; r12 = coseno
                movd xmm1, r12d ; xmm1 = x|x|x|coseno
                shufps xmm1, xmm1, 0h ; xmm1 = coseno|coseno|coseno|coseno

                xor r15, r15 ; flag = 0

.ciclo:
                cmp r13, 0
                je .fin ;si r13 es 0, terminó

                sub r13, 4             
                cmp r13, 0

                jl .me_pase ;si r13 es negativo es porque falta procesar de 0 a 3 floats

.ciclo_aux:
                movups xmm2, [r10] ; xmm2 = jkSelf1|jkSelf2|jkSelf3|jkSelf4
                movups xmm3, [r9] ; xmm3 = ikSelf1|ikSelf2|ikSelf3|ikSelf4
                movups xmm4, [r8] ; xmm4 = jkQ1|jkQ2|jkQ3|jkQ4
                movups xmm5, [rbx] ; xmm5 = ikQ1|ikQ2|ikQ3|ikQ4
                movups xmm6, xmm2 ; xmm6 = jkSelf1|jkSelf2|jkSelf3|jkSelf4
                movups xmm7, xmm3 ; xmm7 = ikSelf1|ikSelf2|ikSelf3|ikSelf4
                movups xmm8, xmm4 ; xmm8 = jkQ1|jkQ2|jkQ3|jkQ4
                movups xmm9, xmm5 ; xmm9 = ikQ1|ikQ2|ikQ3|ikQ4
                       
                ;cálculo de jk para self
                mulps xmm2, xmm1 ; xmm2 = jkSelf1 * cos | jkSelf2 * cos | jkSelf3 * cos | jkSelf4 * cos
                mulps xmm3, xmm0 ; xmm3 = ikSelf1 * sen | ikSelf2 * sen | ikSelf3 * sen | ikSelf4 * sen
                addps xmm2, xmm3 ; xmm2 = auxSelf|auxSelf|auxSelf|auxSelf

                ;cálculo de ik para self
                mulps xmm7, xmm1 ; xmm7 = ikSelf1 * cos | ikSelf2 * cos | ikSelf3 * cos | ikSelf4 * cos
                mulps xmm6, xmm0 ; xmm6 = jkSelf1 * sen | jkSelf2 * sen | jkSelf3 * sen | jkSelf4 * sen
                subps xmm7, xmm6 ; xmm7 = auxSelf|auxSelf|auxSelf|auxSelf

                ;cálculo de jk para Q
                mulps xmm4, xmm1 ; xmm4 = jkQ1 * cos | jkQ2 * cos | jkQ3 * cos | jkQ4 * cos
                mulps xmm5, xmm0 ; xmm3 = ikQ1 * sen | ikQ2 * sen | ikQ3 * sen | ikQ4 * sen
                addps xmm4, xmm5 ; xmm4 = auxQ|auxQ|auxQ|auxQ

                ;cálculo de ik para Q
                mulps xmm9, xmm1 ; xmm9 = ikQ1 * cos | ikQ2 * cos | ikQ3 * cos | ikQ4 * cos
                mulps xmm8, xmm0 ; xmm8 = jkQ1 * sen | jkQ2 * sen | jkQ3 * sen | jkQ4 * sen
                subps xmm9, xmm8 ; xmm9 = auxQ|auxQ|auxQ|auxQ

                cmp r15, 0
                jne .guardo_me_pase

                ;guarda los valores obtenidos
                movups [r10], xmm2
                movups [r9], xmm7
                movups [r8], xmm4
                movups [rbx], xmm9

                ;avanza los punteros de los ik, jk de Q y de self
                add r10, 16
                add r9, 16
                add r8, 16
                add rbx, 16

                jmp .ciclo

.me_pase:
                imul r13, 4 ;cantidad de bytes a retroceder            

                add r10, r13
                add r9, r13
                add r8, r13
                add rbx, r13

                mov r15, 1 ; seteo de flag
                jmp .ciclo_aux
               
.guardo_me_pase:
                ;vuelve a colocar los punteros en la posición en la que hay que cargar los datos
                sub r10, r13  
                sub r9, r13
                sub r8, r13
                sub rbx, r13

                add r13, 16 ; paso a positivo
                shr r13, 2 ; cálculo de la cantidad de datos a almacenar
                mov r14d, 4
                sub r14d, r13d ; cálculo de la cantidad de datos que no se utilizarán

                ; 0|1|2|3 -> 3|2|1|0
                shufps xmm2, xmm2, 1Bh
                shufps xmm7, xmm7, 1Bh
                shufps xmm4, xmm4, 1Bh
                shufps xmm9, xmm9, 1Bh

.acomodo_me_pase:
                ;pasaje para adelante de los datos a almacenar
                shufps xmm2, xmm2, 93h
                shufps xmm7, xmm7, 93h
                shufps xmm4, xmm4, 93h
                shufps xmm9, xmm9, 93h

                sub r14d, 1
                cmp r14d, 0
                jne .acomodo_me_pase

.ciclo_me_pase:
                pextrd r12d, xmm2, 3
                mov dword [r10], r12d
                pextrd r12d, xmm7, 3
                mov dword [r9], r12d
                pextrd r12d, xmm4, 3
                mov dword [r8], r12d
                pextrd r12d, xmm9, 3
                mov dword [rbx], r12d

                ;mueve los punteros
                add r10, 4
                add r9, 4
                add r8, 4
                add rbx, 4

                ;mueve los datos un lugar a la izquierda
                shufps xmm2, xmm2, 93h
                shufps xmm7, xmm7, 93h
                shufps xmm4, xmm4, 93h
                shufps xmm9, xmm9, 93h

                sub r13, 1
                cmp r13, 0
                jne .ciclo_me_pase

.fin:          
                ;fuerzo el 0 en la posición i, j de self
                ;puntero a self + tamaño del dato * #columnas * i + tamaño del dato * j
                mov r13d, [rdi+offset_columna] ; r13 = cantidad de columnas de self
                mov eax, r13d
                mul edx ; rax = #columnas * i
                shl rax, 2 ; rax = #columnas * i * tamaño del dato

                mov r11d, ecx ; r11 = j
                shl r11, 2 ; r11 = j * tamaño elemento

                pop r15 ; recupera el puntero al vector self
                add r11, r15
                add r11, rax ; r11 = self(ij)

                mov r15d, 0
                mov dword [r11], r15d ; coloca el 0

                add rsp, 8
                pop r12
                pop r13
                pop r14
                pop r15
                pop rbx
                pop rbp
                ret