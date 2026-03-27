import { create } from 'zustand';
import type { TaskProps } from '@/components/TaskCard';
import {
  getTasksLocally,
  saveTaskLocally,
  clearLocalTasks,
  saveCompletionLog,
  saveAnomalyReport,
  getUnsyncedLogs,
  getUnsyncedAnomalies
} from '../data/localDb';
import { syncEngine } from '../sync/syncEngine';
import type { AnomalyType, TaskStatus } from '@/types/database';

export type StoredTask = Omit<TaskProps, 'onComplete' | 'onAnomaly'> & { pointId: string };

interface RouteState {
  tasks: StoredTask[];
  shiftName: string;
  isSyncing: boolean;
  hasUnsyncedChanges: boolean;
  isHydrated: boolean;
  
  // Actions
  hydrate: () => Promise<void>;
  loadTasks: (tasks: StoredTask[], shiftName?: string) => Promise<void>;
  completeTask: (id: string, userId: string, grammage?: number) => Promise<void>;
  reportAnomaly: (id: string, userId: string, anomalyType: AnomalyType, description?: string) => Promise<void>;
  syncWithCloud: () => Promise<void>;
  clearRoute: () => Promise<void>;
}

export const useRouteStore = create<RouteState>()((set, get) => ({
  tasks: [],
  shiftName: 'Turno Actual',
  isSyncing: false,
  hasUnsyncedChanges: false,
  isHydrated: false,

  hydrate: async () => {
    try {
      const localTasks = await getTasksLocally();
      const logs = await getUnsyncedLogs();
      const anomalies = await getUnsyncedAnomalies();
      
      set({ 
        tasks: localTasks, 
        isHydrated: true,
        hasUnsyncedChanges: logs.length > 0 || anomalies.length > 0
      });
    } catch (e) {
      console.error('Failed to hydrate local db', e);
      set({ isHydrated: true });
    }
  },

  loadTasks: async (tasks, shiftName = 'Turno Actual') => {
    await clearLocalTasks();
    const savePromises = tasks.map(t => saveTaskLocally(t));
    await Promise.all(savePromises);
    
    set({ tasks, shiftName, hasUnsyncedChanges: false });
  },

  completeTask: async (id, userId, grammage) => {
    const state = get();
    const task = state.tasks.find(t => t.id === id);
    if (!task) return;

    const newTaskState = { ...task, status: 'completed' as TaskStatus };
    const newTasks = state.tasks.map(t => t.id === id ? newTaskState : t);
    
    // Save to IDB immediately
    await saveTaskLocally(newTaskState);
    
    // Generate completion log offline
    await saveCompletionLog({
      id: crypto.randomUUID(),
      lubrication_point_id: task.pointId, 
      user_id: userId,
      completed_at: new Date().toISOString(),
      status: 'completed',
      grammage_used_g: grammage,
    });

    set({ tasks: newTasks, hasUnsyncedChanges: true });
  },

  reportAnomaly: async (id, userId, type, desc) => {
    const state = get();
    const task = state.tasks.find(t => t.id === id);
    if (!task) return;

    const newTaskState = { ...task, status: 'anomaly' as TaskStatus };
    const newTasks = state.tasks.map(t => t.id === id ? newTaskState : t);
    
    await saveTaskLocally(newTaskState);
    
    const anomalyId = crypto.randomUUID();
    await saveAnomalyReport({
      id: anomalyId,
      lubrication_point_id: task.pointId,
      user_id: userId,
      anomaly_type: type,
      description: desc,
      created_at: new Date().toISOString(),
      resolved: false,
    });

    await saveCompletionLog({
      id: crypto.randomUUID(),
      lubrication_point_id: task.pointId,
      user_id: userId,
      completed_at: new Date().toISOString(),
      status: 'anomaly',
      anomaly_report_id: anomalyId
    });

    set({ tasks: newTasks, hasUnsyncedChanges: true });
  },

  syncWithCloud: async () => {
    const state = get();
    const { user } = (await import('../auth/useAuth')).useAuth(); // Minor hack if not in context, better passed from component
    const userId = user?.id || 'offline-user';

    set({ isSyncing: true });
    try {
      await syncEngine.syncFull(userId);
      await state.hydrate(); // Refresh state from IDB
      set({ isSyncing: false, hasUnsyncedChanges: false });
    } catch (error) {
      console.error("Sync Engine Failed:", error);
      set({ isSyncing: false });
    }
  },

  clearRoute: async () => {
    await clearLocalTasks();
    set({ tasks: [], hasUnsyncedChanges: false });
  }
}));
