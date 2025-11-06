/*

AMPc for Windows - Entorno web local para Windows
Copyright (C) 2025  Hu SpA ( https://hucreativa.cl )

This file is part of AMPc for Windows.

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------

Functions.nsh - Archivo de funciones.

IMPORTANTE:
+ Todas las funciones a declarar, excepto aquellas que se utilicen para manejar
  los dialogos con nsDialogs, DEBEN comenzar con func_ seguido de letra capital
  para cada palabra que compone el nombre y SIN ANNADIR espacios entre ellas.
  Puede consultar las funciones declaradas mas abajo para un ejemplo practico.

*/

/*

func_ReplaceInFile
 Reemplaza un determinado valor por otro dado, en un archivo.

 Creado por Stu (Afrow UK)
 https://nsis.sourceforge.io/More_advanced_replace_text_in_file#Code
 Licencia zlib/libpng

 Modificaciones por rainmanx
 https://nsis.sourceforge.io/Advanced_Replace_within_text_II
 Licencia zlib/libpng
*/
Function func_ReplaceInFile
	Exch $0 ;file to replace in
	Exch
	Exch $1 ;number to replace after
	Exch
	Exch 2
	Exch $2 ;replace and onwards
	Exch 2
	Exch 3
	Exch $3 ;replace with
	Exch 3
	Exch 4
	Exch $4 ;to replace
	Exch 4

	Push $5 ;minus count
	Push $6 ;universal
	Push $7 ;end string
	Push $8 ;left string
	Push $9 ;right string
	Push $R0 ;file1
	Push $R1 ;file2
	Push $R2 ;read
	Push $R3 ;universal
	Push $R4 ;count (onwards)
	Push $R5 ;count (after)
	Push $R6 ;temp file name

	; Find folder with file to edit:
	GetFullPathName $R1 $0\..

	; Put temporary file in same folder to preserve access rights:
	GetTempFileName $R6 $R1

	FileOpen $R1 $0 r ;file to search in
	FileOpen $R0 $R6 w ;temp file

	StrLen $R3 $4
	StrCpy $R4 -1
	StrCpy $R5 -1
	loop_read:
		ClearErrors
		FileRead $R1 $R2 ;read line
		IfErrors exit
		StrCpy $5 0
		StrCpy $7 $R2
	loop_filter:
		IntOp $5 $5 - 1
		StrCpy $6 $7 $R3 $5 ;search
		StrCmp $6 "" file_write2
		StrCmp $6 $4 0 loop_filter
		StrCpy $8 $7 $5 ;left part
		IntOp $6 $5 + $R3
		StrCpy $9 $7 "" $6 ;right part
		StrLen $6 $7
		StrCpy $7 $8$3$9 ;re-join
		StrCmp -$6 $5 0 loop_filter
		IntOp $R4 $R4 + 1
		StrCmp $2 all file_write1
		StrCmp $R4 $2 0 file_write2
		IntOp $R4 $R4 - 1
		IntOp $R5 $R5 + 1
		StrCmp $1 all file_write1
		StrCmp $R5 $1 0 file_write1
		IntOp $R5 $R5 - 1
		Goto file_write2
	file_write1:
		FileWrite $R0 $7 ;write modified line
		Goto loop_read
	file_write2:
		FileWrite $R0 $7 ;write modified line
		Goto loop_read
	exit:
		FileClose $R0
		FileClose $R1
		SetDetailsPrint none
		Delete $0
		Rename $R6 $0
		Delete $R6
		SetDetailsPrint both

		Pop $R6
		Pop $R5
		Pop $R4
		Pop $R3
		Pop $R2
		Pop $R1
		Pop $R0
		Pop $9
		Pop $8
		Pop $7
		Pop $6
		Pop $5
		Pop $4
		Pop $3
		Pop $2
		Pop $1
		Pop $0
FunctionEnd

