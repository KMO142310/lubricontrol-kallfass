-- ============================================================
-- 12. MACHINE MANUALS LINKING
-- Linking found PDF files to machine records
-- ============================================================

-- Update machines with document paths
UPDATE machines SET doc_reference = '/manuals/520379_VFW-600.pdf' WHERE position_code = 'Pos 115';
UPDATE machines SET doc_reference = '/manuals/Lubrication_P-700.pdf' WHERE position_code = 'Pos 120';
UPDATE machines SET doc_reference = '/manuals/Lubrication_QSS-700L.pdf' WHERE position_code = 'Pos 125';
UPDATE machines SET doc_reference = '/manuals/520391_BR-610JR.pdf' WHERE position_code = 'Pos 130';
UPDATE machines SET doc_reference = '/manuals/Lubrication_CT-100.pdf' WHERE position_code = 'Pos 135';
UPDATE machines SET doc_reference = '/manuals/520394_Feed_work_500A.pdf' WHERE position_code = 'Pos 140';
UPDATE machines SET doc_reference = '/manuals/Lubrication_HDSV-700.pdf' WHERE position_code = 'Pos 160';
UPDATE machines SET doc_reference = '/manuals/520595_Roll_conveyor.pdf' WHERE position_code = 'Pos 180.1';
