[README.md](./../README.md) | [Lista de Cambios](./../CHANGELOG.md) | [Lanzamiento Actual](README.md) | [Licencias y Créditos](./../LICENSES.md)
---
# AMPc: lanzamiento actual

> Última actualización: 03 de septiembre de 2025

El lanzamiento actual es ``0.19.5`` y el SHA-256 de la distribución compilada es:

``
69DDBCA633E676FC8C2BAC27782D8268A5D71BAF2A4EBFC9317189638EE61B7E  ampc-0.19.5.exe
``.

## Integridad
Para fines practicos, ``{{version}}`` será utilizado para referirse a la versión actual.

La compilación y firmas de integridad están disponibles en la carpeta que acompaña este README.md, y corresponden a:

``
    ampc-{{version}}.exe            [ Distribución compilada. Archivo omitido por <.gitignore>.]
    ampc-{{version}}.exe.sig        [ Firma PGP para la distribución compilada.]
    ampc-{{version}}.exe.sha256     [ SHA-256 de la distribución compilada.]
    ampc-{{version}}.exe.sha256.sig [ Firma PGP para el SHA-256 de la distribución.]
    public-key.asc                  [ Clave pública PGP para validar firmas.]
``

El contenido de esta carpeta es actualizado cuando se genera una nueva versión, y corresponden a los archivos adjuntados en [las notas de la versión](https://github.com/hucrea/AMPc/releases/latest).

## Componentes
Para obtener una copia de los binarios utilizados en la compilación de esta versión, visita [el repositorio AMPc-bin](https://github.com/hucrea/AMPc-bin).

#### Apache HTTP Server
- **Versión**: 2.4.65
- **Nombre binario**: ``httpd-2.4.65-250724-Win64-VS17.zip``
- **SHA-256 checksum**: ``b6c6d5ad9ec05d7003a0a329b5afee7c638433c84079a315b5d6a50feb9c4e43``
- **Fuente del binario**: https://www.apachelounge.com/download/
- **Dependencia**: VS17

#### MariaDB Community Server
- **Versión**: 11.4.8
- **Nombre binario**: ``mariadb-11.4.8-winx64.zip``
- **SHA-256 checksum**: ``ed86e93157af46317bb49161451c2ec258498a6fa8e68ca821ef1d780d855e6b``
- **Fuente del binario**: https://mariadb.org/download/?t=mariadb&p=mariadb&r=11.4.8&os=windows&cpu=x86_64&pkg=zip&mirror=insacom

#### PHP: Hypertext Preprocessor
- **Versión**: 8.3.25
- **Nombre binario**: ``php-8.3.25-Win32-vs16-x64.zip``
- **SHA-256 checksum**: ``43ef071f4a8faaaade13c32076544f3f1acf491a000f754e73568598af7f3599``
- **Fuente del binario**: https://www.php.net/downloads.php?os=windows&osvariant=windows-downloads&version=8.3&multiversion=Y
- **Dependencia**: VS16

#### ca-cert
- **Versión**: 2025.08.12
- **Nombre binario**: ``cacert.pem``
- **SHA-256 checksum**: ``64dfd5b1026700e0a0a324964749da9adc69ae5e51e899bf16ff47d6fd0e9a5e``
- **Fuente del binario**: https://curl.se/docs/caextract.html

#### phpMyAdmin
``@deprecated 0.19.6``
- **Versión**: 5.2.2
- **Nombre binario**: ``phpMyAdmin-5.2.2-all-languages.zip``
- **SHA-256 checksum**: ``6b99534f72ffb1d7275f50d23ca4141e1495c97d7cadb73a41d6dc580ed5ce29``
- **Fuente del binario**: https://www.phpmyadmin.net/

#### Adminer
``@deprecated 0.19.6``
- **Versión**: 5.3.0
- **Nombre binario**: ``adminer-5.3.0.php``
- **SHA-256 checksum**: ``7dcc196e941b18b74635afe1740dcd86970ab08b8eba0f00f149925aea3972ed``
- **Fuente del binario**: https://www.adminer.org/en/#download