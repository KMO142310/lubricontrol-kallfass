import { openDB, DBSchema, IDBPDatabase } from 'idb';
import type { CompletionLog, AnomalyReport } from '@/types/database';
import type { StoredTask } from '../store/useRouteStore';

interface LubriControlDB extends DBSchema {
  tasks: {
    key: string;
    value: StoredTask;
  };
  completion_logs: {
    key: string;
    value: CompletionLog;
    indexes: { 'synced_at': string };
  };
  anomaly_reports: {
    key: string;
    value: AnomalyReport;
    indexes: { 'synced_at': string };
  };
}

const DB_NAME = 'lubricontrol-offline-db';
const DB_VERSION = 1;

let dbPromise: Promise<IDBPDatabase<LubriControlDB>> | null = null;

export function getDB() {
  if (typeof window === 'undefined') return null; // Avoid SSR issues
  
  if (!dbPromise) {
    dbPromise = openDB<LubriControlDB>(DB_NAME, DB_VERSION, {
      upgrade(db) {
        if (!db.objectStoreNames.contains('tasks')) {
          db.createObjectStore('tasks', { keyPath: 'id' });
        }
        if (!db.objectStoreNames.contains('completion_logs')) {
          const store = db.createObjectStore('completion_logs', { keyPath: 'id' });
          store.createIndex('synced_at', 'synced_at'); // useful to find unsynced ones
        }
        if (!db.objectStoreNames.contains('anomaly_reports')) {
          const store = db.createObjectStore('anomaly_reports', { keyPath: 'id' });
          store.createIndex('synced_at', 'synced_at'); // useful to find unsynced ones
        }
      },
    });
  }
  return dbPromise;
}

// ------------------------------------------------------------------
// HELPER METHODS FOR OFFLINE SYNC
// ------------------------------------------------------------------

export async function saveTaskLocally(task: StoredTask) {
  const db = await getDB();
  if (!db) return;
  await db.put('tasks', task);
}

export async function getTasksLocally(): Promise<StoredTask[]> {
  const db = await getDB();
  if (!db) return [];
  return db.getAll('tasks');
}

export async function clearLocalTasks() {
  const db = await getDB();
  if (!db) return;
  await db.clear('tasks');
}

export async function saveCompletionLog(log: CompletionLog) {
  const db = await getDB();
  if (!db) return;
  await db.put('completion_logs', log);
}

export async function saveAnomalyReport(report: AnomalyReport) {
  const db = await getDB();
  if (!db) return;
  await db.put('anomaly_reports', report);
}

export async function getUnsyncedLogs(): Promise<CompletionLog[]> {
  const db = await getDB();
  if (!db) return [];
  // Using the index where synced_at is effectively null (handled manually via map/filter usually since IDB index on null can be tricky)
  const allLogs = await db.getAll('completion_logs');
  return allLogs.filter((l) => !l.synced_at);
}

export async function getUnsyncedAnomalies(): Promise<AnomalyReport[]> {
  const db = await getDB();
  if (!db) return [];
  const allAnomalies = await db.getAll('anomaly_reports');
  return allAnomalies.filter((a) => !a.synced_at);
}
