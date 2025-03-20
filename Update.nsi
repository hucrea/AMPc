/*

AMPc for Windows - Entorno web local para Windows
Copyright (C) 2025  Hu SpA ( https://hucreativa.cl )

This file is part of AMPc for Windows.

AMPc for Windows is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by 
the Free Software Foundation, either version 3 of the License, or 
(at your option) any later version.

AMPc for Windows is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
for more details.

You should have received a copy of the GNU General Public License along 
with AMPc for Windows. If not, see <https://www.gnu.org/licenses/>. 

-------------------------------------------------------------------------------

Updater.nsi - Genera ejecutable para consulta y descarga de actualizaciones.

NOTAS:
+ Algunas constantes estan ubicadas en el archivo Commons.nsi y son
 compartidas por otros archivos *.NSI del proyecto.
+ Todos los caracteres especiales se han omitido para mayor compatibilidad.

*/

;
; PACKAGE - Nombre del paquete a compilar.
!define PACKAGE "Update AMPc for Windows"
!define PACKAGE_REV "1"
;
; URL_CURRENT_INI - URL para consultar ultima version publicada.
!define URL_UPDATE_INI "https://raw.githubusercontent.com/hucrea/AMPc/main/update.ini"
;
; Incluye el archivo de constantes compartidas con otros *.NSI del proyecto.
!include "Commons.nsh"

###############################################################################
; DETALLES DE LA COMPILACION ACTUAL.
###############################################################################
;
; Nombre del instalador EXE compilado.
OutFile "update-ampc.exe"
;
; Permitir mostrar detalles durante instalacion.
ShowInstDetails show
;
; Ruta de instalacion, para almacenar instalable actualizado.
InstallDir "$APPDATA\Hu SpA"
;
; Descripcion del archivo.
VIAddVersionKey /LANG=0 "FileDescription" "${PACKAGE}"
VIAddVersionKey /LANG=0 "FileVersion" "${AMPC_VERSION}.${AMPC_VERSION}"

###############################################################################
; PROCESO DE INSTALACION.
###############################################################################
;!include "MUI.nsh"
!include "x64.nsh"
!include "MUI2.nsh"
;!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "VersionCompare.nsh"

; Configuracion de la instalacion.
!define MUI_HEADERIMAGE_BITMAP "media-src\header-install.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "media-src\banner-install.bmp"
!define MUI_ICON "media-src\icon-updater.ico"
!define MUI_PAGE_HEADER_TEXT "Guardar (ejecutable de) actualización"
!define MUI_PAGE_HEADER_SUBTEXT "Selecciona una carpeta para guardar la actualización"
!define MUI_DIRECTORYPAGE_TEXT_TOP "Selecciona la carpeta donde se guardará el archivo ampc-lastest.exe$\n$\n \
Por defecto, se selecciona el directorio de la instalación actual aunque puede ser cambiado."
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "Carpeta donde se guardará ampc-latest.exe"
!insertmacro MUI_PAGE_DIRECTORY
!define MUI_PAGE_HEADER_TEXT "Actualización"
!define MUI_PAGE_HEADER_SUBTEXT "Espera mientras se ejecutan las tareas de actualización."
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_RUN "$INSTDIR\ampc_for_windows-latest.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Actualizar AMPc for Windows"
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "Spanish"

