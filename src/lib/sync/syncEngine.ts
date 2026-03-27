import { createClient } from '../supabase/client';
import {
  getUnsyncedLogs,
  getUnsyncedAnomalies,
  saveTaskLocally,
  clearLocalTasks,
  saveCompletionLog,
  saveAnomalyReport,
} from '../data/localDb';
import { downloadRouteForShift } from '../data/tasks';

const isDevBypass = () =>
  typeof window !== 'undefined' && window.location.search.includes('bypass=true');

export const syncEngine = {
  /**
   * Envía todos los logs y anomalías pendientes a Supabase.
   */
  async pushLocalChanges() {
    if (isDevBypass()) return;

    const supabase = createClient();
    const today = new Date().toISOString().split('T')[0];

    // 1. Push completion logs
    const unsyncedLogs = await getUnsyncedLogs();
    for (const log of unsyncedLogs) {
      try {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const { error } = await (supabase.from('completion_logs') as any).insert({
          id: log.id,
          lubrication_point_id: log.lubrication_point_id,
          user_id: log.user_id,
          completed_at: log.completed_at,
          grammage_used_g: log.grammage_used_g,
          status: log.status,
          anomaly_report_id: log.anomaly_report_id ?? null,
        });

        if (!error) {
          await saveCompletionLog({ ...log, synced_at: new Date().toISOString() });
          // Actualizar el daily_task correspondiente
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          await (supabase.from('daily_tasks') as any)
            .update({ status: log.status, completed_at: log.completed_at })
            .eq('lubrication_point_id', log.lubrication_point_id)
            .eq('scheduled_date', today);
        } else {
          console.warn('Push log failed:', error.message);
        }
      } catch (err) {
        console.error('Error pushing log:', log.id, err);
      }
    }

    // 2. Push anomaly reports
    const unsyncedAnomalies = await getUnsyncedAnomalies();
    for (const anomaly of unsyncedAnomalies) {
      try {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const { error } = await (supabase.from('anomaly_reports') as any).insert({
          id: anomaly.id,
          lubrication_point_id: anomaly.lubrication_point_id,
          user_id: anomaly.user_id,
          anomaly_type: anomaly.anomaly_type,
          description: anomaly.description ?? null,
          media_url: anomaly.media_url ?? null,
          created_at: anomaly.created_at,
          resolved: false,
        });

        if (!error) {
          await saveAnomalyReport({ ...anomaly, synced_at: new Date().toISOString() });
        } else {
          console.warn('Push anomaly failed:', error.message);
        }
      } catch (err) {
        console.error('Error pushing anomaly:', anomaly.id, err);
      }
    }
  },

  /**
   * Descarga la ruta del turno actual y actualiza IndexedDB.
   */
  async pullTasks(userId: string) {
    if (isDevBypass() || userId === 'dev-user-id') {
      return [];
    }

    try {
      const remoteTasks = await downloadRouteForShift(userId);
      if (remoteTasks.length > 0) {
        await clearLocalTasks();
        for (const task of remoteTasks) {
          await saveTaskLocally(task);
        }
      }
      return remoteTasks;
    } catch (err) {
      console.error('pullTasks failed:', err);
      throw err;
    }
  },

  /**
   * Sincronización completa: push → pull.
   */
  async syncFull(userId: string) {
    await this.pushLocalChanges();
    const tasks = await this.pullTasks(userId);
    return tasks;
  },
};
