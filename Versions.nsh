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

; VER_*
;	Versionado de AMPc.
;		VER_MAJOR => Version mayor, anno.
;		VER_MENOR => Version menor.
;		VER_PATCH => Version parche.
;		VER_BUILD => Fecha de compilacion.
!define VER_MAJOR "26"
!define VER_MENOR "1"
!define VER_PATCH "0"
!define /date VER_BUILD "%y%m%d%H%M%S"

; VERSION_*
;	Versiones declarada de los componentes incluidos en la compilacion..
;		VERSION_APACHE 	=> Apache HTTP Server, build ApacheLounge.
;		VERSION_MARIADB => MariaDB Community Server, build oficial.
;		VERSION_PHP 	=> PHP, build oficial.
;		VERSION_CACERT 	=> Mozilla CA certificate (version AA.MM.DD).
!define VERSION_APACHE  "2.4.66"
!define VERSION_MARIADB "11.4.10"
!define VERSION_PHP     "8.4.19"
!define VERSION_CACERT  "26.02.11"