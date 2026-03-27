'use client';

import React, { useState } from 'react';
import { X, Maximize2, Minimize2, Download, FileText } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

interface BlueprintOverlayProps {
  isOpen: boolean;
  onClose: () => void;
  pdfUrl: string;
  title: string;
}

export function BlueprintOverlay({ isOpen, onClose, pdfUrl, title }: BlueprintOverlayProps) {
  const [isMaximized, setIsMaximized] = useState(false);

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-8 pointer-events-none">
          {/* Backdrop */}
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="absolute inset-0 bg-slate-950/80 backdrop-blur-md pointer-events-auto"
          />

          {/* Window */}
          <motion.div 
            initial={{ scale: 0.9, opacity: 0, y: 20 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            exit={{ scale: 0.9, opacity: 0, y: 20 }}
            className={`
              relative bg-slate-900 border-2 border-cyan-500 shadow-2xl overflow-hidden flex flex-col pointer-events-auto
              transition-all duration-500 ease-in-out blueprint-frame
              ${isMaximized ? 'w-full h-full' : 'w-full max-w-6xl h-[90vh]'}
            `}
          >
            {/* Blueprint Header */}
            <div className="bg-slate-950/50 border-b border-indigo-500/20 px-6 py-4 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="bg-indigo-500/20 p-2 rounded-lg text-indigo-400">
                  <FileText size={20} />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-white tracking-tight">{title}</h2>
                  <p className="text-[0.65rem] text-indigo-400 font-black uppercase tracking-widest">Technical Blueprint Viewport v2.0</p>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <button 
                  onClick={() => setIsMaximized(!isMaximized)}
                  className="p-2 text-slate-400 hover:text-white hover:bg-white/5 rounded-lg transition-colors"
                >
                  {isMaximized ? <Minimize2 size={20} /> : <Maximize2 size={20} />}
                </button>
                <a 
                  href={pdfUrl} 
                  download 
                  className="p-2 text-slate-400 hover:text-white hover:bg-white/5 rounded-lg transition-colors"
                >
                  <Download size={20} />
                </a>
                <button 
                  onClick={onClose}
                  className="p-2 bg-red-500/10 text-red-400 hover:bg-red-500 hover:text-white rounded-lg transition-all"
                >
                  <X size={20} />
                </button>
              </div>
            </div>

            {/* Viewer Content */}
            <div className="flex-1 bg-slate-950 relative">
              {/* Grid Overlay for Blueprint Look */}
              <div 
                className="absolute inset-0 pointer-events-none opacity-10"
                style={{ 
                  backgroundImage: `radial-gradient(circle, #6366f1 1px, transparent 1px)`,
                  backgroundSize: '30px 30px'
                }}
              />
              
              <iframe 
                src={`${pdfUrl}#toolbar=0&navpanes=0`} 
                className="w-full h-full border-none relative z-10"
                title="Technical Manual Viewer"
              />
            </div>

            {/* Footer / Status Bar */}
            <div className="bg-slate-950/80 border-t border-indigo-500/10 px-6 py-2 flex items-center justify-between text-[0.6rem] font-bold text-indigo-500/60 uppercase tracking-tighter">
              <span>Secure Document Access: System Auth Verified</span>
              <span className="animate-pulse">● System Online</span>
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
