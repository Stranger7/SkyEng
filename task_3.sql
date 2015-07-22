USE skyeng_01234;

--
-- Select lost students who have payment count less than or equal to three
--
SELECT `student`.*
FROM `student`
WHERE (
        -- Get last status
        SELECT `status`
        FROM `student_status`
        WHERE `student_id` = `student`.`id`
        ORDER BY `datetime` DESC
        LIMIT 1
      ) = 'lost'
      AND
      (
        -- Get payment count
        SELECT COUNT(*)
        FROM `payments`
        WHERE `amount` > 0 AND `student_id` = `student`.`id`
      ) <= 3
;