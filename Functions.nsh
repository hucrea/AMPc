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
 Funcion base para el macro ReplaceInFile.

 Reemplaza TODAS las ocurrencias de un texto por otro en un archivo.
 Version simplificada para reemplazar todas las ocurrencias desde la primera ocurrencia.
 Basado en codigo original de Stu (Afrow UK) y rainmanx.

*/
Function func_ReplaceInFile
    ; Obtener parametros del stack.
    Pop $R2    ; texto a buscar.
    Pop $R1    ; texto de reemplazo.
    Pop $R0    ; archivo a modificar.
    
    ; Variables de trabajo.
    Push $0    ; contador de posicion en linea.
    Push $1    ; texto temporal.
    Push $2    ; linea completa actual.
    Push $3    ; parte izquierda de la linea.
    Push $4    ; parte derecha de la linea.
    Push $5    ; handle archivo original.
    Push $6    ; handle archivo temporal.
    Push $7    ; linea leida.
    Push $8    ; longitud del texto a buscar.
    Push $9    ; archivo temporal.
    Push $R3   ; directorio del archivo original.
    
    ; Inicializar.
    StrLen $8 $R2    ; longitud del texto a buscar.
    
    ; Crear archivo temporal en el mismo directorio.
    GetFullPathName $R3 $R0\..
    GetTempFileName $9 $R3
    
    ; Abrir archivos.
    FileOpen $5 $R0 r     ; archivo original (lectura).
    FileOpen $6 $9 w      ; archivo temporal (escritura).
    
    ; Procesar linea por linea.
    leer_linea:
        ClearErrors
        FileRead $5 $7
        IfErrors finalizar
        
        StrCpy $2 $7  ; copia de la linea para procesar.
        
        ; Buscar y reemplazar todas las ocurrencias en la linea actual.
        buscar_en_linea:
            StrCpy $0 0
            
            encontrar_siguiente:
                IntOp $0 $0 - 1
                StrCpy $1 $2 $8 $0    ; extraer substring para comparar.
                StrCmp $1 "" escribir_linea  ; no hay mas texto.
                StrCmp $1 $R2 reemplazar encontrar_siguiente
            
            reemplazar:
                ; Dividir la linea en partes.
                StrCpy $3 $2 $0               ; parte izquierda.
                IntOp $1 $0 + $8             ; posicion despues del texto encontrado.
                StrCpy $4 $2 "" $1           ; parte derecha.
                
                ; Reconstruir linea con el reemplazo.
                StrCpy $2 "$3$R1$4"
                
                ; Ajustar posicion para continuar busqueda despues del reemplazo.
                StrLen $1 $3
                StrLen $0 $R1
                IntOp $0 $1 + $0
                IntOp $0 $0 - 1
                
                ; Continuar buscando en la misma linea.
                Goto buscar_en_linea
        
        escribir_linea:
            FileWrite $6 $2
            Goto leer_linea
    
    finalizar:
        ; Cerrar archivos.
        FileClose $5
        FileClose $6
        
        ; Reemplazar archivo original.
        SetDetailsPrint none
        Delete $R0
        Rename $9 $R0
        Delete $9
        SetDetailsPrint both
        
        ; Limpiar stack.
        Pop $R3
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

; Macro ReplaceInFile.
; !insertmacro ReplaceInFile "$INSTDIR\config.ini" "__TEXT_TO_REPLACE__" "192.168.1.100"
!macro ReplaceInFile archivo buscar reemplazar
    Push "${archivo}"
    Push "${reemplazar}"
    Push "${buscar}"
    Call func_ReplaceInFile
!macroend

/*
func_ReplaceSlash
 Reemplaza las barras \ por barras /.

 Esto evita ciertos errores al momento de guardar la ruta completa de instalacion
 en los archivos de configuracion php.ini y httpd.conf.

*/
Function func_ReplaceSlash
    Exch $R1       ; $R1 = String de entrada.
    Push $R2       ; $R2 = Resultado.
    Push $R6       ; $R6 = Longitud.
    Push $R7       ; $R7 = Caracter actual.
    
    StrCpy $R2 ""
    StrLen $R6 $R1
    StrCmp $R6 0 done
    
    loop:
        StrCpy $R7 $R1 1
        StrCpy $R1 $R1 "" 1
        StrCmp $R7 "\" 0 +3
        StrCpy $R2 "$R2/"    ; Siempre reemplaza \ por /.
        Goto continue
        
        StrCpy $R2 "$R2$R7"

        continue:
            StrCmp $R1 "" done
            Goto loop
    
    done:
        Pop $R7
        Pop $R6
        Pop $R1
        Exch $R2
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