import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';
import ptLocale from '@fullcalendar/core/locales/pt-br';
import Swal from 'sweetalert2';
import '../css/calendar.css';


document.addEventListener('DOMContentLoaded', function () {
    const calendarEl = document.getElementById('calendar');
    if (!calendarEl) return;

    const eventsUrl = calendarEl.dataset.events;

    const calendar = new Calendar(calendarEl, {
        plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin],
        initialView: 'dayGridMonth',
        locale: ptLocale,
        height: 'auto',
        selectable: true,
        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,timeGridWeek,timeGridDay'
        },
        events: eventsUrl,

        eventClick(info) {
            const event = info.event;
            Swal.fire({
                title: `<strong>${event.title}</strong>`,
                html: `
                    <p><b>Profissional:</b> ${event.extendedProps.profissional}</p>
                    <p><b>Valor:</b> R$ ${event.extendedProps.valor.toFixed(2)}</p>
                    <p><b>Status:</b> ${event.extendedProps.status}</p>
                    <p><b>Pagamento:</b> ${event.extendedProps.payment}</p>
                    <p><b>Início:</b> ${new Date(event.start).toLocaleString('pt-BR')}</p>
                    <p><b>Término:</b> ${new Date(event.end).toLocaleString('pt-BR')}</p>
                `,
                icon: 'info',
                confirmButtonColor: '#ec4899',
                confirmButtonText: 'Fechar'
            });
        },

        dateClick(info) {
            Swal.fire({
                title: 'Novo Agendamento',
                html: `
                    <form id="newAppointmentForm" class="text-left">
                        <label class="block mb-2 text-sm font-semibold">Cliente</label>
                        <select id="client_id" class="swal2-select" required>
                            ${window.clients.map(c => `<option value="${c.id}">${c.name}</option>`).join('')}
                        </select>

                        <label class="block mb-2 text-sm font-semibold">Serviço</label>
                        <select id="service_id" class="swal2-select" required>
                            ${window.services.map(s => `<option value="${s.id}">${s.name}</option>`).join('')}
                        </select>

                        <label class="block mb-2 text-sm font-semibold">Profissional</label>
                        <select id="professional_id" class="swal2-select" required>
                            ${window.professionals.map(p => `<option value="${p.id}">${p.name}</option>`).join('')}
                        </select>

                        <label class="block mb-2 text-sm font-semibold">Horário Início</label>
                        <input type="time" id="start_time" class="swal2-input" required>

                        <label class="block mb-2 text-sm font-semibold">Horário Fim</label>
                        <input type="time" id="end_time" class="swal2-input" required>

                        <label class="block mb-2 text-sm font-semibold">Valor (R$)</label>
                        <input type="number" id="price" class="swal2-input" min="0" step="0.01" required>
                    </form>
                `,
                focusConfirm: false,
                showCancelButton: true,
                confirmButtonText: 'Salvar',
                cancelButtonText: 'Cancelar',
                preConfirm: () => {
                    const data = {
                        client_id: document.getElementById('client_id').value,
                        service_id: document.getElementById('service_id').value,
                        professional_id: document.getElementById('professional_id').value,
                        date: info.dateStr,
                        start_time: `${info.dateStr}T${document.getElementById('start_time').value}`,
                        end_time: `${info.dateStr}T${document.getElementById('end_time').value}`,
                        price: document.getElementById('price').value
                    };

                    return fetch('/appointments', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                        },
                        body: JSON.stringify(data)
                    })
                        .then(res => {
                            if (!res.ok) throw new Error('Erro ao salvar');
                            return res.json();
                        })
                        .catch(err => Swal.showValidationMessage(`Erro: ${err.message}`));
                }
            }).then(result => {
                if (result.isConfirmed) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Agendamento criado com sucesso!',
                        timer: 1500,
                        showConfirmButton: false
                    });
                    calendar.refetchEvents();
                }
            });
        }
    });

    calendar.render();
});
