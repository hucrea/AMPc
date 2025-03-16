/*

AMPc for Windows - Entorno web local para Windows
Copyright (C) 2025  Hu SpA ( https://hucreativa.cl )

This file is part of AMPc for Windows.

AMPc for Windows is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by 
the Free Software Foundation, either version 3 of the License, or 
(at your option) any later version.

AMPc for Windows is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
for more details.

You should have received a copy of the GNU General Public License along 
with AMPc for Windows. If not, see <https://www.gnu.org/licenses/>. 

-------------------------------------------------------------------------------

LangString.nsh - Archivo de strings traducidos.

IMPORTANTE:
Lea las siguientes notas antes de comenzar a traducir:
+ Todos los string de traduccion deben comenzar con i18n_ y continuar con 
  letras MAYUSCULA (ver mas abajo para ejemplos), a fin de facilitar su rapida
  identificacion dentro del codigo.
+ El nombre del string debe ser descriptivo y breve.
+ Los string siguientes son para copiar, pegar, y reemplazar los textos, a 
  falta de un sistema mejor para las traducciones.

; Inicio de string para traduccion.
LangString i18n_KEYWORD ${LANG_SPANISH} "El texto"
LangString i18n_KEYWORD ${LANG_ENGLISH} "The text"
LangString i18n_KEYWORD ${LANG_PORTUGUESEBR} "O texto"
; Fin de string para traduccion.

*/

; on.Init

LangString i18n_FINISHPAGE_RUN ${LANG_SPANISH} "Iniciar servicios Apache HTTP y MariaDB."
LangString i18n_FINISHPAGE_RUN ${LANG_ENGLISH} "Start Apache HTTP and MariaDB services"
LangString i18n_FINISHPAGE_RUN ${LANG_PORTUGUESEBR} "Iniciar os serviços Apache HTTP e MariaDB."

LangString i18n_APACHE_HEADER ${LANG_SPANISH} "Configuración inicial para Apache HTTP"
LangString i18n_APACHE_HEADER ${LANG_ENGLISH} "Initial configuration for Apache HTTP"
LangString i18n_APACHE_HEADER ${LANG_PORTUGUESEBR} "Configuração inicial do Apache HTTP"

LangString i18n_APACHE_DESCR ${LANG_SPANISH} "Establece los parámetros iniciales para el servicio Apache HTTP Server."
LangString i18n_APACHE_DESCR ${LANG_ENGLISH} "Sets the initial parameters for the Apache HTTP Server service."
LangString i18n_APACHE_DESCR ${LANG_PORTUGUESEBR} "Define os parâmetros iniciais do serviço Apache HTTP Server."

LangString i18n_APACHE_SERVNAME ${LANG_SPANISH} "Nombre del Servidor (por defecto, localhost)"
LangString i18n_APACHE_SERVNAME ${LANG_ENGLISH} "Server name (by default, localhost)"
LangString i18n_APACHE_SERVNAME ${LANG_PORTUGUESEBR} "Nome do servidor (padrão, localhost)"

LangString i18n_APACHE_PORT ${LANG_SPANISH} "Puerto HTTP para Apache (por defecto, puerto 80)"
LangString i18n_APACHE_PORT ${LANG_ENGLISH} "HTTP port for Apache (by default, port 80)"
LangString i18n_APACHE_PORT ${LANG_PORTUGUESEBR} "Porta HTTP para o Apache (padrão, 80)"

LangString i18n_APACHE_EMPTY_SERVNAME ${LANG_SPANISH} "Debes establecer un Nombre del Servidor."
LangString i18n_APACHE_EMPTY_SERVNAME ${LANG_ENGLISH} "You must set a Server Name."
LangString i18n_APACHE_EMPTY_SERVNAME ${LANG_PORTUGUESEBR} "Você deve definir um Nome de Servidor."

