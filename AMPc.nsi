/*
	AMPc - Distribucion WAMP ligera.
	Copyright (C) 2025  Hu SpA - https://hucreativa.cl/.

	This file is part of AMPc for Windows.

	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this file,
	You can obtain one at http://mozilla.org/MPL/2.0/.

	///////////////////////////
	
	AMPc.nsi - Archivo principal de la distribucion.

	Tildes y caracteres especiales omitidos por compatibilidad.

*/

; Algoritmo de compresion.
SetCompressor /SOLID /FINAL lzma

###############################
; CONSTANTES
###############################
; Marcas de tiempo.
!define /date BUILD_TIMESTAMP   "%Y%m%d_%H%M%S"
!define BUILD_TIMESTAMP_BRAND   "Build at ${__TIME__} on ${__DATE__}"

; Versionado.
!include "Versions.nsh"
!define VERSION_API "2"
!define VERSION_BUILD "${VERSION_DISTRO}+${BUILD_TIMESTAMP}"
!define VERSION_VIPV "${VERSION_DISTRO}.${VERSION_API}"

; Identificadores de la distribucion.
!define SHORTNAME "ampc"
!define DISTRO_NAME "AMPc"
!define DISTRO_GUID "{FB39BDE3-4D2E-4634-BBB0-19B4D0AB5E13}"
!define DISTRO_PUB "Hu SpA"
!define DISTRO_PUB_COUNTRY "Chile"

; Claves del registro.
!define REGKEY_ROOT "HKLM"
!define REGKEY_PACKAGE "Software\${DISTRO_PUB}\${DISTRO_GUID}"
!define REGKEY_UNINST "Software\Microsoft\Windows\CurrentVersion\Uninstall\${DISTRO_GUID}"

; Direcciones web.
!define URL_VCREDIST "https://aka.ms/vs/17/release/vc_redist.x64.exe"
!define URL_DISTRO "https://github.com/hucrea/AMPc"
!define URL_DISTRO_PUB "https://hucreativa.cl"
!define URL_DISTRO_UPDATE "${URL_DISTRO}/releases"
!define URL_DISTRO_HELP "${URL_DISTRO}/wiki"

; Carpetas de trabajo.
!define DIR_MEDIA "media-files"
!define DIR_COMPONENTS "components-files"
!define DIR_WWW "htdocs-files"
!define DIR_CONFIG "config-files"

; Timeouts.
!define TIMEOUT_STOP_SERVICE 60000
!define TIMEOUT_KILL_PROCESS 10000

; Validacion.
!define MIN_PASSWORD_LENGTH 8
!define RECOMMENDED_PASSWORD_LENGTH 12
!define MIN_PORT 1
!define MAX_PORT 65535

###############################
; DETALLES DE LA COMPILACION.
###############################
Unicode True
Name "${DISTRO_NAME}"
Caption "${DISTRO_NAME}"
BrandingText "${DISTRO_NAME} ${VERSION_DISTRO} - ${BUILD_TIMESTAMP_BRAND}"
AllowRootDirInstall true
OutFile "${SHORTNAME}-${VERSION_BUILD}.exe"
InstallDir "$PROGRAMFILES\${DISTRO_NAME}"
ManifestSupportedOS Win10
RequestExecutionLevel admin
ShowInstDetails show
ShowUnInstDetails show

; Version Information.
VIProductVersion "${VERSION_VIPV}"
VIAddVersionKey /LANG=0 "FileVersion" "${VERSION_VIPV}"
VIAddVersionKey /LANG=0 "ProductVersion" "${VERSION_VIPV}"
VIAddVersionKey /LANG=0 "ProductName" "${DISTRO_NAME}"
VIAddVersionKey /LANG=0 "CompanyName" "${DISTRO_PUB} (${DISTRO_PUB_COUNTRY})"
VIAddVersionKey /LANG=0 "LegalCopyright" "© 2025 - 2026 ${DISTRO_PUB} (${DISTRO_PUB_COUNTRY})"
VIAddVersionKey /LANG=0 "LegalTrademarks" "${DISTRO_NAME} is a trademark of ${DISTRO_PUB}"
VIAddVersionKey /LANG=0 "FileDescription" "Installer ${DISTRO_NAME}"

###############################
; VARIABLES.
###############################
Var ampcPrevInstall ; Instalacion previa.
Var ampcBackSlash ; Usada por func_ReplaceSlash.

; Ventana de componentes.
Var ampcComponentsDialog
Var ampcComponentsLabel6
Var ampcComponentsLabel5
Var ampcComponentsLabel4
Var ampcComponentsLabel3
Var ampcComponentsLabel2
Var ampcComponentsLabel1
Var ampcFontBold

; Ventana y Estado de de VC++ Redis.
Var ampcVCRedist
Var ampcVCRedistDialog
Var ampcVCRLabel1
Var ampcVCRCheckbox
Var ampcVCRLabel2

