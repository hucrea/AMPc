# AMPc for Windows

![GitHub Release](https://img.shields.io/github/v/release/hucrea/AMPc?color=%2523585858&link=https://github.com/hucrea/AMPc/releases/latest)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-blue.svg)](https://opensource.org/licenses/MPL-2.0)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fhucrea%2FAMPc.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fhucrea%2FAMPc?ref=badge_shield)

AMPc 0.19.5 instala un entorno WAMP. Son las iniciales de:

```
A > Apache HTTP Server - 2.4.65
M > MariaDB Community Server - 11.4.8
P > PHP - 8.3.25
c > ca-cert - 12-ago-2025 (25.08.12)
```
Enfocado en una experiencia vanilla:
- Para usuarios avanzados o que no deseen ayuda más allá de la necesaria.
- Carece de paneles de control o servicios ajenos a los propios componentes del entorno.
- Centrado en la instalación mínima, rápida, actualizada, y segura de los componentes.
- Permite actualizar los componentes ya instalados, automatica o manualmente.


## Instalación
Durante la instalación, AMPc comprobará que exista Visual C++ Redistributable, dependencia para Apache y PHP. Si no se encuentra, se ofrece la descarga (desde servidores de Microsoft) e instalación automática de la dependencia: el usuario puede aceptar y continuar con la instalación, o rechazar e instalar por su cuenta la dependencia. Independiente de la elección, la instalación continuará.

> [!IMPORTANT]
> Si se rechaza la descarga e instalación de Visual C++ Redistributable, el servicio Apache2.4 **no se instalará**. Tampoco se ejecutarán los servicios una vez finalice el proceso de instalación, aún cuando la casilla "Ejecutar servicios" esté marcada.

Tras la instalación, un breve asistente te ayudará a configurar:
- Para Apache, el nombre del servidor y el puerto.
- Para MariaDB, la contraseña del usuario root y el puerto.

Una vez finalizado cada asistente, el servicio se instala. Los nombres de cada servicio son onomatopéyicos: Apache2.4 y MariaDB.

Cuando ambos estén listos, la instalación finalizará y se te ofrecerá iniciar los servicios.

## Actualización
AMPc facilita la actualización de los componentes ya instalados. Puedes actualizar manualmente los componentes

Cuando una nueva versión es liberada, puedes descargar la nueva versión y ejecutarla. AMPc detectará la instalación previa, detendrá los servicios, actualizará (opcionalmente, instalará nuevos) componentes, y omitirá los asistentes de instalación.

Una vez finalizada la actualización, se te ofrecerá iniciar los servicios.

### Actualización manual
tldw: AMPc está compilado en base a las versiones ZIP de cada componente. Si puedes conseguir los ZIP de nuevas versiones (consulta la Wiki)

# Licencia

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fhucrea%2FAMPc.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fhucrea%2FAMPc?ref=badge_large)

> [!NOTE]
> Los componentes incluidos en las versiones compiladas se encuentran en https://github.com/hucrea/AMPc-bin

AMPc está disponible bajo Mozilla Public License 2.0.

Las versiones compiladas de AMPc incluye software licenciado bajo otras licencias, citadas en [CREDITS.md](CREDITS.md). Para consultar el código de los componentes distribuidos, dirígase a https://github.com/hucrea/AMPc-bin
