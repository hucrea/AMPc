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
; CONSTANTES DEL PAQUETE.
###############################
!define /date BUILD_TIMESTAMP   "%Y%m%d_%H%M%S"
!define BUILD_TIMESTAMP_BRAND   "Build at ${__TIME__} on ${__DATE__}"

!define VERSION_DISTRO "0.20.0"
!define VERSION_API "2"
!define VERSION_BUILD "${VERSION_DISTRO}+${BUILD_TIMESTAMP}"
!define VERSION_VIPV "${VERSION_DISTRO}.${VERSION_API}"

!define SHORTNAME "ampc"
!define DISTRO_NAME "AMPc"
!define DISTRO_GUID "{FB39BDE3-4D2E-4634-BBB0-19B4D0AB5E13}"
!define DISTRO_PUB "Hu SpA"
!define DISTRO_PUB_COUNTRY "Chile"

!define COMPONENT_A_VERSION "2.4.65"
!define COMPONENT_M_VERSION "11.4.8"
!define COMPONENT_P_VERSION "8.3.25"
!define COMPONENT_C_VERSION "25.08.12"

!define REGKEY_ROOT "HKLM"
!define REGKEY_PACKAGE "Software\${DISTRO_PUB}\${DISTRO_GUID}"
!define REGKEY_UNINST "Software\Microsoft\Windows\CurrentVersion\Uninstall\${DISTRO_GUID}"

!define URL_VCREDIST "https://aka.ms/vs/17/release/vc_redist.x64.exe"
!define URL_DISTRO "https://github.com/hucrea/AMPc"
!define URL_DISTRO_PUB "https://hucreativa.cl"
!define URL_DISTRO_UPDATE "${URL_DISTRO}/releases"
!define URL_DISTRO_HELP "${URL_DISTRO}/wiki"

!define DIR_MEDIA "media-src"
!define DIR_COMPONENTS "components"
!define DIR_WWW "www-src"
!define DIR_CONFIG "config-src"

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
ShowInstDetails hide
ShowUnInstDetails hide

; Version Information
VIProductVersion "${VERSION_VIPV}"
VIAddVersionKey /LANG=0 "FileVersion" "${VERSION_VIPV}"
VIAddVersionKey /LANG=0 "ProductVersion" "${VERSION_VIPV}"
VIAddVersionKey /LANG=0 "ProductName" "${DISTRO_NAME}"
VIAddVersionKey /LANG=0 "CompanyName" "${DISTRO_PUB} (${DISTRO_PUB_COUNTRY})"
VIAddVersionKey /LANG=0 "LegalCopyright" "© 2025 ${DISTRO_PUB} (${DISTRO_PUB_COUNTRY})"
VIAddVersionKey /LANG=0 "LegalTrademarks" "${DISTRO_NAME} is a trademark of ${DISTRO_PUB}"
VIAddVersionKey /LANG=0 "FileDescription" "Installer ${DISTRO_NAME}"

###############################
; VARIABLES DEL PAQUETE.
###############################
Var ampcPrevInstall ; Instalacion previa.
Var ampcBackSlash ; Usada por func_ReplaceSlash.

Var ampcComponents
Var ampcComponents_Label6
Var ampcComponents_Label5
Var ampcComponents_Label4
Var ampcComponents_Label3
Var ampcComponents_Label2
Var ampcComponents_Label1
Var ampcFontBold

Var ampcVCRedist ; Estado de Visual C++ Redistributable.
Var ampcVCRedistDialog
Var ampcVCRLabel1
Var ampcVCRCheckbox
Var ampcVCRLabel2

Var apachePath ; Ruta local de instalacion de Apache.
Var apacheVersion ; Version local de Apache.
Var apacheCustomServerName ; Nombre del servidor (Apache).
Var apacheCustomPort ; Puerto (Apache).
Var apacheCustomServiceName ; Nombre del servicio (Apache).

Var mariadbPath ; Ruta local de instalacion de MariaDB.
Var mariadbVersion ; Version local de MariaDB.
Var mariadbCustomPass ; Contrasenna root (MariaDB).
Var mariadbCustomPassCheck ; Repeticion de contrasenna root (MariaDB).
Var mariadbCustomPort ; Puerto (MariaDB).
Var mariadbCustomServiceName ; Nombre del servicio (MariaDB).

Var phpVersion ; Version local de PHP.
Var phpPath ; Ruta local de instalacion de PHP.

