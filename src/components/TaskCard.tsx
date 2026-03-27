import React, { useState } from 'react';
import { CheckCircle2, AlertTriangle, X, ChevronDown, ChevronUp, Droplets, Wrench, Flame } from 'lucide-react';
import { cn } from '@/lib/utils';
import type { TaskType, TaskStatus, AnomalyType } from '@/types/database';
import { motion, AnimatePresence } from 'framer-motion';
import confetti from 'canvas-confetti';

export interface TaskProps {
  id: string;
  machineName: string;
  positionCode: string;
  taskType: TaskType;
  description: string;
  status: TaskStatus | 'pending';
  lubricantName?: string;
  grammage?: number;
  pumps?: number;
  isManual?: boolean;
  pointId: string;
  onComplete: (id: string, grammage?: number) => void;
  onAnomaly: (id: string, anomalyType: AnomalyType, description?: string) => void;
}

const ANOMALY_TYPES: { type: AnomalyType; label: string; color: string }[] = [
  { type: 'leak',        label: 'Fuga',        color: 'text-orange-400' },
  { type: 'noise',       label: 'Ruido',       color: 'text-yellow-400' },
  { type: 'vibration',   label: 'Vibración',   color: 'text-purple-400' },
  { type: 'temperature', label: 'Temperatura', color: 'text-red-400'    },
  { type: 'other',       label: 'Otro',        color: 'text-slate-400'  },
];

