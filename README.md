# AMPc for Windows ``0.18.1``
_AMPc for Windows_ es un paquete WAMP para Windows 10 y Windows 11 de 64 bits. Se diferencia del resto de paquetes WAMP al carecer totalmente de panel de control, centrándose exclusivamente en la instalación y actualización del entorno.

Inspirado, pero no basado, en AppServ.

## Caracteristicas
Concebido como un proyecto de uso interno, _AMPc for Windows_ está construido sobre NSIS, disponible bajo GNU/GPLv3 o posterior.

> [!NOTE]
> A contar de la versión ``0.19.0``, el código estará bajo Mozilla Public License 2.0.<br />
> La versión ``0.18.1`` es la última versión disponible bajo los términos de la GNU/GPLv3.

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

## Componentes incluidos

> [!IMPORTANT]
> La instalación de Apache HTTP, MariaDB, PHP, y CA certificate **no son opcionales**.

| Componente | Versión | Fuente |
|---|:-:|---|
| Apache HTTP Server | ``2.4.63`` | [Apache Lounge](https://www.apachelounge.com/download/) |
| MariaDB Server | ``11.4.5`` | [MariaDB Community](https://mariadb.com/downloads/) |
| PHP | ``8.3.19`` | [PHP for Windows](https://windows.php.net/download/) |
| phpMyAdmin | ``5.2.2`` | [phpMyAdmin](https://www.phpmyadmin.net/) |
| Adminer | ``5.0.5`` | [Adminer](https://www.adminer.org/) |
| CA certificate | ``25-Feb-2025`` | [cURL - CA certificates extracted from Mozilla](https://curl.se/docs/caextract.html) |
