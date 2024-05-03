Peer-graded Assignment: AB Testing
1. 
No. We need he created_at date.

SELECT * 
FROM 
  dsv1069.final_assignments_qa;

----------
2.
(SELECT
    item_id, test_a AS test_assignment, COALESCE('test_a') AS test_number, COALESCE('2013-01-05 00:00:00') AS test_start_day
  FROM
    dsv1069.final_assignments_qa
  UNION ALL
  SELECT
    item_id, test_b AS test_assignment, COALESCE('test_b') AS test_number, COALESCE('2013-01-05 00:00:00') AS test_start_day
  FROM
    dsv1069.final_assignments_qa
  UNION ALL
  SELECT
    item_id, test_c AS test_assignment, COALESCE('test_c') AS test_number, COALESCE('2013-01-05 00:00:00') AS test_start_day
  FROM
    dsv1069.final_assignments_qa
  UNION ALL
  SELECT
    item_id, test_d AS test_assignment, COALESCE('test_d') AS test_number, COALESCE('2013-01-05 00:00:00') AS test_start_day
  FROM
    dsv1069.final_assignments_qa
  UNION ALL
  SELECT
    item_id, test_e AS test_assignment, COALESCE('test_e') AS test_number, COALESCE('2013-01-05 00:00:00') AS test_start_day
  FROM
    dsv1069.final_assignments_qa
  UNION ALL
  SELECT
    item_id, test_f AS test_assignment, COALESCE('test_f') AS test_number, COALESCE('2013-01-05 00:00:00') AS test_start_day
  FROM
    dsv1069.final_assignments_qa
)
ORDER BY
  test_number

----------
3. 
WITH item_test_2 AS (
    SELECT
        final_assignments.item_id,
        final_assignments.test_assignment,
        final_assignments.test_number,
        final_assignments.test_start_date,
        DATE(orders.created_at) AS created_at,
        CASE
            WHEN (created_at > test_start_date 
            AND DATE_PART('day', created_at - test_start_date) <= 30) THEN 1
            ELSE 0
        END AS order_binary
    FROM dsv1069.final_assignments AS final_assignments
    LEFT JOIN dsv1069.orders AS orders ON final_assignments.item_id = orders.item_id
    WHERE test_number = 'item_test_2'
)
SELECT
    test_assignment,
    COUNT(DISTINCT item_id) AS number_of_items,
    SUM(order_binary) AS items_ordered_30d
FROM item_test_2
GROUP BY test_assignment;
LIMIT 100

----------
4. 
SELECT item_test_2.item_id,
       item_test_2.test_assignment,
       item_test_2.test_number,
       MAX(CASE
               WHEN (view_date > test_start_date
                     AND DATE_PART('day', view_date - test_start_date) <= 30) THEN 1
               ELSE 0
           END) AS view_binary
FROM
  (SELECT final_assignments.*,
          DATE(events.event_time) AS view_date
   FROM dsv1069.final_assignments AS final_assignments
   LEFT JOIN
       (SELECT event_time,
               CASE
                   WHEN parameter_name = 'item_id' THEN CAST(parameter_value AS NUMERIC)
                   ELSE NULL
               END AS item_id
      FROM dsv1069.events
      WHERE event_name = 'view_item') AS events
     ON final_assignments.item_id = events.item_id
   WHERE test_number = 'item_test_2') AS item_test_2
GROUP BY item_test_2.item_id,
         item_test_2.test_assignment,
         item_test_2.test_number
LIMIT 100;

----------
5.
WITH item_test_2 AS (
    SELECT
        final_assignments.item_id AS item,
        test_assignment,
        test_number,
        test_start_date,
        MAX(CASE
            WHEN date(event_time) - date(test_start_date) BETWEEN 0 AND 30 THEN 1
            ELSE 0
        END) AS view_binary_30d
    FROM dsv1069.final_assignments
    LEFT JOIN dsv1069.view_item_events
        ON final_assignments.item_id = view_item_events.item_id
    WHERE test_number = 'item_test_2'
    GROUP BY final_assignments.item_id, test_assignment, test_number, test_start_date
)
SELECT
    test_assignment,
    test_number,
    COUNT(DISTINCT item) AS number_of_items,
    SUM(view_binary_30d) AS view_binary_30d
FROM item_test_2
GROUP BY test_assignment, test_number, test_start_date;

----------
6.
-- View Binary 
-- p_value is 0.2. 
--There is no significant difference in the number of views within 30 days with the two treatments.

-- Order binary
-- p-value is 0.88.  
-- There is no significant difference in the number of views within 30 days with the two treatments.































