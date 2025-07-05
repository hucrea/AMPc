# AMPc

> Instalador WAMP minimalista para Windows, inspirado en AppServ pero con componentes actualizados y sin paneles innecesarios.

## 🚀 ¿Qué es AMPc?

AMPc es un instalador para entornos de desarrollo WAMP (Windows, Apache, MariaDB, PHP) creado con NSIS.  
Está pensado para desarrolladores que **prefieren controlar sus servicios manualmente**, sin paneles de control que agreguen capas innecesarias o instalen servicios que jamás usarás.

Nació como respuesta a:
- XAMPP: sobrecargado, con componentes desactualizados y un panel que oculta la configuración real.
- AppServ: limpio, pero abandonado, con políticas de actualización dudosas.

Con AMPc tienes:
- **Apache, MariaDB y PHP actualizados**, listos para usarse.
- Configuración mínima lista para funcionar (rutas absolutas en `httpd.conf` y `my.ini`).
- Instalación rápida, sin scripts extraños ni servicios corriendo en segundo plano.
- Ideal para quienes **saben dónde están sus archivos de configuración** y prefieren hacer ajustes directos.

---

## 🔍 Características principales

- **Sin panel de control:** maneja Apache y MariaDB por consola o por servicios directos, como siempre.
- **Sin bloat:** no incluye Mercury, Tomcat, Perl, ni FileZilla.
- **Instalación limpia y directa:** elige la carpeta de destino y listo.
- **Fácil de desinstalar:** borra la carpeta y se acabó; no deja basura en el registro ni demonios ocultos.
- **Política de actualizaciones mensual:** versiones estables de PHP, MariaDB y Apache alineadas con sus lanzamientos.

---

## 📝 ¿Por qué AMPc?

Porque a veces solo quieres:
- Instalar el stack.
- Configurar un `vhost` o el `my.ini` a mano.
- Tener control total sin intermediarios.
- Y olvidarte de actualizaciones rotas.

AMPc fue creado para entornos de desarrollo donde:
- No necesitas interfaces gráficas para iniciar/parar servicios.
- Te interesa que sea **portable**, fácil de borrar, y fácil de actualizar por componentes.

---

## 🚀 Instalación

1. Descarga el instalador `.exe` desde la sección [Releases](https://github.com/hucrea/AMPc/releases).
2. Elige el directorio de instalación (por defecto `C:\AMPc`).
3. Al finalizar, el instalador abre tu navegador en `http://localhost/`.

---

## 💻 Uso básico

- Configura Apache en `AMPc\Apache24\conf\httpd.conf`.
- Configura MariaDB en `AMPc\MariaDB\my.ini`.
- PHP ya está enlazado con Apache (`LoadModule` y `PHPIniDir` configurados).
- Para iniciar o detener servicios, usa:
  ```bash
  httpd -k start
  mysqld --console