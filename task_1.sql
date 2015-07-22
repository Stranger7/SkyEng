USE skyeng_01234;

--
-- Select the student whose sum payments in second place after the maximum
--

SELECT tmp.*
FROM (
       SELECT student_id, SUM(amount) AS s_amount
       FROM `payments`
       GROUP BY student_id
       ORDER BY s_amount DESC
       LIMIT 2
     ) AS tmp
ORDER BY s_amount
LIMIT 1;
