<?php
// Generates lib/l10n/laravel_messages_maps.dart from UberEat/lang/*/messages.php
// Run from repo: php tool/generate_laravel_message_maps.php
//
// Colons in output are built with chr(58) so no PHP single-quoted literal starts with ':' (avoids
// "syntax error, unexpected token ':'" from some IDE PHP lexers that misparse ':...' strings).

$c = chr(58);

$base = dirname(__DIR__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'UberEat' . DIRECTORY_SEPARATOR . 'lang';
$out = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'lib' . DIRECTORY_SEPARATOR . 'l10n' . DIRECTORY_SEPARATOR . 'laravel_messages_maps.dart';

function exportMap($path, $constName)
{
    $c = chr(58);
    $a = require $path;
    $lines = array('const Map<String, String> ' . $constName . ' = {');
    foreach ($a as $k => $v) {
        $lines[] = '  ' . json_encode($k, JSON_UNESCAPED_UNICODE) . $c . ' ' . json_encode($v, JSON_UNESCAPED_UNICODE) . ',';
    }
    $lines[] = '};';
    return implode("\n", $lines) . "\n";
}

$header = '// GENERATED FILE - do not edit by hand.' . "\n"
    . '// Regenerate' . $c . ' php tool/generate_laravel_message_maps.php' . "\n"
    . '// Source' . $c . ' UberEat/lang/{en,fa,ps}/messages.php' . "\n\n";

$body = exportMap($base . DIRECTORY_SEPARATOR . 'en' . DIRECTORY_SEPARATOR . 'messages.php', 'kLaravelMessagesEn');
$body .= "\n" . exportMap($base . DIRECTORY_SEPARATOR . 'fa' . DIRECTORY_SEPARATOR . 'messages.php', 'kLaravelMessagesFa');
$body .= "\n" . exportMap($base . DIRECTORY_SEPARATOR . 'ps' . DIRECTORY_SEPARATOR . 'messages.php', 'kLaravelMessagesPs');

$footer = "\n"
    . '/// Same keys and strings as Laravel messages.php for en, fa, ps.' . "\n"
    . 'const Map<String, Map<String, String>> kLaravelMessagesByLocale = {' . "\n"
    . '  \'en\'' . $c . ' ' . 'kLaravelMessagesEn,' . "\n"
    . '  \'fa\'' . $c . ' ' . 'kLaravelMessagesFa,' . "\n"
    . '  \'ps\'' . $c . ' ' . 'kLaravelMessagesPs,' . "\n"
    . '};' . "\n";

file_put_contents($out, $header . $body . $footer);
echo 'Wrote ' . $out . "\n";

$keysPath = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'lib' . DIRECTORY_SEPARATOR . 'l10n' . DIRECTORY_SEPARATOR . 'message_keys.dart';
$enPath = $base . DIRECTORY_SEPARATOR . 'en' . DIRECTORY_SEPARATOR . 'messages.php';
$a = require $enPath;
$kb = '// GENERATED - same keys as UberEat/lang/en/messages.php' . "\n"
    . '// Regenerate' . $c . ' php tool/generate_laravel_message_maps.php' . "\n"
    . '// ignore_for_file' . $c . ' constant_identifier_names - names mirror Laravel snake_case keys.' . "\n\n"
    . 'abstract final class MessageKeys {' . "\n"
    . '  MessageKeys._();' . "\n";
foreach (array_keys($a) as $k) {
    $safe = preg_replace('/[^a-zA-Z0-9_]/', '_', $k);
    if ($safe === '' || is_numeric($safe[0])) {
        $safe = 'k_' . $safe;
    }
    $kb .= '  static const String ' . $safe . ' = ' . json_encode($k, JSON_UNESCAPED_UNICODE) . ";\n";
}
$kb .= "}\n";
file_put_contents($keysPath, $kb);
echo 'Wrote ' . $keysPath . "\n";
