# 카페 주문 관리 데이터베이스 (SQLite)

- 고객, 메뉴, 주문, 주문 상세를 네 테이블로 관리하는 SQL 실습
- 테이블 생성부터 데이터 입력, 조회, 조인, 집계, 수정·삭제, 인덱스 생성까지 포함

## 파일

- `01_schema.sql` — 테이블과 PK/FK 및 제약조건
- `02_seed.sql` — 고객 12명, 메뉴 12개, 주문 18건, 주문 상세 36건
- `03_queries.sql` — 설명이 포함된 핵심 쿼리 15개
- `04_results.md` — 쿼리문과 실제 실행 결과
- `05_ERD.md` — 테이블 관계도

## 실행

SQLite가 설치된 환경에서 프로젝트 폴더에서 실행합니다.

```bash
sqlite3 cafe_local.sqlite3 < 01_schema.sql
sqlite3 cafe_local.sqlite3 < 02_seed.sql
sqlite3 -header -column cafe_local.sqlite3 < 03_queries.sql
```

## 데이터 관계

- `customer` 1:N `cafe_order`
- `cafe_order` 1:N `order_item`
- `menu` 1:N `order_item`

`order_item.unit_price`에는 주문 당시 가격을 저장해 메뉴 가격이 바뀌어도 과거 주문 금액을 보존합니다. 날짜와 시간은 ISO 형식의 TEXT, 금액은 원 단위 정수로 저장합니다.

## 쿼리 구성

| 쿼리 | 내용 |
| --- | --- |
| Q01~Q04 | 기본 조회 |
| Q05~Q08 | INNER JOIN 및 LEFT JOIN |
| Q09~Q11 | AVG, COUNT, SUM 집계와 GROUP BY |
| Q12 | 서브쿼리 |
| Q13~Q14 | UPDATE, DELETE |
| Q15 | 고객별 주문 조회를 위한 복합 인덱스 생성 |

Q09~Q11은 단일 테이블에서 카테고리별 평균 가격, 주문 상태별 건수, 카테고리별 가격 합계를 구합니다. Q12가 평균 메뉴 가격을 기준으로 메뉴를 조회합니다.
