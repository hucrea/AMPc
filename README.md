[README.md](README.md) | [Lista de Cambios](CHANGELOG.md) | [Lanzamiento Actual](release/README.md) | [Licencias y Créditos](LICENSES.md)
---
# AMPc for Windows [``0.19.5``](CHANGELOG.md)

![GitHub Release](https://img.shields.io/github/v/release/hucrea/AMPc?color=white&link=https://github.com/hucrea/AMPc/releases/latest)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-blue.svg)](https://opensource.org/licenses/MPL-2.0)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fhucrea%2FAMPc.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fhucrea%2FAMPc?ref=badge_shield)

AMPc es una distribución WAMP. Son las iniciales de:

```
    A > Apache HTTP Server
    M > MariaDB Community Server
    P > PHP
    c > ca-cert
```

Es una alternativa a [XAMPP](https://www.apachefriends.org/es/index.html), [AppServ](https://www.appserv.org/en/), [Ampps](https://ampps.com/), [Wamp](https://www.wampserver.com/en/download-wampserver-64bits/), y similares.

Está centrada en [desplegar](#instalación) y [actualizar](#actualización-de-componentes) los [componentes del entorno](release/README.md), dejando la configuración de cada componente en los manos del usuario. Posee una [Política de Actualizaciones](#política-de-actualizaciones) clara, descrita más abajo.

## Instalación
Durante la instalación, AMPc comprobará que exista Visual C++ Redistributable, dependencia para Apache y PHP. Si no se encuentra, se ofrece la descarga (desde servidores de Microsoft) e instalación automática de la dependencia: el usuario puede aceptar y continuar con la instalación, o rechazar e instalar por su cuenta la dependencia. Independiente de la elección, la instalación continuará.

> [!IMPORTANT]
> Si se rechaza la descarga e instalación de Visual C++ Redistributable, el servicio Apache2.4 **no se instalará**. Tampoco se ejecutarán los servicios una vez finalice el proceso de instalación, aún cuando la casilla "Ejecutar servicios" esté marcada.

Tras la instalación, un breve asistente te ayudará a configurar:
- Para Apache, el nombre del servidor y el puerto.
- Para MariaDB, la contraseña del usuario root y el puerto.

Una vez finalizado cada asistente, el servicio se instala. Los nombres de cada servicio son onomatopéyicos: Apache2.4 y MariaDB.

Cuando ambos estén listos, la instalación finalizará y se te ofrecerá iniciar los servicios.

## Actualización de componentes
### Instalación previa detectada
AMPc facilita la actualización de los componentes ya instalados.

Cuando una nueva versión es liberada, puedes descargar la nueva versión y ejecutarla. AMPc detectará la instalación previa, detendrá los servicios, actualizará (opcionalmente, instalará nuevos) componentes, y omitirá los asistentes de instalación.

Una vez finalizada la actualización, se te ofrecerá iniciar los servicios.

### Actualización manual
AMPc está compilado en base a las versiones ZIP de cada componente, y fue construido con la idea de permitir que cada componente sea actualizado en base a su versión ZIP.

Si bien las distribuciones actuales no cuentan con una API formal, el actual borrador del API 2 cuenta con una definición formal para actualizaciones manuales.

## Política de Actualizaciones
AMPc sigue el ciclo de lanzamientos de PHP. Las compilaciones tipo ``<parche>`` son lanzadas mensualmente, a no más de 15 días posteriores al lanzamiento de una nueva versión parche de PHP.

Las ramas actuales soportadas son:

| Componente | Rama     | EOL en AMPc | Siguiente rama  |
| ----       | :---:    | :---:       | :---:           |
| Apache     | ``2.4``  | n/d         | n/d             |
| MariaDB    | ``11.4`` | dic 2027    | por definir     |
| PHP        | ``8.3``  | dic 2025    | ``8.4``         |

La rama de PHP soportada es la anterior a la última publicada. Para la versión actual de AMPc esta es ``8.3.x``.

### Diciembre 2025: cambio de SemVer a CalVer
Iniciando con la publicación de la actualización de diciembre de 2025, se comenzará a utilizar el formato CalVer para versionar la distribución, estilo ``<YY>.<RELEASE>.<PATCH>.<API_LEVEL>``.

Esto permitirá ser más precisos al momento de comunicar cambios mediante la numeración de la versión:

```
    <YY>        : Año de la versión.
                  Cambios nivel <MAJOR> en los componentes (ej, cambio de ramas soportadas).

    <RELEASE>   : Lanzamiento destacable del año.
                  Unifica <MAJOR> y <MINOR>, que para efectos de la distribución, son casi lo mismo.
                  Su valor se restablece a 0 cuando <YY> aumenta.
                  Incrementar o restablecer este valor, restablece <PATCH> a 0.

    <PATCH>     : Versión parche, comienza en 0 y se incrementa con cada lanzamiento parche.
                  Se restablece a 0 cuando <YY> aumenta.
                  Cuando <RELEASE> aumenta o es restablecido, su valor también se restablece a 0.

    <API_LEVEL> : Versión del API.
                  No se restablece, solo incrementa.
                  Útil solo para uso del API, de cara al usuario es irrelevante y puede ser omitido.
```

La última versión bajo SemVer será la ``0.19.8``, que además será la última versión con la rama  ``8.3``.

# Licencia: MPL 2.0
AMPc está disponible bajo Mozilla Public License 2.0.

```
SPDXVersion: SPDX-2.3
DataLicense: CC0-1.0
SPDXID: SPDXRef-DOCUMENT
Name: AMPc-for-Windows
DocumentNamespace: https://github.com/hucrea/AMPc
Creator: Tool: manual
PackageName: AMPc for Windows
SPDXID: SPDXRef-Package
PackageDownloadLocation: https://github.com/hucrea/AMPc
FilesAnalyzed: false
PackageLicenseConcluded: MPL-2.0
PackageLicenseDeclared: MPL-2.0
PackageCopyrightText: Copyright © 2025 Hu SpA
```

Las versiones compiladas de AMPc incluye software licenciado bajo otras licencias, citadas en [LICENSES.md](LICENSES.md). Para consultar el código de los componentes distribuidos, dirígase a https://github.com/hucrea/AMPc-bin
