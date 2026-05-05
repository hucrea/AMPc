/*

AMPc for Windows - Entorno web local para Windows 10 y Windows 11
Copyright (C) 2025-2026  Hu SpA ( https://hucreativa.cl )

This file is part of AMPc for Windows.

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------

AMPc.nsi - Archivo principal del paquete.

NOTAS: 
	- Todos los caracteres especiales se han omitido para mayor compatibilidad.

*/

/* Constantes del paquete. */
; Marcas de tiempo.
!define /date TIMESTAMP_COMPILE "%Y%m%d_%H%M%S"
!define COMPILED_STAMP "Compiled at ${__TIME__} on ${__DATE__}"
!define METADATA_BUILD "${PACKAGE_VERSION}+${TIMESTAMP_COMPILE}"

; Versiones.
!define VER_MAJOR "26"
!define VER_MENOR "1"
!define VER_PATCH "0"
!define /date VER_BUILD "%y%m%d%H%M%S"
!include "Versions.nsh"

; Datos del paquete.
# Para derivaciones del codigo, es buena idea cambiar las siguientes
# constantes por unas personalizadas, a fin de evitar conflictos con
# instalaciones de AMPc ya existentes.
!define PACKAGE_VERSION "${VER_MAJOR}.${VER_MENOR}.${VER_PATCH}"
!define PACKAGE_NAME "AMPc for Windows"
!define PACKAGE_SHORTNAME "AMPc"
!define PACKAGE_GUID "{FB39BDE3-4D2E-4634-BBB0-19B4D0AB5E13}"
!define PACKAGE_URL "https://github.com/hucrea/AMPc"
!define PACKAGE_URL_UPDATE "${PACKAGE_URL}/releases"
!define PACKAGE_URL_HELP "${PACKAGE_URL}/wiki"
!define PACKAGE_PUBLISHER "Hu SpA"
!define PACKAGE_PUBLISHER_URL "https://hucreativa.cl"
!define PACKAGE_PUBLISHER_COUNTRY "Chile"

; URL de descarga para Visual C++ Redistributable.
!define URL_VCREDIST "https://aka.ms/vs/17/release/vc_redist.x64.exe"

; Claves del registro.
!define REGKEY_ROOT "HKLM"
!define REGKEY_PACKAGE "Software\${PACKAGE_PUBLISHER}\${PACKAGE_GUID}"
!define REGKEY_UNINST "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PACKAGE_GUID}"

; Directorios de trabajo.
!define DIR_COMPONENTS "src-components"
!define DIR_EXTRAS "src-extras"
!define DIR_CONFIG "src-configs"

/* Detalles de la compilacion actual. */
SetCompressor /SOLID /FINAL lzma
Name "${PACKAGE_NAME}"
Caption "${PACKAGE_NAME}"
BrandingText "${PACKAGE_VERSION} - ${COMPILED_STAMP}"
ManifestSupportedOS Win10
Unicode True
RequestExecutionLevel admin
OutFile "${PACKAGE_SHORTNAME}-${METADATA_BUILD}.exe"
InstallDir "$PROGRAMFILES\AMPc"
ShowInstDetails hide
ShowUnInstDetails hide
AllowRootDirInstall true

; Informacion de la version.
VIProductVersion "${PACKAGE_VERSION}.${VER_BUILD}"
VIAddVersionKey /LANG=0 "FileVersion"		"${PACKAGE_VERSION}.${VER_BUILD}"
VIAddVersionKey /LANG=0 "ProductVersion" 	"${PACKAGE_VERSION}.${VER_BUILD}"
VIAddVersionKey /LANG=0 "ProductName" 		"${PACKAGE_NAME}"
VIAddVersionKey /LANG=0 "CompanyName" 		"${PACKAGE_PUBLISHER} (${PACKAGE_PUBLISHER_COUNTRY})"
VIAddVersionKey /LANG=0 "LegalCopyright" 	"© 2025-2026 ${PACKAGE_PUBLISHER} (${PACKAGE_PUBLISHER_COUNTRY})"
VIAddVersionKey /LANG=0 "LegalTrademarks" 	"${PACKAGE_NAME} is a trademark of ${PACKAGE_PUBLISHER}"
VIAddVersionKey /LANG=0 "FileDescription" 	"${PACKAGE_NAME} ${PACKAGE_VERSION}.${VER_BUILD}"

