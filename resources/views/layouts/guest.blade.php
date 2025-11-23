@php
    $cssFile = null;
    $jsFile  = null;

    $manifestPath = public_path('build/manifest.json');

    if (file_exists($manifestPath)) {
        $manifest = json_decode(file_get_contents($manifestPath), true);

        $cssFile = $manifest['resources/css/app.css']['file'] ?? null;
        $jsFile  = $manifest['resources/js/app.js']['file'] ?? null;
    }
@endphp

@if ($cssFile)
    <link rel="stylesheet" href="{{ asset('build/' . $cssFile) }}">
@endif
