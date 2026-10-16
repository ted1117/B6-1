# 카페 주문 관리 데이터베이스 실습 (SQLite)

## 제출 파일

- `01_schema.sql`: 테이블 4개, PK/FK/NOT NULL/UNIQUE/CHECK 제약조건 정의
- `02_seed.sql`: 고객 12건·메뉴 12건·주문 18건·주문 상세 36건 입력
- `03_queries.sql`: 요구 범주를 충족하는 핵심 SQL **15개**
- `04_results/`: Q01~Q15 실제 실행 결과 텍스트 및 무결성 검증 결과
- `05_ERD.md`: 관계도(Mermaid)와 테이블 설계 요약
- `cafe_demo.sqlite3`: 모든 쿼리를 적용한 SQLite 실습 DB 파일(편의 제공)

## 로컬 실행법

macOS에서 `sqlite3 --version`으로 설치 여부를 확인한 후, 프로젝트 폴더에서 다음 명령을 실행합니다.

```bash
sqlite3 cafe_local.sqlite3 < 01_schema.sql
sqlite3 cafe_local.sqlite3 < 02_seed.sql
sqlite3 -header -column cafe_local.sqlite3 < 03_queries.sql
```

모든 SQL 파일에 `PRAGMA foreign_keys = ON;`을 넣었습니다. **SQLite는 연결마다 FK 검사를 켜야 합니다.** 위 명령은 매번 연결을 새로 만들지만, 각 파일에 PRAGMA가 있으므로 FK가 적용됩니다.

03번 스크립트는 Q13 UPDATE, Q14 DELETE로 데이터를 변경합니다. 최초 샘플 데이터 상태로 되돌리려면 위 세 명령을 처음부터 다시 실행하세요. `01_schema.sql`은 실습 DB 테이블을 삭제하고 다시 만드므로, 다른 DB 파일이 아닌 **실습 전용 DB**에서만 실행하세요.

DBeaver 등에서는 SQLite DB 파일을 연결한 후, 01 → 02 → 03 순서대로 실행하면 됩니다. 도구에서 새 SQL 실행 연결을 열 때에는 `PRAGMA foreign_keys = ON;`을 실행해 FK 검사를 확인하세요.

## 데이터 모델

- `customer` 1:N `cafe_order` (`cafe_order.customer_id` FK)
- `cafe_order` 1:N `order_item` (`order_item.order_id` FK)
- `menu` 1:N `order_item` (`order_item.menu_id` FK)

`order_item.unit_price`는 **주문 당시 판매가를 보존**합니다. 메뉴 가격이 변경되어도 과거 매출이 바뀌지 않도록 `menu.price`와 분리했습니다. `order_item`은 주문과 메뉴 사이의 다대다 관계를 두 개의 1:N 관계로 풀어낸 중간 테이블입니다.

SQLite에서는 날짜/시간을 ISO 형식의 TEXT (`YYYY-MM-DD`, `YYYY-MM-DD HH:MM:SS`)로 저장합니다. 가격은 원(KRW) 단위 정수로 저장해 소수점 오차를 피합니다. 날짜 처리 `date()`, `datetime()` 및 `PRAGMA`는 SQLite 관련 문법입니다.

## 쿼리 요구사항 대응표

| 범주 | 쿼리 | 수량 |
|---|---|---:|
| 기본 조회(WHERE/ORDER BY/LIMIT) | Q01~Q04 | 4 |
| 조인(INNER JOIN 3, LEFT JOIN 1) | Q05~Q08 | 4 |
| 집계(COUNT, SUM, AVG / GROUP BY) | Q09~Q11 | 3 |
| 서브쿼리 | Q12 | 1 |
| UPDATE / DELETE | Q13~Q14 | 2 |
| CREATE INDEX 및 이유 | Q15 | 1 |
| **합계** | **Q01~Q15** | **15** |

유효 주문에 대한 매출 지표는 `PAID`, `COMPLETED`만 포함하며, `PLACED`, `CANCELED`는 제외합니다. Q07, Q09~Q11은 이 동일한 기준을 사용합니다.

## 확인 자료

각 `04_results/Q##_result.txt` 파일에 쿼리의 설명, 실행 SQL, 결과 행 또는 변경 전·후 상태를 넣었습니다. Q15에는 인덱스 존재와 `EXPLAIN QUERY PLAN`의 사용 여부도 포함했습니다. `04_results/integrity_checks.txt`는 의도적 FK/UNIQUE 위반 입력이 실패하는지 확인한 기록입니다.

엑셀은 시트에 데이터를 직접 열거해 관리하기 편하지만, 관계형 DB는 PK/FK로 여러 테이블 사이 참조를 강제하고, 데이터 무결성을 보장하며, JOIN을 통해 복수 테이블을 조합할 수 있습니다. 이 실습은 같은 고객·메뉴 정보를 주문마다 반복 저장하지 않고 테이블로 분리합니다.
