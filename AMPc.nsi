﻿/*

AMPc for Windows - Entorno web local para Windows
Copyright (C) 2025  Hu SpA ( https://hucreativa.cl )

This file is part of AMPc for Windows.

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------

AMPc.nsi - Archivo principal del paquete.

NOTAS:
+ Algunas constantes estan ubicadas en el archivo Commons.nsi y son
 compartidas por otros archivos *.NSI del proyecto.
+ Todos los caracteres especiales se han omitido para mayor compatibilidad.

*/

###############################################################################
; CONSTANTES DEL PAQUETE.
###############################################################################
; PACKAGE - Nombre del paquete a compilar.
!define PACKAGE "AMPc for Windows"
;
; VER_F_VIP - Version apta para VIProductVersion (no cumple SemVer).
!define VER_F_VIP "${AMPC_VERSION}.0"
;
; URL_VCREDIST - URL de descarga para Visual C++ Redistributable.
!define URL_VCREDIST "https://aka.ms/vs/17/release/vc_redist.x64.exe"
;
; Incluye el archivo de constantes compartidas con otros *.NSI del proyecto.
!include "Commons.nsh"

###############################################################################
; DETALLES DE LA COMPILACION ACTUAL.
###############################################################################
; Nombre del instalador EXE compilado.
OutFile "ampc-${VER_BUILD}.exe"
InstallDir "$PROGRAMFILES\AMPc"
;
; Detalles durante la instalacion.
ShowInstDetails hide
;
; Detalles durante la desinstalacion.
ShowUnInstDetails hide
;
; Habilita instalacion en carpeta raiz.
AllowRootDirInstall true
;
; Detalles del paquete (Archivo EXE > Propiedades > Detalles).
VIAddVersionKey /LANG=0 "LegalTrademarks" "${PACKAGE} is a trademark of ${AMPC_PUBLISHER}"
VIAddVersionKey /LANG=0 "FileDescription" "Install ${PACKAGE}"

###############################################################################
; VARIABLES DEL PAQUETE.
###############################################################################

