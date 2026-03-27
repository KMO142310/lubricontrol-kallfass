// src/lib/data/tasks.ts
import { createClient } from '../supabase/client';
import type { StoredTask } from '../store/useRouteStore';

/**
 * Descarga las tareas asignadas al usuario para la fecha actual.
 * Intenta daily_tasks primero; si no hay, usa lubrication_points como ruta manual.
 */
export async function downloadRouteForShift(userId: string): Promise<StoredTask[]> {
  const supabase = createClient();

  try {
    const today = new Date().toISOString().split('T')[0];

    // 1. Intentar traer daily_tasks asignadas para hoy
    const { data: dailyTasks, error: dailyError } = await supabase
      .from('daily_tasks')
      .select(`
        id,
        status,
        completed_at,
        lubrication_points!inner (
          id,
          description,
          task_type,
          grammage_g,
          volume_ml,
          num_points,
          is_manual,
          machines!inner (
            position_code,
            model_name
          ),
          lubricants!inner (
            product_name
          )
        )
      `)
      .eq('assigned_user_id', userId)
      .eq('scheduled_date', today);

    if (!dailyError && dailyTasks && dailyTasks.length > 0) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      return dailyTasks.map((task: any) => {
        const point = task.lubrication_points;
        const lubName = buildLubricantLabel(point.lubricants?.product_name, point.volume_ml);
        return {
          id: task.id,
          pointId: point.id,
          positionCode: point.machines?.position_code || 'N/A',
          machineName: `${point.machines?.position_code} ${point.machines?.model_name || ''}`.trim(),
          taskType: point.task_type as 'lubrication' | 'inspection',
          description: point.description,
          status: task.status ?? 'pending',
          lubricantName: lubName,
          grammage: point.grammage_g ? parseFloat(point.grammage_g) : undefined,
          pumps: point.num_points || 1,
          isManual: point.is_manual ?? false,
        };
      });
    }

    // 2. Fallback: traer lubrication_points directamente (ruta manual sin asignación previa)
    if (dailyError) {
      console.warn('daily_tasks error, using fallback:', dailyError.message);
    } else {
      console.info('No daily_tasks para hoy. Usando ruta manual desde lubrication_points.');
    }

    const { data: points, error: pointsError } = await supabase
      .from('lubrication_points')
      .select(`
        id,
        description,
        task_type,
        grammage_g,
        volume_ml,
        num_points,
        is_manual,
        machines (
          position_code,
          model_name
        ),
        lubricants (
          product_name
        )
      `)
      .order('id')
      .limit(80);

    if (pointsError) throw pointsError;
    if (!points) return [];

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    return points.map((p: any) => ({
      id: p.id,
      pointId: p.id,
      positionCode: p.machines?.position_code || 'N/A',
      machineName: `${p.machines?.position_code} ${p.machines?.model_name || ''}`.trim(),
      taskType: p.task_type as 'lubrication' | 'inspection',
      description: p.description,
      status: 'pending' as const,
      lubricantName: buildLubricantLabel(p.lubricants?.product_name, p.volume_ml),
      grammage: p.grammage_g ? parseFloat(p.grammage_g) : undefined,
      pumps: p.num_points || 1,
      isManual: p.is_manual ?? false,
    }));

  } catch (err) {
    console.error('Error descargando ruta:', err);
    return [];
  }
}

function buildLubricantLabel(productName?: string, volumeMl?: number): string {
  if (!productName) return 'N/A';
  if (volumeMl) return `${productName} (${volumeMl} cm³)`;
  return productName;
}
