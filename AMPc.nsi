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
!define BUILD_TIMESTAMP_BRAND   "Compiled at ${__TIME__} on ${__DATE__}"

!define DIST_NAME "AMPc"
!define SHORTNAME "ampc"
!define PACKAGE "${DIST_NAME} for Windows"

; Version apta para VIProductVersion (no cumple SemVer).
!define VER_F_VIP "${AMPC_VERSION}.${API_LEVEL}"

; URL de descarga para Visual C++ Redistributable.
!define URL_VCREDIST "https://aka.ms/vs/17/release/vc_redist.x64.exe"

; VER_*
;	Versionado de AMPc.
;		VER_MAJOR => Version mayor.
;		VER_MENOR => Version menor.
;		VER_PATCH => Version parche.
;		VER_BUILD => Version de la compilacion.
;
;!define YEAR        "25"
!define RELEASE     "20"
!define PATCH       "0"
!define API_LEVEL   "2"
# DEPRECATED
!define VER_MAJOR "0" ;DEPRECATED.
!define VER_MENOR "${RELEASE}"
!define VER_PATCH "${PATCH}"
!define VER_BUILD "${AMPC_VERSION}+${BUILD_TIMESTAMP}"

;---------------
# DEPRECATED
; VERSION_*
;	Versiones declarada de los componentes incluidos en la compilacion..
;		VERSION_APACHE 	=> Apache HTTP Server.
;		VERSION_MARIADB => MariaDB Community Server.
;		VERSION_PHP 	=> PHP.
;		VERSION_CACERT 	=> Mozilla CA certificate (version AA.MM.DD).
;

# REEMPLAZO
!define COMP_APACHE_VER     "2.4.65"
!define COMP_MARIADB_VER    "11.4.8"
!define COMP_PHP_VER        "8.3.25"
!define COMP_CACERT_VER     "25.08.12"

;---------------
# DEPRECATED
; AMPC_*
;	Para derivaciones del codigo, las siguientes constantes DEBEN ser
;	cambiadas para evitar problemas tecnicos y legales.
;		AMPC_VERSION 	        => Version del paquete, formato SemVer.
;		AMPC_GUID		        => GUID para el paquete.
;		AMPC_URL			    => URL oficial del paquete.
;		AMPC_PUBLISHER	        => Nombre del publicador (aviso marca comercial)
;		AMPC_PUBLISHER_URL	    => Direccion web del publicador
;		AMPC_PUBLISHER_COUNTRY  => Pais del publicador.
;
!define AMPC_VERSION            "${VER_MAJOR}.${VER_MENOR}.${VER_PATCH}"
!define AMPC_GUID               "{FB39BDE3-4D2E-4634-BBB0-19B4D0AB5E13}"
!define AMPC_URL                "https://github.com/hucrea/AMPc"
!define AMPC_PUBLISHER          "Hu SpA"
!define AMPC_PUBLISHER_URL      "https://hucreativa.cl"
!define AMPC_PUBLISHER_COUNTRY  "Chile"

# REEMPLAZO
!define DIST_VERSION        "${DIST_YEAR}.${DIST_RELEASE}.${DIST_PATCH}"
!define DIST_GUID           "{FB39BDE3-4D2E-4634-BBB0-19B4D0AB5E13}"
!define DIST_URL            "https://github.com/hucrea/AMPc"
!define PUB_NAME            "Hu SpA"
!define PUB_WEBSITE         "https://hucreativa.cl"
!define PUB_COUNTRY         "Chile"

;
; URL_*
;	Direcciones web utilizadas por el paquete.
;		URL_UPDATE		=> Consultar nuevas versiones del paquete.
;		URL_HELP 		=> Ayuda sobre el paquete.
;
!define URL_UPDATE  "${AMPC_URL}/releases"
!define URL_HELP    "${AMPC_URL}/wiki"

