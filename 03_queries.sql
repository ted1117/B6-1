-- 03_queries.sql | SQLite 3 | 01_schema.sql → 02_seed.sql 이후 실행
-- 13·14번은 실제 데이터를 바꾸므로, 원래 결과 재현 시 01·02부터 다시 실행하세요.
PRAGMA foreign_keys = ON;

-- Q01 [기본 조회] 판매 중인 커피 메뉴를 가격 높은 순으로 최대 5건 조회합니다.
SELECT menu_id, menu_name, price
FROM menu
WHERE is_available = 1 AND category = 'COFFEE'
ORDER BY price DESC, menu_id
LIMIT 5;

-- Q02 [기본 조회] 2026년 8월 이후 가입한 고객 중 최근 가입자 5명을 확인합니다.
SELECT customer_id, customer_name, joined_at
FROM customer
WHERE joined_at >= '2026-08-01'
ORDER BY joined_at DESC
LIMIT 5;

-- Q03 [기본 조회] 이름에 ‘김’이 포함된 고객을 검색합니다.
SELECT customer_id, customer_name, phone
FROM customer
WHERE customer_name LIKE '%김%'
ORDER BY customer_id;

-- Q04 [기본 조회] 결제 완료(PAID) 주문을 최근 주문순으로 조회합니다.
SELECT order_id, customer_id, ordered_at, status
FROM cafe_order
WHERE status = 'PAID' AND ordered_at >= '2026-10-01 00:00:00'
ORDER BY ordered_at DESC
LIMIT 5;

-- Q05 [INNER JOIN] 주문과 고객을 연결해 최근 주문의 고객명을 확인합니다.
SELECT o.order_id, c.customer_name, o.ordered_at, o.status
FROM cafe_order AS o
INNER JOIN customer AS c ON c.customer_id = o.customer_id
ORDER BY o.ordered_at DESC
LIMIT 8;

-- Q06 [INNER JOIN] 주문 상세와 메뉴를 연결해 수량 2개 이상 주문 항목의 금액을 확인합니다.
SELECT oi.order_id, m.menu_name, oi.quantity,
       oi.unit_price, oi.quantity * oi.unit_price AS line_total
FROM order_item AS oi
INNER JOIN menu AS m ON m.menu_id = oi.menu_id
WHERE oi.quantity >= 2
ORDER BY line_total DESC, oi.order_id
LIMIT 10;

-- Q07 [INNER JOIN] 고객·주문·상세를 연결하여 유효 주문별 총액 상위 8개를 확인합니다.
SELECT o.order_id, c.customer_name, o.status,
       SUM(oi.quantity * oi.unit_price) AS order_total
FROM cafe_order AS o
INNER JOIN customer AS c ON c.customer_id = o.customer_id
INNER JOIN order_item AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('PAID', 'COMPLETED')
GROUP BY o.order_id, c.customer_name, o.status
ORDER BY order_total DESC, o.order_id
LIMIT 8;

-- Q08 [LEFT JOIN] 주문 이력이 없는 고객도 빠뜨리지 않고 찾아냅니다.
SELECT c.customer_id, c.customer_name
FROM customer AS c
LEFT JOIN cafe_order AS o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

-- Q09 [집계] 결제·완료 주문 기준 메뉴별 판매 수량 및 매출을 집계합니다.
SELECT m.menu_name,
       SUM(oi.quantity) AS units_sold,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_item AS oi
INNER JOIN menu AS m ON m.menu_id = oi.menu_id
INNER JOIN cafe_order AS o ON o.order_id = oi.order_id
WHERE o.status IN ('PAID', 'COMPLETED')
GROUP BY m.menu_id, m.menu_name
ORDER BY revenue DESC, m.menu_id
LIMIT 10;

-- Q10 [집계] 고객별 유효 주문 횟수와 누적 사용 금액을 집계합니다.
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT o.order_id) AS paid_order_count,
       SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customer AS c
INNER JOIN cafe_order AS o ON o.customer_id = c.customer_id
INNER JOIN order_item AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('PAID', 'COMPLETED')
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC, c.customer_id
LIMIT 5;

-- Q11 [집계] 일자별 유효 주문 수·평균 객단가·매출을 계산합니다.
-- SQLite 전용: date(TEXT)를 이용해 타임스탬프에서 날짜를 추출합니다.
SELECT order_day, COUNT(*) AS order_count,
       ROUND(AVG(order_total), 0) AS avg_ticket,
       SUM(order_total) AS daily_revenue
FROM (
    SELECT date(o.ordered_at) AS order_day, o.order_id,
           SUM(oi.quantity * oi.unit_price) AS order_total
    FROM cafe_order AS o
    INNER JOIN order_item AS oi ON oi.order_id = o.order_id
    WHERE o.status IN ('PAID', 'COMPLETED')
    GROUP BY date(o.ordered_at), o.order_id
) AS daily_orders
GROUP BY order_day
ORDER BY order_day;

-- Q12 [서브쿼리] 전체 메뉴 평균 가격을 초과하는 메뉴를 확인합니다.
SELECT menu_id, menu_name, price
FROM menu
WHERE price > (SELECT AVG(price) FROM menu)
ORDER BY price DESC, menu_id;

-- Q13 [UPDATE] 16번 주문 상태를 PAID에서 COMPLETED로 변경합니다.
UPDATE cafe_order
SET status = 'COMPLETED'
WHERE order_id = 16 AND status = 'PAID';

-- Q14 [DELETE] 취소된 18번 주문의 테스트 상세 항목(36번)을 삭제합니다.
DELETE FROM order_item
WHERE order_item_id = 36 AND order_id = 18
  AND EXISTS (
      SELECT 1 FROM cafe_order
      WHERE order_id = 18 AND status = 'CANCELED'
  );

-- Q15 [인덱스] 고객별 주문 이력 검색과 날짜순 정렬을 위해 복합 인덱스를 생성합니다.
-- SQLite 전용: IF NOT EXISTS를 사용하여 재실행 시 중복 생성을 방지합니다.
-- customer_id로 필터링한 뒤 ordered_at으로 정렬하는 접근을 빠르게 합니다.
CREATE INDEX IF NOT EXISTS idx_cafe_order_customer_date
ON cafe_order(customer_id, ordered_at);

