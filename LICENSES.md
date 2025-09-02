# Licencias y Créditos

Este documento lista todos los componentes de terceros incluidos en AMPc for Windows.

## Componentes Principales

### Apache HTTP Server
- **Licencia**: Apache-2.0
- **URL de Licencia**: https://www.apache.org/licenses/LICENSE-2.0
- **Origen**: https://httpd.apache.org/
- **Repositorio**: https://github.com/apache/httpd
- **Copyright**: Copyright © The Apache Software Foundation
- **SPDX-License-Identifier**: Apache-2.0

### MariaDB Community Server
- **Licencia**: GPL-2.0
- **URL de Licencia**: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
- **Origen**: https://mariadb.org/
- **Repositorio**: https://github.com/MariaDB/server
- **Copyright**: Copyright © MariaDB Foundation
- **SPDX-License-Identifier**: GPL-2.0-only

### PHP: Hypertext Preprocessor
- **Licencia**: PHP-3.01
- **URL de Licencia**: https://www.php.net/license/3_01.txt
- **Origen**: https://www.php.net/
- **Repositorio**: https://github.com/php/php-src
- **Copyright**: Copyright © The PHP Group
- **SPDX-License-Identifier**: PHP-3.01

### Certificados CA
- **Licencia**: MPL-2.0
- **URL de Licencia**: https://mozilla.org/MPL/2.0/
- **Origen**: https://curl.se/ca/
- **Repositorio**: https://hg.mozilla.org/mozilla-central/file/tip/security/nss/lib/ckfw/builtins
- **Copyright**: Copyright © Mozilla Foundation
- **SPDX-License-Identifier**: MPL-2.0

## Componentes Opcionales

### phpMyAdmin
- **Licencia**: GPL-2.0
- **URL de Licencia**: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
- **Origen**: https://www.phpmyadmin.net/
- **Repositorio**: https://github.com/phpmyadmin/phpmyadmin
- **Copyright**: Copyright © The phpMyAdmin Team
- **SPDX-License-Identifier**: GPL-2.0-or-later

### Adminer
- **Licencia**: Apache-2.0 O GPL-2.0
- **URL de Licencia**: https://www.apache.org/licenses/LICENSE-2.0
- **URL de Licencia Alternativa**: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
- **Origen**: https://www.adminer.org/
- **Repositorio**: https://github.com/vrana/adminer
- **Copyright**: Copyright © Jakub Vrána
- **SPDX-License-Identifier**: Apache-2.0 OR GPL-2.0-only

## Dependencias de Ejecución

### Microsoft Visual C++ Redistributable
- **Versión**: Más reciente (se descarga durante la instalación)
- **Licencia**: Términos de Licencia de Software de Microsoft
- **URL de Licencia**: https://visualstudio.microsoft.com/license-terms/
- **Origen**: https://docs.microsoft.com/cpp/windows/redistributing-visual-cpp-files
- **Copyright**: Copyright © Microsoft Corporation
- **SPDX-License-Identifier**: LicenseRef-Microsoft-Visual-Studio

## Herramientas de Compilación

### NSIS (Nullsoft Scriptable Install System)
- **Licencia**: Zlib
- **URL de Licencia**: https://opensource.org/licenses/Zlib
- **Origen**: https://nsis.sourceforge.io/
- **Repositorio**: https://github.com/kichik/nsis
- **Copyright**: Copyright © Nullsoft and Contributors
- **SPDX-License-Identifier**: Zlib
- **Uso**: Solo en tiempo de compilación (creación del instalador)

## Cumplimiento de Licencias

### Componentes GPL
Los siguientes componentes están licenciados bajo GPL:
- MariaDB Community Server (GPL-2.0)
- phpMyAdmin (GPL-2.0-or-later)

El código fuente de estos componentes está disponible en sus respectivos repositorios enlazados arriba.

### Componentes con Licencia Dual
- **Adminer**: Disponible bajo Apache-2.0 O GPL-2.0 (distribuimos bajo Apache-2.0)

### Componentes Modificados
AMPc for Windows incluye archivos de configuración personalizados para algunos componentes, pero no modifica el código fuente de ningún componente de terceros.

De cualquier forma, los componentes distribuidos se encuentran en el respositorio https://github.com/hucrea/AMPc-bin bajo el mismo versionamiento.

## Documento SPDX
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

## Contacto

Para consultas sobre licencias o cumplimiento normativo:
- **Repositorio**: https://github.com/hucrea/AMPc
- **Issues**: https://github.com/hucrea/AMPc/issues
- **Email**: legal@hucreativa.cl

---

**Última Actualización**: Septiembre 2025  
**Versión del Documento**: 1.0