!define DIST_URL_UPDATE  "${DIST_URL}/releases"
!define DIST_URL_HELP    "${DIST_URL}/wiki"
;
; REGKEY_*
;	Claves del registro.
;		REGKEY_ROOT 	=> Clave raiz en regedit.
;		REGKEY_PACKAGE 	=> Ruta regedit del instalador.
;		REGKEY_UNINST 	=> Ruta regedit del desinstalador.
;
!define REGKEY_ROOT     "HKLM"
!define REGKEY_PACKAGE  "Software\${AMPC_PUBLISHER}\${AMPC_GUID}" # DEPRECATED
!define REGKEY_UNINST   "Software\Microsoft\Windows\CurrentVersion\Uninstall\${AMPC_GUID}"

!define REGKEY_DIST "Software\${AMPC_PUBLISHER}\${AMPC_GUID}"

###############################################################################
; DETALLES DE LA COMPILACION ACTUAL.
###############################################################################
Unicode True
Name "${DIST_NAME}"
Caption "${PACKAGE}"
BrandingText "${AMPC_VERSION} - ${BUILD_TIMESTAMP_BRAND}"
AllowRootDirInstall true
OutFile "${SHORTNAME}-${VER_BUILD}.exe"
InstallDir "$PROGRAMFILES\AMPc"
ManifestSupportedOS Win10
RequestExecutionLevel admin
ShowInstDetails hide
ShowUnInstDetails hide

; Version Information
VIProductVersion "${VER_F_VIP}"
VIAddVersionKey /LANG=0 "FileVersion"       "${VER_F_VIP}"
VIAddVersionKey /LANG=0 "ProductVersion"    "${VER_F_VIP}"
VIAddVersionKey /LANG=0 "ProductName"       "${PACKAGE}"
VIAddVersionKey /LANG=0 "CompanyName"       "${AMPC_PUBLISHER} (${AMPC_PUBLISHER_COUNTRY})"
VIAddVersionKey /LANG=0 "LegalCopyright"	"© 2025 ${AMPC_PUBLISHER} (${AMPC_PUBLISHER_COUNTRY})"
VIAddVersionKey /LANG=0 "LegalTrademarks"	"${PACKAGE} is a trademark of ${AMPC_PUBLISHER}"
VIAddVersionKey /LANG=0 "FileDescription"	"Install ${PACKAGE}"

###############################################################################
; VARIABLES DEL PAQUETE.
###############################################################################
Var prevInstallAMPc ; Instalacion previa.
Var backSlashInstDir ; Usada por func_ReplaceSlash.
Var apacheConfigServerName ; Nombre del servidor (Apache).
Var apacheConfigPort ; Puerto (Apache).
Var mariadbConfigPass ; Contrasenna root (MariaDB).
Var mariadbConfigCheck ; Repeticion de contrasenna root (MariaDB).
Var mariadbConfigPort ; Puerto (MariaDB).
Var statusVCRuntime ; Estado de Visual C++ Redistributable.
Var pathApache ; Ruta de instalacion de Apache.
Var pathMariadb ; Ruta de instalacion de MariaDB.
Var pathPhp ; Ruta de instalacion de PHP.
Var pathCACERT ; Ruta de instalacion de ca-cert.

###############################################################################
; PROCESO DE INSTALACION.
###############################################################################
!include "x64.nsh"
!include "MUI.nsh"
!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "Functions.nsh"