; Ventana y valores de Apache.
Var apachePath
Var apacheVersion
Var apacheCustomServerName
Var apacheCustomPort
Var apacheCustomServiceName

; Ventana y valores de MariaDB.
Var mariadbPath
Var mariadbVersion
Var mariadbCustomPass
Var mariadbCustomPassCheck
Var mariadbCustomPort
Var mariadbCustomServiceName

; Valores de PHP.
Var phpVersion
Var phpPath

; Valores de cacert.
Var cacertPath
Var cacertVersion

; Variables temporales para validaciones.
Var tempResult
Var tempString
Var tempLength
Var tempPort

###############################
; PROCESO DE INSTALACION.
###############################
!include "x64.nsh"
!include "MUI.nsh"
!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "Functions.nsh"

; Configuracion de la instalacion.
!define MUI_ABORTWARNING
!define MUI_ICON "${DIR_MEDIA}\ampc_install.ico"
!define MUI_UNICON "${DIR_MEDIA}\ampc_uninstall.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${DIR_MEDIA}\banner-install.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${DIR_MEDIA}\banner-uninstall.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${DIR_MEDIA}\header-install.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "${DIR_MEDIA}\header-uninstall.bmp"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "$(i18n_FINISHPAGE_RUN)"
!define MUI_FINISHPAGE_RUN_FUNCTION func_StartServices
!define MUI_LICENSEPAGE_BUTTON
!define MUI_FINISHPAGE_LINK "${DISTRO_NAME}"
!define MUI_FINISHPAGE_LINK_LOCATION "${URL_DISTRO}"
!define MUI_COMPONENTSPAGE_SMALLDESC

; Proceso de instalacion.
!define MUI_PAGE_HEADER_TEXT "$(i18n_LICENSE_TITLE)"
!define MUI_PAGE_HEADER_SUBTEXT "$(i18n_LICENSE_SUBTITLE)"; 
!insertmacro MUI_PAGE_LICENSE "${DIR_MEDIA}\license.rtf"
!define MUI_PAGE_HEADER_TEXT "$(i18n_LICENSE_THIRD_TITLE)"
!define MUI_PAGE_HEADER_SUBTEXT "$(i18n_LICENSE_THIRD_SUBTITLE)"
!define MUI_LICENSEPAGE_TEXT_TOP "$(i18n_LICENSE_THIRD_TEXTTOP)"
!define MUI_LICENSEPAGE_TEXT_BOTTOM "$(i18n_LICENSE_THIRD_TEXTTBOTTOM)"
!define MUI_LICENSEPAGE_BUTTON "$(i18n_LICENSE_THIRD_BUTTON)"
!insertmacro MUI_PAGE_LICENSE "${DIR_MEDIA}\license-components.rtf"
!insertmacro MUI_PAGE_DIRECTORY
Page Custom custom_PageVCRedist leave_PageVCRedist
Page Custom custom_PageComponents leave_PageComponents
!define MUI_FINISHPAGE_NOAUTOCLOSE
!insertmacro MUI_PAGE_INSTFILES
Page Custom custom_PageApache leave_PageApache
Page Custom custom_PageMariadb leave_PageMariadb
!define MUI_PAGE_CUSTOMFUNCTION_SHOW func_DisableBackButton
!define MUI_FINISHPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_FINISH

; Proceso de desinstalacion.
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Opciones de lenguaje.
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "PortugueseBR"
!insertmacro MUI_RESERVEFILE_LANGDLL
!define MUI_LANGDLL_REGISTRY_ROOT "${REGKEY_ROOT}" 
!define MUI_LANGDLL_REGISTRY_KEY "${REGKEY_PACKAGE}" 
!define MUI_LANGDLL_REGISTRY_VALUENAME "LangInstall"
!include "LangStrings.nsh"