# Generales.
Var statusVCRuntime ; Comprobacion de Visual C++ Redistributable.
Var prevInstallAMPc ; Instalacion previa.
Var backSlashInstDir ; Ver Functions.nsh, funcion func_ReplaceSlash.
# Paginas personalizadas.
Var apache_ConfigServerName ; Apache, custom_PageApache y leave_PageApache.
Var apache_ConfigPort ; Apache, custom_PageApache y leave_PageApache.
Var mariadb_ConfigPass ; MariaDB, custom_PageMariadb y leave_PageMariadb.
Var mariadb_ConfigCheck ; MariaDB, custom_PageMariadb y leave_PageMariadb.
Var mariadb_ConfigPort ; MariaDB, custom_PageMariadb y leave_PageMariadb.
# Rutas
Var path_Apache ; Apache.
Var path_Mariadb ; MariaDB.
Var path_Php ; PHP.
Var path_Cacert ; ca-cert.
Var path_PMA ; phpMyAdmin.
Var path_Adminer ; Adminer.

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
!insertmacro MUI_PAGE_LICENSE "media-src\license.rtf"
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

	; Splash al iniciar el instalador.
	SetOutPath $PLUGINSDIR
  	File "media-src\splash-install.bmp"
	splash::show 1750 "$PLUGINSDIR\splash-install"
	Pop $0
	Delete "$PLUGINSDIR\splash-install.bmp"

	SetOutPath $INSTDIR

	; Verifica que arquitectura del sistema anfitrion sea x64.
	${IfNot} ${RunningX64}
		MessageBox MB_OK|MB_ICONSTOP "$(i18n_32BITS_NOT_SUPPORT).$\n$\n$(i18n_INSTALL_CANT_CONTINUE)"
		Abort

	${EndIf}

	; Evita redirecciones de WOW64 en directorios y registros.
	${DisableX64FSRedirection}
	SetRegView 64

	; Inicializa instalador.
	!insertmacro MUI_LANGDLL_DISPLAY

	# INSTALACION PREVIA
	; Inicializa variables.
	StrCpy $path_Apache 	"unknow"
	StrCpy $path_Mariadb	"unknow"
	StrCpy $path_Php 	"unknow"
	StrCpy $path_Cacert 	"unknow"
	StrCpy $path_PMA 	"unknow"
	StrCpy $path_Adminer "unknow"

	; Verifica si existe alguna instalacion previa.
	ClearErrors
	EnumRegKey $R0 ${REGKEY_ROOT} "${REGKEY_PACKAGE}" 0

	; NO EXISTE instalacion previa.
	${If} ${Errors}
		StrCpy $prevInstallAMPc "none"

		; Establece la ruta de instalacion en la unidad raiz de Windows.
		StrCpy "$INSTDIR" "$WINDIR" 2
		StrCpy "$INSTDIR" "$INSTDIR\AMPc"

	; EXISTE instalacion previa.
	${Else}
		ClearErrors ; Ahora, lee la ruta de la instalacion actual.
		ReadRegStr $R1 ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "PathInstall"

		${IfNot} ${Errors}
			StrCpy "$INSTDIR" "$R1"
			StrCpy $prevInstallAMPc "$R1"

		${Else}
			MessageBox MB_OK|MB_ICONSTOP "$(i18n_PATH_MISSING) INSTDIR_UNKNOW.$\n$\n$(i18n_INSTALL_CANT_CONTINUE)"
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

			LogText "#####################"
			LogText "# custom_PageApache #"
			LogText "#####################"

			!insertmacro MUI_HEADER_TEXT "$(i18n_APACHE_HEADER)" "$(i18n_APACHE_DESCR)"

			${NSD_CreateLabel} 0 0 100% 8u "$(i18n_APACHE_SERVNAME)"
			${NSD_CreateText} 0 12u 80% 12u "localhost"
			Pop $apache_ConfigServerName

			${NSD_CreateLabel} 0 30u 100% 8u "$(i18n_APACHE_PORT)"
			${NSD_CreateNumber} 0 42u 20% 12u "80"
			Pop $apache_ConfigPort

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

		${NSD_GetText} $apache_ConfigServerName $R7
		${NSD_GetText} $apache_ConfigPort $R8

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
			!insertmacro ReplaceInFile "$path_Apache\conf\httpd.conf" "___AMPC_SERVERNAME___" "$R7"
			Pop $0
			LogText $0

			!insertmacro ReplaceInFile "$path_Apache\conf\httpd.conf" "___AMPC_HTTP_PORT___" "$R8"
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
			Pop $mariadb_ConfigPass

			${NSD_CreateLabel} 0 36u 100% 8u "$(i18n_MARIADB_PASSCHECK)"
			${NSD_CreatePassword} 0 48u 80% 12u ""
			Pop $mariadb_ConfigCheck

			${NSD_CreateLabel} 0 72u 100% 8u "$(i18n_MARIADB_PORT)"
			${NSD_CreateNumber} 0 84u 20% 12u "3306"
			Pop $mariadb_ConfigPort

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
		
		${NSD_GetText} $mariadb_ConfigPass $R0
		${NSD_GetText} $mariadb_ConfigCheck $R1
		${NSD_GetText} $mariadb_ConfigPort $R2

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
	LogText "########################################################################################################"
	LogText "########################################################################################################"
	LogText "########################################################################################################"
	LogText "		${PACKAGE}"
	LogText "		${AMPC_VERSION}"
	LogText "		${COMPILED_STAMP}"
	LogText "########################################################################################################"

	${If} $prevInstallAMPc == "none"
		; Si es una instalacion nueva, se crea el directorio.
		; El directorio se crea inmediatamente para asegurar que el LOG tenga donde
		; almacenarse y, asi, se registre todo el proceso de instalacion.
		CreateDirectory "$INSTDIR"

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

	${EndIf}

	DetailPrint "Creando acceso directo a web del proyecto"
	WriteIniStr "$INSTDIR\${PACKAGE}.url" "InternetShortcut" "URL" "${AMPC_URL}"

	; Algunos archivos requieren barras invertidas tipo UNIX, mientras que $INSTDIR
	; contiene barras tipo Windows. La variable $backSlashInstDir almacena el valor
	; de $INSTDIR con barras tipo UNIX.
	Push $INSTDIR
	Call func_ReplaceSlash
	Pop $backSlashInstDir
	LogText $backSlashInstDir

	; Se registran valores de la instalacion actual, para futuras actualizaciones.
	WriteRegDWORD ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "LangInstall" "$LANGUAGE"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "VersionInstall" "${AMPC_VERSION}"
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

	StrCpy $path_Apache "$INSTDIR\Apache"

	DetailPrint "Instalando Apache HTTP..."

	SetOverwrite ifdiff
		!include "bin-src\apache\files.nsh" ; Incluye archivos del paquete.
	SetOutPath "$INSTDIR\htdocs"

	SetOverwrite off
		File "www-src\index.html"
		File /oname=favicon.ico media-src\ampc.ico
	SetOutPath "$INSTDIR\htdocs\cgi-bin"
		File "www-src\printenv.pl"
	SetOutPath "$path_Apache\conf"
		File "config-src\httpd.conf"

	${If} $prevInstallAMPc == "none"
		; Se reemplazan las barras de Windows por barras tipo UNIX en el archivo de
		; configuracion httpd.conf de Apache HTTP.
		!insertmacro ReplaceInFile "$path_Apache\conf\httpd.conf" "___AMPC_PATH___" "$backSlashInstDir"
		Pop $R0
		LogText $R0
	${EndIf}

	; Se registra la version instalada y la ruta de instalacion, para futuras versiones.
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionApache" "${VERSION_APACHE}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "path_Apache" "$path_Apache"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MariaDB Community Server.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section "MariaDB Community Server (${VERSION_MARIADB})" section_Mariadb
	LogText "############################"
	LogText "# MariaDB Community Server #"
	LogText "############################"

	SectionIn RO

	StrCpy $path_Mariadb "$INSTDIR\MariaDB"

	DetailPrint "Instalando MariaDB..."
	SetOverwrite ifdiff
		!include "bin-src\mariadb\files.nsh" ; Incluye archivos del paquete.

	; Se registra la version instalada y la ruta de instalacion, para futuras versiones.
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionMariadb" "${VERSION_MARIADB}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "path_Mariadb" "$path_Mariadb"
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

		StrCpy $path_Php "$INSTDIR\PHP"

		DetailPrint "Instalando PHP..."
		SetOverwrite ifdiff
			!include "bin-src\php\files.nsh" ; Incluye archivos del paquete.

		SetOverwrite off
		SetOutPath "$path_Php"
			File "config-src\php.ini"
		SetOutPath "$INSTDIR\htdocs"
			File "www-src\phpinfo.php"

		${If} $prevInstallAMPc == "none"
			; Se reemplazan las barras de Windows por barras tipo UNIX en el archivo de
			; configuracion php.ini de PHP.
			!insertmacro ReplaceInFile "$path_Php\php.ini" "___AMPC_PATH___" "$backSlashInstDir"
			Pop $R0
			LogText $R0
		${EndIf}

		; Se registra la version instalada y la ruta de instalacion, para futuras versiones.
		WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionPhp" "${VERSION_PHP}"
		WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "path_Php" "$path_Php"		
	SectionEnd

	Section "cacert.pem para cURL (versión ${VERSION_CACERT})" section_CACERT
		LogText "##############################"
		LogText "#         cacert.pem         #"
		LogText "##############################"

		SectionIn RO

		StrCpy $path_Cacert "$path_Php\extras\ssl"

		SetOverwrite ifdiff
		SetOutPath "$path_Cacert"
			File "bin-src\cacert\cacert.pem"

		; Se registra la version instalada y la ruta de instalacion, para futuras versiones.
		WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionCACERT" "${VERSION_CACERT}"
		WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "path_Cacert" "$path_Cacert"
	SectionEnd
SectionGroupEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; phpMyAdmin.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section "phpMyAdmin (${VERSION_PMA})" section_Pma
	LogText "######################"
	LogText "#     phpMyAdmin     #"
	LogText "######################"

	StrCpy $path_PMA "$INSTDIR\htdocs\phpmyadmin"

	DetailPrint "Instalando phpMyAdmin..."
	SetOverwrite ifdiff
		!include "bin-src\phpmyadmin\files.nsh" ; Incluye archivos del paquete.

	; Se registra la version instalada y la ruta de instalacion, para futuras versiones.
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionPMA" "${VERSION_PMA}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "path_PMA" "$path_PMA"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adminer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Section /O "Adminer (${VERSION_ADMINER})" section_Adminer
	LogText "######################"
	LogText "#      Adminer       #"
	LogText "######################"

	StrCpy $path_Adminer "$INSTDIR\htdocs\adminer"

	DetailPrint "Instalando Adminer..."
	SetOverwrite ifdiff
	SetOutPath "$path_Adminer"
		File /oname=index.php bin-src\adminer\adminer-${VERSION_ADMINER}.php
	
	; Se registra la version instalada y la ruta de instalacion, para futuras versiones.
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "versionAdminer" "${VERSION_ADMINER}"
	WriteRegStr ${REGKEY_ROOT} "${REGKEY_PACKAGE}" "path_Adminer" "$path_Adminer"
SectionEnd

Section -uninstaller
	LogText "################ DESINSTALADOR"

	DetailPrint "Creando desinstalador"

	; Se registra el desinstalador.
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
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Describe las secciones declaradas.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Apache} "$(i18n_DESCR_APACHE)" ; DEPRECATED.
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Mariadb} "$(i18n_DESCR_MARIADB)" ; DEPRECATED.
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Php} "$(i18n_DESCR_PHP)" ; DEPRECATED.
	!insertmacro MUI_DESCRIPTION_TEXT ${section_PhpCore} "$(i18n_DESCR_PHP)" ; DEPRECATED.
	!insertmacro MUI_DESCRIPTION_TEXT ${section_CACERT} "cacert.pem" ; DEPRECATED.
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Pma} "$(i18n_DESCR_PMA)"
	!insertmacro MUI_DESCRIPTION_TEXT ${section_Adminer} "$(i18n_DESCR_ADMINER)"
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

	DetailPrint "Eliminando archivos de Apache HTTP"
	RMDir /r /REBOOTOK "$INSTDIR\Apache"

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