@extends('layouts.guest')

@section('content')
    <div class="mb-4 text-sm text-gray-600">
        {{ __('Thanks for signing up! Please verify your email address by clicking on the link we just emailed to you.') }}
    </div>

    @if (session('status') == 'verification-link-sent')
        <div class="mb-4 font-medium text-sm text-green-600">
            {{ __('A new verification link has been sent to your email address.') }}
        </div>
    @endif

    <div class="mt-4 flex items-center justify-between">
        <form method="POST" action="{{ route('verification.send') }}">
            @csrf
            <x-primary-button>
                {{ __('Resend Verification Email') }}
            </x-primary-button>
        </form>

        <form method="POST" action="{{ route('logout') }}">
            @csrf
            <button
                class="underline text-sm text-gray-600 hover:text-gray-900">
                {{ __('Log Out') }}
            </button>
        </form>
    </div>
@endsection
