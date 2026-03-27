"use client";

import React, { useEffect, useState, useCallback } from 'react';
import { useAuth } from '@/lib/auth/auth-context';
import { createClient } from '@/lib/supabase/client';
import {
  TrendingUp, AlertCircle, Users, Clock, ChevronRight,
  Droplet, CheckCircle2, Settings, LogOut, Bell, RefreshCw,
  Map, BarChart3, Activity, ArrowUpRight, ArrowDownRight
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { motion } from 'framer-motion';

interface AreaStat {
  name: string;
  total: number;
  completed: number;
}

export default function SupervisorDashboard() {
  const { user, profile, signOut } = useAuth();
  const supabase = createClient();

  const [stats, setStats] = useState({
    totalTasks: 0,
    completedTasks: 0,
    activeAnomalies: 0,
    activeLubricators: 0,
  });
  const [recentAnomalies, setRecentAnomalies] = useState<any[]>([]);
  const [areaStats, setAreaStats]             = useState<AreaStat[]>([]);
  const [isLoading, setIsLoading]             = useState(true);
  const [lastRefresh, setLastRefresh]         = useState(new Date());

  const fetchStats = useCallback(async () => {
    if (!user) return;
    setIsLoading(true);
    const today = new Date().toISOString().split('T')[0];

    try {
      // Tasks de hoy
      const { data: rawTasks } = await supabase
        .from('daily_tasks')
        .select('status, assigned_user_id')
        .eq('scheduled_date', today);

      const tasks = (rawTasks || []) as Array<{ status: string; assigned_user_id: string }>;
      const total     = tasks.length;
      const completed = tasks.filter(t => t.status === 'completed').length;

      // Anomalías abiertas
      const { data: anomalies } = await supabase
        .from('anomaly_reports')
        .select(`
          id, anomaly_type, description, created_at, resolved,
          lubrication_points (
            description,
            machines ( position_code, model_name )
          )
        `)
        .eq('resolved', false)
        .order('created_at', { ascending: false })
        .limit(10);

      // Lubricadores activos
      const { count: lubCount } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true })
        .eq('role', 'lubricator');

      // Progreso por área
      const { data: machines } = await supabase
        .from('machines')
        .select('id, areas(name)');

      const areaMap: Record<string, AreaStat> = {};
      if (machines) {
        for (const m of machines) {
          const areaName = (m as any).areas?.name || 'Sin área';
          if (!areaMap[areaName]) areaMap[areaName] = { name: areaName, total: 0, completed: 0 };

          // Contar tareas de esta máquina hoy
          const machineTasks = tasks?.filter(() => true) || []; // tasks ya están cargadas
          // Simplificado: usamos proporción de tareas totales por área
          areaMap[areaName].total += 1; // 1 máquina = 1 unidad
        }
      }

      // Calcular progreso real por área desde tasks
      const { data: tasksWithMachine } = await supabase
        .from('daily_tasks')
        .select(`
          status,
          lubrication_points (
            machine_id,
            machines ( areas ( name ) )
          )
        `)
        .eq('scheduled_date', today);

      const areaProgress: Record<string, { total: number; completed: number }> = {};
      if (tasksWithMachine) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        for (const t of tasksWithMachine as any[]) {
          const areaName = t.lubrication_points?.machines?.areas?.name || 'Sin área';
          if (!areaProgress[areaName]) areaProgress[areaName] = { total: 0, completed: 0 };
          areaProgress[areaName].total += 1;
          if (t.status === 'completed') areaProgress[areaName].completed += 1;
        }
      }

      setStats({ totalTasks: total, completedTasks: completed, activeAnomalies: anomalies?.length || 0, activeLubricators: lubCount || 0 });
      setRecentAnomalies(anomalies || []);
      setAreaStats(
        Object.entries(areaProgress).map(([name, v]) => ({ name, ...v }))
      );
    } catch (err) {
      console.error('fetchStats error:', err);
    } finally {
      setIsLoading(false);
      setLastRefresh(new Date());
    }
  }, [user, supabase]);

  useEffect(() => {
    fetchStats();
    const interval = setInterval(fetchStats, 5 * 60 * 1000); // refresh cada 5 min
    return () => clearInterval(interval);
  }, [fetchStats]);

  const compliance = stats.totalTasks > 0
    ? Math.round((stats.completedTasks / stats.totalTasks) * 100)
    : 0;

  if (isLoading) {
    return (
      <div className="min-h-screen bg-[#05070a] flex items-center justify-center">
        <div className="w-10 h-10 border-2 border-cyan-500 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#05070a] text-slate-200 font-sans">

      {/* Sidebar — desktop */}
      <aside className="fixed left-0 top-0 bottom-0 w-60 bg-[#07090d] border-r border-white/[0.04] hidden lg:flex flex-col p-5 z-50">
        <div className="flex items-center gap-2.5 mb-8">
          <div className="w-8 h-8 bg-cyan-500 flex items-center justify-center">
            <Droplet className="text-[#05070a]" size={18} />
          </div>
          <div>
            <p className="text-white font-black text-sm tracking-tighter">LUBRICONTROL</p>
            <p className="tech-label text-[0.5rem] text-slate-600">SUPERVISIÓN</p>
          </div>
        </div>

        <nav className="flex-1 space-y-1">
          {[
            { icon: <BarChart3 size={16} />, label: 'Dashboard',    active: true  },
            { icon: <Map size={16} />,       label: 'Mapa Planta',  active: false },
            { icon: <AlertCircle size={16} />, label: 'Anomalías', active: false, badge: stats.activeAnomalies },
            { icon: <Users size={16} />,     label: 'Equipo',       active: false },
            { icon: <Activity size={16} />,  label: 'Historial',    active: false },
          ].map(item => (
            <button
              key={item.label}
              className={cn(
                'w-full flex items-center gap-3 px-3 py-2.5 text-xs font-bold transition-all',
                item.active
                  ? 'bg-cyan-500/10 text-cyan-400 border-l border-cyan-500'
                  : 'text-slate-600 hover:text-slate-300 hover:bg-white/[0.03]'
              )}
            >
              {item.icon}
              <span className="flex-1 text-left tracking-wide">{item.label}</span>
              {item.badge ? (
                <span className="bg-red-500 text-white text-[0.5rem] px-1.5 py-0.5 font-black">
                  {item.badge}
                </span>
              ) : null}
            </button>
          ))}
        </nav>

        <div className="pt-4 border-t border-white/5">
          <div className="flex items-center gap-2.5 p-3 bg-white/[0.02] border border-white/5 mb-3">
            <div className="w-8 h-8 bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center">
              <span className="text-emerald-400 text-xs font-black">
                {(profile?.full_name || 'SU').slice(0, 2).toUpperCase()}
              </span>
            </div>
            <div className="flex-1 overflow-hidden">
              <p className="text-xs font-bold truncate text-white">{profile?.full_name}</p>
              <p className="tech-label text-[0.5rem] text-slate-600">{profile?.role?.toUpperCase()}</p>
            </div>
          </div>
          <button
            onClick={() => signOut()}
            className="w-full flex items-center gap-2 px-3 py-2 text-slate-600 hover:text-red-400 transition-colors text-xs font-bold"
          >
            <LogOut size={14} /> CERRAR SESIÓN
          </button>
        </div>
      </aside>

      {/* Main */}
      <main className="lg:ml-60 min-h-screen flex flex-col">

        {/* Top header */}
        <header className="h-16 border-b border-white/[0.04] bg-[#05070a]/80 backdrop-blur-xl sticky top-0 z-40 px-6 flex items-center justify-between">
          <div>
            <p className="tech-label text-[0.5rem] text-slate-600 mb-0.5">SUPERVISIÓN · {new Date().toLocaleDateString('es-CL', { weekday: 'long', day: 'numeric', month: 'long' })}</p>
            <h2 className="text-sm font-black text-white tracking-tight uppercase">Panel Operativo</h2>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={fetchStats}
              className="p-2 text-slate-600 hover:text-cyan-400 transition-colors"
              title={`Actualizado: ${lastRefresh.toLocaleTimeString()}`}
            >
              <RefreshCw size={16} />
            </button>
            <button className="p-2 text-slate-600 hover:text-white transition-colors relative">
              <Bell size={16} />
              {stats.activeAnomalies > 0 && (
                <span className="absolute top-1.5 right-1.5 w-1.5 h-1.5 bg-red-500 rounded-full" />
              )}
            </button>
            <button className="p-2 text-slate-600 hover:text-white transition-colors">
              <Settings size={16} />
            </button>
          </div>
        </header>

        <div className="p-6 space-y-6 max-w-7xl mx-auto w-full">

          {/* KPI Cards */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard
              label="Cumplimiento"
              value={`${compliance}%`}
              sub={`${stats.completedTasks} / ${stats.totalTasks} tareas`}
              icon={<TrendingUp size={20} />}
              color="cyan"
              trend={compliance >= 80 ? 'up' : 'down'}
            />
            <KpiCard
              label="Anomalías"
              value={stats.activeAnomalies}
              sub="Pendientes de resolución"
              icon={<AlertCircle size={20} />}
              color={stats.activeAnomalies > 3 ? 'red' : 'amber'}
              trend={stats.activeAnomalies > 0 ? 'down' : 'up'}
            />
            <KpiCard
              label="Lubricadores"
              value={stats.activeLubricators}
              sub="Registrados en sistema"
              icon={<Users size={20} />}
              color="emerald"
            />
            <KpiCard
              label="Actualizado"
              value={lastRefresh.toLocaleTimeString('es-CL', { hour: '2-digit', minute: '2-digit' })}
              sub="Auto-refresh cada 5 min"
              icon={<Clock size={20} />}
              color="slate"
            />
          </div>

          {/* Compliance bar */}
          {stats.totalTasks > 0 && (
            <div className="bg-[#07090d] border border-white/[0.04] p-4 space-y-2">
              <div className="flex justify-between items-center">
                <span className="tech-label text-[0.55rem]">PROGRESO GLOBAL DEL TURNO</span>
                <span className="font-mono font-black text-cyan-400">{compliance}%</span>
              </div>
              <div className="h-2 w-full bg-white/5 overflow-hidden">
                <motion.div
                  className={cn(
                    'h-full',
                    compliance >= 80 ? 'bg-emerald-500' : compliance >= 50 ? 'bg-amber-500' : 'bg-red-500'
                  )}
                  initial={{ width: 0 }}
                  animate={{ width: `${compliance}%` }}
                  transition={{ duration: 1, ease: 'easeOut' }}
                />
              </div>
            </div>
          )}

          <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">

            {/* Anomalías recientes */}
            <div className="xl:col-span-2 space-y-3">
              <SectionTitle icon={<AlertCircle size={14} />} label="Últimas Anomalías" />
              {recentAnomalies.length === 0 ? (
                <div className="flex flex-col items-center justify-center py-12 bg-[#07090d] border border-white/[0.04] gap-3 opacity-50">
                  <CheckCircle2 size={32} className="text-emerald-500" />
                  <p className="tech-label text-slate-500">SIN ANOMALÍAS PENDIENTES</p>
                </div>
              ) : (
                <div className="space-y-2">
                  {recentAnomalies.map(anomaly => (
                    <AnomalyRow key={anomaly.id} anomaly={anomaly} />
                  ))}
                </div>
              )}
            </div>

            {/* Estado por Área */}
            <div className="space-y-3">
              <SectionTitle icon={<Map size={14} />} label="Estado por Área" />
              <div className="bg-[#07090d] border border-white/[0.04] p-5 space-y-5">
                {areaStats.length === 0 ? (
                  // Fallback con áreas conocidas si no hay tasks asignadas
                  <>
                    <AreaBar label="Línea Principal Kallfass" progress={compliance} />
                    <AreaBar label="Bruks" progress={0} />
                    <AreaBar label="SORSA" progress={0} />
                  </>
                ) : (
                  areaStats.map(a => (
                    <AreaBar
                      key={a.name}
                      label={a.name}
                      progress={a.total > 0 ? Math.round((a.completed / a.total) * 100) : 0}
                    />
                  ))
                )}
                <div className="pt-4 border-t border-white/5">
                  <button className="w-full py-3 bg-cyan-500 text-[#05070a] font-black text-xs tracking-widest hover:bg-cyan-400 transition-colors">
                    GENERAR REPORTE PDF
                  </button>
                </div>
              </div>
            </div>

          </div>
        </div>
      </main>
    </div>
  );
}

function KpiCard({ label, value, sub, icon, color, trend }: any) {
  const colors: Record<string, string> = {
    cyan:    'text-cyan-400 bg-cyan-500/10',
    red:     'text-red-400 bg-red-500/10',
    amber:   'text-amber-400 bg-amber-500/10',
    emerald: 'text-emerald-400 bg-emerald-500/10',
    slate:   'text-slate-400 bg-white/5',
  };
  return (
    <div className="bg-[#07090d] border border-white/[0.04] p-4 space-y-3 hover:border-white/10 transition-colors">
      <div className="flex items-center justify-between">
        <div className={cn('p-2', colors[color] || colors.slate)}>
          <span className={colors[color]?.split(' ')[0]}>{icon}</span>
        </div>
        {trend && (
          trend === 'up'
            ? <ArrowUpRight size={14} className="text-emerald-500" />
            : <ArrowDownRight size={14} className="text-red-400" />
        )}
      </div>
      <div>
        <p className="text-2xl font-black text-white tracking-tighter">{value}</p>
        <p className="tech-label text-[0.55rem] text-slate-500 mt-0.5">{label}</p>
        <p className="text-[0.6rem] text-slate-700 mt-1">{sub}</p>
      </div>
    </div>
  );
}

function SectionTitle({ icon, label }: { icon: React.ReactNode; label: string }) {
  return (
    <div className="flex items-center gap-2 text-slate-500">
      {icon}
      <span className="tech-label text-[0.55rem] tracking-widest">{label.toUpperCase()}</span>
    </div>
  );
}

function AnomalyRow({ anomaly }: { anomaly: any }) {
  const machine = anomaly.lubrication_points?.machines;
  const point   = anomaly.lubrication_points;
  const colorMap: Record<string, string> = {
    leak: 'border-l-orange-500', noise: 'border-l-yellow-500',
    vibration: 'border-l-purple-500', temperature: 'border-l-red-500', other: 'border-l-slate-600',
  };
  return (
    <div className={cn('bg-[#07090d] border border-white/[0.04] border-l-2 p-4 flex items-center gap-3 group hover:bg-white/[0.01] transition-colors', colorMap[anomaly.anomaly_type] || 'border-l-slate-600')}>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-1">
          <span className="tech-label text-[0.5rem] text-slate-600">
            {machine?.position_code} · {machine?.model_name}
          </span>
          <span className="tech-label text-[0.5rem] text-red-400 bg-red-500/10 px-1.5 py-0.5">
            {anomaly.anomaly_type?.toUpperCase()}
          </span>
        </div>
        <p className="text-sm font-bold text-white/80 truncate">{point?.description}</p>
        {anomaly.description && (
          <p className="text-xs text-slate-600 mt-0.5 italic truncate">"{anomaly.description}"</p>
        )}
      </div>
      <div className="flex flex-col items-end gap-2 shrink-0">
        <span className="tech-label text-[0.5rem] text-slate-700">
          {new Date(anomaly.created_at).toLocaleDateString('es-CL')}
        </span>
        <button className="p-1.5 bg-cyan-500/10 text-cyan-400 opacity-0 group-hover:opacity-100 transition-opacity">
          <ChevronRight size={14} />
        </button>
      </div>
    </div>
  );
}

function AreaBar({ label, progress }: { label: string; progress: number }) {
  return (
    <div className="space-y-1.5">
      <div className="flex justify-between items-center">
        <span className="text-xs font-bold text-slate-300">{label}</span>
        <span className="tech-label text-[0.5rem] text-slate-500 font-mono">{progress}%</span>
      </div>
      <div className="h-1 w-full bg-white/5 overflow-hidden">
        <motion.div
          className={cn(
            'h-full transition-all',
            progress >= 80 ? 'bg-emerald-500' : progress >= 50 ? 'bg-amber-500' : progress > 0 ? 'bg-red-500' : 'bg-white/10'
          )}
          initial={{ width: 0 }}
          animate={{ width: `${progress}%` }}
          transition={{ duration: 1, ease: 'easeOut' }}
        />
      </div>
    </div>
  );
}
