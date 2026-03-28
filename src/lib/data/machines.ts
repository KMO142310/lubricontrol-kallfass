import { createClient } from '../supabase/client';
import type { Machine, LubricationPoint } from '@/types/database';

export async function getMachineByCode(code: string): Promise<Machine | null> {
  const supabase = createClient();
  const { data, error } = await supabase
    .from('machines')
    .select(`
      *,
      machine_images ( image_url, image_type )
    `)
    .ilike('position_code', `%${code}%`)
    .limit(1)
    .maybeSingle();

  if (error) {
    console.error('Error fetching machine:', error);
    return null;
  }
  if (!data) return null;

  // Attach diagram URL to image_url field from machine_images
  const raw = data as Record<string, unknown>;
  const images = raw.machine_images as { image_url: string; image_type: string }[] | null;
  const diagram = images?.find(i => i.image_type === 'diagram');
  const result: Machine = { ...(raw as unknown as Machine) };
  if (diagram?.image_url) result.image_url = diagram.image_url;
  return result;
}

export async function getMachinePoints(machineId: string): Promise<LubricationPoint[]> {
  const supabase = createClient();
  const { data, error } = await supabase
    .from('lubrication_points')
    .select(`
      *,
      lubricants (*),
      frequencies (*)
    `)
    .eq('machine_id', machineId)
    .order('item_number');

  if (error) {
    console.error('Error fetching points:', error);
    return [];
  }
  return data as any;
}