###############################
; Al iniciar el instalador.
###############################
Function .onInit
	InitPluginsDir

	${IfNot} ${RunningX64}
		# No se puede continuar: sistema de 32 bits detectado.
		MessageBox MB_OK|MB_ICONSTOP "$(i18n_32BITS_NOTSUPPORT).$\n$\n$(i18n_INSTALL_CANNOT)"
		Abort
	${EndIf}

	; Evita redirecciones de WOW64 en directorios y registros.
	${DisableX64FSRedirection}
	SetRegView 64

	!insertmacro MUI_LANGDLL_DISPLAY

	; Inicializa variables.
	StrCpy $apachePath "unknown"
	StrCpy $apacheVersion "unknown"
	StrCpy $mariadbPath "unknown"
	StrCpy $mariadbVersion "unknown"
	StrCpy $phpPath "unknown"
	StrCpy $phpVersion "unknown"
	StrCpy $cacertPath "unknown"
	StrCpy $cacertVersion "unknown"
	StrCpy $tempResult ""
	StrCpy $tempString ""
	StrCpy $tempLength ""
	StrCpy $tempPort ""

	; Verifica si existe alguna instalacion previa.
	ClearErrors
	EnumRegKey $tempResult ${REGKEY_ROOT} "${REGKEY_PACKAGE}" 0

	; No existe instalacion previa.
	${If} ${Errors}
		StrCpy $ampcPrevInstall "none"
		StrCpy $tempResult ""

		; Splash al iniciar el instalador.
		SetOutPath $PLUGINSDIR
		File "${DIR_MEDIA}\splash-install.bmp"
		splash::show 1750 "$PLUGINSDIR\splash-install"
		Pop $tempResult
		Delete "$PLUGINSDIR\splash-install.bmp"
		StrCpy $tempResult ""

		SetOutPath $INSTDIR

		; Establece la ruta de instalacion en la unidad raiz de Windows.
		StrCpy "$INSTDIR" "$WINDIR" 2
		StrCpy "$INSTDIR" "$INSTDIR\AMPc"

	; Existe instalacion previa.
	${Else}
		StrCpy $ampcPrevInstall "yes"
		StrCpy $tempResult ""

		; Splash al iniciar el actualizador.
		SetOutPath $PLUGINSDIR
		File "${DIR_MEDIA}\splash-update.bmp"
		splash::show 1750 "$PLUGINSDIR\splash-update"
		Pop $tempResult
		Delete "$PLUGINSDIR\splash-update.bmp"
		StrCpy $tempResult ""

		SetOutPath $INSTDIR
		
		; Lee la ruta de la instalacion actual.
		ClearErrors
		ReadRegStr $tempString ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "PathInstall"

		${IfNot} ${Errors}
			StrCpy "$INSTDIR" "$tempString"
			StrCpy $tempString ""
		${Else}
			; No se puede leer la ruta de insralacion.
			MessageBox MB_OK|MB_ICONSTOP "$(i18n_NOT_PATH_FOUND)"
			Abort
		${EndIf}
	${EndIf}
FunctionEnd

###############################
; PAGINAS PERSONALIZADAS.
###############################

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pre-requisitos.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function custom_PageVCRedist
	ClearErrors
	; Para mas informacion, leer el siguiente enlace:
	; https://learn.microsoft.com/es-mx/cpp/windows/redistributing-visual-cpp-files?view=msvc-170
	ReadRegDWORD $tempResult HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" "Installed"

	; No se ha detectado el componente.
	${If} ${Errors}
    ${OrIf} $tempResult != 1
		StrCpy $tempResult ""
		nsDialogs::Create 1018
		Pop $ampcVCRedistDialog
		${If} $ampcVCRedistDialog == error
			Abort
		${EndIf}

		; Titulo y subtitulo para VCREDIST.
		!insertmacro MUI_HEADER_TEXT "$(i18n_VCR_HEADER)" "$(i18n_VCR_SUBTITLE)"

		; Descripcion de funcion de descarga e instalacion de VCREDIST.
		${NSD_CreateLabel} 0 10u 100% 20u "$(i18n_VCR_DESCRIPTION)"
		Pop $ampcVCRLabel1

		; Checkbox para aceptar descarga e instalacion.
		${NSD_CreateCheckbox} 0 40u 100% 15u "$(i18n_VCR_CHECKBOX)"
		Pop $ampcVCRCheckbox
		${NSD_Check} $ampcVCRCheckbox

		; Avisos en caso de no marcar el checkbox.
		${NSD_CreateLabel} 0 72u 100% 36u "$(i18n_VCR_NOTICE)"
		Pop $ampcVCRLabel2
		nsDialogs::Show
	${Else}
		StrCpy $tempResult ""
	${EndIf}
FunctionEnd

Function leave_PageVCRedist
	${NSD_GetState} $ampcVCRCheckbox $tempResult

    ${If} $tempResult == ${BST_CHECKED}
        StrCpy $ampcVCRedist "install"
    ${Else}
        StrCpy $ampcVCRedist "skip"
    ${EndIf}

	StrCpy $tempResult ""
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Componentes.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function custom_PageComponents
	CreateFont $ampcFontBold "Microsoft Sans Serif" "8.25" "700"
  
	nsDialogs::Create 1018
	Pop $ampcComponentsDialog
	${If} $ampcComponentsDialog == error
		Abort
	${EndIf}
	!insertmacro MUI_HEADER_TEXT "$(i18n_COMPONENTS_HEADER)" "$(i18n_COMPONENTS_SUBTITLE)"

	${NSD_CreateLabel} 0 0 100% 17u "$(i18n_COMPONENTS_DESCRIPTION)"
	Pop $ampcComponentsLabel1

	${NSD_CreateLabel} 16u 33u 100% 17u "Apache HTTP Server - ${COMPONENT_A_VERSION}"
	Pop $ampcComponentsLabel2
	SendMessage $ampcComponentsLabel2 ${WM_SETFONT} $ampcFontBold 0

	${NSD_CreateLabel} 16u 50u 100% 17u "MariaDB Community Server - ${COMPONENT_M_VERSION}"
	Pop $ampcComponentsLabel3
	SendMessage $ampcComponentsLabel3 ${WM_SETFONT} $ampcFontBold 0

	${NSD_CreateLabel} 16u 67u 100% 17u "PHP: Hypertext Preprocessor - ${COMPONENT_P_VERSION}"
	Pop $ampcComponentsLabel4
	SendMessage $ampcComponentsLabel4 ${WM_SETFONT} $ampcFontBold 0

	${NSD_CreateLabel} 16u 84u 100% 17u "cacert - ${COMPONENT_C_VERSION}"
	Pop $ampcComponentsLabel5
	SendMessage $ampcComponentsLabel5 ${WM_SETFONT} $ampcFontBold 0

	${NSD_CreateLabel} 0 110u 100% 25u "$(i18n_COMPONENTS_WIZARD_NOTICE)"
	Pop $ampcComponentsLabel6
	nsDialogs::Show