; Configuracion de la instalacion.
!define MUI_ABORTWARNING
!define MUI_ICON "media-src\ampc_install.ico"
!define MUI_UNICON "media-src\ampc_uninstall.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "media-src\banner-install.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "media-src\banner-uninstall.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "media-src\header-install.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "media-src\header-uninstall.bmp"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "$(i18n_FINISHPAGE_RUN)"
!define MUI_FINISHPAGE_RUN_FUNCTION func_StartServices
!define MUI_LICENSEPAGE_BUTTON
!define MUI_FINISHPAGE_LINK "${PACKAGE}"
!define MUI_FINISHPAGE_LINK_LOCATION "${AMPC_URL}"
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
!insertmacro MUI_PAGE_COMPONENTS
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Al iniciar el instalador.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	StrCpy $pathApache 	"unknow"
	StrCpy $pathMariadb	"unknow"
	StrCpy $pathPhp 	"unknow"
	StrCpy $pathCACERT 	"unknow"

	; Verifica si existe alguna instalacion previa.
	ClearErrors
	EnumRegKey $R0 ${REGKEY_ROOT} "${REGKEY_PACKAGE}" 0

	; No existe instalacion previa.
	${If} ${Errors}
		StrCpy $prevInstallAMPc "none"

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
		StrCpy $prevInstallAMPc "yes"

		; Splash al iniciar el instalador.
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
			MessageBox MB_OK|MB_ICONSTOP "ERROR 1001."
			Abort
		${EndIf}
	${EndIf}
FunctionEnd

###############################################################################
; PAGINAS PERSONALIZADAS.
###############################################################################

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Apache HTTP Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function custom_PageApache
	; Mostrar solo si NO EXISTE instalacion previa.
	${If} $prevInstallAMPc == "none"
		nsDialogs::Create 1018
			Pop $0

			!insertmacro MUI_HEADER_TEXT "$(i18n_APACHE_HEADER)" "$(i18n_APACHE_DESCR)"

			${NSD_CreateLabel} 0 0 100% 8u "$(i18n_APACHE_SERVNAME)"
			${NSD_CreateText} 0 12u 80% 12u "localhost"
			Pop $apacheConfigServerName

			${NSD_CreateLabel} 0 30u 100% 8u "$(i18n_APACHE_PORT)"
			${NSD_CreateNumber} 0 42u 20% 12u "80"
			Pop $apacheConfigPort

			${NSD_CreateLabel} 0 120u 100% 12u "$(i18n_CONFIG_NOTBACK)"
			Pop $R1

			Call func_DisableBackButton
		nsDialogs::Show
	${EndIf}
FunctionEnd

Function leave_PageApache ; Funcion de salida para custom_PageApache.
	; Ejecutar solo si NO EXISTE instalacion previa.
	${If} $prevInstallAMPc == "none"

		${NSD_GetText} $apacheConfigServerName $R7
		${NSD_GetText} $apacheConfigPort $R8

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

			StrCmp $statusVCRuntime "none" vcrNotInstall vcrInstalled

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
	${If} $prevInstallAMPc == "none"

		nsDialogs::Create 1018
			Pop $R0
			!insertmacro MUI_HEADER_TEXT "$(i18n_MARIADB_HEADER)" "$(i18n_MARIADB_DESCR)"

			${NSD_CreateLabel} 0 0 100% 8u "$(i18n_MARIADB_PASS)"
			${NSD_CreatePassword} 0 12u 80% 12u ""
			Pop $mariadbConfigPass

			${NSD_CreateLabel} 0 36u 100% 8u "$(i18n_MARIADB_PASSCHECK)"
			${NSD_CreatePassword} 0 48u 80% 12u ""
			Pop $mariadbConfigCheck

			${NSD_CreateLabel} 0 72u 100% 8u "$(i18n_MARIADB_PORT)"
			${NSD_CreateNumber} 0 84u 20% 12u "3306"
			Pop $mariadbConfigPort

			${NSD_CreateLabel} 0 120u 100% 12u "$(i18n_CONFIG_NOTBACK)"
			Pop $R1

			Call func_DisableBackButton
		nsDialogs::Show
	${EndIf}
FunctionEnd

