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
 * create_versions_file.php - Genera archivo Versions.nsh.
 * 
 * @package AMPc
 * @subpackage prebuild
 * @since 0.20.0
 */

$componentsIni = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'components.ini';
$outputNsh = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'Versions.nsh';

echo "===========================================\n";
echo "Generador de versions.nsh para NSIS\n";
echo "===========================================\n\n";

// Verificar que existe components.ini
if (!file_exists($componentsIni)) {
    echo "[X] ERROR: No se encuentra components.ini\n";
    echo "Ubicacion esperada: $componentsIni\n";
    exit(1);
}

echo "[OK] Leyendo components.ini...\n";
$components = parse_ini_file($componentsIni, true);

if ($components === false) {
    echo "[X] ERROR: No se pudo parsear components.ini\n";
    exit(1);
}

echo "[i] Componentes encontrados: " . count($components) . "\n\n";

$date = date('Y-m-d H:i:s');
$output = <<<NSH
; ============================================
; Versions.nsh
; Generated automatically on {$date}
; DO NOT EDIT MANUALLY - Changes will be lost
; ============================================

NSH;

// Mapeo de componentes
$mapping = [
    'ampc' => 'VERSION_DISTRO',
    'apache' => 'COMPONENT_A_VERSION',
    'mariadb' => 'COMPONENT_M_VERSION',
    'php' => 'COMPONENT_P_VERSION',
    'cacert' => 'COMPONENT_C_VERSION',
];

foreach ($mapping as $component => $define) {
    if (isset($components[$component]['version'])) {
        $rawVersion = $components[$component]['version'];
        $version = cleanSemver($rawVersion);
        $output .= "!define {$define} \"{$version}\"\n";
        
        if ($rawVersion !== $version) {
            echo "[OK] {$component}: {$rawVersion} -> {$version}\n";
        } else {
            echo "[OK] {$component}: {$version}\n";
        }
    } else {
        echo "[!] ADVERTENCIA: No se encontro version para {$component}\n";
        $output .= "!define {$define} \"unknown\"\n";
    }
}

// Escribir archivo
if (file_put_contents($outputNsh, $output) === false) {
    echo "\n[X] ERROR: No se pudo escribir versions.nsh\n";
    exit(1);
}

echo "\n[OK] versions.nsh generado exitosamente\n";
echo "Ubicacion: $outputNsh\n\n";
echo "===========================================\n";
echo "Proceso completado\n";
echo "===========================================\n";

exit(0);

/**
 * Limpia una versión extrayendo solo el formato SEMVER (X.Y.Z)
 * 
 * @param string $version Versión completa (ej: "2.4.65-250724")
 * @return string Versión en formato SEMVER (ej: "2.4.65")
 */
function cleanSemver($version) {
    // Extraer solo números y puntos al inicio del string
    if (preg_match('/^(\d+\.\d+(?:\.\d+)?)/', $version, $matches)) {
        return $matches[1];
    }
    // Si no coincide con el patrón, devolver la versión original
    return $version;
}