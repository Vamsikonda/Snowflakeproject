use role accountadmin;
use database sandbox;
use schema consumption_sch;

```sql
CREATE OR REPLACE TABLE consumption_sch.order_item_fact (
    order_item_fact_sk NUMBER AUTOINCREMENT COMMENT 'Surrogate Key (EDW)',
    order_item_id NUMBER COMMENT 'Order Item FK (Source System)',
    order_id NUMBER COMMENT 'Order FK (Source System)',

    customer_dim_key NUMBER COMMENT 'Customer DIM FK',
    customer_id NUMBER COMMENT 'Reference to the customer dimension',

    customer_address_dim_key NUMBER COMMENT 'Customer Address DIM FK',
    address_id NUMBER COMMENT 'Reference to the customer address',

    restaurant_dim_key NUMBER COMMENT 'Restaurant DIM FK',
    restaurant_id NUMBER COMMENT 'Reference to the restaurant dimension',

    restaurant_location_dim_key NUMBER COMMENT 'Restaurant Location DIM FK',
    location_id NUMBER COMMENT 'Reference to the restaurant location',

    menu_dim_key NUMBER COMMENT 'Menu DIM FK',
    menu_id NUMBER COMMENT 'Reference to the menu dimension',

    delivery_agent_dim_key NUMBER COMMENT 'Delivery Agent DIM FK',
    delivery_agent_id NUMBER COMMENT 'Reference to the delivery agent',

    order_date_dim_key NUMBER COMMENT 'Reference to the date dimension',

    quantity NUMBER COMMENT 'Measure',
    price NUMBER(10, 2) COMMENT 'Measure',
    subtotal NUMBER(10, 2) COMMENT 'Measure',

    delivery_status VARCHAR COMMENT 'Delivery information',
    estimated_time VARCHAR COMMENT 'Delivery information'
)
COMMENT = 'The item order fact table that has item level price, quantity and other details';
```