Var cacertPath ; Ruta local de instalacion de ca-cert.
Var cacertVersion ; Version local de cacert.

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
!define MUI_PAGE_HEADER_SUBTEXT "$(i18n_LICENSE_SUBTITLE)"
!insertmacro MUI_PAGE_LICENSE "media-src\license.rtf"
!define MUI_PAGE_HEADER_TEXT "$(i18n_LICENSE_THIRD_TITLE)"
!define MUI_PAGE_HEADER_SUBTEXT "$(i18n_LICENSE_THIRD_SUBTITLE)"
!define MUI_LICENSEPAGE_TEXT_TOP "$(i18n_LICENSE_THIRD_TEXTTOP)"
!define MUI_LICENSEPAGE_TEXT_BOTTOM "$(i18n_LICENSE_THIRD_TEXTTBOTTOM)"
!define MUI_LICENSEPAGE_BUTTON "$(i18n_LICENSE_THIRD_BUTTON)"
!insertmacro MUI_PAGE_LICENSE "media-src\license-components.rtf"
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
# Al iniciar el instalador.
###############################
Function .onInit
	InitPluginsDir

	; Verifica que arquitectura del sistema anfitrion sea x64.
	${IfNot} ${RunningX64}
		MessageBox MB_OK|MB_ICONSTOP "$(i18n_32BITS_NOTSUPPORT).$\n$\n$(i18n_INSTALL_CANNOT)"
		Abort
	${EndIf}

	; Evita redirecciones de WOW64 en directorios y registros.
	${DisableX64FSRedirection}
	SetRegView 64

	; Inicializa instalador.
	!insertmacro MUI_LANGDLL_DISPLAY

	# INSTALACION PREVIA
	; Inicializa variables.
	StrCpy $apachePath "unknow"
	StrCpy $apacheVersion "unknow"
	StrCpy $mariadbPath "unknow"
	StrCpy $mariadbVersion "unknow"
	StrCpy $phpPath "unknow"
	StrCpy $phpVersion "unknow"
	StrCpy $cacertPath "unknow"
	StrCpy $cacertVersion "unknow"

	; Verifica si existe alguna instalacion previa.
	ClearErrors
	EnumRegKey $R0 ${REGKEY_ROOT} "${REGKEY_PACKAGE}" 0

	; No existe instalacion previa.
	${If} ${Errors}
		StrCpy $ampcPrevInstall "none"

		; Splash al iniciar el instalador.
		SetOutPath $PLUGINSDIR
		File "media-src\splash-install.bmp"
		splash::show 1750 "$PLUGINSDIR\splash-install"
		Pop $0
		Delete "$PLUGINSDIR\splash-install.bmp"

		SetOutPath $INSTDIR

		; Establece la ruta de instalacion en la unidad raiz de Windows.
		StrCpy "$INSTDIR" "$WINDIR" 2
		StrCpy "$INSTDIR" "$INSTDIR\AMPc"

	; Existe instalacion previa.
	${Else}
		StrCpy $ampcPrevInstall "yes"

		; Splash al iniciar el actualizador.
		SetOutPath $PLUGINSDIR
		File "media-src\splash-update.bmp"
		splash::show 1750 "$PLUGINSDIR\splash-update"
		Pop $0
		Delete "$PLUGINSDIR\splash-update.bmp"

		SetOutPath $INSTDIR
		
		; Lee la ruta de la instalacion actual.
		ClearErrors
		ReadRegStr $R1 ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "PathInstall"

		${IfNot} ${Errors}
			StrCpy "$INSTDIR" "$R1"

		${Else}
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
	ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" "Installed"

	; No se ha detectado el componente.
	${If} ${Errors}
    ${OrIf} $0 != 1
		nsDialogs::Create 1018
		Pop $ampcVCRedistDialog
		${If} $ampcVCRedistDialog == error
			Abort
		${EndIf}

		!insertmacro MUI_HEADER_TEXT "Descargar e Instalar dependencia" "Dependencia necesaria no encontrada"

		${NSD_CreateLabel} 0 10u 100% 20u "No se ha detectado Visual C++ Redistributable y es necesario para ejecutar los binarios de Apache HTTP Server y PHP en Windows."
		Pop $ampcVCRLabel1

		${NSD_CreateCheckbox} 0 40u 100% 15u "Descargar e Instalar Visual C++ Redistributable durante la instalación."
		Pop $ampcVCRCheckbox
		${NSD_Check} $ampcVCRCheckbox

		${NSD_CreateLabel} 0 72u 100% 36u "La descarga se realiza desde el servidor oficial de Microsoft. Si no aceptas la descarga e instalación automática deberás realizarla por tu cuenta para poder ejecutar Apache y PHP, además de instalar el servicio de Apache manualmente. La descarga requiere conexión a internet."
		Pop $ampcVCRLabel2
		nsDialogs::Show
	${EndIf}