FunctionEnd

Function leave_PageComponents
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Apache HTTP Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function custom_PageApache
	; Mostrar solo si NO EXISTE instalacion previa.
	${If} $ampcPrevInstall == "none"
		nsDialogs::Create 1018
			Pop $tempResult

			!insertmacro MUI_HEADER_TEXT "$(i18n_APACHE_HEADER)" "$(i18n_APACHE_DESCR)"

			${NSD_CreateLabel} 0 0 100% 8u "$(i18n_APACHE_SERVNAME)"
			${NSD_CreateText} 0 12u 80% 12u "localhost"
			Pop $apacheCustomServerName

			${NSD_CreateLabel} 0 30u 100% 8u "$(i18n_APACHE_PORT)"
			${NSD_CreateNumber} 0 42u 20% 12u "80"
			Pop $apacheCustomPort

			${NSD_CreateLabel} 0 72u 100% 8u "$(i18n_APACHE_SRVNAME)"
			${NSD_CreateText} 0 84u 20% 12u "Apache2.4"
			Pop $apacheCustomServiceName

			${NSD_CreateLabel} 0 120u 100% 12u "$(i18n_CONFIG_NOTBACK)"
			Pop $tempResult

			Call func_DisableBackButton
		StrCpy $tempResult ""
		nsDialogs::Show
	${EndIf}
FunctionEnd

Function leave_PageApache
	; Ejecutar solo si NO EXISTE instalacion previa.
	${If} $ampcPrevInstall == "none"

		${NSD_GetText} $apacheCustomServerName $tempString
		${NSD_GetText} $apacheCustomPort $tempPort

		; Validar nombre de servidor vacio
		StrCmp $tempString "" 0 +3
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_APACHE_EMPTY_SERVNAME)"
			Abort

		; Validar puerto vacio
		StrCmp $tempPort "" 0 +3
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_APACHE_EMPTY_PORT)"
			Abort

		; Validar rango de puerto
		IntCmp $tempPort ${MIN_PORT} port_min_ok 0 port_min_ok
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_PORT_INVALID_RANGE)"
			Abort
		port_min_ok:

		IntCmp $tempPort ${MAX_PORT} port_max_ok port_max_ok 0
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_PORT_INVALID_RANGE)"
			Abort
		port_max_ok:

		; Verificar si el puerto esta en uso.
		nsExec::ExecToStack 'netstat -an | findstr ":$tempPort "'
		Pop $tempResult
		${If} $tempResult == 0
			MessageBox MB_YESNO|MB_ICONQUESTION "$(i18n_PORT_IN_USE) $tempPort. $(i18n_CONTINUE_QUESTION)" IDYES port_continue
			Abort
		${EndIf}
		port_continue:
		StrCpy $tempResult ""

		; Verificar que el nombre del servicio no exista.
		${NSD_GetText} $apacheCustomServiceName $tempString
		nsExec::ExecToStack 'sc query "$tempString"'
		Pop $tempResult
		${If} $tempResult == 0
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_SERVICE_ALREADY_EXISTS) $tempString"
			Abort
		${EndIf}
		StrCpy $tempResult ""

		; Aplicar configuracion
		${NSD_GetText} $apacheCustomServerName $tempString
		Push '___AMPC_SERVERNAME___'
		Push $tempString
		Push all
		Push all
		Push '$INSTDIR\Apache\conf\httpd.conf'
		Call func_ReplaceInFile
		Pop $tempResult
		LogText $tempResult
		StrCpy $tempResult ""
		StrCpy $tempString ""

		${NSD_GetText} $apacheCustomPort $tempPort
		Push '___AMPC_HTTP_PORT___'
		Push $tempPort 
		Push all 
		Push all 
		Push '$INSTDIR\Apache\conf\httpd.conf' 
		Call func_ReplaceInFile
		Pop $tempResult
		LogText $tempResult
		StrCpy $tempResult ""
		StrCpy $tempPort ""

		StrCmp $ampcVCRedist "none" vcr_not_install vcr_installed

		vcr_not_install:
			MessageBox MB_OK "$(i18n_VCR_APACHE_LEAVE)$\n$\n$(i18n_VCR_DOWNLOAD_REMINDER)"
			Goto vcr_leave

		vcr_installed:
			nsExec::ExecToStack /OEM '"$INSTDIR\Apache\bin\httpd.exe" -k install -n {$apacheCustomServiceName}'
			Pop $tempResult
			Pop $tempString
			
			${If} $tempResult != 0
				MessageBox MB_OK|MB_ICONSTOP "$(i18n_APACHE_INSTALL_SERVICE_ERROR): $tempString"
				LogText "Error installing Apache service: $tempResult - $tempString"
			${Else}
				LogText "Apache service installed successfully"
			${EndIf}
			
			StrCpy $tempResult ""
			StrCpy $tempString ""
			Goto vcr_leave
			
		vcr_leave:
	${EndIf}
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MariaDB Community Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function custom_PageMariadb
	; Mostrar solo si NO EXISTE instalacion previa.
	${If} $ampcPrevInstall == "none"

		nsDialogs::Create 1018
			Pop $tempResult
			!insertmacro MUI_HEADER_TEXT "$(i18n_MARIADB_HEADER)" "$(i18n_MARIADB_DESCR)"

			${NSD_CreateLabel} 0 0 100% 8u "$(i18n_MARIADB_PASS)"
			${NSD_CreatePassword} 0 12u 80% 12u ""
			Pop $mariadbCustomPass

			${NSD_CreateLabel} 0 36u 100% 8u "$(i18n_MARIADB_PASSCHECK)"
			${NSD_CreatePassword} 0 48u 80% 12u ""
			Pop $mariadbCustomPassCheck

			${NSD_CreateLabel} 0 72u 100% 8u "$(i18n_MARIADB_PORT)"
			${NSD_CreateNumber} 0 84u 20% 12u "3306"
			Pop $mariadbCustomPort

			${NSD_CreateLabel} 0 96u 100% 8u "$(i18n_MARIADB_SRVNAME)"
			${NSD_CreateText} 0 108u 20% 12u "MariaDB"
			Pop $mariadbCustomServiceName

			${NSD_CreateLabel} 0 120u 100% 12u "$(i18n_CONFIG_NOTBACK)"
			Pop $tempResult

			Call func_DisableBackButton
		StrCpy $tempResult ""
		nsDialogs::Show
	${EndIf}