```sql
MERGE INTO consumption_sch.order_item_fact AS target
USING (
    SELECT 
        oi.order_item_id AS order_item_id,
        oi.order_id_fk AS order_id,

        c.customer_hk AS customer_dim_key,
        c.customer_id AS customer_id,

        ca.customer_address_hk AS customer_address_dim_key,
        ca.address_id AS address_id,

        r.restaurant_hk AS restaurant_dim_key,
        r.restaurant_id AS restaurant_id,

        rl.restaurant_location_hk AS restaurant_location_dim_key,
        rl.location_id AS location_id,

        m.menu_dim_hk AS menu_dim_key,
        m.menu_id AS menu_id,

        da.delivery_agent_hk AS delivery_agent_dim_key,
        da.delivery_agent_id AS delivery_agent_id,

        dd.date_dim_hk AS order_date_dim_key,

        oi.quantity::NUMBER(10,2) AS quantity,
        oi.price AS price,
        oi.subtotal AS subtotal,

        d.delivery_status AS delivery_status,
        d.estimated_time AS estimated_time

    FROM clean_sch.order_item oi

    JOIN clean_sch.orders o
        ON oi.order_id_fk = o.order_id

    JOIN clean_sch.delivery d
        ON o.order_id = d.order_id_fk

    JOIN consumption_sch.customer_dim c
        ON o.customer_id_fk = c.customer_id

    JOIN consumption_sch.customer_address_dim ca
        ON c.customer_id = ca.customer_id_fk

    JOIN consumption_sch.restaurant_dim r
        ON o.restaurant_id_fk = r.restaurant_id

    JOIN consumption_sch.menu_dim m
        ON oi.menu_id_fk = m.menu_id

    JOIN consumption_sch.delivery_agent_dim da
        ON d.delivery_agent_id_fk = da.delivery_agent_id

    JOIN consumption_sch.restaurant_location_dim rl
        ON r.location_id_fk = rl.location_id

    JOIN consumption_sch.date_dim dd
        ON dd.calendar_date = DATE(o.order_date)

) AS source_stm

ON target.order_item_id = source_stm.order_item_id
AND target.order_id = source_stm.order_id

WHEN MATCHED THEN
    UPDATE SET
        target.customer_dim_key = source_stm.customer_dim_key,
        target.customer_id = source_stm.customer_id,
        target.customer_address_dim_key = source_stm.customer_address_dim_key,
        target.address_id = source_stm.address_id,
        target.restaurant_dim_key = source_stm.restaurant_dim_key,
        target.restaurant_id = source_stm.restaurant_id,
        target.restaurant_location_dim_key = source_stm.restaurant_location_dim_key,
        target.location_id = source_stm.location_id,
        target.menu_dim_key = source_stm.menu_dim_key,
        target.menu_id = source_stm.menu_id,
        target.delivery_agent_dim_key = source_stm.delivery_agent_dim_key,
        target.delivery_agent_id = source_stm.delivery_agent_id,
        target.order_date_dim_key = source_stm.order_date_dim_key,
        target.quantity = source_stm.quantity,
        target.price = source_stm.price,
        target.subtotal = source_stm.subtotal,
        target.delivery_status = source_stm.delivery_status,
        target.estimated_time = source_stm.estimated_time

WHEN NOT MATCHED THEN
    INSERT (
        order_item_id,
        order_id,
        customer_dim_key,
        customer_id,
        customer_address_dim_key,
        address_id,
        restaurant_dim_key,
        restaurant_id,
        restaurant_location_dim_key,
        location_id,
        menu_dim_key,
        menu_id,
        delivery_agent_dim_key,
        delivery_agent_id,
        order_date_dim_key,
        quantity,
        price,
        subtotal,
        delivery_status,
        estimated_time
    )
    VALUES (
        source_stm.order_item_id,
        source_stm.order_id,
        source_stm.customer_dim_key,
        source_stm.customer_id,
        source_stm.customer_address_dim_key,
        source_stm.address_id,
        source_stm.restaurant_dim_key,
        source_stm.restaurant_id,
        source_stm.restaurant_location_dim_key,
        source_stm.location_id,
        source_stm.menu_dim_key,
        source_stm.menu_id,
        source_stm.delivery_agent_dim_key,
        source_stm.delivery_agent_id,
        source_stm.order_date_dim_key,
        source_stm.quantity,
        source_stm.price,
        source_stm.subtotal,
        source_stm.delivery_status,
        source_stm.estimated_time
    );
```




-- start with 
alter table consumption_sch.order_item_fact
    add constraint fk_order_item_fact_customer_dim
    foreign key (customer_dim_key)
    references consumption_sch.customer_dim (customer_hk);

alter table consumption_sch.order_item_fact
    add constraint fk_order_item_fact_customer_address_dim
    foreign key (customer_address_dim_key)
    references consumption_sch.customer_address_dim (CUSTOMER_ADDRESS_HK);

alter table consumption_sch.order_item_fact
    add constraint fk_order_item_fact_restaurant_dim
    foreign key (restaurant_dim_key)
    references consumption_sch.restaurant_dim (restaurant_hk);

alter table consumption_sch.order_item_fact
    add constraint fk_order_item_fact_restaurant_location_dim
    foreign key (restaurant_location_dim_key)
    references consumption_sch.restaurant_location_dim (restaurant_location_hk);

alter table consumption_sch.order_item_fact
    add constraint fk_order_item_fact_menu_dim
    foreign key (menu_dim_key)
    references consumption_sch.menu_dim (menu_dim_hk);

alter table consumption_sch.order_item_fact
    add constraint fk_order_item_fact_delivery_agent_dim
    foreign key (delivery_agent_dim_key)
    references consumption_sch.delivery_agent_dim (delivery_agent_hk);

alter table consumption_sch.order_item_fact
    add constraint fk_order_item_fact_delivery_date_dim
    foreign key (order_date_dim_key)
    references consumption_sch.date_dim (date_dim_hk);


    7 dimesions and 1 fact - Order_item_fact

    Dim_date, Dim_customers, dim_menu, dim_deliveryagent, dim_restaurent, dim_Customenr addres, dim_location




    Select * from Order_item_fact 