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
 * generate_nsh_files.php - Genera archivos files.nsh y uninstall.nsh
 * 
 * @package AMPc
 * @subpackage prebuild
 * @since 0.20.0
 */

// ====================================
// CONFIGURACIÓN GLOBAL
// ====================================
define('INDENT', "\t");
define('HEADER_COMMENT', true);
define('SORT_FILES', true);
define('GENERATE_BACKUP', true);
define('VERBOSE', false);

// Mapeo de componentes a variables NSIS
$NSIS_VARS = [
    'apache'   => '$apachePath',
    'mariadb'  => '$mariadbPath',
    'php'      => '$phpPath',
    'cacert'   => '$cacertPath',
];

// Patrones de exclusión globales (aplicados a TODOS los componentes)
$GLOBAL_EXCLUDE_PATTERNS = [
    '*.nsh',     // Archivos NSH generados
    '*.bak',     // Backups
    '*.zip',     // Archivos ZIP
];

// Patrones de exclusión por componente
$EXCLUDE_PATTERNS = [
    'apache' => [
        'conf/httpd.conf',
        'logs/*.log',
    ],
    'mariadb' => [
        'data/*',
        '*.ini',
    ],
    'php' => [
        'php.ini',
        'php.ini-*',
    ],
    'cacert' => [],
];

// Directorios vacíos a preservar
$PRESERVE_EMPTY_DIRS = [
    'apache'  => ['logs'],
    'mariadb' => ['data'],
    'php'     => [],
    'cacert'  => [],
];

// ====================================
// PROGRAMA PRINCIPAL
// ====================================

$dirbase = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'components';
$components_ini = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'components.ini';

echo "===========================================\n";
echo "Generador de archivos NSH para AMPc\n";
echo "===========================================\n\n";

// Verificar components.ini
if (!file_exists($components_ini)) {
    echo "[X] ERROR: No se encontro el archivo components.ini\n";
    echo "Ubicacion esperada: $components_ini\n";
    exit(1);
}

$components = parse_ini_file($components_ini, true);

if (false === $components) {
    echo "[X] ERROR: No se pudo leer el archivo components.ini\n";
    echo "    Verifica que el formato sea correcto\n";
    exit(1);
}

echo "[OK] Archivo components.ini leido correctamente\n";
echo "[i] Componentes encontrados: " . count($components) . "\n\n";

// Estadísticas
$stats = [];
$totalFiles = 0;
$totalDirs = 0;

