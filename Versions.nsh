/*

AMPc for Windows - Entorno web local para Windows 10 y Windows 11
Copyright (C) 2025-2026  Hu SpA ( https://hucreativa.cl )

This file is part of AMPc for Windows.

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------

Versions.nsh - Archivo de versiones del paquete.

NOTAS: 
	- Todos los caracteres especiales se han omitido para mayor compatibilidad.

*/
;
; VER_*
;	Versionado de AMPc.
;		VER_MAJOR => Version mayor.
;		VER_MENOR => Version menor.
;		VER_PATCH => Version parche.
!define VER_MAJOR "0"
!define VER_MENOR "19"
!define VER_PATCH "6"
!define /date VER_BUILD "%Y%m%d%H%M%S"

; VERSION_*
;	Versiones declarada de los componentes incluidos en la compilacion..
;		VERSION_APACHE 	=> Apache HTTP Server.
;		VERSION_MARIADB => MariaDB Community Server.
;		VERSION_PHP 	=> PHP.
;		VERSION_PMA 	=> phpMyAdmin.
;		VERSION_ADMINER => Adminer.
;		VERSION_CACERT 	=> Mozilla CA certificate (version AA.MM.DD).
!define VERSION_APACHE  "2.4.65"
!define VERSION_MARIADB "11.4.8"
!define VERSION_PHP     "8.3.25"
!define VERSION_PMA     "5.2.2"
!define VERSION_ADMINER "5.3.0"
!define VERSION_CACERT  "25.08.12"