Function leave_PageMariadb ; Funcion de salida para custom_PageMariadb.
	; Ejecutar solo si NO EXISTE instalacion previa.
	${If} $prevInstallAMPc == "none"
		
		${NSD_GetText} $mariadbConfigPass $R0
		${NSD_GetText} $mariadbConfigCheck $R1
		${NSD_GetText} $mariadbConfigPort $R2

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
	LogText "${PACKAGE} ${AMPC_VERSION}"
	LogText "${BUILD_TIMESTAMP_BRAND}"

	${If} $prevInstallAMPc == "none"
		; Si es una instalacion nueva, se crea el directorio.
		; El directorio se crea inmediatamente para asegurar que el LOG tenga donde
		; almacenarse y, asi, se registre todo el proceso de instalacion.
		DetailPrint "$(i18n_INSTALL_CREATEDIR) $INSTDIR"
		CreateDirectory "$INSTDIR"

	${Else}
		; Si se detecto una instalacion previa, se detienen los servicios de 
		; Apache HTTP y de MariaDB.
		DetailPrint "$(i18n_INSTALL_PREVINSTALL)"
		DetailPrint "$(i18n_INSTALL_STOP_APACHESRV)"
		nsExec::ExecToStack /OEM 'net stop Apache2.4'
		Pop $0
		DetailPrint "$(i18n_INSTALL_STOP_MARIADBSRV)"
		nsExec::ExecToStack /OEM 'net stop MariaDB'
		Pop $0

	${EndIf}
SectionEnd

