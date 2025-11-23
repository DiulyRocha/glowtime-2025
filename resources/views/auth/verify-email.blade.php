<x-guest-layout>
    <div class="mb-4 text-sm text-gray-600">
        Thanks for signing up! Please verify your email using the link we sent.
    </div>

    @if (session('status') === 'verification-link-sent')
        <div class="mb-4 text-green-600 font-medium">
            A new verification link has been sent!
        </div>
    @endif

    <div class="mt-4 flex justify-between items-center">

        <form method="POST" action="{{ route('verification.send') }}">
            @csrf
            <x-primary-button>
                Resend Email
            </x-primary-button>
        </form>

        <form method="POST" action="{{ route('logout') }}">
            @csrf
            <button class="underline text-sm text-gray-600 hover:text-gray-900">
                Log Out
            </button>
        </form>

    </div>
</x-guest-layout>