FunctionEnd

Function leave_PageVCRedist ; Funcion de salida para custom_PageVCRedist.
	Push $0

    ${NSD_GetState} $ampcVCRCheckbox $0

    ${If} $0 == ${BST_CHECKED}
        StrCpy $ampcVCRedist "install"
    ${Else}
        StrCpy $ampcVCRedist "skip"
    ${EndIf}

    Pop $0
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Componentes.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function custom_PageComponents
	CreateFont $ampcFontBold "Microsoft Sans Serif" "8.25" "700"
  
	nsDialogs::Create 1018
	Pop $ampcComponents
	${If} $ampcComponents == error
		Abort
	${EndIf}
	!insertmacro MUI_HEADER_TEXT "Componentes a instalar" "Los siguientes componentes se instalarán"

	${NSD_CreateLabel} 0 0 100% 17u "Los siguientes componentes se instalarán:"
	Pop $ampcComponentsLabel1

	${NSD_CreateLabel} 16u 33u 100% 17u "Apache HTTP Server ${apacheVersion}"
	Pop $ampcComponentsLabel2
	SendMessage $ampcComponentsLabel2 ${WM_SETFONT} $ampcFontBold 0

	${NSD_CreateLabel} 16u 50u 100% 17u "MariaDB Community Server ${mariadbVersion}"
	Pop $ampcComponentsLabel3
	SendMessage $ampcComponentsLabel3 ${WM_SETFONT} $ampcFontBold 0

	${NSD_CreateLabel} 16u 67u 100% 17u "PHP: Hypertext Preprocessor ${phpVersion}"
	Pop $ampcComponentsLabel4
	SendMessage $ampcComponentsLabel4 ${WM_SETFONT} $ampcFontBold 0

	${NSD_CreateLabel} 16u 84u 100% 17u "cacert ${cacertVersion}"
	Pop $ampcComponentsLabel5
	SendMessage $ampcComponentsLabel5 ${WM_SETFONT} $ampcFontBold 0

	${NSD_CreateLabel} 0 110u 100% 25u "Una vez finalizada la instalación, se iniciará el asistente que le guiará para la configuración inicial de Apache y MariaDB."
	Pop $ampcComponentsLabel6
	nsDialogs::Show
FunctionEnd

Function leave_PageComponents ; Funcion de salida para custom_PageComponents.
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Apache HTTP Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function custom_PageApache
	; Mostrar solo si NO EXISTE instalacion previa.
	${If} $ampcPrevInstall == "none"
		nsDialogs::Create 1018
			Pop $0

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
			Pop $R1

			Call func_DisableBackButton
		nsDialogs::Show
	${EndIf}
FunctionEnd

Function leave_PageApache ; Funcion de salida para custom_PageApache.
	; Ejecutar solo si NO EXISTE instalacion previa.
	${If} $ampcPrevInstall == "none"

		${NSD_GetText} $apacheCustomServerName $R7
		${NSD_GetText} $apacheCustomPort $R8

		StrCmp $R7 "" failEmptyServer stepCheckPort

		stepCheckPort:
			StrCmp $R8 "" failEmptyPort leaveActions

		failEmptyServer:
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_APACHE_EMPTY_SERVNAME)"
			Abort
			
		failEmptyPort:
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_APACHE_EMPTY_PORT)"
			Abort

		leaveActions:
			Push '___AMPC_SERVERNAME___'
			Push $R7
			Push all
			Push all
			Push '$INSTDIR\Apache\conf\httpd.conf'
			Call func_ReplaceInFile
			Pop $0
			LogText $0

			Push '___AMPC_HTTP_PORT___'
			Push $R8 
			Push all 
			Push all 
			Push '$INSTDIR\Apache\conf\httpd.conf' 
			Call func_ReplaceInFile
			Pop $0
			LogText $0

			StrCmp $ampcVCRedist "none" vcrNotInstall vcrInstalled

			vcrNotInstall:
				MessageBox MB_OK "$(i18n_VCR_APACHE_LEAVE)$\n$\n$(i18n_VCR_DOWNLOAD_REMINDER)"
				Goto vcrLeave

			vcrInstalled:
				nsExec::ExecToStack /OEM '"$INSTDIR\Apache\bin\httpd.exe" -k install'
				Pop $0
				Pop $1
				LogText $0
				LogText $1
				Goto vcrLeave
				
			vcrLeave:
	${EndIf}
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MariaDB Community Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function custom_PageMariadb
	; Mostrar solo si NO EXISTE instalacion previa.
	${If} $ampcPrevInstall == "none"

		nsDialogs::Create 1018
			Pop $R0
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
			Pop $R1

			Call func_DisableBackButton
		nsDialogs::Show
	${EndIf}