Section -sectionUninstaller
	; Se registra el desinstalador.
	DetailPrint "$(i18n_CREATE_UNINSTALL)"
	WriteUninstaller "$INSTDIR\uninstall-ampc.exe"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "DisplayName" "${PACKAGE}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "DisplayIcon" "$INSTDIR\uninstall-ampc.exe"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "InstallLocation" "$INSTDIR"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "UninstallString" "$INSTDIR\uninstall-ampc.exe"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "DisplayVersion" "${AMPC_VERSION}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "URLInfoAbout" "${AMPC_URL}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "URLUpdateInfo" "${URL_UPDATE}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "HelpLink" "${URL_HELP}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "Publisher" "${AMPC_PUBLISHER}"

	DetailPrint "$(i18n_CREATE_SHORTLINK)"
	WriteIniStr "$INSTDIR\${PACKAGE}.url" "InternetShortcut" "URL" "${AMPC_URL}"

	; Algunos archivos requieren barras invertidas tipo UNIX, mientras que $INSTDIR
	; contiene barras tipo Windows. La variable $backSlashInstDir almacena el valor
	; de $INSTDIR con barras tipo UNIX.
	Push $INSTDIR
	Push "\"
	Call func_ReplaceSlash
	Pop $backSlashInstDir
	LogText $backSlashInstDir

	WriteRegDWORD ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "LangInstall" "$LANGUAGE"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "VersionInstall" "${AMPC_VERSION}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "BuildVersion" "${VER_BUILD}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "PathInstall" "$INSTDIR"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Visual C++ Redistributable.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section -sectionVCRedist
	; Visual C++ Redistributable es requerido por Apache HTTP y PHP.
	; Para verificar si existe dicho componente, se consulta una clave del registro
	; tal como se indica en la web de Microsoft (revise el link de abajo)
	; https://learn.microsoft.com/es-mx/cpp/windows/redistributing-visual-cpp-files?view=msvc-170
	; Si EnumRegKey devuelve error, se asume que el componente no esta instalado
	; y se procede a ofrecer la descarga e instalacion al usuario, quien puede
	; aceptar o rechazar la descarga e instalacion del componente. La variable
	; $statusVCRuntime almacena el valor de la decision del usuario o existencia
	; del componente, para consulta posterior.
	ClearErrors
	EnumRegKey $0 HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" 0

	; No se ha detectado el componente.
	${If} ${Errors}
		; Se ofrece al usuario la descarga e instalacion automatica de 
		; Visual C++ Redistributable. Puede rechazar esta accion.
		DetailPrint "$(i18n_VCR_NOTFOUND)"
		MessageBox MB_YESNO "$(i18n_VCR_NOTFOUND) \
		$(i18n_VCR_MBOX_DETAILS1)$\n$\n$(i18n_VCR_MBOX_DETAILS2)" IDYES install IDNO skip

		; El usuario acepta la descarga e instalacion.
		install:
			DetailPrint "$(i18n_VCR_DOWNLOADING)"
			NScurl::http get "${URL_VCREDIST}" "$PLUGINSDIR\vcredist_x64.exe" /INSIST /CANCEL /RESUME /END
			Pop $1

			; El componente se pudo descargar y se procede a instalar.
			${If} $1 == "OK"
				StrCpy $statusVCRuntime "install"
				DetailPrint "$(i18n_VCR_INSTALLING)"
				nsExec::ExecToStack /OEM '"$PLUGINSDIR\vcredist_x64.exe" /q /norestart'
				Pop $R0
				Pop $R1

				; Si ocurre un error al instalar, se notifica al usuario.
				${If} $R0 == "error"
					StrCpy $statusVCRuntime "none"
					MessageBox MB_OK "$(i18n_ERROR_VCREDIST) $R1" 
					Goto skip
				${EndIf}

				; Si se agota el tiempo de ejecucion al instalar, se notifica al usuario.
				${If} $R0 == "timeout"
					StrCpy $statusVCRuntime "none"
					MessageBox MB_OK "$(i18n_TIMEOUT_VCREDIST) $R1"
					Goto skip
				${EndIf}

				DetailPrint "$(i18n_VCR_SUCCESS)"
				Goto continue

			; El componente no se pudo descargar.
			${Else}
				StrCpy $statusVCRuntime "none"
				DetailPrint "$(i18n_VCR_ERROR) $1"
			${EndIf}

		; Si el usuario rechaza la instalacion u ocurre un error que impide que el
		; componente sea instalado, se notifica al usuario que debe instalar el
		; componente por sus propios medios.
		skip:
			StrCpy $statusVCRuntime "none"
			MessageBox MB_OK "$(i18n_VCR_SKIP_REMINDER)"
			DetailPrint "$(i18n_VCR_SKIP_REMINDER)"

		continue:
	; Se ha detectado el componente, se omite todo lo anterior.
	${Else}
		StrCpy $statusVCRuntime "done"
		DetailPrint "$(i18n_VCR_EXIST)"
	${EndIf}
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Apache HTTP Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section "Apache HTTP Server (${COMP_APACHE_VER})" section_Apache
	SectionIn RO

	StrCpy $pathApache "$INSTDIR\Apache"

	DetailPrint "Instalando Apache HTTP..."

	SetOverwrite ifdiff
		!include "components\apache\files.nsh" ; Incluye archivos del paquete.
	SetOutPath "$INSTDIR\htdocs"

	SetOverwrite off
		File "www-src\index.html"
		File /oname=favicon.ico media-src\ampc.ico
	SetOutPath "$pathApache\conf"
		File "config-src\httpd.conf"

	${If} $prevInstallAMPc == "none"
		; Se reemplazan las barras de Windows por barras tipo UNIX en el archivo de
		; configuracion httpd.conf de Apache HTTP.
		Push '___AMPC_PATH___'
		Push $backSlashInstDir
		Push all
		Push all
		Push '$pathApache\conf\httpd.conf'
		Call func_ReplaceInFile
		Pop $R0
		LogText $R0
	${EndIf}

	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionApache" "${COMP_APACHE_VER}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "pathApache" "$pathApache"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MariaDB Community Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section "MariaDB Community Server (${COMP_MARIADB_VER})" section_Mariadb
	SectionIn RO

	StrCpy $pathMariadb "$INSTDIR\MariaDB"

	DetailPrint "Instalando MariaDB..."
	SetOverwrite ifdiff
		!include "components\mariadb\files.nsh" ; Incluye archivos del paquete.

	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionMariadb" "${COMP_MARIADB_VER}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "pathMariadb" "$pathMariadb"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PHP.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section "PHP (${COMP_PHP_VER})" section_Php
	SectionIn RO

	StrCpy $pathPhp "$INSTDIR\PHP"

	DetailPrint "Instalando PHP..."
	SetOverwrite ifdiff
		!include "components\php\files.nsh" ; Incluye archivos del paquete.

	SetOverwrite off
	SetOutPath "$pathPhp"
		File "config-src\php.ini"
	SetOutPath "$INSTDIR\htdocs"
		File "www-src\phpinfo.php"

	${If} $prevInstallAMPc == "none"
		; Se reemplazan las barras de Windows por barras tipo UNIX en el archivo de
		; configuracion php.ini de PHP.
		Push '___AMPC_PATH___'
		Push $backSlashInstDir
		Push all
		Push all
		Push '$pathPhp\php.ini'
		Call func_ReplaceInFile
		Pop $R0
		LogText $R0
	${EndIf}

	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionPhp" "${COMP_PHP_VER}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "pathPhp" "$pathPhp"		
