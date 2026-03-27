import React, { useState } from 'react';
import { X, Info, Settings, Wrench, ClipboardList, ChevronRight, Droplet } from 'lucide-react';
import { cn } from '@/lib/utils';
import type { Machine, LubricationPoint } from '@/types/database';
import { BlueprintOverlay } from './BlueprintOverlay';

interface MachineDetailSheetProps {
  machine: Machine;
  points: LubricationPoint[];
  onClose: () => void;
}

export function MachineDetailSheet({ machine, points, onClose }: MachineDetailSheetProps) {
  const [showBlueprint, setShowBlueprint] = useState(false);
  return (
    <div className="fixed inset-0 z-[110] bg-black/60 backdrop-blur-sm flex items-end sm:items-center sm:justify-center">
      <div 
        className="w-full sm:max-w-lg bg-[#0a0e17] rounded-t-[2.5rem] sm:rounded-3xl border-t sm:border border-white/10 shadow-2xl flex flex-col max-h-[90vh] animate-slide-up"
      >
        {/* Header */}
        <div className="relative p-6 pb-4">
          <div className="flex justify-between items-start">
            <div className="flex-1">
              <span className="text-[0.65rem] font-bold text-indigo-400 uppercase tracking-[0.2em]">Ficha Técnica</span>
              <h2 className="text-2xl font-black tracking-tight mt-1">{machine.position_code}</h2>
              <p className="text-slate-400 font-bold">{machine.model_name} — {machine.description}</p>
            </div>
            <button 
              onClick={onClose}
              className="p-2 rounded-full bg-white/5 text-slate-400"
            >
              <X size={24} />
            </button>
          </div>
          
          <div className="flex gap-4 mt-6">
            <div className="bg-white/5 rounded-2xl p-4 flex-1 border border-white/5 group relative overflow-hidden">
              <span className="text-[0.6rem] font-bold text-slate-500 uppercase block mb-1">Doc. Ref</span>
              <span className="text-sm font-bold text-slate-200">{machine.doc_reference}</span>
              {machine.doc_reference?.endsWith('.pdf') && (
                <button 
                  onClick={() => setShowBlueprint(true)}
                  className="absolute inset-0 bg-indigo-600/90 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity translate-y-full group-hover:translate-y-0 duration-300 border-none cursor-pointer w-full h-full"
                >
                  <span className="text-xs font-bold text-white flex items-center gap-2">
                     VER PLANO PDF <ChevronRight size={14} />
                  </span>
                </button>
              )}
            </div>
            <div className="bg-white/5 rounded-2xl p-4 flex-1 border border-white/5">
              <span className="text-[0.6rem] font-bold text-slate-500 uppercase block mb-1">Puntos Totales</span>
              <span className="text-sm font-bold text-slate-200">{points.length} puntos</span>
            </div>
          </div>
        </div>

        {/* Scrollable Content */}
        <div className="flex-1 overflow-y-auto px-6 pb-10">
          <h3 className="text-xs font-bold text-slate-500 uppercase tracking-widest mb-4 flex items-center gap-2">
            <Droplet size={14} /> Puntos de Lubricación
          </h3>
          
          <div className="space-y-3">
            {points.map((point) => (
              <div 
                key={point.id}
                className="group flex items-center gap-4 p-4 rounded-2xl bg-white/5 border border-white/5 hover:bg-white/10 transition-all active:scale-[0.98]"
              >
                <div className="w-10 h-10 rounded-xl bg-indigo-500/20 flex items-center justify-center font-bold text-indigo-400 border border-indigo-500/30">
                  {point.item_number}
                </div>
                <div className="flex-1">
                  <h4 className="text-sm font-bold text-slate-100">{point.description}</h4>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[0.65rem] text-slate-500 font-bold">
                      {(point as any).lubricants?.product_name || '—'}
                    </span>
                    <span className="text-[0.6rem] text-slate-600">•</span>
                    <span className="text-[0.65rem] text-indigo-400/80 font-bold">
                      {(point as any).frequencies?.label || '—'}
                    </span>
                  </div>
                </div>
                <ChevronRight size={18} className="text-slate-600 group-hover:text-indigo-400 transition-colors" />
              </div>
            ))}
          </div>

          {points.length === 0 && (
            <div className="py-10 text-center opacity-30">
              <ClipboardList size={40} className="mx-auto mb-2" />
              <p className="text-sm">Sin puntos registrados</p>
            </div>
          )}
        </div>
      </div>

      <BlueprintOverlay 
        isOpen={showBlueprint}
        onClose={() => setShowBlueprint(false)}
        pdfUrl={machine.doc_reference || ''}
        title={`${machine.position_code} - ${machine.model_name}`}
      />

      <style jsx>{`
        @keyframes slide-up {
          from { transform: translateY(100%); }
          to { transform: translateY(0); }
        }
        .animate-slide-up {
          animation: slide-up 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        }
      `}</style>
    </div>
  );
}