FunctionEnd

Function leave_PageMariadb
	; Ejecutar solo si NO EXISTE instalacion previa.
	${If} $ampcPrevInstall == "none"
		
		${NSD_GetText} $mariadbCustomPass $tempString
		${NSD_GetText} $mariadbCustomPassCheck $tempResult
		${NSD_GetText} $mariadbCustomPort $tempPort

		; Validar contrasenna vacia.
		StrCmp $tempString "" 0 +3
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_MARIADB_PASSEMPTY)"
			Abort

		; Validar que las contrasennas coincidan.
		StrCmp $tempString $tempResult pass_match_ok 0
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_MARIADB_NOTCHECK)"
			Abort
		pass_match_ok:

		; Validar longitud minima de contrasenna.
		StrLen $tempLength $tempString
		IntCmp $tempLength ${MIN_PASSWORD_LENGTH} pass_min_ok pass_too_short pass_min_ok
		pass_too_short:
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_MARIADB_PASS_TOO_SHORT)"
			Abort
		pass_min_ok:

		; Recomendar contrasenna mas fuerte.
		IntCmp $tempLength ${RECOMMENDED_PASSWORD_LENGTH} pass_strength_ok pass_strength_ok pass_weak
		pass_weak:
			MessageBox MB_YESNO|MB_ICONQUESTION "$(i18n_MARIADB_PASS_WEAK)" IDYES pass_strength_ok
			Abort
		pass_strength_ok:

		; Validar puerto vacio.
		StrCmp $tempPort "" 0 +3
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_MARIADB_EMPTY_PORT)"
			Abort

		; Validar rango de puerto.
		IntCmp $tempPort ${MIN_PORT} mariadb_port_min_ok 0 mariadb_port_min_ok
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_PORT_INVALID_RANGE)"
			Abort
		mariadb_port_min_ok:

		IntCmp $tempPort ${MAX_PORT} mariadb_port_max_ok mariadb_port_max_ok 0
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_PORT_INVALID_RANGE)"
			Abort
		mariadb_port_max_ok:

		; Verificar si el puerto esta en uso.
		nsExec::ExecToStack 'netstat -an | findstr ":$tempPort "'
		Pop $tempLength
		${If} $tempLength == 0
			MessageBox MB_YESNO|MB_ICONQUESTION "$(i18n_PORT_IN_USE) $tempPort. $(i18n_CONTINUE_QUESTION)" IDYES mariadb_port_continue
			Abort
		${EndIf}
		mariadb_port_continue:
		StrCpy $tempLength ""

		; Verificar que el nombre del servicio no exista.
		${NSD_GetText} $mariadbCustomServiceName $tempResult
		nsExec::ExecToStack 'sc query "$tempResult"'
		Pop $tempLength
		${If} $tempLength == 0
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_SERVICE_ALREADY_EXISTS) $tempResult"
			Abort
		${EndIf}
		StrCpy $tempLength ""
		StrCpy $tempResult ""

		; Instalar MariaDB.
		DetailPrint "$(i18n_MARIADB_INSTALLING_SERVICE)"
		nsExec::ExecToStack /OEM '"$INSTDIR\MariaDB\bin\mariadb-install-db.exe" --service=MariaDB --password="$tempString" --port=$tempPort'
		Pop $tempResult
		Pop $tempLength
		
		${If} $tempResult != 0
			MessageBox MB_OK|MB_ICONSTOP "$(i18n_MARIADB_INSTALL_SERVICE_ERROR): $tempLength"
			LogText "Error installing MariaDB service: $tempResult"
			Abort
		${Else}
			LogText "MariaDB service installed successfully on port $tempPort"
		${EndIf}
		
		; Limpiar variables temporales
		StrCpy $tempResult ""
		StrCpy $tempString ""
		StrCpy $tempLength ""
		StrCpy $tempPort ""
	${EndIf}
