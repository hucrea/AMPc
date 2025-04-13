/*

AMPc for Windows - Entorno web local para Windows
Copyright (C) 2025  Hu SpA ( https://hucreativa.cl )

This file is part of AMPc for Windows.

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------

CommonsConstants.nsh - Constantes comunes entre archivos *.NSI del proyecto.

*/

; Nivel de detalle durante la compilacion.
;!verbose 3
;
; Algoritmo de compresion.
SetCompressor /SOLID /FINAL lzma
;
; Establece marcas de tiempo para la compilacion actual.
;   TIME_STAMP      => Marca numerica formato {anno}{mes}{dia}_{hora}{min}{seg}
;   COMPILE_STAMP   => Marca para utilizar en BrandingText.
!define /date TIME_STAMP    "%Y%m%d_%H%M%S"
!define COMPILED_STAMP      "Compiled at ${__TIME__} on ${__DATE__}"
;
; BUILD - Entorno de la build. Valores: dev|rc|prod.
!define BUILD "dev"
;
; VER_*
;	Versionado de AMPc.
;		VER_MAJOR => Version mayor.
;		VER_MENOR => Version menor.
;		VER_PATCH => Version parche.
;		VER_BUILD => Version de la compilacion.
;
!define VER_MAJOR "0"
!define VER_MENOR "19"
!define VER_PATCH "0"
!define VER_BUILD "${AMPC_VERSION}+${TIME_STAMP}"
;
; VERSION_*
;	Versiones declarada de los componentes incluidos en la compilacion..
;		VERSION_APACHE 	=> Apache HTTP Server.
;		VERSION_MARIADB => MariaDB Community Server.
;		VERSION_PHP 	=> PHP.
;		VERSION_PMA 	=> phpMyAdmin.
;		VERSION_ADMINER => Adminer.
;		VERSION_CACERT 	=> Mozilla CA certificate (version AA.MM.DD).
;       VERSION_LIBCURL => cURL. No implementado.
;
!define VERSION_APACHE  "2.4.63"
!define VERSION_MARIADB "11.4.5"
!define VERSION_PHP     "8.3.20"
!define VERSION_PMA     "5.2.2"
!define VERSION_ADMINER "5.2.1"
!define VERSION_CACERT  "25.02.25"
;!define VERSION_LIBCURL "8.6.0"
;
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
;
; URL_*
;	Direcciones web utilizadas por el paquete.
;		URL_UPDATE		=> Consultar nuevas versiones del paquete.
;		URL_HELP 		=> Ayuda sobre el paquete.
;
!define URL_UPDATE  "${AMPC_URL}/releases"
!define URL_HELP    "${AMPC_URL}/wiki"
;
; REGKEY_*
;	Claves del registro.
;		REGKEY_ROOT 	=> Clave raiz en regedit.
;		REGKEY_PACKAGE 	=> Ruta regedit del instalador.
;		REGKEY_UNINST 	=> Ruta regedit del desinstalador.
;
!define REGKEY_ROOT     "HKLM"
!define REGKEY_PACKAGE  "Software\${AMPC_PUBLISHER}\${AMPC_GUID}"
!define REGKEY_UNINST   "Software\Microsoft\Windows\CurrentVersion\Uninstall\${AMPC_GUID}"

###############################################################################
; PREFERENCIAS DE LA COMPILACION.
###############################################################################
;
; Nombre del paquete.
Name "${PACKAGE}"
;
; Titulo para el paquete.
Caption "${PACKAGE}"
;
; Texto al pie del paquete.
BrandingText "${AMPC_VERSION} - ${COMPILED_STAMP}"
;
; Manifest Windows 10 o superior.
ManifestSupportedOS Win10
;
; Codificacion.
Unicode True
;
; Requiere privilegios de Administrador.
RequestExecutionLevel admin
;
; Informacion de Version.
VIProductVersion "${VER_F_VIP}"
VIAddVersionKey /LANG=0 "FileVersion"       "${VER_F_VIP}"
VIAddVersionKey /LANG=0 "ProductVersion"    "${VER_F_VIP}"
VIAddVersionKey /LANG=0 "ProductName"       "${PACKAGE}"
VIAddVersionKey /LANG=0 "CompanyName"       "${AMPC_PUBLISHER} (${AMPC_PUBLISHER_COUNTRY})"
VIAddVersionKey /LANG=0 "LegalCopyright"    "© 2025 ${AMPC_PUBLISHER} (${AMPC_PUBLISHER_COUNTRY})"