LangString i18n_APACHE_EMPTY_PORT ${LANG_SPANISH} "Debes establecer un puerto para Apache HTTP."
LangString i18n_APACHE_EMPTY_PORT ${LANG_ENGLISH} "You must set a port for Apache HTTP."
LangString i18n_APACHE_EMPTY_PORT ${LANG_PORTUGUESEBR} "Você deve definir uma porta para o Apache HTTP."

LangString i18n_CONFIG_NOTBACK ${LANG_SPANISH} "Una vez presiones «Siguiente», no podrás regresar a esta pantalla."
LangString i18n_CONFIG_NOTBACK ${LANG_ENGLISH} "Once you press «Next», you will not be able to return to this screen."
LangString i18n_CONFIG_NOTBACK ${LANG_PORTUGUESEBR} "Depois de pressionar «Next», não será possível retornar a essa tela."

LangString i18n_MARIADB_HEADER ${LANG_SPANISH} "Contraseña para MariaDB"
LangString i18n_MARIADB_HEADER ${LANG_ENGLISH} "Password for MariaDB"
LangString i18n_MARIADB_HEADER ${LANG_PORTUGUESEBR} "Senha para MariaDB"

LangString i18n_MARIADB_DESCR ${LANG_SPANISH} "Establece la contraseña para la cuenta «root» de MariaDB."
LangString i18n_MARIADB_DESCR ${LANG_ENGLISH} "Set the password for the MariaDB «root» account."
LangString i18n_MARIADB_DESCR ${LANG_PORTUGUESEBR} "Defina a senha para a conta «root» do MariaDB."

LangString i18n_MARIADB_PASS ${LANG_SPANISH} "Ingresa una contraseña para la cuenta «root»"
LangString i18n_MARIADB_PASS ${LANG_ENGLISH} "Enter a password for the «root» account"
LangString i18n_MARIADB_PASS ${LANG_PORTUGUESEBR} "Digite uma senha para a conta «root»"

LangString i18n_MARIADB_PASSCHECK ${LANG_SPANISH} "Confirma la contraseña creada para «root»"
LangString i18n_MARIADB_PASSCHECK ${LANG_ENGLISH} "Confirm the password created for «root»"
LangString i18n_MARIADB_PASSCHECK ${LANG_PORTUGUESEBR} "Confirmar a senha criada para o «root»"

LangString i18n_MARIADB_PORT ${LANG_SPANISH} "Puerto HTTP para MariaDB (por defecto, puerto 3306)"
LangString i18n_MARIADB_PORT ${LANG_ENGLISH} "HTTP port for MariaDB (by default, port 3306)"
LangString i18n_MARIADB_PORT ${LANG_PORTUGUESEBR} "Porta HTTP para o MariaDB (padrão, 3306)"

LangString i18n_MARIADB_NOTCHECK ${LANG_SPANISH} "Las contraseñas ingresadas no coinciden."
LangString i18n_MARIADB_NOTCHECK ${LANG_ENGLISH} "The passwords entered do not match."
LangString i18n_MARIADB_NOTCHECK ${LANG_PORTUGUESEBR} "As senhas inseridas não correspondem."

LangString i18n_MARIADB_EMPTY_PORT ${LANG_SPANISH} "Debes establecer un puerto para MariaDB."
LangString i18n_MARIADB_EMPTY_PORT ${LANG_ENGLISH} "You must set a port for MariaDB."
LangString i18n_MARIADB_EMPTY_PORT ${LANG_PORTUGUESEBR} "Você deve definir uma porta para o MariaDB."

LangString i18n_MARIADB_PASSEMPTY ${LANG_SPANISH} "No puedes dejar la contraseña en blanco para la cuenta «root»."
LangString i18n_MARIADB_PASSEMPTY ${LANG_ENGLISH} "You cannot leave the password blank for the «root» account."
LangString i18n_MARIADB_PASSEMPTY ${LANG_PORTUGUESEBR} "Você não pode deixar a senha em branco para a conta «root»."

