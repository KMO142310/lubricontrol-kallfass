"use client";

import React, { useState, useEffect, useRef } from 'react';
import { QrCode, X, Search, ChevronRight, Settings, Camera, AlertCircle } from 'lucide-react';
import { cn } from '@/lib/utils';

interface MachineScannerProps {
  onScan: (machineCode: string) => void;
  onClose: () => void;
}

export function MachineScanner({ onScan, onClose }: MachineScannerProps) {
  const [activeTab, setActiveTab] = useState<'qr' | 'manual'>('qr');
  const [manualCode, setManualCode] = useState('');
  const [hasCamera, setHasCamera] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (activeTab === 'qr') {
      startCamera();
    } else {
      stopCamera();
    }
    return () => stopCamera();
  }, [activeTab]);

  const startCamera = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ 
        video: { facingMode: 'environment' } 
      });
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        setHasCamera(true);
        setError(null);
      }
    } catch (err) {
      console.error("Camera access failed:", err);
      setHasCamera(false);
      setError("No se pudo acceder a la cámara. Usa el modo manual.");
      setActiveTab('manual');
    }
  };

  const stopCamera = () => {
    if (videoRef.current && videoRef.current.srcObject) {
      const stream = videoRef.current.srcObject as MediaStream;
      stream.getTracks().forEach(track => track.stop());
      videoRef.current.srcObject = null;
    }
  };

  const handleManualSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (manualCode.trim()) {
      onScan(manualCode.trim());
    }
  };

  return (
    <div className="fixed inset-0 z-[100] bg-[#0a0e17] flex flex-col">
      {/* Header */}
      <div className="p-4 flex justify-between items-center border-b border-white/5">
        <h2 className="text-xl font-black tracking-tight">IDENTIFICAR MÁQUINA</h2>
        <button 
          onClick={onClose}
          className="p-2 rounded-full bg-white/5 text-slate-400"
        >
          <X size={24} />
        </button>
      </div>

      {/* Tabs */}
      <div className="flex p-1 bg-white/5 rounded-xl mx-4 mt-4">
        <button 
          onClick={() => setActiveTab('qr')}
          className={cn(
            "flex-1 flex items-center justify-center gap-2 py-3 rounded-lg font-bold text-sm transition-all",
            activeTab === 'qr' ? "bg-indigo-600 text-white shadow-lg" : "text-slate-400"
          )}
        >
          <QrCode size={18} /> ESCANEAR QR
        </button>
        <button 
          onClick={() => setActiveTab('manual')}
          className={cn(
            "flex-1 flex items-center justify-center gap-2 py-3 rounded-lg font-bold text-sm transition-all",
            activeTab === 'manual' ? "bg-indigo-600 text-white shadow-lg" : "text-slate-400"
          )}
        >
          <Search size={18} /> CÓDIGO MANUAL
        </button>
      </div>

      {/* Content */}
      <div className="flex-1 flex flex-col p-4">
        {activeTab === 'qr' ? (
          <div className="flex-1 flex flex-col">
            <div className="relative flex-1 rounded-3xl overflow-hidden bg-slate-900 border-2 border-white/10 shadow-2xl">
              {hasCamera ? (
                <>
                  <video 
                    ref={videoRef} 
                    autoPlay 
                    playsInline 
                    className="w-full h-full object-cover"
                  />
                  {/* Scanner overlay */}
                  <div className="absolute inset-0 flex items-center justify-center">
                    <div className="w-64 h-64 border-2 border-indigo-400 rounded-3xl relative">
                      <div className="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-indigo-500 rounded-tl-lg"></div>
                      <div className="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-indigo-500 rounded-tr-lg"></div>
                      <div className="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-indigo-500 rounded-bl-lg"></div>
                      <div className="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-indigo-500 rounded-br-lg"></div>
                      <div className="absolute top-1/2 left-0 right-0 h-0.5 bg-indigo-500/50 animate-scanner-line shadow-[0_0_15px_rgba(99,102,241,0.8)]"></div>
                    </div>
                  </div>
                  <div className="absolute bottom-6 left-0 right-0 text-center">
                    <p className="text-white/60 text-xs font-bold uppercase tracking-widest bg-black/40 backdrop-blur-md inline-block px-4 py-2 rounded-full">
                      Alinea el código QR de la máquina
                    </p>
                  </div>
                </>
              ) : (
                <div className="flex-1 flex flex-col items-center justify-center text-center p-8">
                  <Camera size={48} className="text-slate-700 mb-4" />
                  <p className="text-slate-400 font-medium">Iniciando cámara...</p>
                </div>
              )}
            </div>
            
            {error && (
              <div className="mt-4 p-4 bg-red-500/10 border border-red-500/20 rounded-2xl flex items-center gap-3 text-red-400 text-sm font-bold animate-shake">
                <AlertCircle size={20} />
                {error}
              </div>
            )}
          </div>
        ) : (
          <form onSubmit={handleManualSubmit} className="flex-1 flex flex-col">
            <div className="bg-white/5 border border-white/10 rounded-2xl p-6 mb-6">
              <label className="block text-[0.65rem] font-bold text-slate-500 uppercase tracking-widest mb-3">
                Identificador de Posición (ej: Pos 115)
              </label>
              <div className="relative">
                <input 
                  type="text" 
                  value={manualCode}
                  onChange={(e) => setManualCode(e.target.value)}
                  placeholder="Escribe el código aquí..."
                  className="w-full bg-slate-900 border border-white/10 rounded-xl py-4 px-6 text-xl font-bold focus:outline-none focus:ring-2 focus:ring-indigo-500 transition-all"
                  autoFocus
                />
              </div>
              <p className="text-slate-500 text-xs mt-4 leading-relaxed">
                Ingresa el código de posición que se encuentra en la placa física de la máquina.
              </p>
            </div>

            <button 
              type="submit"
              disabled={!manualCode.trim()}
              className="w-full py-5 rounded-2xl bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 font-black text-lg transition-all shadow-xl shadow-indigo-600/20 flex items-center justify-center gap-3"
            >
              BUSCAR MÁQUINA <ChevronRight size={24} />
            </button>
            
            <div className="grid grid-cols-2 gap-3 mt-8">
              {['Pos 115', 'Pos 125', 'Pos 160', 'Pos 180.1'].map(code => (
                <button 
                  key={code}
                  type="button"
                  onClick={() => setManualCode(code)}
                  className="p-3 bg-white/5 border border-white/10 rounded-xl text-left hover:bg-white/10 transition-colors"
                >
                  <span className="text-[0.6rem] font-bold text-slate-500 block uppercase">Reciente</span>
                  <span className="font-bold text-slate-300">{code}</span>
                </button>
              ))}
            </div>
          </form>
        )}
      </div>

      <style jsx>{`
        @keyframes scanner-line {
          0% { top: 0; }
          100% { top: 100%; }
        }
        .animate-scanner-line {
          animation: scanner-line 3s linear infinite;
        }
        @keyframes shake {
          0%, 100% { transform: translateX(0); }
          10%, 30%, 50%, 70%, 90% { transform: translateX(-4px); }
          20%, 40%, 60%, 80% { transform: translateX(4px); }
        }
        .animate-shake {
          animation: shake 0.5s cubic-bezier(.36,.07,.19,.97) both;
        }
      `}</style>
    </div>
  );
}
