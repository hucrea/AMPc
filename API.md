# API (Draft 1)

El instalador de AMPc crea entradas en el Registro de Windows (regedit). Dichas entradas (y sus respectivas claves y valores) se crean para uso futuro, no siendo utilizadas actualmente.

Su uso previsto es facilitar la actualización de los componentes del entorno, permitiendo que futuras versiones sean capaces de leer los valores de la instalación actual y actúen en concordancia a ellos.

La versión actual de la API es Draft 1, vigente en la versión 0.19.

> [!IMPORTANT]
> **Para compilaciones personalizadas**:
>   1. TODOS los valores bajo el formato ``${AMPC_<valor>}`` DEBEN ser reemplazados por otros.
>   2. Dichos valores NO DEBEN coincidir con alguno de los valores de una instalación típica.
>
> Los valores de estas claves se definen en el código fuente, archivo `Commons.nsh`.

## Entradas registradas

Las entradas se dividen en dos grupos: instalación y desinstalador.

### Desinstalador

La clave de desinstalación es obligatoria para registrar el desinstalador correctamente en Windows y se registra solo información compatible con dicha API.

En el código: `HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\${AMPC_GUID}`

En una instalación típica: `HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\{FB39BDE3-4D2E-4634-BBB0-19B4D0AB5E13}`

### Valores registrados
```
    "DisplayName"       "${PACKAGE}"
	"DisplayIcon"       "$INSTDIR\uninstall-ampc.exe"
	"InstallLocation"   "$INSTDIR"
	"UninstallString"   "$INSTDIR\uninstall-ampc.exe"
	"DisplayVersion"    "${AMPC_VERSION}"
	"URLInfoAbout"      "${AMPC_URL}"
	"URLUpdateInfo"     "${URL_UPDATE}"
	"HelpLink"          "${URL_HELP}"
	"Publisher"         "${AMPC_PUBLISHER}"
```

### Instalación

La clave de instalación es personalizada y registra información de la instalación actual, como rutas de los componentes y versiones instaladas.

Para detectar si una instalación previa existe, el instalador consultará la existencia de esta clave. 

En el código: `HKLM Software\${AMPC_PUBLISHER}\${AMPC_GUID}`

En una instlación típica: `HKLM Software\Hu SpA\{FB39BDE3-4D2E-4634-BBB0-19B4D0AB5E13}`

### Valores registrados
```
	"LangInstall"       "$LANGUAGE"
	"VersionInstall"    "${AMPC_VERSION}"
	"BuildVersion"      "${VER_BUILD}"
	"PathInstall"       "$INSTDIR"

    "versionApache"     "${VERSION_APACHE}"
	"pathApache"        "$pathApache"

    "versionMariadb"    "${VERSION_MARIADB}"
	"pathMariadb"       "$pathMariadb"

    "versionPhp"        "${VERSION_PHP}"
    "pathPhp"           "$pathPhp"

    "versionCACERT"     "${VERSION_CACERT}"
    "pathCACERT"        "$pathCACERT"

    "versionPMA"        "${VERSION_PMA}"
	"pathPMA"           "$pathPMA"

    "versionAdminer"    "${VERSION_ADMINER}"
	"pathAdminer"       "$pathAdminer"
```
