"use client";

import React, { useEffect, useState, useCallback } from 'react';
import { TaskCard } from '@/components/TaskCard';
import { cn } from '@/lib/utils';
import {
  LayoutGrid, Map, QrCode, AlertOctagon, User2,
  WifiOff, Wifi, Download, LogOut, RefreshCw, UserCircle
} from 'lucide-react';
import { useRouteStore } from '@/lib/store/useRouteStore';
import { useAuth } from '@/lib/auth/auth-context';
import { syncEngine } from '@/lib/sync/syncEngine';
import { MachineScanner } from '@/components/MachineScanner';
import { MachineDetailSheet } from '@/components/MachineDetailSheet';
import { getMachineByCode, getMachinePoints } from '@/lib/data/machines';
import { createClient } from '@/lib/supabase/client';
import type { Machine, LubricationPoint } from '@/types/database';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';

type Tab = 'tasks' | 'anomalies' | 'profile';

export default function DashboardPage() {
  const router = useRouter();
  const [mounted, setMounted]           = useState(false);
  const [isOnline, setIsOnline]         = useState(true);
  const [isDownloading, setIsDownloading] = useState(false);
  const [isScannerOpen, setIsScannerOpen] = useState(false);
  const [selectedMachine, setSelectedMachine] = useState<Machine | null>(null);
  const [machinePoints, setMachinePoints]       = useState<LubricationPoint[]>([]);
  const [activeTab, setActiveTab]        = useState<Tab>('tasks');
  const [anomalies, setAnomalies]        = useState<any[]>([]);

  const { user, profile, signOut } = useAuth();

  // Redirect supervisor to their dashboard
  useEffect(() => {
    if (profile?.role === 'supervisor' || profile?.role === 'admin') {
      router.push('/dashboard/supervisor');
    }
  }, [profile, router]);

  const {
    tasks,
    shiftName,
    isSyncing,
    hasUnsyncedChanges,
    isHydrated,
    hydrate,
    loadTasks,
    completeTask,
    reportAnomaly,
    syncWithCloud,
  } = useRouteStore();

  useEffect(() => {
    setMounted(true);
    setIsOnline(navigator.onLine);
    hydrate();

    const onOnline  = () => setIsOnline(true);
    const onOffline = () => setIsOnline(false);
    window.addEventListener('online', onOnline);
    window.addEventListener('offline', onOffline);
    return () => {
      window.removeEventListener('online', onOnline);
      window.removeEventListener('offline', onOffline);
    };
  }, [hydrate]);

  // Auto-sync cuando vuelve la conexión
  useEffect(() => {
    if (isOnline && hasUnsyncedChanges && !isSyncing) {
      syncWithCloud();
    }
  }, [isOnline, hasUnsyncedChanges, isSyncing, syncWithCloud]);

  // Cargar anomalías cuando se abre esa tab
  const loadAnomalies = useCallback(async () => {
    if (!user) return;
    const supabase = createClient();
    const { data } = await supabase
      .from('anomaly_reports')
      .select(`
        id, anomaly_type, description, created_at, resolved,
        lubrication_points (
          description,
          machines ( position_code, model_name )
        )
      `)
      .eq('user_id', user.id)
      .order('created_at', { ascending: false })
      .limit(20);
    setAnomalies(data || []);
  }, [user]);

  useEffect(() => {
    if (activeTab === 'anomalies') loadAnomalies();
  }, [activeTab, loadAnomalies]);

  const handleScan = async (code: string) => {
    setIsScannerOpen(false);
    const machine = await getMachineByCode(code);
    if (machine) {
      const points = await getMachinePoints(machine.id);
      setSelectedMachine(machine);
      setMachinePoints(points);
    }
  };

  const handleDownloadRoute = async () => {
    if (!user) return;
    setIsDownloading(true);
    try {
      const liveTasks = await syncEngine.pullTasks(user.id);
      if (liveTasks && liveTasks.length > 0) {
        await loadTasks(liveTasks, 'Ruta del Turno');
      } else {
        alert('No hay ruta disponible. Verifica la asignación con el supervisor.');
      }
    } catch {
      alert('Error al descargar ruta. Verifica tu conexión.');
    } finally {
      setIsDownloading(false);
    }
  };

  if (!mounted || !isHydrated) {
    return (
      <div className="min-h-[100dvh] flex items-center justify-center bg-[#05070a]">
        <div className="w-8 h-8 border-2 border-cyan-500 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  const pending   = tasks.filter(t => t.status === 'pending').length;
  const completed = tasks.filter(t => t.status === 'completed').length;
  const progress  = tasks.length > 0 ? (completed / tasks.length) * 100 : 0;

  return (
    <div className="min-h-[100dvh] flex flex-col pb-20 bg-[#05070a] scada-grid text-slate-200">

      {/* Header */}
      <header className="sticky top-0 z-50 bg-[#05070a]/95 backdrop-blur-xl border-b border-white/5 px-4 pt-10 pb-4">
        <div className="flex justify-between items-start mb-4">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <div className={cn('w-1.5 h-1.5 rounded-full', isOnline ? 'bg-emerald-400 shadow-[0_0_6px_#34d399]' : 'bg-red-500')} />
              <span className="tech-label text-[0.55rem] tracking-[0.15em]">
                {isOnline ? 'EN LÍNEA' : 'SIN CONEXIÓN'}
              </span>
              {hasUnsyncedChanges && (
                <span className="tech-label text-[0.5rem] text-amber-400 tracking-wide">· SYNC PENDIENTE</span>
              )}
            </div>
            <h1 className="text-xl font-black tracking-tighter text-white uppercase">
              {profile?.full_name?.split(' ')[0] || 'Lubricador'}
              <span className="text-cyan-400 font-light ml-2 normal-case text-base not-italic tracking-normal">
                {shiftName || 'BITACORA'}
              </span>
            </h1>
          </div>

          <div className="flex items-center gap-2">
            {isSyncing && (
              <RefreshCw size={14} className="text-cyan-400 animate-spin" />
            )}
            <button
              onClick={() => { if (confirm('¿Cerrar sesión?')) signOut(); }}
              className="p-2 text-slate-600 hover:text-red-400 transition-colors"
            >
              <LogOut size={17} />
            </button>
            <div className="w-8 h-8 bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center">
              <UserCircle size={18} className="text-cyan-400" />
            </div>
          </div>
        </div>

        {/* Progress bar — solo si hay tareas */}
        {tasks.length > 0 && (
          <div className="space-y-1.5">
            <div className="flex justify-between items-center">
              <span className="tech-label text-[0.5rem] text-slate-600">CUMPLIMIENTO</span>
              <span className="font-mono font-black text-sm text-cyan-400">{Math.round(progress)}%</span>
            </div>
            <div className="h-[3px] w-full bg-white/5 overflow-hidden">
              <motion.div
                className="h-full bg-cyan-500 shadow-[0_0_8px_rgba(0,242,255,0.6)]"
                initial={{ width: 0 }}
                animate={{ width: `${progress}%` }}
                transition={{ duration: 0.8, ease: 'easeOut' }}
              />
            </div>
            <div className="flex justify-between text-[0.5rem] font-mono text-slate-700">
              <span>{completed} COMPLETADOS</span>
              <span>{pending} PENDIENTES</span>
            </div>
          </div>
        )}
      </header>

      {/* Main */}
      <main className="flex-1 px-4 py-5">
        <AnimatePresence mode="wait">

          {/* TAB: TAREAS */}
          {activeTab === 'tasks' && (
            <motion.div key="tasks" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
              {tasks.length === 0 ? (
                <div className="flex flex-col items-center justify-center min-h-[50vh] gap-6 text-center">
                  <div className="w-16 h-16 border border-dashed border-white/10 flex items-center justify-center">
                    <Map size={28} className="text-white/20" />
                  </div>
                  <div>
                    <p className="tech-label text-slate-500 mb-1">SIN RUTA ACTIVA</p>
                    <p className="text-xs text-slate-700">Descarga tu ruta para comenzar el turno</p>
                  </div>
                  <button
                    onClick={handleDownloadRoute}
                    disabled={!isOnline || isDownloading}
                    className="scada-button py-4 px-8 text-sm disabled:opacity-30"
                  >
                    {isDownloading
                      ? <><div className="w-4 h-4 border border-cyan-500 border-t-transparent rounded-full animate-spin" /> DESCARGANDO...</>
                      : <><Download size={16} /> INICIAR RUTA</>
                    }
                  </button>
                </div>
              ) : (
                <div className="grid grid-cols-1 gap-3">
                  {tasks.map(t => (
                    <TaskCard
                      key={t.id}
                      {...t}
                      onComplete={(id, g) => { void completeTask(id, user?.id || 'offline', g); }}
                      onAnomaly={(id, type, desc) => { void reportAnomaly(id, user?.id || 'offline', type, desc); }}
                    />
                  ))}
                </div>
              )}
            </motion.div>
          )}

          {/* TAB: ANOMALÍAS */}
          {activeTab === 'anomalies' && (
            <motion.div key="anomalies" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
              <div className="space-y-3">
                <h2 className="tech-label text-slate-500 px-1 mb-4">MIS REPORTES DE ANOMALÍAS</h2>
                {anomalies.length === 0 ? (
                  <div className="text-center py-16 text-slate-700">
                    <AlertOctagon size={32} className="mx-auto mb-3 opacity-30" />
                    <p className="tech-label">SIN ANOMALÍAS REPORTADAS</p>
                  </div>
                ) : anomalies.map((a: any) => {
                  const machine = a.lubrication_points?.machines;
                  return (
                    <div key={a.id} className="glass-card px-4 py-3 border-l-4 border-l-red-500/60">
                      <div className="flex items-start justify-between gap-3">
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-1">
                            <span className="tech-label text-[0.5rem] text-slate-600">
                              {machine?.position_code} · {machine?.model_name}
                            </span>
                            <span className={cn(
                              'tech-label text-[0.5rem] px-1.5 py-0.5',
                              a.resolved ? 'text-emerald-500 bg-emerald-500/10' : 'text-red-400 bg-red-500/10'
                            )}>
                              {a.anomaly_type?.toUpperCase()}
                            </span>
                          </div>
                          <p className="text-sm font-medium text-white/80 truncate">
                            {a.lubrication_points?.description}
                          </p>
                          {a.description && (
                            <p className="text-xs text-slate-500 mt-0.5 italic">"{a.description}"</p>
                          )}
                        </div>
                        <span className="text-[0.55rem] tech-label text-slate-700 shrink-0 mt-0.5">
                          {new Date(a.created_at).toLocaleDateString('es-CL')}
                        </span>
                      </div>
                    </div>
                  );
                })}
              </div>
            </motion.div>
          )}

          {/* TAB: PERFIL */}
          {activeTab === 'profile' && (
            <motion.div key="profile" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
              <div className="space-y-4 max-w-sm mx-auto pt-4">
                <div className="glass-card p-6 flex flex-col items-center gap-3 text-center">
                  <div className="w-16 h-16 bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center">
                    <User2 size={28} className="text-cyan-400" />
                  </div>
                  <div>
                    <h3 className="font-black text-white text-lg tracking-tight">{profile?.full_name || 'Usuario'}</h3>
                    <p className="tech-label text-cyan-400 text-[0.6rem]">{profile?.role?.toUpperCase()}</p>
                    <p className="text-xs text-slate-600 mt-1">{profile?.email}</p>
                  </div>
                </div>

                <div className="glass-card divide-y divide-white/5">
                  <div className="px-4 py-3 flex justify-between items-center">
                    <span className="tech-label text-[0.6rem]">TAREAS HOY</span>
                    <span className="font-mono font-black text-white">{tasks.length}</span>
                  </div>
                  <div className="px-4 py-3 flex justify-between items-center">
                    <span className="tech-label text-[0.6rem]">COMPLETADAS</span>
                    <span className="font-mono font-black text-emerald-400">{completed}</span>
                  </div>
                  <div className="px-4 py-3 flex justify-between items-center">
                    <span className="tech-label text-[0.6rem]">SYNC PENDIENTE</span>
                    <span className={cn('font-mono font-black text-xs', hasUnsyncedChanges ? 'text-amber-400' : 'text-slate-600')}>
                      {hasUnsyncedChanges ? 'SÍ' : 'NO'}
                    </span>
                  </div>
                </div>

                {hasUnsyncedChanges && isOnline && (
                  <button
                    onClick={() => syncWithCloud()}
                    className="scada-button w-full py-3 text-sm"
                  >
                    <RefreshCw size={16} /> SINCRONIZAR AHORA
                  </button>
                )}

                <button
                  onClick={() => { if (confirm('¿Cerrar sesión?')) signOut(); }}
                  className="scada-button w-full py-3 text-sm border-red-500/30 text-red-400 hover:bg-red-500/10"
                >
                  <LogOut size={16} /> CERRAR SESIÓN
                </button>
              </div>
            </motion.div>
          )}

        </AnimatePresence>
      </main>

      {/* Overlays */}
      {isScannerOpen && (
        <MachineScanner onScan={handleScan} onClose={() => setIsScannerOpen(false)} />
      )}
      {selectedMachine && (
        <MachineDetailSheet
          machine={selectedMachine}
          points={machinePoints}
          onClose={() => setSelectedMachine(null)}
        />
      )}

      {/* Bottom Tab Bar */}
      <nav className="fixed bottom-0 left-0 right-0 h-16 bg-[#05070a]/95 backdrop-blur-xl border-t border-white/5 flex justify-around items-center px-2 z-[60]">
        <TabBtn
          icon={<LayoutGrid size={20} />}
          label="TAREAS"
          active={activeTab === 'tasks'}
          onClick={() => setActiveTab('tasks')}
          badge={pending > 0 ? pending : undefined}
        />

        <TabBtn
          icon={<Map size={20} />}
          label="PLANOS"
          active={false}
          onClick={() => setIsScannerOpen(true)}
        />

        {/* Central QR button */}
        <div className="relative -top-5">
          <motion.button
            whileTap={{ scale: 0.93 }}
            onClick={() => setIsScannerOpen(true)}
            className="w-14 h-14 bg-cyan-500 text-[#05070a] flex items-center justify-center shadow-[0_0_24px_rgba(0,242,255,0.35)] border-2 border-[#05070a]"
          >
            <QrCode size={26} />
          </motion.button>
        </div>

        <TabBtn
          icon={<AlertOctagon size={20} />}
          label="ANOMALÍAS"
          active={activeTab === 'anomalies'}
          onClick={() => setActiveTab('anomalies')}
        />

        <TabBtn
          icon={<User2 size={20} />}
          label="PERFIL"
          active={activeTab === 'profile'}
          onClick={() => setActiveTab('profile')}
        />
      </nav>
    </div>
  );
}

function TabBtn({
  icon, label, active, onClick, badge
}: {
  icon: React.ReactNode;
  label: string;
  active: boolean;
  onClick: () => void;
  badge?: number;
}) {
  return (
    <button
      onClick={onClick}
      className={cn(
        'flex flex-col items-center gap-1 transition-colors relative px-2',
        active ? 'text-cyan-400' : 'text-slate-600 hover:text-slate-400'
      )}
    >
      {icon}
      <span className="tech-label text-[0.45rem] tracking-[0.1em]">{label}</span>
      {badge !== undefined && (
        <span className="absolute -top-1 -right-0 bg-cyan-500 text-[#05070a] text-[0.45rem] font-black px-1 min-w-[14px] text-center leading-[14px]">
          {badge}
        </span>
      )}
    </button>
  );
}
