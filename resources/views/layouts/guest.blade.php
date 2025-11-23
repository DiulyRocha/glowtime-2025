<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'GlowTime') }}</title>

    @php
        $manifestPath = public_path('build/manifest.json');
        $cssFile = null;
        $jsFile  = null;

        if (file_exists($manifestPath)) {
            $manifest = json_decode(file_get_contents($manifestPath), true);

            $cssFile = $manifest['resources/css/app.css']['file'] ?? null;
            $jsFile  = $manifest['resources/js/app.js']['file'] ?? null;
        }
    @endphp

    {{-- CSS COMPILADO --}}
    @if ($cssFile)
        <link rel="stylesheet" href="/build/{{ $cssFile }}">
    @endif

    {{-- FONTES --}}
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

</head>
<body class="font-sans text-gray-900 antialiased bg-gray-100">

    <div class="min-h-screen flex flex-col sm:justify-center items-center pt-6 sm:pt-0">

        {{-- LOGO DO BREEZE --}}
        <div>
            <a href="/">
                <x-application-logo class="w-20 h-20 text-gray-500" />
            </a>
        </div>

        {{-- CONTEÚDO DAS PÁGINAS DE LOGIN/REGISTER --}}
        <div class="w-full sm:max-w-md mt-6 px-6 py-4 bg-white shadow-md overflow-hidden sm:rounded-lg">
            {{ $slot }}
        </div>
    </div>

    {{-- JS COMPILADO --}}
    @if ($jsFile)
        <script type="module" src="/build/{{ $jsFile }}"></script>
    @endif

</body>
</html>
