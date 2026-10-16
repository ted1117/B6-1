-- 01_schema.sql | SQLite 3 | 재실행 시 기존 실습 데이터를 초기화합니다.
-- SQLite 전용: PRAGMA foreign_keys = ON 은 연결마다 실행해야 합니다.
PRAGMA foreign_keys = ON;

-- FK로 참조하는 자식 테이블부터 제거합니다.
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS cafe_order;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS customer;

CREATE TABLE customer (
    customer_id   INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    phone         TEXT UNIQUE, -- 전화번호는 선택 입력, 등록 시 중복 방지
    joined_at     TEXT NOT NULL CHECK (date(joined_at) IS NOT NULL)
);

CREATE TABLE menu (
    menu_id       INTEGER PRIMARY KEY,
    menu_name     TEXT NOT NULL UNIQUE,
    category      TEXT NOT NULL CHECK (category IN ('COFFEE', 'TEA', 'DESSERT', 'OTHER')),
    price         INTEGER NOT NULL CHECK (price > 0), -- 원(KRW), 정수 보관
    is_available  INTEGER NOT NULL DEFAULT 1 CHECK (is_available IN (0, 1))
);

CREATE TABLE cafe_order (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER NOT NULL,
    ordered_at    TEXT NOT NULL CHECK (datetime(ordered_at) IS NOT NULL),
    status        TEXT NOT NULL CHECK (status IN ('PLACED', 'PAID', 'COMPLETED', 'CANCELED')),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE RESTRICT
);

CREATE TABLE order_item (
    order_item_id INTEGER PRIMARY KEY,
    order_id      INTEGER NOT NULL,
    menu_id       INTEGER NOT NULL,
    quantity      INTEGER NOT NULL CHECK (quantity > 0),
    unit_price    INTEGER NOT NULL CHECK (unit_price > 0), -- 주문 당시 가격 스냅샷
    FOREIGN KEY (order_id) REFERENCES cafe_order(order_id) ON DELETE RESTRICT,
    FOREIGN KEY (menu_id) REFERENCES menu(menu_id) ON DELETE RESTRICT,
    UNIQUE (order_id, menu_id) -- 한 주문 안의 동일 메뉴는 수량으로 관리
);
