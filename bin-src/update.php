<?php
/**
 * AMPc for Windows - Entorno web local para Windows
 * Copyright (C) 2025  Hu SpA ( https://hucreativa.cl )
 * 
 * This file is part of AMPc for Windows.
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/.
 * 
 * ---------------------------------------------------------------------------
 * 
 * update.php - Script para automatizar actualizacion de componentes.
 * 
 * @package AMPc
 * @subpackage prebuild
 */

/**
 * Elimina archivos y directorios de forma recursiva.
 * @param string $dir Directorio a eliminar.
 * @since 0.20.0
 */
function delete_all( string $dir ) {
    if( !is_dir($dir) ) {
        return false;
    }
    
    $files = scandir($dir);
    
    foreach( $files as $file ) {
        if( $file === '.' || $file === '..' ) {
            continue;
        }
        
        $path = $dir . DIRECTORY_SEPARATOR . $file;
        
        if( is_dir($path) ) {
            delete_all($path);
        } else {
            unlink($path);
        }
    }

    return rmdir($dir);
}

/**
 * Inicializacion del script.
 * El script requiere que exista el archivo components.ini en el mismo
 * directorio de trabajo, ademas de tener la extension ZIP habilitada.
 * 
 * @since 0.20.0
 */
$dirbase = __DIR__;
$components_ini = dirname($dirbase) . DIRECTORY_SEPARATOR . 'components.ini';

echo "===========================================\n";
echo "Iniciando descompresion de archivos ZIP\n";
echo "===========================================\n\n";

if( !file_exists($components_ini) ) {
	echo "[X] ERROR: No se encontro el archivo components.ini\n";
	echo "Ubicacion esperada: $components_ini\n";
	exit(1);
}

$components = parse_ini_file($components_ini, true);

if( false === $components ) {
	echo "[X] ERROR: No se pudo leer el archivo components.ini\n";
	echo "    Verifica que el formato sea correcto\n";
	exit(1);
}

echo "[OK] Archivo components.ini leido correctamente\n";
echo "[i] Componentes encontrados: " . count($components) . "\n\n";

if( !extension_loaded('zip') ) {
	echo "[X] ERROR: La extension ZIP de PHP no esta habilitada.\n";
	echo "Habilita la extension zip en php.ini\n";
	exit(1);
}

/** 
 * Procesa cada componente.
 * 
 * @since 0.20.0
 */