###############################################################################
; VARIABLES DEL PAQUETE.
###############################################################################
Var versionCurrentAMPc
Var versionAvailableAMPc
Var urlDownloadRelease
Var urlUpdateINI
Var remoteHashUpdate
;Var proceedUpdate

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Al iniciar el ejecutable.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function .onInit
	InitPluginsDir

	; Splash al iniciar el instalador.
	SetOutPath $PLUGINSDIR
  	File /oname=splash.bmp "media-src\splash-update.bmp"
	splash::show 1750 "$PLUGINSDIR\splash"
	Pop $0
	Delete "$PLUGINSDIR\splash.bmp"

	; Verifica que arquitectura del sistema anfitrion sea x64.
	${IfNot} ${RunningX64}
		MessageBox MB_OK|MB_ICONSTOP "Error inesperado (2000)."
		Abort
	${EndIf}

	; Evita redirecciones de WOW64 en directorios y registros.
	${DisableX64FSRedirection}
	SetRegView 64

	; Verifica si existe alguna instalacion previa.
	ClearErrors
	ReadRegStr $R1 ${REGKEY_ROOT} "${REGKEY_UNINST}" "DisplayVersion"

	; No existe instalacion previa.
	${If} ${Errors}
		MessageBox MB_OK|MB_ICONINFORMATION "No se ha detectado ninguna versión de AMPc for Windows instalada.$\n$\nSi esto un error y necesitas ayuda, o deseas obtener más información, visita$\n$\n${AMPC_URL}"
		Abort ; Aborta el proceso.
	${EndIf}

	; Almacena numero de version actual encontrado.
	StrCpy $versionCurrentAMPc "$R1"
	
	; Descarga archivo update.ini desde el repositorio.
	NScurl::http get "${URL_UPDATE_INI}" "$PLUGINSDIR\update.ini"
	Pop $0

	; NScurl devuelve OK solo si todo sale bien.
	${IfNot} $0 == "OK"
		MessageBox MB_OK|MB_ICONINFORMATION "Error al descargar update.ini desde la URL:$\n$\n${URL_UPDATE_INI}$\n$\nError devuelto: $0"
		Abort ; Aborta el proceso.
	${EndIf}

	; Lee la version declarada como última desde update.ini
	ReadINIStr $versionAvailableAMPc "$PLUGINSDIR\update.ini" "AMPc" "version"

	; Lee la URL declarada en update.ini para update.ini.
	ReadINIStr $urlUpdateINI "$PLUGINSDIR\update.ini" "AMPc" "current"

	; Lee la firma HASH SHA-256 de la ultima version disponible.
	ReadINIStr $remoteHashUpdate "$PLUGINSDIR\update.ini" "AMPc" "hsha256"

	; Compara que la URL declarada sea igual a la URL almacenada en el paquete.
	StrCmp $urlUpdateINI ${URL_UPDATE_INI} isSameUrl notSameUrl

	notSameUrl: ; No es la misma URL.
		MessageBox MB_OK|MB_ICONINFORMATION "Error inesperado (2050)"
		Abort ; Aborta el proceso.
	isSameUrl:

	; Compara la version local con la version declarada en update.ini.
	${VersionCompare} "$versionCurrentAMPc" "$versionAvailableAMPc" $R2

	${If} $R2 == "0"
	; Esta utilizando la ultima version.
		MessageBox MB_OK|MB_USERICON "Tienes la última versión disponible.$\n$\n$versionCurrentAMPc (actual) = $versionAvailableAMPc (disponible)"
		Abort ; Aborta el proceso.

	${ElseIf} $R2 == "1"
	; La version instalada es superior a la ultima version.
		MessageBox MB_OK|MB_USERICON "Estas usando una versión en desarrollo.$\n$\n$versionCurrentAMPc (actual) > $versionAvailableAMPc (disponible)"
		Abort ; Aborta el proceso.

	${ElseIf} $R2 == "2"
	; La version instalada es inferior a la ultima version.
   		MessageBox MB_YESNO|MB_USERICON "Hay una actualización disponible.$\n$\n$versionCurrentAMPc (actual) < $versionAvailableAMPc (disponible)$\n$\n¿Descargar la última versión?" IDYES true IDNO false
		; Usuario rechaza la descarga automatica.
		false:
			Abort ; Aborta el proceso.
		true:

	${Else}
	; No deberias llegar aqui, pero por si las moscas.
		MessageBox MB_OK|MB_ICONEXCLAMATION "Error inesperado (2001)."
		Abort ; Aborta el proceso.
	${EndIf}

FunctionEnd

Section -"Prepare"
	DetailPrint "Estableciendo URL de descarga."
	
	; La URL de descarga no se puede establecer via constante.
	StrCpy $urlDownloadRelease "https://github.com/hucrea/AMPc/releases/download/$versionAvailableAMPc/ampc-$versionAvailableAMPc.exe"
	DetailPrint "URL de descarga establecida:$\n$\n$urlDownloadRelease"
SectionEnd

Section -"Download"
	DetailPrint "Descargando versión $versionAvailableAMPc"

	; Descarga la ultima version disponbile.
	NScurl::http get "$urlDownloadRelease" "$INSTDIR\ampc_for_windows-latest.exe" /INSIST /CANCEL /RESUME /END
	Pop $0

	; NScurl devuelve OK solo si todo sale bien.
	${IfNot} $0 == "OK"
		DetailPrint "La descarga no se pudo completar."
		MessageBox MB_OK|MB_ICONEXCLAMATION "Ocurrio un error al intentar descargar la última versión. Reintenta más tarde o visita ${URL_UPDATE} para descargar la última versión disponible."
		DetailPrint "Detalles del error: $0"
		DetailPrint "Presiona Cancelar para cerrar."
		Abort ; Aborta el proceso.
	${EndIf}

	DetailPrint "Última versión ($versionAvailableAMPc) descargada."
SectionEnd

Section -"CheckIntegrity"
	DetailPrint "Comprobando integridad de la descarga."

	ClearErrors
	Crypto::HashFile "SHA2" "$INSTDIR\ampc_for_windows-latest.exe"
	Pop $R0

	${If} ${Errors}
		DetailPrint "No se pudo obtener el HASH del archivo descargado."
		DetailPrint "Detalles del error: $R0"
		MessageBox MB_OK|MB_ICONEXCLAMATION "No se pudo obtener el HASH para el archivo descargado. Proceso abortado."
		DetailPrint "Presiona Cancelar para cerrar."
		Abort ; Aborta el proceso.
	${EndIf}

	StrCmp $R0 $remoteHashUpdate isSameHash notSameHash

	notSameHash:
		DetailPrint "Los hash no coinciden."
		DetailPrint "Hash esperado: $remoteHashUpdate"
		DetailPrint "Hash obtenido: $R0"
		MessageBox MB_OK|MB_ICONEXCLAMATION "El hash de la descarga no coincide con el valor obtenido desde update.ini$\n$\nVuelve a ejecutar el actualizador y, si el problema persiste, visita la página de soporte."
		DetailPrint "Presiona Cancelar para cerrar."
		Abort ; Aborta el proceso.

	isSameHash:
	DetailPrint "Los hash coinciden."
	DetailPrint "Hash esperado: $remoteHashUpdate"
	DetailPrint "Hash obtenido: $R0"

	DetailPrint "Finalizando asistente."
SectionEnd