FunctionEnd

###############################################################################
; SECCIONES INSTALACION.
###############################################################################

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inicializacion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section -sectionInit
	; Habilita registro en LOG de instalacion. La unica razon por la que se activa
	; aqui y no antes, es porque desde este punto hay garantia absoluta de la ruta
	; de instalacion y, por tanto, un lugar donde almacenar el archivo.
	LogSet on
	LogText "${DISTRO_NAME} ${VERSION_DISTRO}"
	LogText "${BUILD_TIMESTAMP_BRAND}"

	${If} $ampcPrevInstall == "none"
		; Si es una instalacion nueva, se crea el directorio.
		; El directorio se crea inmediatamente para asegurar que el LOG tenga donde
		; almacenarse y, asi, se registre todo el proceso de instalacion.
		DetailPrint "$(i18n_INSTALL_CREATEDIR) $INSTDIR"
		CreateDirectory "$INSTDIR"
	${EndIf}

	; Algunos archivos requieren barras invertidas tipo UNIX, mientras que $INSTDIR
	; contiene barras tipo Windows. La variable $ampcBackSlash almacena el valor
	; de $INSTDIR con barras tipo UNIX.
	Push $INSTDIR
	Push "\"
	Call func_ReplaceSlash
	Pop $ampcBackSlash
	LogText $ampcBackSlash
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Instalacion Previa
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section -sectionPrevInstallOne
	${If} $ampcPrevInstall == "yes"
		DetailPrint "$(i18n_INSTALL_PREVINSTALL)"

		DetailPrint "$(i18n_INSTALL_STOP_APACHESRV)"
		nsExec::ExecToStack /TIMEOUT=30000 /OEM 'net stop Apache2.4'
		Pop $0

		${If} $0 == "timeout"
            DetailPrint "$(i18n_INSTALL_KILL_APACHESRV)"
            nsExec::ExecToStack /OEM 'taskkill /F /IM httpd.exe'
            Pop $0
            Pop $1
        ${EndIf}

		DetailPrint "$(i18n_INSTALL_STOP_MARIADBSRV)"
		nsExec::ExecToStack /TIMEOUT=30000 /OEM 'net stop MariaDB'
		Pop $0

		${If} $0 == "timeout"
            DetailPrint "$(i18n_INSTALL_KILL_MARIADBSRV)"
            nsExec::ExecToStack /OEM 'taskkill /F /IM mariadbd.exe'
            Pop $0
            Pop $1
        ${EndIf}
	${EndIf}
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Desinstalador
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section -sectionUninstaller
	; Se registra el desinstalador.
	DetailPrint "$(i18n_CREATE_UNINSTALL)"
	WriteUninstaller "$INSTDIR\uninstall-ampc.exe"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "DisplayName" "${DISTRO_NAME}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "DisplayIcon" "$INSTDIR\uninstall-ampc.exe"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "InstallLocation" "$INSTDIR"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "UninstallString" "$INSTDIR\uninstall-ampc.exe"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "DisplayVersion" "${VERSION_DISTRO}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "URLInfoAbout" "${URL_DISTRO}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "URLUpdateInfo" "${URL_DISTRO_UPDATE}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "HelpLink" "${URL_DISTRO_HELP}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "Publisher" "${DISTRO_PUB}"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AMPc API
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section -sectionAmpc
	DetailPrint "$(i18n_CREATE_SHORTLINK)"
	WriteIniStr "$INSTDIR\${DISTRO_NAME}.url" "InternetShortcut" "URL" "${URL_DISTRO}"

	WriteRegDWORD ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "VersionAPI" "${VERSION_API}"
	WriteRegDWORD ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "LangInstall" "$LANGUAGE"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "VersionInstall" "${VERSION_DISTRO}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "BuildVersion" "${VERSION_BUILD}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "PathInstall" "$INSTDIR"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Visual C++ Redistributable.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section -sectionVCRedist
	
	${If} $ampcVCRedist == "install"
		DetailPrint "$(i18n_VCR_DOWNLOADING)"
		NScurl::http get "${URL_VCREDIST}" "$PLUGINSDIR\vcredist_x64.exe" /INSIST /CANCEL /RESUME /END
		Pop $1

		; El componente se pudo descargar y se procede a instalar.
		${If} $1 == "OK"
			StrCpy $ampcVCRedist "install"
			DetailPrint "$(i18n_VCR_INSTALLING)"
			nsExec::ExecToStack /OEM '"$PLUGINSDIR\vcredist_x64.exe" /q /norestart'
			Pop $R0
			Pop $R1

			; Si ocurre un error al instalar, se notifica al usuario.
			${If} $R0 == "error"
				StrCpy $ampcVCRedist "none"
				MessageBox MB_OK "$(i18n_ERROR_VCREDIST) $R1" 
			${EndIf}

			; Si se agota el tiempo de ejecucion al instalar, se notifica al usuario.
			${If} $R0 == "timeout"
				StrCpy $ampcVCRedist "none"
				MessageBox MB_OK "$(i18n_TIMEOUT_VCREDIST) $R1"
			${EndIf}

			DetailPrint "$(i18n_VCR_SUCCESS)"

		; El componente no se pudo descargar.
		${Else}
			StrCpy $ampcVCRedist "none"
			DetailPrint "$(i18n_VCR_ERROR) $1"
		${EndIf}

	${ElseIf} $ampcVCRedist == "skip"
		StrCpy $ampcVCRedist "none"
		MessageBox MB_OK "$(i18n_VCR_SKIP_REMINDER)"
		DetailPrint "$(i18n_VCR_SKIP_REMINDER)"

	; Se ha detectado el componente, se omite todo lo anterior.
	${Else}
		ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" "Version"
		StrCpy $ampcVCRedist "done"
		DetailPrint "$(i18n_VCR_EXIST) $1"
		Pop $1
	${EndIf}
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Apache HTTP Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section "Apache HTTP Server (${COMPONENT_A_VERSION})" section_Apache
	SectionIn RO

	StrCpy $apachePath "$INSTDIR\Apache"

	DetailPrint "$(i18n_INSTALL_APACHE)"
	SetOverwrite on
		!include "${DIR_COMPONENTS}\apache\files_install.nsh" ; Incluye archivos del paquete.

	${If} $ampcPrevInstall == "none"

		SetOutPath "$INSTDIR\htdocs"
			File "${DIR_WWW}\index.html"
			File /oname=favicon.ico ${DIR_MEDIA}\ampc.ico

		SetOutPath "$apachePath\conf"
			File "${DIR_CONFIG}\httpd.conf"

		; Se reemplazan las barras de Windows por barras tipo UNIX en el archivo de
		; configuracion httpd.conf de Apache HTTP.
		Push '___AMPC_PATH___'
		Push $ampcBackSlash
		Push all
		Push all
		Push '$apachePath\conf\httpd.conf'
		Call func_ReplaceInFile
		Pop $R0
		LogText $R0
	${EndIf}

	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionApache" "${COMPONENT_A_VERSION}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "pathApache" "$apachePath"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MariaDB Community Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section "MariaDB Community Server (${COMPONENT_M_VERSION})" section_Mariadb
	SectionIn RO

	StrCpy $mariadbPath "$INSTDIR\MariaDB"

	DetailPrint "$(i18n_INSTALL_MARIADB)"
	SetOverwrite on
		!include "${DIR_COMPONENTS}\mariadb\files_install.nsh" ; Incluye archivos del paquete.

	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionMariadb" "${COMPONENT_M_VERSION}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "pathMariadb" "$mariadbPath"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PHP.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section "PHP (${COMPONENT_P_VERSION})" section_Php
	SectionIn RO

	StrCpy $phpPath "$INSTDIR\PHP"

	DetailPrint "$(i18n_INSTALL_PHP)"
	SetOverwrite on
		!include "${DIR_COMPONENTS}\php\files_install.nsh" ; Incluye archivos del paquete.

	${If} $ampcPrevInstall == "none"

		SetOutPath "$phpPath"
			File "${DIR_CONFIG}\php.ini"
		SetOutPath "$INSTDIR\htdocs"
			File "${DIR_WWW}\phpinfo.php"

		; Se reemplazan las barras de Windows por barras tipo UNIX en el archivo de
		; configuracion php.ini de PHP.
		Push '___AMPC_PATH___'
		Push $ampcBackSlash
		Push all
		Push all
		Push '$phpPath\php.ini'
		Call func_ReplaceInFile
		Pop $R0
		LogText $R0
	${EndIf}

	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionPhp" "${COMPONENT_P_VERSION}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "pathPhp" "$phpPath"		
