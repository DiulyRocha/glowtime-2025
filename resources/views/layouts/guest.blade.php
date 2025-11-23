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

    @if ($cssFile)
        <link rel="stylesheet" href="/build/{{ $cssFile }}">
    @endif

</head>

<body class="font-sans bg-gray-100 antialiased">

    <div class="min-h-screen flex flex-col sm:justify-center items-center pt-6 sm:pt-0">

        {{-- TÍTULO SIMPLES PARA EVITAR ERROS --}}
        <div class="text-3xl font-bold text-pink-600 mb-4">
            GlowTime
        </div>

        {{-- CONTEÚDO DO LOGIN/REGISTER --}}
        <div class="w-full sm:max-w-md mt-6 px-6 py-4 bg-white shadow-md sm:rounded-lg">
            {{ $slot }}
        </div>

    </div>

    @if ($jsFile)
        <script type="module" src="/build/{{ $jsFile }}"></script>
    @endif

</body>
</html>