LangString i18n_VCR_DOWNLOAD_REMINDER ${LANG_SPANISH} "Visite la web de Microsoft para descargar la última versión disponible."
LangString i18n_VCR_DOWNLOAD_REMINDER ${LANG_ENGLISH} "Visit the Microsoft website to download the latest version available."
LangString i18n_VCR_DOWNLOAD_REMINDER ${LANG_PORTUGUESEBR} "Visite o site da Microsoft para fazer o download da versão mais recente disponível."

LangString i18n_VCR_APACHE_LEAVE ${LANG_SPANISH} "La configuración para Apache HTTP Server se ha guardado, pero el servicio no se instalará ni tampoco se podrá ejecutar hasta que Visual C++ Redistributable sea instalado."
LangString i18n_VCR_APACHE_LEAVE ${LANG_ENGLISH} "The configuration for Apache HTTP Server has been saved, but the service will not be installed and cannot run until Visual C++ Redistributable is installed."
LangString i18n_VCR_APACHE_LEAVE ${LANG_PORTUGUESEBR} "A configuração do Apache HTTP Server foi salva, mas o serviço não será instalado e não poderá ser executado até que o Visual C++ Redistributable seja instalado."

LangString i18n_VCR_NOTFOUND ${LANG_SPANISH} "No se encuentra Visual C++ Redistributable."
LangString i18n_VCR_NOTFOUND ${LANG_ENGLISH} "Visual C++ Redistributable is not found."
LangString i18n_VCR_NOTFOUND ${LANG_PORTUGUESEBR} "O Visual C++ Redistributable não foi encontrado."

LangString i18n_VCR_MBOX_DETAILS1 ${LANG_SPANISH} "Para ejecutar Apache HTTP Server y PHP se necesita que Visual C++ Redistributable esté instalado."
LangString i18n_VCR_MBOX_DETAILS1 ${LANG_ENGLISH} "To run Apache HTTP Server and PHP, Visual C++ Redistributable must be installed."
LangString i18n_VCR_MBOX_DETAILS1 ${LANG_PORTUGUESEBR} "Para executar Apache HTTP Server e PHP, é necessário instalar Visual C++ Redistributable."

LangString i18n_VCR_MBOX_DETAILS2 ${LANG_SPANISH} "¿Deseas que AMPc descargue e instale la última versión? La descarga se realiza desde los servidores oficiales de Microsoft."
LangString i18n_VCR_MBOX_DETAILS2 ${LANG_ENGLISH} "Do you want AMPc to download and install the latest version? The download is done from Microsoft's official servers."
LangString i18n_VCR_MBOX_DETAILS2 ${LANG_PORTUGUESEBR} "Deseja que o AMPc faça o download e instale a versão mais recente? O download é feito a partir dos servidores oficiais da Microsoft."

LangString i18n_VCR_INSTALLING ${LANG_SPANISH} "Instalando Visual C++ Redistributable."
LangString i18n_VCR_INSTALLING ${LANG_ENGLISH} "Installing Visual C++ Redistributable."
LangString i18n_VCR_INSTALLING ${LANG_PORTUGUESEBR} "Instalação do Visual C++ Redistributable."

LangString i18n_VCR_DOWNLOADING ${LANG_SPANISH} "Descargando última versión de Visual C++ Redistributable."
LangString i18n_VCR_DOWNLOADING ${LANG_ENGLISH} "Downloading the latest version of Visual C++ Redistributable."
LangString i18n_VCR_DOWNLOADING ${LANG_PORTUGUESEBR} "Download da versão mais recente do Visual C++ Redistributable."

LangString i18n_VCR_SUCCESS ${LANG_SPANISH} "Visual C++ Redistributable instalado correctamente."
LangString i18n_VCR_SUCCESS ${LANG_ENGLISH} "Visual C++ Redistributable installed correctly."
LangString i18n_VCR_SUCCESS ${LANG_PORTUGUESEBR} "Visual C++ Redistributable instalado corretamente."