SectionEnd

Section "ca-cert (${COMP_CACERT_VER})" section_CACERT
	SectionIn RO

	StrCpy $pathCACERT "$pathPhp\extras\ssl"

	SetOverwrite ifdiff
	SetOutPath "$pathCACERT"
		File "components\cacert\cacert.pem"

	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionCACERT" "${COMP_CACERT_VER}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "pathCACERT" "$pathCACERT"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Describe las secciones declaradas.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Apache} "$(i18n_DESCR_APACHE)"
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Mariadb} "$(i18n_DESCR_MARIADB)"
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Php} "$(i18n_DESCR_PHP)"
	!insertmacro MUI_DESCRIPTION_TEXT ${section_CACERT} "$(i18n_DESCR_CACERT)" ;
!insertmacro MUI_FUNCTION_DESCRIPTION_END

###############################################################################
; SECCIONES DESINSTALACION.
###############################################################################

; Al iniciar desinstalacion.
Function un.onInit
	InitPluginsDir

	; Splash al iniciar el desinstalador.
	SetOutPath $PLUGINSDIR
  	File "media-src\splash-uninstall.bmp"
	splash::show 1750 "$PLUGINSDIR\splash-uninstall"
	Pop $0
	Delete "$PLUGINSDIR\splash-uninstall.bmp"

	SetRegView 64
	!insertmacro MUI_UNGETLANGUAGE
	MessageBox MB_ICONINFORMATION|MB_OK "Vas a desinstalar ${PACKAGE}.$\n$\n \
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
	Delete "$INSTDIR\${PACKAGE}.url"
	Delete "$INSTDIR\uninstall-ampc.exe"
	Delete "$INSTDIR\updater-ampc.exe"

	DetailPrint "Eliminando archivos de Apache HTTP"
	RMDir /r /REBOOTOK "$INSTDIR\Apache"

	DetailPrint "Eliminando archivos de MariaDB"
	RMDir /r /REBOOTOK "$INSTDIR\MariaDB"

	DetailPrint "Eliminando archivos de PHP"
	RMDir /r /REBOOTOK "$INSTDIR\PHP"

	DetailPrint "Eliminando archivos de phpMyAdmin"
	RMDir /r /REBOOTOK "$INSTDIR\htdocs\phpmyadmin"

	DetailPrint "Eliminando archivos de Adminer"
	RMDir /r /REBOOTOK "$INSTDIR\htdocs\adminer"

	DetailPrint "Eliminando LOG de instalación"
	Delete "$INSTDIR\install.log"

	DetailPrint "Eliminando claves del registro"
	DeleteRegKey ${REGKEY_ROOT} "${REGKEY_PACKAGE}"
	DeleteRegKey ${REGKEY_ROOT} "${REGKEY_UNINST}"
SectionEnd

; Al finalizar desinstalacion.
Function un.onUninstSuccess
	HideWindow
	MessageBox MB_ICONINFORMATION|MB_OK "La desinstalación de ${PACKAGE} finalizó correctamente.$\n$\n \
	La carpeta $INSTDIR\htdocs no se ha eliminado."
FunctionEnd