// Procesar cada componente
foreach ($components as $componente => $datos) {
    echo "-------------------------------------------\n";
    echo "Procesando: $componente\n";
    echo "-------------------------------------------\n";
    
    // Validar configuración
    if (empty($datos['work_folder'])) {
        echo "[!] ADVERTENCIA: No hay work_folder configurado\n";
        echo "Saltando $componente\n\n";
        continue;
    }
    
    // Verificar si el componente tiene variable NSIS
    if (!isset($NSIS_VARS[$componente])) {
        echo "[!] ADVERTENCIA: No hay variable NSIS definida\n";
        echo "Saltando $componente\n\n";
        continue;
    }
    
    // Construir ruta del directorio fuente
    $componentPath = $dirbase . DIRECTORY_SEPARATOR . $datos['work_folder'];
    
    // Reemplazar %version% en nsis_path si existe
    if (!empty($datos['nsis_path'])) {
        $nsisPath = str_replace('%version%', $datos['version'] ?? '', $datos['nsis_path']);
        $sourceDir = $componentPath . DIRECTORY_SEPARATOR . $nsisPath;
    } else {
        $sourceDir = $componentPath;
    }
    
    // Verificar que el directorio existe
    if (!is_dir($sourceDir)) {
        echo "[!] ADVERTENCIA: Directorio no encontrado\n";
        echo "Ruta buscada: $sourceDir\n";
        echo "Saltando $componente\n\n";
        continue;
    }
    
    echo "Directorio fuente: " . basename($sourceDir) . "\n";
    
    // Escanear archivos
    echo "Escaneando archivos...\n";
    $excludePatterns = array_merge(
        $GLOBAL_EXCLUDE_PATTERNS,
        $EXCLUDE_PATTERNS[$componente] ?? []
    );
    $files = scan_directory($sourceDir, $excludePatterns);
    
    if (empty($files)) {
        echo "[!] ADVERTENCIA: No se encontraron archivos para procesar\n";
        echo "Saltando $componente\n\n";
        continue;
    }
    
    // Estadísticas
    $uniqueDirs = count(array_unique(array_map(function($f) {
        return dirname($f);
    }, $files)));
    
    echo "Archivos encontrados: " . count($files) . "\n";
    echo "Directorios unicos: " . $uniqueDirs . "\n";
    
    $stats[$componente] = [
        'files' => count($files),
        'dirs' => $uniqueDirs
    ];
    
    $totalFiles += count($files);
    $totalDirs += $uniqueDirs;
    
    // Archivos de salida
    $outputInstall = $componentPath . DIRECTORY_SEPARATOR . 'files_install.nsh';
    $outputUninstall = $componentPath . DIRECTORY_SEPARATOR . 'uninstall_files.nsh';
    
    // Construir ruta relativa para NSIS
    $relativePath = 'components\\' . $datos['work_folder'];
    if (!empty($datos['nsis_path'])) {
        $nsisPath = str_replace('%version%', $datos['version'] ?? '', $datos['nsis_path']);
        $relativePath .= '\\' . $nsisPath;
    }
    
    // Generar files.nsh
    echo "Generando files.nsh...\n";
    $emptyDirs = $PRESERVE_EMPTY_DIRS[$componente] ?? [];
    
    if (generate_install_file(
        $componente,
        $NSIS_VARS[$componente],
        $relativePath,
        $files,
        $emptyDirs,
        $outputInstall
    )) {
        echo "[OK] Generado: files.nsh\n";
    } else {
        echo "[X] ERROR: No se pudo generar files.nsh\n";
    }
    
    // Generar uninstall.nsh
    echo "Generando uninstall.nsh...\n";
    
    if (generate_uninstall_file(
        $componente,
        $NSIS_VARS[$componente],
        $files,
        $outputUninstall
    )) {
        echo "[OK] Generado: uninstall.nsh\n";
    } else {
        echo "[X] ERROR: No se pudo generar uninstall.nsh\n";
    }
    
    echo "\n";
}

// Resumen
echo "===========================================\n";
echo "RESUMEN\n";
echo "===========================================\n";

foreach ($stats as $component => $data) {
    echo sprintf(
        "%-15s: %5d archivos, %4d directorios\n",
        ucfirst($component),
        $data['files'],
        $data['dirs']
    );
}

echo str_repeat('-', 43) . "\n";
echo sprintf(
    "%-15s: %5d archivos, %4d directorios\n",
    "TOTAL",
    $totalFiles,
    $totalDirs
);
echo "===========================================\n\n";

if (empty($stats)) {
    echo "[!] No se proceso ningun componente\n";
    exit(1);
}

echo "[OK] Proceso completado exitosamente\n";
exit(0);

// ====================================
// FUNCIONES
// ====================================

/**
 * Genera encabezado del archivo NSH
 * 
 * @param string $componentName Nombre del componente
 * @param string $type Tipo (Installation/Uninstallation)
 * @return string
 */
function generate_header($componentName, $type) {
    if (!HEADER_COMMENT) {
        return '';
    }
    
    $date = date('Y-m-d H:i:s');
    return <<<HEADER
; ============================================
; {$componentName} - {$type} Files
; Generated automatically on {$date}
; DO NOT EDIT MANUALLY - Changes will be lost
; ============================================


HEADER;
}

/**
 * Obtiene ruta relativa
 * 
 * @param string $base Ruta base
 * @param string $path Ruta completa
 * @return string
 */