/*

func_ReplaceSlash
 Reemplaza las barras \ por barras /.

 Esto evita ciertos errores al momento de guardar la ruta completa de instalacion
 en los archivos de configuracion php.ini y httpd.conf.

 Codigo generado por ChatGPT con modificaciones propias.

*/
Function func_ReplaceSlash
	Exch $R3       ; $R3 = Needle (carácter a reemplazar "\" o "/")
	Exch
	Exch $R1       ; $R1 = String de entrada (ruta original)
	Push $R2       ; $R2 = Resultado con reemplazos
	Push $R4       ; $R4 = Carácter de reemplazo ("/" o "\")
	Push $R6       ; $R6 = Longitud de la cadena
	Push $R7       ; $R7 = Carácter actual en el loop

	StrCpy $R2 ""  ; Inicializa la cadena vacía (donde construiremos el resultado)
	StrLen $R6 $R1 ; Obtiene la longitud de la cadena de entrada
	StrCpy $R4 "/" ; Define el carácter de reemplazo

	StrCmp $R3 "/" 0 +2  ; Si el needle es "/", cambia el reemplazo a "\"
	StrCpy $R4 "\"       

	StrCmp $R6 0 done  ; Si la longitud de la cadena de entrada es 0, termina

	loop:
		StrCpy $R7 $R1 1    ; Obtiene el primer carácter de la cadena original
		StrCpy $R1 $R1 "" 1 ; Elimina el primer carácter de la cadena original

		StrCmp $R7 $R3 found  ; Si el carácter es igual al needle, se reemplaza
		StrCpy $R2 "$R2$R7"   ; Si no, se agrega tal cual
		StrCmp $R1 "" done    ; Si la cadena original está vacía, terminamos
		Goto loop             ; Continúa el bucle

	found:
		StrCpy $R2 "$R2$R4"  ; Reemplaza el carácter encontrado
		StrCmp $R1 "" done   ; Si la cadena original está vacía, terminamos
		Goto loop            ; Continúa el bucle

	done:
		Pop $R7
		Pop $R6
		Pop $R4
		Pop $R1
		Exch $R2            ; Devuelve la cadena convertida
FunctionEnd

/*

func_DisableBackButton
 Deshabilita el boton "Atras".

 Las paginas personalizadas efectuan reemplazos en archivos en base a variables
 del tipo ___AMPC_<VAR>___ (donde <VAR> puede ser cualquier valor). Una vez que
 el usuario presiona SIGUIENTE, las variables son reemplazadas y, si por
 cualquier razon, el usuario presiona ATRAS y luego SIGUIENTE, el reemplazo 
 de las variables fallara (puesto que ya fueron reemplazadas y no existen).
 Deshabilitar el boton ATRAS es una solucion MUY bestia, pero necesaria.

*/
Function func_DisableBackButton
    GetDlgItem $0 $HWNDPARENT 3 ; Obtiene el boton "Atrás"
    EnableWindow $0 0 ; Deshabilita el boton "Atrás"
FunctionEnd

/*

func_StartServices
 Inicia los servicios Apache HTTP y MariaDB

 La funcion realiza una pequeña comprobacion previa para asegurar que existe
 una instalacion de Visual C++ Redistributable. La variable $statusVCRuntime se
 define al iniciar la instalacion del paquete y puede tomar los valores 
 "skipped", "install" o "installed", siendo los ultimos valores un fallback: 
 el que importa es "skipped", valor que toma si el usuario no acepta la 
 descarga e instalacion automatica de Visual C++ Redistributable.

*/
Function func_StartServices
	StrCmp $statusVCRuntime "skipped" warning execute

	warning:
		MessageBox MB_OK "No has instalado Visual C++ Redistributable, el servicio de Apache HTTP no se puede iniciar."
		Goto next
	execute:
		nsExec::ExecToStack /OEM 'net start Apache2.4'
		Pop $R0
		Pop $R1
		LogText $R1
		Goto next
	next:
		nsExec::ExecToStack /OEM 'net start MariaDB'
		Pop $R2
		Pop $R3
		LogText $R3
FunctionEnd