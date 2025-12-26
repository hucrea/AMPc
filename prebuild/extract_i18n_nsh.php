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
 * extract_i18n_strings.php - Extrae strings i18n desde AMPc.nsi
 * 
 * @package AMPc
 * @subpackage prebuild
 * @since 0.20.0
 */

// Configuración
$sourceFile = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'AMPc.nsi';
$langFile = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'LangStrings.nsh';
$outputFile = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'LangStrings_missing.nsh';

echo "===========================================\n";
echo "Extractor de strings i18n\n";
echo "===========================================\n\n";

// Verificar que existe AMPc.nsi
if (!file_exists($sourceFile)) {
    echo "[X] ERROR: No se encuentra AMPc.nsi\n";
    echo "Ubicacion esperada: $sourceFile\n";
    exit(1);
}

echo "[OK] Leyendo AMPc.nsi...\n";
$content = file_get_contents($sourceFile);

if ($content === false) {
    echo "[X] ERROR: No se pudo leer AMPc.nsi\n";
    exit(1);
}

// Extraer todos los strings i18n usando expresión regular
preg_match_all('/\$\(i18n_([A-Z_0-9]+)\)/', $content, $matches);

if (empty($matches[1])) {
    echo "[!] No se encontraron strings i18n en el archivo\n";
    exit(0);
}

// Obtener strings únicos y ordenarlos
$strings = array_unique($matches[1]);
sort($strings);

echo "[i] Strings i18n encontrados: " . count($strings) . "\n\n";

// Leer LangStrings.nsh existente para identificar cuáles ya están definidos
$existingStrings = [];
if (file_exists($langFile)) {
    echo "[OK] Leyendo LangStrings.nsh existente...\n";
    $langContent = file_get_contents($langFile);
    
    // Extraer strings ya definidos
    preg_match_all('/^LangString i18n_([A-Z_0-9]+)/m', $langContent, $existingMatches);
    $existingStrings = array_unique($existingMatches[1]);
    
    echo "[i] Strings ya definidos: " . count($existingStrings) . "\n\n";
}

// Identificar strings faltantes
$missingStrings = array_diff($strings, $existingStrings);

if (empty($missingStrings)) {
    echo "[OK] Todos los strings están definidos en LangStrings.nsh\n";
    echo "\n===========================================\n";
    echo "Proceso completado - No hay strings faltantes\n";
    echo "===========================================\n";
    exit(0);
}

echo "[!] Strings faltantes: " . count($missingStrings) . "\n\n";

// Generar archivo con strings faltantes
$output = <<<HEADER
/*
AMPc for Windows - Entorno web local para Windows
Copyright (C) 2025  Hu SpA ( https://hucreativa.cl )

This file is part of AMPc for Windows.

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------

LangStrings_missing.nsh - Strings i18n faltantes detectados en AMPc.nsi

GENERADO AUTOMATICAMENTE - NO EDITAR MANUALMENTE
Fecha: {date}

INSTRUCCIONES:
1. Revise cada string y complete las traducciones
2. Copie los strings completados a LangStrings.nsh
3. Elimine este archivo o actualícelo ejecutando extract_i18n_strings.php

*/


HEADER;

$output = str_replace('{date}', date('Y-m-d H:i:s'), $output);

foreach ($missingStrings as $string) {
    $stringName = "i18n_{$string}";
    
    // Buscar contexto en el archivo fuente
    $context = findContext($content, $string);
    
    $output .= "; ===========================================\n";
    $output .= "; {$stringName}\n";
    if ($context) {
        $output .= "; Contexto: {$context}\n";
    }
    $output .= "; ===========================================\n";
    
    $output .= "LangString {$stringName} \${LANG_SPANISH} \"TODO: Traducir al español\"\n";
    $output .= "LangString {$stringName} \${LANG_ENGLISH} \"TODO: Translate to English\"\n";
    $output .= "LangString {$stringName} \${LANG_PORTUGUESEBR} \"TODO: Traduzir para português\"\n";
    $output .= "\n";
    
    echo "[+] {$stringName}\n";
}

// Escribir archivo
if (file_put_contents($outputFile, $output) === false) {
    echo "\n[X] ERROR: No se pudo escribir {$outputFile}\n";
    exit(1);
}

echo "\n[OK] Archivo generado exitosamente\n";
echo "Ubicacion: $outputFile\n\n";

// Generar también un reporte en texto plano
$reportFile = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'i18n_report.txt';
$report = "REPORTE DE STRINGS i18n\n";
$report .= "Generado: " . date('Y-m-d H:i:s') . "\n";
$report .= str_repeat("=", 60) . "\n\n";
$report .= "Total de strings encontrados: " . count($strings) . "\n";
$report .= "Strings ya definidos: " . count($existingStrings) . "\n";
$report .= "Strings faltantes: " . count($missingStrings) . "\n\n";

$report .= str_repeat("-", 60) . "\n";
$report .= "STRINGS FALTANTES:\n";
$report .= str_repeat("-", 60) . "\n";

foreach ($missingStrings as $string) {
    $context = findContext($content, $string);
    $report .= "i18n_{$string}\n";
    if ($context) {
        $report .= "  Contexto: {$context}\n";
    }
    $report .= "\n";
}

file_put_contents($reportFile, $report);
echo "[OK] Reporte generado: $reportFile\n\n";

echo "===========================================\n";
echo "Proceso completado\n";
echo "===========================================\n";

exit(0);

/**
 * Encuentra el contexto donde se usa un string i18n
 * 
 * @param string $content Contenido del archivo
 * @param string $string Nombre del string sin prefijo i18n_
 * @return string|null Contexto encontrado o null
 */
function findContext($content, $string) {
    $pattern = '/\$\(i18n_' . preg_quote($string, '/') . '\)/';
    
    // Dividir contenido en líneas
    $lines = explode("\n", $content);
    
    foreach ($lines as $index => $line) {
        if (preg_match($pattern, $line)) {
            // Buscar comentarios anteriores
            $comment = null;
            for ($i = $index - 1; $i >= 0 && $i >= $index - 5; $i--) {
                $prevLine = trim($lines[$i]);
                if (preg_match('/^;(.+)$/', $prevLine, $matches)) {
                    $comment = trim($matches[1]);
                    break;
                }
            }
            
            // Si no hay comentario, buscar en qué función/sección está
            for ($i = $index; $i >= 0; $i--) {
                $prevLine = trim($lines[$i]);
                
                // Buscar Function
                if (preg_match('/^Function\s+(\w+)/', $prevLine, $matches)) {
                    return $comment ? "{$matches[1]} - {$comment}" : $matches[1];
                }
                
                // Buscar Section
                if (preg_match('/^Section\s+"?([^"]+)"?/', $prevLine, $matches)) {
                    return $comment ? "{$matches[1]} - {$comment}" : $matches[1];
                }
                
                // Buscar MUI_HEADER_TEXT
                if (preg_match('/MUI_HEADER_TEXT/', $prevLine)) {
                    return $comment ? "Header - {$comment}" : "Header";
                }
            }
            
            return $comment;
        }
    }
    
    return null;
}