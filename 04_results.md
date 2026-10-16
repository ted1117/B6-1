# 쿼리 15개 실행 결과

`01_schema.sql`과 `02_seed.sql`을 적용한 새 임시 SQLite 데이터베이스에서 `03_queries.sql`을 순서대로 실행했습니다. 각 항목에 쿼리문과 SQLite CLI 실행 결과를 함께 기록했습니다.

## Q01 · 판매 중인 커피 메뉴 가격순 조회

```sql
SELECT menu_id, menu_name, price
FROM menu
WHERE is_available = 1 AND category = 'COFFEE'
ORDER BY price DESC, menu_id
LIMIT 5;
```

```text
menu_id  menu_name  price
-------  ---------  -----
3        바닐라라떼      5500 
5        콜드브루       5200 
2        카페라떼       5000 
4        카푸치노       5000 
1        아메리카노      4500
```

## Q02 · 2026년 8월 이후 가입 고객 최근 가입순 조회

```sql
SELECT customer_id, customer_name, joined_at
FROM customer
WHERE joined_at >= '2026-08-01'
ORDER BY joined_at DESC
LIMIT 5;
```

```text
customer_id  customer_name  joined_at 
-----------  -------------  ----------
12           한유나            2026-10-10
11           오시온            2026-10-05
10           임소율            2026-10-01
9            장서준            2026-09-28
8            윤지호            2026-09-17
```

## Q03 · 이름에 ‘김’이 포함된 고객 검색

```sql
SELECT customer_id, customer_name, phone
FROM customer
WHERE customer_name LIKE '%김%'
ORDER BY customer_id;
```

```text
customer_id  customer_name  phone        
-----------  -------------  -------------
1            김민서            011-0000-0001
```

## Q04 · 결제 완료 주문 최근순 조회

```sql
SELECT order_id, customer_id, ordered_at, status
FROM cafe_order
WHERE status = 'PAID' AND ordered_at >= '2026-10-01 00:00:00'
ORDER BY ordered_at DESC
LIMIT 5;
```

```text
order_id  customer_id  ordered_at           status
--------  -----------  -------------------  ------
16        1            2026-10-11 09:50:00  PAID  
13        10           2026-10-08 17:40:00  PAID  
7         6            2026-10-04 18:10:00  PAID  
3         3            2026-10-02 12:15:00  PAID
```

## Q05 · 최근 주문별 고객명 조회

```sql
SELECT o.order_id, c.customer_name, o.ordered_at, o.status
FROM cafe_order AS o
INNER JOIN customer AS c ON c.customer_id = o.customer_id
ORDER BY o.ordered_at DESC
LIMIT 8;
```

```text
order_id  customer_name  ordered_at           status   
--------  -------------  -------------------  ---------
18        임소율            2026-10-13 12:00:00  CANCELED 
17        정하준            2026-10-12 13:10:00  COMPLETED
16        김민서            2026-10-11 09:50:00  PAID     
15        강하은            2026-10-10 10:35:00  COMPLETED
14        최서윤            2026-10-09 16:15:00  COMPLETED
13        임소율            2026-10-08 17:40:00  PAID     
12        장서준            2026-10-08 08:30:00  COMPLETED
11        박지우            2026-10-07 15:20:00  COMPLETED
```

## Q06 · 수량 2개 이상 주문 항목 금액 조회

```sql
SELECT oi.order_id, m.menu_name, oi.quantity,
       oi.unit_price, oi.quantity * oi.unit_price AS line_total
FROM order_item AS oi
INNER JOIN menu AS m ON m.menu_id = oi.menu_id
WHERE oi.quantity >= 2
ORDER BY line_total DESC, oi.order_id
LIMIT 10;
```

