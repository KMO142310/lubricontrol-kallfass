import Link from 'next/link';
import { Droplet, ShieldCheck, WifiOff, BarChart3, ArrowRight, Wrench } from 'lucide-react';

export default function HomePage() {
  return (
    <div className="min-h-[100dvh] flex flex-col bg-[#05070a] text-slate-200 selection:bg-cyan-500/30">

      {/* Header */}
      <header className="px-6 pt-12 pb-6 flex items-center justify-between border-b border-white/[0.04]">
        <div className="flex items-center gap-2.5">
          <div className="w-8 h-8 bg-cyan-500 flex items-center justify-center">
            <Droplet className="text-[#05070a]" size={18} />
          </div>
          <div>
            <p className="text-white font-black text-sm tracking-tighter">LUBRICONTROL</p>
            <p className="tech-label text-[0.45rem] text-slate-600 tracking-[0.2em]">KALLFASS · BITACORA v1.0</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-1.5 h-1.5 bg-emerald-400 rounded-full shadow-[0_0_6px_#34d399]" />
          <span className="tech-label text-[0.5rem] text-slate-600">SISTEMA ACTIVO</span>
        </div>
      </header>

      {/* Hero */}
      <main className="flex-1 flex flex-col px-6 py-10 gap-12 max-w-lg mx-auto w-full">

        <section className="space-y-4">
          <p className="tech-label text-[0.55rem] text-cyan-500 tracking-[0.25em]">GESTIÓN DE LUBRICACIÓN INDUSTRIAL</p>
          <h1 className="text-4xl font-black text-white tracking-tighter leading-none">
            Planta Kallfass<br />
            <span className="text-slate-600 font-light text-2xl tracking-normal">Aserradero Chile</span>
          </h1>
          <p className="text-sm text-slate-500 leading-relaxed max-w-xs">
            Sistema de registro offline-first para lubricadores en terreno. Trabaja sin conexión, sincroniza automáticamente.
          </p>
        </section>

        {/* Stats */}
        <section className="grid grid-cols-3 gap-px bg-white/[0.04]">
          {[
            { value: '20',   label: 'MÁQUINAS', sub: 'Kallfass' },
            { value: '128+', label: 'PUNTOS',   sub: 'lubricación' },
            { value: '5',    label: 'GRUPOS',   sub: 'Kallfass I–V' },
          ].map(s => (
            <div key={s.label} className="bg-[#05070a] flex flex-col items-center justify-center py-6 gap-1">
              <span className="text-2xl font-black text-white tracking-tighter">{s.value}</span>
              <span className="tech-label text-[0.5rem] text-cyan-400">{s.label}</span>
              <span className="tech-label text-[0.45rem] text-slate-700">{s.sub}</span>
            </div>
          ))}
        </section>

        {/* Features */}
        <section className="space-y-3">
          {[
            { icon: <WifiOff size={16} />,      label: 'Modo offline completo',  desc: '8h sin conexión, sync automático'   },
            { icon: <ShieldCheck size={16} />,  label: 'Roles y permisos',        desc: 'Lubricador · Supervisor · Admin'    },
            { icon: <BarChart3 size={16} />,    label: 'Dashboard supervisión',   desc: 'KPIs en tiempo real por área'       },
            { icon: <Wrench size={16} />,       label: 'Reporte de anomalías',    desc: 'Tipos, descripción, evidencia'      },
          ].map(f => (
            <div key={f.label} className="flex items-center gap-4 p-4 bg-white/[0.02] border border-white/[0.04]">
              <div className="text-cyan-500 shrink-0">{f.icon}</div>
              <div>
                <p className="text-sm font-bold text-white">{f.label}</p>
                <p className="text-[0.65rem] text-slate-600">{f.desc}</p>
              </div>
            </div>
          ))}
        </section>

        {/* CTA */}
        <section className="space-y-3">
          <Link
            href="/login"
            className="flex items-center justify-center gap-3 w-full py-4 bg-cyan-500 text-[#05070a] font-black text-sm tracking-widest hover:bg-cyan-400 active:scale-[0.98] transition-all"
          >
            ACCEDER AL SISTEMA <ArrowRight size={18} />
          </Link>
          <p className="text-center tech-label text-[0.5rem] text-slate-700">
            lubricador1@planta.local · supervisor1@planta.local · admin@planta.local
            <br />Contraseña: lubricontrol2026
          </p>
        </section>

      </main>

      {/* Footer */}
      <footer className="px-6 py-4 border-t border-white/[0.04] flex justify-between items-center">
        <span className="tech-label text-[0.45rem] text-slate-800">BITACORA © 2026</span>
        <span className="tech-label text-[0.45rem] text-slate-800">KALLFASS INDUSTRIAL PWA</span>
      </footer>
    </div>
  );
}