foreach( $components as $componente => $datos ) {
	echo "-------------------------------------------\n";
	echo "Procesando: $componente\n";
	echo "-------------------------------------------\n";

	/** 
	 * Claves: verificacion y normalizacion.
	 * 
	 * Las claves version, hash_version, zip_name, y work_folder son
	 * obligatorias. Se puede utilizar %version% en la clave zip_name,
	 * y esta sera reemplazada por el valor de la clave version.
	 */
	if( empty($datos['version']) ) {
		echo "[!] ADVERTENCIA: No hay version configurado para $componente\n";
		echo "Saltando $componente\n\n";
		continue;
	}

	if( empty($datos['hash_version']) ) {
		echo "[!] ADVERTENCIA: No hay hash_version configurado para $componente\n";
		echo "Saltando $componente\n\n";
		continue;
	}

	if( empty($datos['zip_name']) ) {
		echo "[!] ADVERTENCIA: No hay zip_name configurado para $componente\n";
		echo "Saltando $componente\n\n";
		continue;
	}

	if( empty($datos['work_folder']) ) {
		echo "[!] ADVERTENCIA: No hay work_folder configurado para $componente\n";
		echo "Saltando $componente\n\n";
		continue;
	}

	/**
	 * Verificacion de archivos y directorios.
	 */

	$zip_name = str_replace( '%version%', $datos['version'], $datos['zip_name'] );
	$zip_file = $dirbase . DIRECTORY_SEPARATOR . $datos['work_folder'] . DIRECTORY_SEPARATOR . $zip_name;

	if( !file_exists($zip_file) ) {
		echo "[!] ADVERTENCIA: No se encontro el archivo ZIP\n";
		echo "Ruta buscada: $zip_file\n\n";
		continue;
	}

	$hash_file = hash_file('sha256', $zip_file);

	if( $hash_file != strtolower($datos['hash_version']) ) {
		echo "[x] ERROR: hash_file y hash_version no coinciden\n";
		echo "HASH esperado: " . $datos['hash_version'] . "\n";
		echo "HASH devuelto: $hash_file\n\n";
		continue;
	}
	
	$component_path = $dirbase . DIRECTORY_SEPARATOR . $datos['work_folder'];

	if( !is_dir($component_path) ) {
		echo "[!] La carpeta '{$datos['work_folder']}' no existe\n";
		echo "Creando carpeta...\n";

		if (!mkdir($component_path, 0755, true)) {
			echo "[X] ERROR: No se pudo crear la carpeta\n\n";
			continue;
		}

		echo "[OK] Carpeta creada exitosamente\n";
	}

	echo "Version: " . $datos['version'] . "\n";
	echo "SHA-256 del ZIP: " . $hash_file . "\n";
	echo "Archivo ZIP: $zip_name\n";
	echo "Carpeta de trabajo: {$datos['work_folder']}\n";

	/**
	 * Antes de descomprimir, elimina todos los archivos existentes en la
	 * carpeta de trabajo, excepto el archivo ZIP y el archivo files.nsh.
	 */
	echo "> Limpiando carpeta {$datos['work_folder']}...\n";

    $not_delete = array(
        strtolower(trim($zip_name)),
        'files.nsh'
	);
    
    echo "[DEBUG] Archivos protegidos:\n";
    foreach ($not_delete as $idx => $protegido) {
        echo "  [$idx] '$protegido' (longitud: " . strlen($protegido) . ")\n";
    }
    
    $count_protegidos = 0;
    $count_delete = 0;
    
    $elementos = scandir($component_path);
    
    foreach ($elementos as $elemento) {
        if ($elemento === '.' || $elemento === '..') {
            continue;
        }

        $elemento_normalizado = strtolower(trim($elemento));

        echo "[DEBUG] Analizando: '$elemento' -> lowercase: '$elemento_normalizado'";

        if (in_array($elemento_normalizado, $not_delete, true)) {
            echo " -> PROTEGIDO\n";
            $count_delete++;
            continue;
        }

        echo "-> ELIMINAR\n";

        $elemento_eliminar = $component_path . DIRECTORY_SEPARATOR . $elemento;

        if (is_dir($elemento_eliminar)) {
            if (delete_all($elemento_eliminar)) {
                $count_protegidos++;
            }
        } else {
            if (unlink($elemento_eliminar)) {
                $count_protegidos++;
            }
        }
    }
    
    echo "Elementos eliminados: $count_protegidos\n";
    echo "Elementos protegidos: $count_delete\n";
    
    echo "> Descomprimiendo: $zip_file\n";

	$zip = new ZipArchive();
	$open_zip = $zip->open($zip_file);
	
	/**
	 * La siguiente comprobacion parece imbecil, pero de otra forma
	 * puede fallar en silencio.
	 */
	if( $open_zip && is_bool($open_zip) ) {		
		if ($zip->extractTo($component_path)) {
			echo "[OK] Descomprimido exitosamente\n";
			echo "Archivos extraidos: " . $zip->numFiles . "\n";

		} else {
			echo "[X] ERROR: No se pudo extraer el contenido\n";
		}

		$zip->close();
	}
	else {
		$error = match($open_zip) {
			ZipArchive::ER_EXISTS => 'El archivo ya existe',
			ZipArchive::ER_INCONS => 'ZIP inconsistente',
			ZipArchive::ER_INVAL => 'Argumento invalido',
			ZipArchive::ER_MEMORY => 'Error de memoria',
			ZipArchive::ER_NOENT => 'Archivo no existe',
			ZipArchive::ER_NOZIP => 'No es un archivo ZIP',
			ZipArchive::ER_OPEN => 'No se puede abrir el archivo',
			ZipArchive::ER_READ => 'Error de lectura',
			ZipArchive::ER_SEEK => 'Error de busqueda',
			default => 'Error desconocido'
		};

		echo "[X] ERROR: No se pudo abrir el archivo ZIP\n";
		echo "Codigo: $open_zip - $error\n";
	}

	echo "\n";
}

echo "===========================================\n";
echo "Proceso finalizado\n";
echo "===========================================\n";