SectionEnd

Section "ca-cert (${COMPONENT_C_VERSION})" section_CACERT
	SectionIn RO

	StrCpy $cacertPath "$phpPath\extras\ssl"

	DetailPrint "$(i18n_INSTALL_CACERT)"
	SetOverwrite on
	SetOutPath "$cacertPath"
		!include "${DIR_COMPONENTS}\cacert\files_install.nsh" ; Incluye archivos del paquete.

	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionCACERT" "${COMPONENT_C_VERSION}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "pathCACERT" "$cacertPath"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Describe las secciones declaradas.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Apache} "$(i18n_DESCR_APACHE)"
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Mariadb} "$(i18n_DESCR_MARIADB)"
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Php} "$(i18n_DESCR_PHP)"
	!insertmacro MUI_DESCRIPTION_TEXT ${section_CACERT} "$(i18n_DESCR_CACERT)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

###############################################################################
; SECCIONES DESINSTALACION.
###############################################################################

; Al iniciar desinstalacion.
Function un.onInit
	InitPluginsDir

	; Splash al iniciar el desinstalador.
	SetOutPath $PLUGINSDIR
  	File "${DIR_MEDIA}\splash-uninstall.bmp"
	splash::show 1750 "$PLUGINSDIR\splash-uninstall"
	Pop $0
	Delete "$PLUGINSDIR\splash-uninstall.bmp"

	SetRegView 64
	!insertmacro MUI_UNGETLANGUAGE
	MessageBox MB_ICONINFORMATION|MB_OK "$(i18n_UNINSTALL_DISTRO).$\n$\n \
	$(i18n_UNINSTALL_DISTRO_HTDOCS)"
