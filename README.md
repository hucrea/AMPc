# AMPc for Windows ``0.19.2``
_AMPc for Windows_ es un paquete WAMP para Windows 10 y Windows 11 de 64 bits. 

Centrado en la instalación y actualización de los componentes del entorno, AMPc no añade capas extras de administración ni servicios ajenos a los del propio entorno.

Nuestra política de actualización sigue, pero no se limita, a la hoja de actualizaciones de PHP.

Inspirado, pero no basado, en AppServ.

## Caracteristicas
Concebido como un proyecto de uso interno, _AMPc for Windows_ está construido sobre NSIS, disponible bajo [Mozilla Public License 2.0](https://www.mozilla.org/en-US/MPL/).

> [!NOTE]
> A contar de la versión ``0.19.0``, el código fuente está bajo licencia MPL 2.0.<br />
> La versión ``0.18.1`` corresponde a la última versión disponible bajo los términos de la GNU/GPLv3.

### Configura desde la instalación
Durante la instalación debes configurar:
- *Para Apache HTTP*: nombre del servidor; puerto.
- *Para MariaDB Server*: contraseña para ``root``; puerto.

### Instalación automática de Visual C++ Redistributable
> [!IMPORTANT]
> Este es un pre-requisito para los binarios de Apache HTTP Server y PHP. La comprobación **no es opcional** pero la descarga e instalación del componente si es opcional.

Durante la instalación se verifica que exista  [Visual C++ Redistributable](https://learn.microsoft.com/es-es/cpp/windows/latest-supported-vc-redist?view=msvc-170).

Si no se detecta una instalación existente, se ofrece la opción de:
1. **Descargar e instalar** la última versión desde la web oficial de Microsoft, y luego proseguir con la instalación de _AMPc for Windows_.
2. Continuar con la instalación de _AMPc for Windows_ **sin descargar ni instalar** Visual C++ Redistributable.

Por razones prácticas, **si elije no instalar Visual C++ Redistributable, Apache HTTP no se instalara como servicio** una vez finalizado el asistente de configuración.

### Actualizaciones regulares
_AMPc for Windows_ se actualiza tras cada lanzamiento de PHP (una vez al mes, aproximadamente).

## Componentes incluidos

> [!IMPORTANT]
> La instalación de Apache HTTP, MariaDB, PHP, y CA certificate **no son opcionales**.

| Componente | Versión | Fuente |
|---|:-:|---|
| Apache HTTP Server | ``2.4.63`` | [Apache Lounge Binaries](https://www.apachelounge.com/download/) |
| MariaDB Community Server | ``11.4.7`` | [MariaDB Community Server](https://mariadb.org/download/) |
| PHP | ``8.3.22`` | [PHP for Windows](https://windows.php.net/download/) |
| phpMyAdmin | ``5.2.2`` | [phpMyAdmin](https://www.phpmyadmin.net/) |
| Adminer | ``5.3.0`` | [Adminer](https://www.adminer.org/) |
| CA certificate | ``20-May-2025`` | [cURL - CA certificates extracted from Mozilla](https://curl.se/docs/caextract.html) |