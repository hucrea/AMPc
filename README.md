# AMPc for Windows
![GitHub Release](https://img.shields.io/github/v/release/hucrea/AMPc?color=%2523585858&link=https://github.com/hucrea/AMPc/releases/latest)
> Instalador WAMP mínimo para Windows, con componentes actualizados y sin paneles innecesarios.

## ¿Qué es AMPc?

AMPc es un instalador para entornos de desarrollo WAMP (Windows, Apache, MariaDB, PHP) creado con NSIS.  
Está pensado para desarrolladores que **prefieren controlar sus servicios manualmente**, sin paneles de control que agreguen capas innecesarias o instalen servicios redundantes.

Nació como respuesta a paquetes WAMP sobrecargados, con componentes desactualizados, que añaden servicios para ejecutar servicios.

AMPc ofrece un entorno AMP limpio listo para funcionar, con dos opciones de agregados: phpMyAdmin y Adminer. También CA-CERT para que cURL funcione.

Durante la instalación se verifica que exista Visual C++ Redistributable y se ofrece descargar e instalar el paquete desde los servidores de Microsoft. La descarga es opcional y solo se ofrece se no se detecta Visual C++ Redistributable.

Posterior a la instalación, un breve asistente te ayudará a configurar rapidamente Apache HTTP Server, establecer la contraseña y puerto para MariaDB, y ejecutar ambos servicios.

Con AMPc obtienes:
- **Apache HTTP Server, MariaDB Community Server y PHP actualizados**, listos para usarse.
- Configuración mínima lista para funcionar.
- Instalación rápida, sin servicios ajenos al stack en segundo plano.
- Ideal para quienes **saben dónde están sus archivos de configuración** y prefieren hacer ajustes directos.

## Características principales

- **Sin panel de control:** la configuración se hace al instalar, despues, ya sabes donde están los archivos.
- **Sin extras innecesarios:** no incluye Mercury, Tomcat, Perl, ni FileZilla.
- **Con extras muy necesarios:** puedes instalar phpMyAdmin, Adminer, ambos, o ninguno.
- **Instalación limpia y directa:** elige la carpeta de destino, instala, configura, ejecuta.
- **Política de actualizaciones mensual:** alineado con las actualizaciones mensuales de PHP.

## ¿Por qué AMPc?

Porque a veces solo quieres:
- Instalar el entorno.
- Configurar el resto a mano.
- Tener control total sin intermediarios.
- Actualizar de forma segura los componentes.

> [!IMPORTANT]
> ## AMPc NO fue creado para entornos de producción
> Está específicamente diseñado para entornos de desarrollo. Evite su uso en servidores de producción.

## Instalación

1. Descarga el instalador `.exe` de la [última versión](https://github.com/hucrea/AMPc/releases/latest).
2. Elige el directorio de instalación (por defecto `C:\AMPc`).
3. Instala.
4. El asistente te permitirá la configuración inicial para Apache HTTP Server.
5. Luego, el asistente te pedirá la configuración inicial para MariaDB Server.
6. Listo. Puedes ejecutar ambos servicios o iniciarlos manualmente despues.

## Uso básico

- Configura Apache en `<ruta de instalación>\Apache\conf\httpd.conf`.
- Configura MariaDB en `<ruta de instalación>\MariaDB\data\my.ini`.
- PHP ya está enlazado con Apache (`LoadModule` y `PHPIniDir` configurados).
- Para iniciar o detener servicios, usa:
  ```bash
  Apache2.4 -k start
  MariaDB --console