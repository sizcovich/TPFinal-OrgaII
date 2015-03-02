# TPFinal-OrgaII

How to compile it:
- You need to have QtCreator installed.
- Open the .pro file with Qt.
- Run it (it is not going to compile because of a matriz_asm.o error)
- You will find a new folder "Build" outside the main folder, open it and copy the Makefile into the folder where the .pro is.
- Open the Makefile and replace the line "matriz_asm.o: ...." by 
" matriz_asm.o: ../TPFinal-OrgaII/codigo/matriz_asm.asm 
	nasm -f elf64 -g -F dwarf -o matriz_asm.o ../TPFinal-OrgaII/codigo/matriz_asm.asm "
- Open the project with Qt again and compile it.
- Enjoy :)

For any further information please contact me: sizcovich@gmail.com sebastian_vita@yahoo.com.ar

Para usarlo:
- Tener instalado QtCreator
- abrir el .pro con el Qt
- Compilarlo (no va a compilar porque no va a poder crear matriz_asm.o)
- Fuera de la carpeta se va a crear una carpeta build
- Abrir la carpeta y copiar el Makefile en la carpeta donde se encuentra el .pro
- Abrir el Makefile y reemplazar matriz_asm.o: .... por
matriz_asm.o: ../TPFinal-OrgaII/codigo/matriz_asm.asm 
	nasm -f elf64 -g -F dwarf -o matriz_asm.o ../TPFinal-OrgaII/codigo/matriz_asm.asm
- volver a abrir el proyecto con el Qt y compilarlo.

Cualquier duda escribime a sizcovich@gmail.com sebastian_vita@yahoo.com.ar