export function TaskCard({
  id,
  machineName,
  positionCode,
  taskType,
  description,
  status,
  lubricantName,
  grammage,
  pumps,
  isManual,
  onComplete,
  onAnomaly,
}: TaskProps) {
  const [showGrammage, setShowGrammage] = useState(false);
  const [showAnomaly, setShowAnomaly]   = useState(false);
  const [inputGrams, setInputGrams]     = useState(grammage ? String(grammage) : '');
  const [anomalyDesc, setAnomalyDesc]   = useState('');
  const [expanded, setExpanded]         = useState(false);

  const isLube      = taskType === 'lubrication';
  const isCompleted = status === 'completed';
  const isPending   = status === 'pending';
  const isSkipped   = status === 'skipped';
  const isCritical  = lubricantName?.includes('LGLT 2') || lubricantName?.includes('SKF');

  const handleCompletePress = () => {
    // Si es lubricación y no hay gramaje definido → pedir al usuario
    if (isLube && !grammage) {
      setShowGrammage(true);
      return;
    }
    fireConfetti();
    onComplete(id, grammage);
  };

  const handleGrammageConfirm = () => {
    const grams = parseFloat(inputGrams);
    fireConfetti();
    onComplete(id, isNaN(grams) ? undefined : grams);
    setShowGrammage(false);
  };

  const handleAnomalySubmit = (type: AnomalyType) => {
    onAnomaly(id, type, anomalyDesc || undefined);
    setShowAnomaly(false);
    setAnomalyDesc('');
  };

  const fireConfetti = () => {
    confetti({
      particleCount: 80,
      spread: 60,
      origin: { y: 0.65 },
      colors: ['#00f2ff', '#00ff41', '#f97316'],
      scalar: 0.8,
    });
  };

  const doseLabel = grammage ? `${grammage}g` : pumps ? `${pumps} punt.` : null;

  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      className={cn(
        'glass-card flex flex-col relative',
        isCritical  ? 'task-type-critical' : isLube ? 'task-type-lube' : 'task-type-inspect',
        !isPending  && 'opacity-55 saturate-0 pointer-events-none',
        isCompleted && 'pointer-events-none',
      )}
    >
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-2 bg-white/[0.03] border-b border-white/10">
        <div className="flex items-center gap-2">
          <div className={cn('status-indicator', isPending ? 'status-online' : 'status-offline')} />
          <span className="tech-label">{positionCode}</span>
        </div>
        <div className="flex items-center gap-3">
          <span className={cn('tech-label text-[0.55rem]', isLube ? 'text-cyan-500' : 'text-purple-400')}>
            {isLube ? 'LUBRICACIÓN' : 'INSPECCIÓN'}
          </span>
          <button onClick={() => setExpanded(v => !v)} className="text-slate-600 hover:text-slate-300 transition-colors">
            {expanded ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
          </button>
        </div>
      </div>

      {/* Body */}
      <div className="p-4 flex flex-col gap-3">
        {/* Machine name + description */}
        <div>
          <h3 className="text-white font-black text-base tracking-tight uppercase leading-tight">
            {machineName.replace(positionCode, '').trim() || machineName}
          </h3>
          <p className="text-slate-400 text-xs mt-0.5 font-medium">{description}</p>
        </div>

        {/* Technical data row */}
        {isLube && lubricantName && (
          <div className="grid grid-cols-2 gap-px bg-white/5 border border-white/10 text-[0.65rem]">
            <div className="bg-[#05070a] px-3 py-2 flex flex-col gap-0.5">
              <span className="tech-label text-[0.5rem]">LUBRICANTE</span>
              <span className={cn('font-mono font-bold truncate', isCritical ? 'text-red-400 animate-pulse' : 'text-cyan-300')}>
                {lubricantName}
              </span>
            </div>
            <div className="bg-[#05070a] px-3 py-2 flex flex-col gap-0.5">
              <span className="tech-label text-[0.5rem]">DOSIS ESTIM.</span>
              <span className="font-mono font-bold text-emerald-400">
                {doseLabel || <span className="text-slate-600">—</span>}
              </span>
            </div>
            {isCritical && (
              <div className="col-span-2 bg-red-500/10 border-t border-red-500/30 px-3 py-1.5 flex items-center gap-2">
                <Flame size={12} className="text-red-400 shrink-0" />
                <span className="tech-label text-red-400 font-black">CRÍTICO: SOLO SKF LGLT 2 — NO SUSTITUIR</span>
              </div>
            )}
          </div>
        )}

        {/* Expanded details */}
        <AnimatePresence>
          {expanded && (
            <motion.div
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: 'auto', opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              className="overflow-hidden"
            >
              <div className="border border-white/5 bg-white/[0.02] px-3 py-2 text-[0.6rem] font-mono space-y-1">
                <p className="text-slate-500"><span className="text-slate-400">POSICIÓN:</span> {positionCode}</p>
                {pumps && <p className="text-slate-500"><span className="text-slate-400">NUM_PUNTOS:</span> {pumps}</p>}
                {isManual && <p className="text-yellow-500 font-bold">⚡ APLICACIÓN MANUAL — registrar gramaje real</p>}
                {isCritical && <p className="text-red-400 font-bold">⚠ Group IV — Grasa sintética PAO específica</p>}
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Action buttons */}
        {isPending && (
          <div className="flex gap-2 mt-1">
            <motion.button
              whileTap={{ scale: 0.97 }}
              onClick={handleCompletePress}
              className={cn('scada-button flex-1 py-3 text-sm', isLube && 'scada-button-success')}
            >
              {isLube ? <><Droplets size={16} /> INYECTAR</> : <><Wrench size={16} /> CONFIRMAR</>}
            </motion.button>
            <motion.button
              whileTap={{ scale: 0.97 }}
              onClick={() => setShowAnomaly(true)}
              className="scada-button py-3 px-3 border-red-500/40 text-red-400 hover:bg-red-500/10"
            >
              <AlertTriangle size={16} />
            </motion.button>
          </div>
        )}
      </div>

      {/* Completed overlay */}
      <AnimatePresence>
        {isCompleted && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="absolute inset-0 bg-emerald-500/5 flex items-center justify-center z-20"
          >
            <div className="bg-[#05070a] border border-emerald-500/50 text-emerald-400 px-5 py-1.5 font-black tech-label tracking-widest shadow-[0_0_20px_rgba(16,185,129,0.2)]">
              ✓ COMPLETADO
            </div>
          </motion.div>
        )}
        {isSkipped && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="absolute inset-0 bg-slate-800/50 flex items-center justify-center z-20"
          >
            <div className="bg-[#05070a] border border-slate-600 text-slate-500 px-5 py-1.5 font-black tech-label tracking-widest">
              OMITIDO
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Grammage Input Modal */}
      <AnimatePresence>
        {showGrammage && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 bg-[#05070a]/95 flex flex-col items-center justify-center gap-4 z-30 p-6"
          >
            <div className="w-full max-w-xs flex flex-col gap-3">
              <span className="tech-label text-cyan-400 text-center">REGISTRAR DOSIS APLICADA</span>
              <div className="flex items-center border border-cyan-500/50 bg-black/50">
                <input
                  autoFocus
                  type="number"
                  inputMode="decimal"
                  min="0"
                  step="0.5"
                  placeholder="0"
                  value={inputGrams}
                  onChange={e => setInputGrams(e.target.value)}
                  className="flex-1 bg-transparent text-white text-2xl font-black text-center py-4 outline-none font-mono"
                />
                <span className="text-slate-400 font-mono font-bold px-4 text-sm">g</span>
              </div>
              <p className="text-[0.55rem] text-slate-600 text-center font-mono">
                Dejar en 0 si la cantidad es estándar
              </p>
              <div className="flex gap-2">
                <button
                  onClick={() => setShowGrammage(false)}
                  className="scada-button flex-1 py-3 border-slate-700 text-slate-500 text-xs"
                >
                  <X size={14} /> CANCELAR
                </button>
                <button
                  onClick={handleGrammageConfirm}
                  className="scada-button scada-button-success flex-1 py-3 text-xs"
                >
                  <CheckCircle2 size={14} /> CONFIRMAR
                </button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Anomaly Type Modal */}
      <AnimatePresence>
        {showAnomaly && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 bg-[#05070a]/95 flex flex-col justify-center gap-4 z-30 p-5"
          >
            <div className="flex items-center justify-between">
              <span className="tech-label text-red-400">TIPO DE ANOMALÍA</span>
              <button onClick={() => setShowAnomaly(false)} className="text-slate-600 hover:text-slate-300">
                <X size={16} />
              </button>
            </div>
            <div className="grid grid-cols-2 gap-2">
              {ANOMALY_TYPES.map(({ type, label, color }) => (
                <button
                  key={type}
                  onClick={() => handleAnomalySubmit(type)}
                  className={cn('scada-button py-3 text-xs border-white/10 hover:bg-white/5 flex-col gap-1', color)}
                >
                  <span className="font-black">{label.toUpperCase()}</span>
                </button>
              ))}
            </div>
            <textarea
              placeholder="Descripción breve (opcional)..."
              value={anomalyDesc}
              onChange={e => setAnomalyDesc(e.target.value)}
              rows={2}
              className="bg-black/50 border border-white/10 text-white text-xs p-3 resize-none outline-none font-mono placeholder:text-slate-700"
            />
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
