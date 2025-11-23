import './bootstrap';

import Alpine from 'alpinejs';

window.Alpine = Alpine;

Alpine.start();
@php
    $js = $manifest['resources/js/app.js']['file'] ?? null;
    $calendarJs = $manifest['resources/js/calendar.js']['file'] ?? null;
@endphp

@if ($js)
    <script type="module" src="/build/{{ $js }}"></script>
@endif

@if ($calendarJs)
    <script type="module" src="/build/{{ $calendarJs }}"></script>
@endif