FunctionEnd

Function leave_PageMariadb ; Funcion de salida para custom_PageMariadb.
	; Ejecutar solo si NO EXISTE instalacion previa.
	${If} $ampcPrevInstall == "none"
		
		${NSD_GetText} $mariadbCustomPass $R0
		${NSD_GetText} $mariadbCustomPassCheck $R1
		${NSD_GetText} $mariadbCustomPort $R2

		StrCmp $R0 "" failEmptyPass stepPassMatch

		stepPassMatch:
			StrCmp $R0 $R1 stepCheckPort failPassMatch

		stepCheckPort:
			StrCmp $R2 "" failEmptyPort leaveActions

		failPassMatch:
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_MARIADB_NOTCHECK)"
			Abort

		failEmptyPass:
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_MARIADB_PASSEMPTY)"
			Abort

		failEmptyPort:
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(i18n_MARIADB_EMPTY_PORT)"
			Abort

		leaveActions:
			nsExec::ExecToStack /OEM '"$INSTDIR\MariaDB\bin\mariadb-install-db.exe" --service=MariaDB --password="$R0" --port=$R2'
			Pop $0
			Pop $1
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
				Goto skip
			${EndIf}

			; Si se agota el tiempo de ejecucion al instalar, se notifica al usuario.
			${If} $R0 == "timeout"
				StrCpy $ampcVCRedist "none"
				MessageBox MB_OK "$(i18n_TIMEOUT_VCREDIST) $R1"
				Goto skip
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
			File /oname=favicon.ico media-src\ampc.ico

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
	MessageBox MB_ICONINFORMATION|MB_OK "Vas a desinstalar ${DISTRO_NAME}.$\n$\n \
	La carpeta $INSTDIR\htdocs NO SE ELIMINARÁ"
FunctionEnd

; Desinstalacion.
Section Uninstall
	DetailPrint "Deteniendo servicio Apache HTTP"
	nsExec::ExecToStack /OEM '"$INSTDIR\Apache\bin\httpd.exe" -k stop'
	Pop $0
	Pop $1
	DetailPrint $0
	DetailPrint $1

	DetailPrint "Eliminando servicio Apache HTTP"
	nsExec::ExecToStack /OEM '"$INSTDIR\Apache\bin\httpd.exe" -k uninstall'
	Pop $0
	Pop $1
	DetailPrint $0
	DetailPrint $1

	DetailPrint "Deteniendo servicio MariaDB"
	nsExec::ExecToStack /OEM 'net stop MariaDB'
	Pop $0
	Pop $1
	DetailPrint $0
	DetailPrint $1

	DetailPrint "Eliminando servicio MariaDB"
	nsExec::ExecToStack /OEM 'sc delete MariaDB'
	Pop $0
	Pop $1
	DetailPrint $0
	DetailPrint $1

	DetailPrint "Eliminando archivos"
	Delete "$INSTDIR\${DISTRO_NAME}.url"
	Delete "$INSTDIR\uninstall-ampc.exe"

	DetailPrint "Eliminando archivos de Apache HTTP"
	!include "${DIR_COMPONENTS}\apache\uninstall_files.nsh"

	DetailPrint "Eliminando archivos de MariaDB"
	!include "${DIR_COMPONENTS}\mariadb\uninstall_files.nsh"

	DetailPrint "Eliminando cacert"
	!include "${DIR_COMPONENTS}\cacert\uninstall_files.nsh"

	DetailPrint "Eliminando archivos de PHP"
	RMDir /r /REBOOTOK "$INSTDIR\PHP"
	!include "${DIR_COMPONENTS}\php\uninstall_files.nsh"

	RMDir /r /REBOOTOK "$INSTDIR\Apache"
	RMDir /r /REBOOTOK "$INSTDIR\MariaDB"
	RMDir /r /REBOOTOK "$INSTDIR\PHP"

	DetailPrint "Eliminando LOG de instalación"
	Delete "$INSTDIR\install.log"

	DetailPrint "Eliminando claves del registro"
	DeleteRegKey ${REGKEY_ROOT} "${REGKEY_PACKAGE}"
	DeleteRegKey ${REGKEY_ROOT} "${REGKEY_UNINST}"
SectionEnd

; Al finalizar desinstalacion.
Function un.onUninstSuccess
	HideWindow
	MessageBox MB_ICONINFORMATION|MB_OK "La desinstalación de ${DISTRO_NAME} finalizó correctamente.$\n$\n \
	La carpeta $INSTDIR\htdocs no se ha eliminado."
FunctionEnd