/* Variables del paquete */
Var tempVar ; Variable temporal.
Var prevInstallAMPc ; Instalacion previa.
Var backSlashInstDir ; Funcion func_ReplaceSlash.
Var apacheConfigServerName ; Usada por custom_PageApache y leave_PageApache.
Var apacheConfigPort ; Usada por custom_PageApache y leave_PageApache.
Var mariadbConfigPass ; Usada por custom_PageMariadb y leave_PageMariadb.
Var mariadbConfigCheck ; Usada por custom_PageMariadb y leave_PageMariadb.
Var mariadbConfigPort ; Usada por custom_PageMariadb y leave_PageMariadb.
Var statusVCRuntime ; Usada para la comprobacion de Visual C++ Redistributable.
Var ampcVCRedistDialog
Var ampcVCRLabel1
Var ampcVCRCheckbox
Var ampcVCRLabel2
Var pathApache ; Almacena ruta de instalacion para Apache.
Var versionApache ; Almacena version instalada de Apache.
Var pathMariadb ; Almacena ruta de instalacion para MariaDB.
Var versionMariadb ; Almacena version instalada de MariaDB.
Var pathPhp ; Almacena ruta de instalacion para PHP.
Var versionPhp ; Almacena version instalada de PHP.
Var pathCACERT ; Almacena ruta de instalacion para ca-cert.
Var versionCACERT ; Almacena version instalada de ca-cert.

/* Proceso de instalacion. */
!include "x64.nsh"
!include "MUI.nsh"
!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "Functions.nsh"

; Configuracion de la instalacion.
!define MUI_ABORTWARNING
!define MUI_ICON "${DIR_EXTRAS}\ampc_install.ico"
!define MUI_UNICON "${DIR_EXTRAS}\ampc_uninstall.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${DIR_EXTRAS}\banner-install.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${DIR_EXTRAS}\banner-uninstall.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${DIR_EXTRAS}\header-install.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "${DIR_EXTRAS}\header-uninstall.bmp"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "$(i18n_FINISHPAGE_RUN)"
!define MUI_FINISHPAGE_RUN_FUNCTION func_StartServices
!define MUI_LICENSEPAGE_BUTTON
!define MUI_FINISHPAGE_LINK "${PACKAGE_NAME}"
!define MUI_FINISHPAGE_LINK_LOCATION "${PACKAGE_URL}"
!define MUI_COMPONENTSPAGE_SMALLDESC

; Proceso de instalacion.
!define MUI_PAGE_HEADER_TEXT "$(i18n_LICENSE_TITLE)"
!define MUI_PAGE_HEADER_SUBTEXT "$(i18n_LICENSE_SUBTITLE)"; 
!insertmacro MUI_PAGE_LICENSE "${DIR_EXTRAS}\license.rtf"
!define MUI_PAGE_HEADER_TEXT "$(i18n_LICENSE_THIRD_TITLE)"
!define MUI_PAGE_HEADER_SUBTEXT "$(i18n_LICENSE_THIRD_SUBTITLE)"
!define MUI_LICENSEPAGE_TEXT_TOP "$(i18n_LICENSE_THIRD_TEXTTOP)"
!define MUI_LICENSEPAGE_TEXT_BOTTOM "$(i18n_LICENSE_THIRD_TEXTTBOTTOM)"
!define MUI_LICENSEPAGE_BUTTON "$(i18n_LICENSE_THIRD_BUTTON)"
!insertmacro MUI_PAGE_LICENSE "${DIR_EXTRAS}\license-components.rtf"
!insertmacro MUI_PAGE_DIRECTORY
Page Custom custom_PageVCRedist leave_PageVCRedist
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
	StrCpy $pathApache "none"
	StrCpy $versionApache "none"
	StrCpy $pathMariadb "none"
	StrCpy $versionMariadb "none"
	StrCpy $pathPhp "none"
	StrCpy $versionPhp "none"
	StrCpy $pathCACERT "none"
	StrCpy $versionCACERT "none"

	; Verifica si existe alguna instalacion previa.
	ClearErrors
	EnumRegKey $tempVar ${REGKEY_ROOT} "${REGKEY_PACKAGE}" 0

	; No existe instalacion previa.
	${If} ${Errors}
		StrCpy $prevInstallAMPc "none"
		StrCpy $tempVar ""

		; Splash al iniciar el instalador.
		SetOutPath $PLUGINSDIR
		File "${DIR_EXTRAS}\splash-install.bmp"
		splash::show 1750 "$PLUGINSDIR\splash-install"
		Pop $tempVar
		Delete "$PLUGINSDIR\splash-install.bmp"
		StrCpy $tempVar ""

		SetOutPath $INSTDIR

		; Establece la ruta de instalacion en la unidad raiz de Windows.
		StrCpy "$INSTDIR" "$WINDIR" 2
		StrCpy "$INSTDIR" "$INSTDIR\AMPc"

	; Existe instalacion previa.
	${Else}
		StrCpy $prevInstallAMPc "yes"
		StrCpy $tempVar ""

		; Splash al iniciar el actualizador.
		SetOutPath $PLUGINSDIR
		File "${DIR_EXTRAS}\splash-update.bmp"
		splash::show 1750 "$PLUGINSDIR\splash-update"
		Pop $tempVar
		Delete "$PLUGINSDIR\splash-update.bmp"
		StrCpy $tempVar ""

		SetOutPath $INSTDIR
		
		; Lee la ruta de la instalacion actual.
		ClearErrors
		ReadRegStr $tempVar ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "PathInstall"

		${IfNot} ${Errors}
			StrCpy "$INSTDIR" "$tempVar"
			StrCpy $tempVar ""
		${Else}
			; No se puede leer la ruta de insralacion.
			MessageBox MB_OK|MB_ICONSTOP "$(i18n_NOT_PATH_FOUND)"
			Abort
		${EndIf}
	${EndIf}
