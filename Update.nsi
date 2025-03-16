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

	DetailPrint "Verificando instalación..."
	EnumRegKey $R0 ${REGKEY_ROOT} "${REGKEY_PACKAGE}" 0

	; No existe instalacion previa.
	${If} ${Errors}
		MessageBox MB_OK|MB_ICONINFORMATION "No se ha detectado ninguna versión de AMPc for Windows instalada.$\n$\nSi esto un error y necesitas ayuda, o deseas obtener más información, visita$\n$\n${AMPC_URL}"
		Abort

	${EndIf}
FunctionEnd

Section -"Prepare"
	DetailPrint "Obteniendo versión instalada..."
	ReadRegStr $R2 ${REGKEY_ROOT} "${REGKEY_UNINST}" "DisplayVersion"
	StrCpy $versionCurrentAMPc "$R2"
	DetailPrint "Versión encontrada: $versionCurrentAMPc"

	DetailPrint "Obteniendo update.ini actualizado"
	DetailPrint "URL de consulta: ${URL_UPDATE_INI}"
    NScurl::http get "${URL_UPDATE_INI}" "$PLUGINSDIR\update.ini" /INSIST /CANCEL /RESUME /END
	Pop $0

	${IfNot} $0 == "OK"
		DetailPrint "No se puede obtener update.ini desde el repositorio."
		MessageBox MB_OK|MB_ICONINFORMATION "No se pudo obtener información sobre la última versión.$\n$\nURL consultada:$\n$\n${URL_UPDATE_INI}"
		DetailPrint "Presiona Cancelar para cerrar..."
		Abort
	${EndIf}

	DetailPrint "update.ini obtenido, leyendo última versión disponible."
    ReadINIStr $versionAvailableAMPc "$PLUGINSDIR\update.ini" "AMPc" "version"
	DetailPrint "Última version disponible: $versionAvailableAMPc"

	DetailPrint "Obteniendo valores de integridad."
    ReadINIStr $urlUpdateINI "$PLUGINSDIR\update.ini" "AMPc" "current"

	StrCmp $urlUpdateINI ${URL_UPDATE_INI} sameUrl distUrl

	distUrl:
		DetailPrint "La URL del archivo INI no coincide con la esperada."
		MessageBox MB_OK|MB_ICONINFORMATION "Error inesperado (2050)"
		DetailPrint "Presiona Cancelar para cerrar..."
		Abort
	sameUrl:

	DetailPrint "Comparando versiones"
	${VersionCompare} "$versionCurrentAMPc" "$versionAvailableAMPc" $R9

	${If} $R9 == "0"
		DetailPrint "La versión actualmente instalada es la última versión disponible."
		MessageBox MB_OK|MB_USERICON "Tienes la última versión disponible.$\n$\nVersión local: $versionCurrentAMPc$\n$\nÚltima versión disponible: $versionAvailableAMPc"
		DetailPrint "Presiona Cancelar para cerrar..."
		Abort
	${ElseIf} $R9 == "1"
		DetailPrint "La versión actualmente instalada es más mayor (¿versión en desarrollo?) que la última versión disponible."
		MessageBox MB_OK|MB_USERICON "Estas usando una versión en desarrollo.$\n$\nVersión local: $versionCurrentAMPc$\n$\nÚltima versión disponible: $versionAvailableAMPc"
		Abort
	${ElseIf} $R9 == "2"
		DetailPrint "La versión actualmente instalada esta desactualizada."
		DetailPrint "URL de descarga encontrada"
		DetailPrint "Solicitando al usuario consentimiento para descargar última versión."
   		MessageBox MB_YESNO|MB_USERICON "Hay una actualización disponible.$\n$\n$versionCurrentAMPc < $versionAvailableAMPc$\n$\n¿Descargar la última versión?" IDYES true IDNO false
		false:
			DetailPrint "Se ha rechazado la descarga de la actualización."
			DetailPrint "Presiona Cancelar para cerrar..."
			Abort
		true:
	${Else}
		DetailPrint "escapa de nuestra comprensión."
		DetailPrint "Error inesperado, abortando el proceso."
		MessageBox MB_OK|MB_ICONEXCLAMATION "Error inesperado (2001)."
		DetailPrint "Presiona Cancelar para cerrar..."
		Abort
	${EndIf}

	DetailPrint "Estableciendo URL de descarga"
	StrCpy $urlDownloadRelease "https://github.com/hucrea/AMPc/releases/download/$versionAvailableAMPc/ampc-$versionAvailableAMPc.exe"
	DetailPrint "URL de descarga establecida: $urlDownloadRelease"
SectionEnd

Section -"Download"
	DetailPrint "Descargando última versión."

	NScurl::http get "$urlDownloadRelease" "$INSTDIR\ampc_for_windows-latest.exe" /INSIST /CANCEL /RESUME /END
	Pop $0
	DetailPrint "Resultado: $0"

	${IfNot} $0 == "OK"
		DetailPrint "La descarga no se pudo completar."
		MessageBox MB_OK|MB_ICONEXCLAMATION "Ocurrio un error al intentar descargar la última versión. Reintenta más tarde o visita ${URL_UPDATE} para descargar la última versión disponible."
		DetailPrint "Presiona Cancelar para cerrar."
		Abort
	${EndIf}

	DetailPrint "Última versión descargada."
	DetailPrint "Presione Siguiente para finalizar el asistente de actualización."
SectionEnd