LangString i18n_VCR_ERROR ${LANG_SPANISH} "La descarga no se ha podido completar:"
LangString i18n_VCR_ERROR ${LANG_ENGLISH} "The download could not be completed:"
LangString i18n_VCR_ERROR ${LANG_PORTUGUESEBR} "O download não pôde ser concluído:"

LangString i18n_VCR_SKIP_REMINDER ${LANG_SPANISH} "Visual C++ Redistributable es requisito de Apache y PHP y deberá instalarlo por otros medios para ejecutar correctamente ambos componentes."
LangString i18n_VCR_SKIP_REMINDER ${LANG_ENGLISH} "Visual C++ Redistributable is required by Apache and PHP and must be installed by other means to properly run both components."
LangString i18n_VCR_SKIP_REMINDER ${LANG_PORTUGUESEBR} "O Visual C++ Redistributable é exigido pelo Apache e pelo PHP e deve ser instalado por outros meios para executar os dois componentes corretamente."

LangString i18n_VCR_EXIST ${LANG_SPANISH} "Visual C++ Redistributable encontrado, instalación omitida."
LangString i18n_VCR_EXIST ${LANG_ENGLISH} "Visual C++ Redistributable found, installation skipped."
LangString i18n_VCR_EXIST ${LANG_PORTUGUESEBR} "Visual C++ Redistributable encontrado, instalação ignorada."

LangString i18n_32BITS_NOTSUPPORT ${LANG_SPANISH} "AMPc no es compatible con Windows de 32 bits."
LangString i18n_32BITS_NOTSUPPORT ${LANG_ENGLISH} "AMPc is not compatible with 32-bit Windows."
LangString i18n_32BITS_NOTSUPPORT ${LANG_PORTUGUESEBR} "AMPc não é compatível com Windows do 32 bits."

LangString i18n_INSTALL_CANNOT ${LANG_SPANISH} "La instalación no puede continuar."
LangString i18n_INSTALL_CANNOT ${LANG_ENGLISH} "The installation cannot continue."
LangString i18n_INSTALL_CANNOT ${LANG_PORTUGUESEBR} "A instalação não pode continuar."

LangString i18n_DESCR_APACHE ${LANG_SPANISH} "Servidor web local"
LangString i18n_DESCR_APACHE ${LANG_ENGLISH} "Local web server"
LangString i18n_DESCR_APACHE ${LANG_PORTUGUESEBR} "Servidor da Web local"

LangString i18n_DESCR_MARIADB ${LANG_SPANISH} "Servidor de Base de Datos"
LangString i18n_DESCR_MARIADB ${LANG_ENGLISH} "Database Server"
LangString i18n_DESCR_MARIADB ${LANG_PORTUGUESEBR} "Servidor de banco de dados"

LangString i18n_DESCR_PHP ${LANG_SPANISH} "Lenguaje de script"
LangString i18n_DESCR_PHP ${LANG_ENGLISH} "Scripting language"
LangString i18n_DESCR_PHP ${LANG_PORTUGUESEBR} "Linguagem de script"

LangString i18n_DESCR_PMA ${LANG_SPANISH} "Administrador de base de datos, vía web"
LangString i18n_DESCR_PMA ${LANG_ENGLISH} "Database administrator, via web"
LangString i18n_DESCR_PMA ${LANG_PORTUGUESEBR} "Administrador de banco de dados, via web"

LangString i18n_DESCR_ADMINER ${LANG_SPANISH} "Alternativa ultra ligera a phpMyAdmin"
LangString i18n_DESCR_ADMINER ${LANG_ENGLISH} "Ultra-lightweight alternative to phpMyAdmin"
LangString i18n_DESCR_ADMINER ${LANG_PORTUGUESEBR} "Alternativa ultraleve ao phpMyAdmin"