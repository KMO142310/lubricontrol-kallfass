-- ============================================================
-- 14. FIX: FORCE TODAY'S TASKS
-- Ensures the user sees active tasks when logging in today.
-- ============================================================

-- Force task generation for the current date
SELECT generate_daily_tasks(CURRENT_DATE);

-- Fix any old tasks that might be lingering in the technician's view
UPDATE daily_tasks 
SET scheduled_date = CURRENT_DATE 
WHERE status = 'pending' 
AND scheduled_date < CURRENT_DATE;

-- Add a few more points to certain critical machines if they are missing
INSERT INTO daily_tasks (lubrication_point_id, assigned_user_id, scheduled_date, status)
SELECT lp.id, (SELECT id FROM profiles WHERE role = 'lubricator' LIMIT 1), CURRENT_DATE, 'pending'
FROM lubrication_points lp
JOIN machines m ON lp.machine_id = m.id
WHERE m.position_code IN ('Pos 115', 'Pos 125')
AND NOT EXISTS (
    SELECT 1 FROM daily_tasks 
    WHERE lubrication_point_id = lp.id 
    AND scheduled_date = CURRENT_DATE
)
LIMIT 5;
