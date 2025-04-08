# AMPc for Windows ``0.19.0-dev``
_AMPc for Windows_ es un paquete WAMP para Windows 10 y Windows 11 de 64 bits. 

Centrado en la instalación y actualización de los componentes del entorno, AMPc no añade capas extras de administración ni servicios ajenos a los del propio entorno.

Nuestra política de actualización sigue, pero no se limita, a la hoja de actualizaciones de PHP.

Inspirado, pero no basado, en AppServ.

## Caracteristicas
Concebido como un proyecto de uso interno, _AMPc for Windows_ está construido sobre NSIS, disponible bajo [Mozilla Public License 2.0](https://www.mozilla.org/en-US/MPL/).

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
_AMPc for Windows_ se actualiza tras cada lanzamiento de PHP (una vez al mes, aproximadamente).

## Componentes incluidos

> [!IMPORTANT]
> La instalación de Apache HTTP, MariaDB, PHP, y CA certificate **no son opcionales**.

| Componente | Versión | Fuente |
|---|:-:|---|
| Apache HTTP Server | ``2.4.63`` | [Apache Lounge](https://www.apachelounge.com/download/) |
| MariaDB Server | ``11.4.5`` | [MariaDB Community](https://mariadb.com/downloads/) |
| PHP | ``8.3.19`` | [PHP for Windows](https://windows.php.net/download/) |
| phpMyAdmin | ``5.2.2`` | [phpMyAdmin](https://www.phpmyadmin.net/) |
| Adminer | ``5.1.1`` | [Adminer](https://www.adminer.org/) |
| CA certificate | ``25-Feb-2025`` | [cURL - CA certificates extracted from Mozilla](https://curl.se/docs/caextract.html) |