```text
order_id  menu_name  quantity  unit_price  line_total
--------  ---------  --------  ----------  ----------
15        아메리카노      3         4500        13500     
12        치즈케이크      2         6500        13000     
9         레몬에이드      2         5500        11000     
16        바닐라라떼      2         5500        11000     
13        콜드브루       2         5200        10400     
11        카페라떼       2         5000        10000     
1         아메리카노      2         4500        9000      
7         얼그레이티      2         4500        9000      
5         초코쿠키       3         2800        8400      
4         크루아상       2         3800        7600
```

## Q07 · 유효 주문 총액 상위 8건 조회

```sql
SELECT o.order_id, c.customer_name, o.status,
       SUM(oi.quantity * oi.unit_price) AS order_total
FROM cafe_order AS o
INNER JOIN customer AS c ON c.customer_id = o.customer_id
INNER JOIN order_item AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('PAID', 'COMPLETED')
GROUP BY o.order_id, c.customer_name, o.status
ORDER BY order_total DESC, o.order_id
LIMIT 8;
```

```text
order_id  customer_name  status     order_total
--------  -------------  ---------  -----------
12        장서준            COMPLETED  17500      
9         조유진            COMPLETED  16600      
15        강하은            COMPLETED  16300      
7         강하은            PAID       15500      
16        김민서            PAID       14800      
13        임소율            PAID       14200      
5         최서윤            COMPLETED  14100      
4         김민서            COMPLETED  12800
```

## Q08 · 주문 이력이 없는 고객 조회

```sql
SELECT c.customer_id, c.customer_name
FROM customer AS c
LEFT JOIN cafe_order AS o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;
```

```text
customer_id  customer_name
-----------  -------------
11           오시온          
12           한유나
```

## Q09 · 메뉴 카테고리별 평균 가격 집계

```sql
SELECT category, ROUND(AVG(price), 0) AS avg_price
FROM menu
GROUP BY category
ORDER BY avg_price DESC, category;
```

```text
category  avg_price
--------  ---------
OTHER     5500.0   
COFFEE    5040.0   
TEA       5000.0   
DESSERT   4367.0
```

## Q10 · 주문 상태별 건수 집계

```sql
SELECT status, COUNT(*) AS order_count
FROM cafe_order
GROUP BY status
ORDER BY order_count DESC, status;
```

```text
status     order_count
---------  -----------
COMPLETED  11         
PAID       4          
CANCELED   2          
PLACED     1
```

## Q11 · 메뉴 카테고리별 가격 합계 집계

```sql
SELECT category, SUM(price) AS total_price
FROM menu
GROUP BY category
ORDER BY total_price DESC, category;
```

```text
category  total_price
--------  -----------
COFFEE    25200      
TEA       15000      
DESSERT   13100      
OTHER     5500
```

## Q12 · 전체 메뉴 평균가 초과 메뉴 조회

```sql
SELECT menu_id, menu_name, price
FROM menu
WHERE price > (SELECT AVG(price) FROM menu)
ORDER BY price DESC, menu_id;
```

```text
menu_id  menu_name  price
-------  ---------  -----
9        치즈케이크      6500 
6        녹차라떼       5700 
3        바닐라라떼      5500 
12       레몬에이드      5500 
5        콜드브루       5200 
2        카페라떼       5000 
4        카푸치노       5000
```

## Q13 · 16번 주문 상태 변경 (PAID → COMPLETED)

```sql
UPDATE cafe_order
SET status = 'COMPLETED'
WHERE order_id = 16 AND status = 'PAID';
```

```text
changes: 1   total_changes: 1
```

## Q14 · 취소 주문 18번의 상세 항목 36번 삭제

```sql
DELETE FROM order_item
WHERE order_item_id = 36 AND order_id = 18;
```

```text
changes: 1   total_changes: 1
```

## Q15 · 고객별 주문 이력·날짜순 정렬용 복합 인덱스 생성

```sql
CREATE INDEX IF NOT EXISTS idx_cafe_order_customer_date
ON cafe_order(customer_id, ordered_at);
```

SQLite CLI 출력 없음 (인덱스 생성 DDL은 결과 행을 반환하지 않음)