function get_relative_path($base, $path) {
    $base = str_replace('\\', '/', realpath($base));
    $path = str_replace('\\', '/', realpath($path));
    
    if (strpos($path, $base) === 0) {
        return substr($path, strlen($base) + 1);
    }
    
    return $path;
}

/**
 * Verifica si un archivo está excluido
 * 
 * @param string $file Archivo a verificar
 * @param array $patterns Patrones de exclusión
 * @return bool
 */
function is_excluded($file, $patterns) {
    foreach ($patterns as $pattern) {
        // Normalizar separadores
        $pattern = str_replace('\\', '/', $pattern);
        $file = str_replace('\\', '/', $file);
        
        // Convertir patrón glob a regex
        $regex = preg_quote($pattern, '/');
        $regex = str_replace(
            ['\*', '\?'],
            ['.*', '.'],
            $regex
        );
        
        // Verificar coincidencia exacta o por extensión
        if (preg_match("/^{$regex}$/", $file)) {
            return true;
        }
        
        // Si el patrón es *.extension, verificar solo el nombre del archivo
        if (strpos($pattern, '*.') === 0) {
            $extension = substr($pattern, 1); // Quitar el *
            if (substr($file, -strlen($extension)) === $extension) {
                return true;
            }
        }
    }
    return false;
}

/**
 * Escanea directorio recursivamente
 * 
 * @param string $dir Directorio a escanear
 * @param array $excludePatterns Patrones de exclusión
 * @return array
 */
function scan_directory($dir, $excludePatterns = []) {
    if (!is_dir($dir)) {
        return [];
    }
    
    $files = [];
    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($dir, RecursiveDirectoryIterator::SKIP_DOTS),
        RecursiveIteratorIterator::SELF_FIRST
    );
    
    foreach ($iterator as $file) {
        if ($file->isFile()) {
            $relativePath = get_relative_path($dir, $file->getPathname());
            
            if (!is_excluded($relativePath, $excludePatterns)) {
                $files[] = $relativePath;
            }
        }
    }
    
    if (SORT_FILES) {
        sort($files);
    }
    
    return $files;
}

/**
 * Agrupa archivos por directorio
 * 
 * @param array $files Lista de archivos
 * @return array
 */
function group_files_by_directory($files) {
    $grouped = [];
    
    foreach ($files as $file) {
        $dir = dirname($file);
        if ($dir === '.') {
            $dir = '.';
        }
        
        if (!isset($grouped[$dir])) {
            $grouped[$dir] = [];
        }
        
        $grouped[$dir][] = basename($file);
    }
    
    // Ordenar directorios por profundidad
    uksort($grouped, function($a, $b) {
        if ($a === '.') return -1;
        if ($b === '.') return 1;
        
        $depthA = substr_count($a, '/');
        $depthB = substr_count($b, '/');
        
        if ($depthA === $depthB) {
            return strcmp($a, $b);
        }
        
        return $depthA - $depthB;
    });
    
    return $grouped;
}

/**
 * Genera archivo files.nsh (instalación)
 * 
 * @param string $componentName Nombre del componente
 * @param string $nsisVar Variable NSIS
 * @param string $relativePath Ruta relativa para NSIS
 * @param array $files Archivos a incluir
 * @param array $emptyDirs Directorios vacíos a crear
 * @param string $outputFile Archivo de salida
 * @return bool
 */