FunctionEnd

; Desinstalacion.
Section Uninstall
	DetailPrint "$(i18n_STOP_SERVICE_APACHE)"
	nsExec::ExecToStack /OEM '"$INSTDIR\Apache\bin\httpd.exe" -k stop'
	Pop $0
	Pop $1
	DetailPrint $0
	DetailPrint $1

	DetailPrint "$(i18n_DELETE_SERVICE_APACHE)"
	nsExec::ExecToStack /OEM '"$INSTDIR\Apache\bin\httpd.exe" -k uninstall'
	Pop $0
	Pop $1
	DetailPrint $0
	DetailPrint $1

	DetailPrint "$(i18n_STOP_SERVICE_MARIADB)"
	nsExec::ExecToStack /OEM 'net stop MariaDB'
	Pop $0
	Pop $1
	DetailPrint $0
	DetailPrint $1

	DetailPrint "$(i18n_DELETE_SERVICE_MARIADB)"
	nsExec::ExecToStack /OEM 'sc delete MariaDB'
	Pop $0
	Pop $1
	DetailPrint $0
	DetailPrint $1

	DetailPrint "$(i18n_UNINSTALL_FILES)"
	Delete "$INSTDIR\${DISTRO_NAME}.url"
	Delete "$INSTDIR\uninstall-ampc.exe"

	DetailPrint "$(i18n_UNINSTALL_FILES_APACHE)"
	!include "${DIR_COMPONENTS}\apache\uninstall_files.nsh"

	DetailPrint "$(i18n_UNINSTALL_FILES_MARIADB)"
	!include "${DIR_COMPONENTS}\mariadb\uninstall_files.nsh"

	DetailPrint "$(i18n_UNINSTALL_FILES_CACERT)"
	!include "${DIR_COMPONENTS}\cacert\uninstall_files.nsh"

	DetailPrint "$(i18n_UNINSTALL_FILES_PHP)"
	RMDir /r /REBOOTOK "$INSTDIR\PHP"
	!include "${DIR_COMPONENTS}\php\uninstall_files.nsh"

	RMDir /r /REBOOTOK "$INSTDIR\Apache"
	RMDir /r /REBOOTOK "$INSTDIR\MariaDB"
	RMDir /r /REBOOTOK "$INSTDIR\PHP"

	DetailPrint "$(i18n_UNINSTALL_LOG_FILE)"
	Delete "$INSTDIR\install.log"

	DetailPrint "$(i18n_DELETE_REGKEY)"
	DeleteRegKey ${REGKEY_ROOT} "${REGKEY_PACKAGE}"
	DeleteRegKey ${REGKEY_ROOT} "${REGKEY_UNINST}"
SectionEnd

; Al finalizar desinstalacion.
Function un.onUninstSuccess
	HideWindow
	MessageBox MB_ICONINFORMATION|MB_OK "$(i18n_UNINSTALL_FILES_SUCCESS)$\n$\n \
	$(i18n_UNINSTALL_DISTRO_HTDOCS)"
FunctionEnd