FunctionEnd

###############################################################################
; PAGINAS PERSONALIZADAS.
###############################################################################

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pre-requisitos.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function custom_PageVCRedist
	ClearErrors
	; Para mas informacion, leer el siguiente enlace:
	; https://learn.microsoft.com/es-mx/cpp/windows/redistributing-visual-cpp-files?view=msvc-170
	ReadRegDWORD $tempVar HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" "Installed"

	; No se ha detectado el componente.
	${If} ${Errors}
    ${OrIf} $tempVar != 1
		StrCpy $tempVar ""
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
		StrCpy $tempVar ""
	${EndIf}
FunctionEnd

Function leave_PageVCRedist
	${NSD_GetState} $ampcVCRCheckbox $tempVar

    ${If} $tempVar == ${BST_CHECKED}
        StrCpy $statusVCRuntime "install"
    ${Else}
        StrCpy $statusVCRuntime "skip"
    ${EndIf}

	StrCpy $tempVar ""
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Apache HTTP Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function custom_PageApache
	; Mostrar solo si NO EXISTE instalacion previa.
	${If} $prevInstallAMPc == "none"
		nsDialogs::Create 1018
			Pop $0

			LogText "#####################"
			LogText "# custom_PageApache #"
			LogText "#####################"

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
		LogText "####################"
		LogText "# leave_PageApache #"
		LogText "####################"

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
			LogText "######################"
			LogText "# custom_PageMariadb #"
			LogText "######################"
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
		LogText "#####################"
		LogText "# leave_PageMariaDB #"
		LogText "#####################"
		
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
			LogText $0
			LogText $1
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
	LogText "${PACKAGE_NAME} ${PACKAGE_VERSION}"
	LogText "${COMPILED_STAMP}"

	${If} $prevInstallAMPc == "none"
		; Si es una instalacion nueva, se crea el directorio.
		; El directorio se crea inmediatamente para asegurar que el LOG tenga donde
		; almacenarse y, asi, se registre todo el proceso de instalacion.
		CreateDirectory "$INSTDIR"

		DetailPrint "Creando desinstalador"

	${Else}
		; Si se detecto una instalacion previa, se detienen los servicios de 
		; Apache HTTP y de MariaDB.
		DetailPrint "Instalación previa detectada."
		DetailPrint "Deteniendo servicio Apache HTTP"
		nsExec::ExecToStack /OEM 'net stop Apache2.4'
		Pop $0
		DetailPrint "Deteniendo servicio MariaDB"
		nsExec::ExecToStack /OEM 'net stop MariaDB'
		Pop $0

		DetailPrint "Actualizando desinstalador"

	${EndIf}

	; Se registra el desinstalador.
	WriteUninstaller "$INSTDIR\uninstall-ampc.exe"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "DisplayName" "${PACKAGE_NAME}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "DisplayIcon" "$INSTDIR\uninstall-ampc.exe"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "InstallLocation" "$INSTDIR"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "UninstallString" "$INSTDIR\uninstall-ampc.exe"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "DisplayVersion" "${PACKAGE_VERSION}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "URLInfoAbout" "${PACKAGE_URL}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "URLUpdateInfo" "${PACKAGE_URL_UPDATE}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "HelpLink" "${PACKAGE_URL_HELP}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_UNINST}" "Publisher" "${PACKAGE_PUBLISHER}"

	DetailPrint "Creando acceso directo a web del proyecto"
	WriteIniStr "$INSTDIR\${PACKAGE_NAME}.url" "InternetShortcut" "URL" "${PACKAGE_URL}"

	; Algunos archivos requieren barras invertidas tipo UNIX, mientras que $INSTDIR
	; contiene barras tipo Windows. La variable $backSlashInstDir almacena el valor
	; de $INSTDIR con barras tipo UNIX.
	Push $INSTDIR
	Push "\"
	Call func_ReplaceSlash
	Pop $backSlashInstDir
	LogText $backSlashInstDir

	WriteRegDWORD ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "LangInstall" "$LANGUAGE"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "VersionInstall" "${PACKAGE_VERSION}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "BuildVersion" "${VER_BUILD}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "PathInstall" "$INSTDIR"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Visual C++ Redistributable.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section -sectionVCRedist
	LogText "##############################"
	LogText "# Visual C++ Redistributable #"
	LogText "##############################"

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
		LogText "Visual C++ Redistributable no encontrado."
		
		; Se ofrece al usuario la descarga e instalacion automatica de 
		; Visual C++ Redistributable. Puede rechazar esta accion.
		DetailPrint "$(i18n_VCR_NOTFOUND)"
		MessageBox MB_YESNO "$(i18n_VCR_NOTFOUND) \
		$(i18n_VCR_MBOX_DETAILS1)$\n$\n$(i18n_VCR_MBOX_DETAILS2)" IDYES install IDNO skip

		; El usuario acepta la descarga e instalacion.
		install:
			LogText "Usuario ACEPTA la descarga e instalación de Visual C++ Redistributable."
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
					LogText "No se pudo completar la instalacion: $R1"
					MessageBox MB_OK "No se pudo completar la instalacion del componente debido a un error: $R1" 
					Goto skip
				${EndIf}

				; Si se agota el tiempo de ejecucion al instalar, se notifica al usuario.
				${If} $R0 == "timeout"
					StrCpy $statusVCRuntime "none"
					LogText "No se pudo completar la instalacion: $R1"
					MessageBox MB_OK "Se agoto el tiempo de espera para la instalación: $R1"
					Goto skip
				${EndIf}

				DetailPrint "$(i18n_VCR_SUCCESS)"
				Goto continue

			; El componente no se pudo descargar.
			${Else}
				StrCpy $statusVCRuntime "none"
				DetailPrint "$(i18n_VCR_ERROR) $1"
				LogText "No se pudo completar la descarga: $1"
			${EndIf}

		; Si el usuario rechaza la instalacion u ocurre un error que impide que el
		; componente sea instalado, se notifica al usuario que debe instalar el
		; componente por sus propios medios.
		skip:
			StrCpy $statusVCRuntime "none"
			LogText "Usuario RECHAZA la descarga e instalación de Visual C++ Redistributable."
			MessageBox MB_OK "$(i18n_VCR_SKIP_REMINDER)"
			DetailPrint "$(i18n_VCR_SKIP_REMINDER)"

		continue:
	; Se ha detectado el componente, se omite todo lo anterior.
	${Else}
		StrCpy $statusVCRuntime "done"
		LogText "Visual C++ Redistributable encontrado."
		DetailPrint "$(i18n_VCR_EXIST)"
	${EndIf}
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Apache HTTP Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section "Apache HTTP Server (${VERSION_APACHE})" section_Apache
	LogText "######################"
	LogText "# Apache HTTP Server #"
	LogText "######################"

	SectionIn RO

	StrCpy $pathApache "$INSTDIR\Apache"

	DetailPrint "Instalando Apache HTTP..."

	SetOverwrite ifdiff
		;!include "${DIR_COMPONENTS}\apache\files.nsh" ; Incluye archivos del paquete.
	SetOutPath "$INSTDIR\htdocs"

	SetOverwrite off
		File "${DIR_EXTRAS}\index.html"
		File /oname=favicon.ico ${DIR_EXTRAS}\ampc.ico
	SetOutPath "$pathApache\conf"
		File "${DIR_CONFIG}\httpd.conf"

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

	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionApache" "${VERSION_APACHE}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "pathApache" "$pathApache"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MariaDB Community Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section "MariaDB Community Server (${VERSION_MARIADB})" section_Mariadb
	LogText "############################"
	LogText "# MariaDB Community Server #"
	LogText "############################"

	SectionIn RO

	StrCpy $pathMariadb "$INSTDIR\MariaDB"

	DetailPrint "Instalando MariaDB..."
	SetOverwrite ifdiff
		;!include "${DIR_COMPONENTS}\mariadb\files.nsh" ; Incluye archivos del paquete.

	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionMariadb" "${VERSION_MARIADB}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "pathMariadb" "$pathMariadb"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PHP.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SectionGroup "PHP: Hypertext Preprocessor (${VERSION_PHP})" section_Php
	Section "Núcleo" section_PhpCore
		LogText "#######################"
		LogText "#         PHP         #"
		LogText "#######################"

		SectionIn RO

		StrCpy $pathPhp "$INSTDIR\PHP"

		DetailPrint "Instalando PHP..."
		SetOverwrite ifdiff
		;	!include "${DIR_COMPONENTS}\php\files.nsh" ; Incluye archivos del paquete.

		SetOverwrite off
		SetOutPath "$pathPhp"
			File "${DIR_CONFIG}\php.ini"
		SetOutPath "$INSTDIR\htdocs"
			File "${DIR_EXTRAS}\phpinfo.php"

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

		WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionPhp" "${VERSION_PHP}"
		WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "pathPhp" "$pathPhp"		
	SectionEnd

	Section "cacert.pem para cURL (versión ${VERSION_CACERT})" section_CACERT
		LogText "##############################"
		LogText "#         cacert.pem         #"
		LogText "##############################"

		SectionIn RO

		StrCpy $pathCACERT "$pathPhp\extras\ssl"

		SetOverwrite ifdiff
		SetOutPath "$pathCACERT"
		;	File "${DIR_COMPONENTS}\cacert\cacert.pem"

		WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionCACERT" "${VERSION_CACERT}"
		WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "pathCACERT" "$pathCACERT"
	SectionEnd
SectionGroupEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Describe las secciones declaradas.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Apache} "$(i18n_DESCR_APACHE)" ; Descripcion de seccion.
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Mariadb} "$(i18n_DESCR_MARIADB)" ; Descripcion de seccion..
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Php} "$(i18n_DESCR_PHP)" ; Descripcion de seccion.
	!insertmacro MUI_DESCRIPTION_TEXT ${section_PhpCore} "$(i18n_DESCR_PHP)" ; Descripcion de seccion.
	!insertmacro MUI_DESCRIPTION_TEXT ${section_CACERT} "$(i18n_DESCR_CACERT)" ; Descripcion de seccion.
!insertmacro MUI_FUNCTION_DESCRIPTION_END

###############################################################################
; SECCIONES DESINSTALACION.
###############################################################################

; Al iniciar desinstalacion.
Function un.onInit
	InitPluginsDir

	; Splash al iniciar el desinstalador.
	SetOutPath $PLUGINSDIR
  	File "${DIR_EXTRAS}\splash-uninstall.bmp"
	splash::show 1750 "$PLUGINSDIR\splash-uninstall"
	Pop $0
	Delete "$PLUGINSDIR\splash-uninstall.bmp"

	SetRegView 64
	!insertmacro MUI_UNGETLANGUAGE
	MessageBox MB_ICONINFORMATION|MB_OK "Vas a desinstalar ${PACKAGE_NAME}.$\n$\n \
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
	Delete "$INSTDIR\${PACKAGE_NAME}.url"
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
	MessageBox MB_ICONINFORMATION|MB_OK "La desinstalación de ${PACKAGE_NAME} finalizó correctamente.$\n$\n \
	La carpeta $INSTDIR\htdocs no se ha eliminado."
FunctionEnd