function generate_install_file($componentName, $nsisVar, $relativePath, $files, $emptyDirs, $outputFile) {
    $output = '';
    
    // Header
    $output .= generate_header($componentName, 'Installation');
    
    // Agrupar archivos por directorio
    $filesByDir = group_files_by_directory($files);
    
    // Generar comandos NSIS
    foreach ($filesByDir as $dir => $dirFiles) {
        $targetDir = $dir === '.' 
            ? $nsisVar 
            : $nsisVar . '\\' . str_replace('/', '\\', $dir);
        
        $output .= "SetOutPath \"{$targetDir}\"\n";
        
        foreach ($dirFiles as $file) {
            $sourcePath = $relativePath . '\\' . ($dir === '.' ? $file : str_replace('/', '\\', $dir) . '\\' . $file);
            $output .= INDENT . "File \"{$sourcePath}\"\n";
        }
    }
    
    // Directorios vacíos
    if (!empty($emptyDirs)) {
        $output .= "\n; Crear directorios vacios\n";
        foreach ($emptyDirs as $emptyDir) {
            $targetDir = $nsisVar . '\\' . str_replace('/', '\\', $emptyDir);
            $output .= "CreateDirectory \"{$targetDir}\"\n";
        }
    }
    
    // Crear directorio de salida si no existe
    $outputDir = dirname($outputFile);
    if (!is_dir($outputDir)) {
        mkdir($outputDir, 0755, true);
    }
    
    // Backup
    if (GENERATE_BACKUP && file_exists($outputFile)) {
        $backupFile = $outputFile . '.bak';
        copy($outputFile, $backupFile);
        if (VERBOSE) {
            echo "   [i] Backup creado: " . basename($backupFile) . "\n";
        }
    }
    
    // Escribir archivo
    return file_put_contents($outputFile, $output) !== false;
}

/**
 * Genera archivo uninstall.nsh (desinstalación)
 * 
 * @param string $componentName Nombre del componente
 * @param string $nsisVar Variable NSIS
 * @param array $files Archivos a eliminar
 * @param string $outputFile Archivo de salida
 * @return bool
 */
function generate_uninstall_file($componentName, $nsisVar, $files, $outputFile) {
    $output = '';
    
    // Header
    $output .= generate_header($componentName, 'Uninstallation');
    
    // Agrupar archivos por directorio
    $filesByDir = group_files_by_directory($files);
    
    // Eliminar archivos (en orden inverso)
    $output .= "; Eliminar archivos\n";
    $allFiles = [];
    foreach ($filesByDir as $dir => $dirFiles) {
        foreach ($dirFiles as $file) {
            $fullPath = $dir === '.' ? $file : $dir . '/' . $file;
            $allFiles[] = $fullPath;
        }
    }
    
    // Invertir orden
    $allFiles = array_reverse($allFiles);
    
    foreach ($allFiles as $file) {
        $targetPath = $nsisVar . '\\' . str_replace('/', '\\', $file);
        $output .= "Delete \"{$targetPath}\"\n";
    }
    
    $output .= "\n; Eliminar directorios\n";
    
    // Obtener directorios únicos y ordenar por profundidad
    $directories = array_unique(array_map(function($f) {
        $dir = dirname($f);
        return $dir === '.' ? null : $dir;
    }, $files));
    
    $directories = array_filter($directories);
    
    // Ordenar por profundidad (más profundo primero)
    usort($directories, function($a, $b) {
        $depthA = substr_count($a, '/');
        $depthB = substr_count($b, '/');
        return $depthB - $depthA;
    });
    
    foreach ($directories as $dir) {
        $targetDir = $nsisVar . '\\' . str_replace('/', '\\', $dir);
        $output .= "RMDir \"{$targetDir}\"\n";
    }
    
    // Directorio raíz
    $output .= "RMDir \"{$nsisVar}\"\n";
    
    // Crear directorio de salida si no existe
    $outputDir = dirname($outputFile);
    if (!is_dir($outputDir)) {
        mkdir($outputDir, 0755, true);
    }
    
    // Backup
    if (GENERATE_BACKUP && file_exists($outputFile)) {
        $backupFile = $outputFile . '.bak';
        copy($outputFile, $backupFile);
        if (VERBOSE) {
            echo "   [i] Backup creado: " . basename($backupFile) . "\n";
        }
    }
    
    // Escribir archivo
    return file_put_contents($outputFile, $output) !== false;
}