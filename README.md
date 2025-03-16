# AMPc for Windows
_AMPc for Windows_ es un paquete WAMP para Windows 10 y Windows 11 de 64 bits. Se diferencia del resto de paquetes WAMP al carecer totalmente de panel de control, centrándose exclusivamente en la instalación y actualización del entorno.

## Caracteristicas
Concebido como un proyecto de uso interno, _AMPc for Windows_ está construido sobre NSIS, disponible bajo GNU/GPLv3 o posterior.

### Configura desde la instalación
Durante la instalación puedes configurar:
- *Para Apache HTTP*: nombre del servidor; puerto.
- *Para MariaDB Server*: contraseña para ``root``; puerto.

### Instalación automática de Visual C++ Redistributable
Durante la instalación se verifica que exista  [Visual C++ Redistributable](https://learn.microsoft.com/es-es/cpp/windows/latest-supported-vc-redist?view=msvc-170). 

Si no se detecta una instalación existente, se ofrece al usuario la opción de:
1. Descargar e instalar la última versión desde la web oficial de Microsoft, y luego proseguir con la instalación de _AMPc_
2. Continuar con la instalación de _AMPc_ **sin** descargar ni instalar Visual C++ Redistributable.

Por razones prácticas, si el usuario elije no instalar el componente, Apache HTTP **no se iniciará** y se advertirá al usuario de ello.

### Actualizaciones regulares
_AMPc for Windows_ se actualiza regularmente para incluir las últimas versiones del entorno.

## Caracteristicas
- Asistente de instalación para configuración rápida del entorno local.
- Verifica que los pre-requisitos de Apache HTTP y PHP se encuentren instalados.
- Sin panel de control, cada componente se administra nativamente.
- Paquete actualizado mensualmente para disponer de las últimas versiones de cada componente.

Inspirado, pero no basado, en AppServ.

## Componentes incluidos

> [!IMPORTANT]
> La instalación de Apache HTTP, MariaDB, PHP, y CA certificate **no son opcionales**.

| Componente | Versión | Fuente |
|---|:-:|---|
| Apache HTTP Server | ``2.4.63`` | [Apache Lounge](https://www.apachelounge.com/download/) |
| MariaDB Server | ``11.4.5`` | [MariaDB Community](https://mariadb.com/downloads/) |
| PHP | ``8.3.17`` | [PHP for Windows](https://windows.php.net/download/) |
| phpMyAdmin | ``5.2.2`` | [phpMyAdmin](https://www.phpmyadmin.net/) |
| Adminer | ``4.17.1`` | [Adminer](https://www.adminer.org/) |
| CA certificate | ``25-Feb-2025`` | [cURL - CA certificates extracted from Mozilla](https://curl.se/docs/caextract.html) |