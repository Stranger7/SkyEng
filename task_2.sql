USE skyeng_01234;

--
-- Select students who are on vacation and who have not defined Gender
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
        -- end of get last status
      ) = 'vacation'
      AND
      (gender = 'unknown')
;