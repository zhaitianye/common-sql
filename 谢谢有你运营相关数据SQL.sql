#平台总用户量
SELECT
  count(*)  
FROM
  users

#部分时间范围内的用户注册量
SELECT
  count(*)  
FROM
  users
where
DATE( DATE_ADD( created_time, INTERVAL 8 HOUR ) ) >= '2019-09-01 00:00:00' 
AND DATE( DATE_ADD( created_time, INTERVAL 8 HOUR ) ) <= '2019-09-09 23:59:59' 

#总单量(全部单量，加上所有历史，包括付款和未付款的)
SELECT
  count(*) 
FROM
  charge

#总单量(全部单量，加上所有历史，已经付款的)
SELECT
  count(*) 
FROM
  charge
where 
  paid_success = 1

#部分时间范围内的总单量(全部单量，加上所有历史，包括付款和未付款的)
SELECT
  count(*) 
FROM
  charge
where 
  DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) >= '2019-09-01 00:00:00' 
  AND DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) <= '2019-09-09 23:59:59'

#部分时间范围内的总单量(全部单量，加上所有历史，已经付款的)
SELECT
  count(*) 
FROM
  charge
where 
  DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) >= '2019-09-01 00:00:00' 
  AND DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) <= '2019-09-09 23:59:59'
  AND paid_success = 1

#部分时间范围内的总营业额已经除去我们自己
SELECT
  SUM(amount)
FROM
  charge
where 
  DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) >= '2019-09-01 00:00:00' 
  AND DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) <= '2019-09-09 23:59:59'
  AND paid_success = 1
  AND sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )


#部分时间范围内的总成本已经除去我们自己
SELECT
  SUM(t.cost)
FROM
  treats AS t,
  charge as c
WHERE
  t.charge_id = c.charge_id
  AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) >= '2019-09-01 00:00:00' 
  AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) <= '2019-09-09 23:59:59'
  AND c.paid_success = 1
  AND c.sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )

#总利润
SELECT
  (
  SELECT
    SUM( c.amount ) 
  FROM
    charge AS c 
  WHERE
    DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) >= '2019-09-01 00:00:00' 
    AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) <= '2019-09-09 23:59:59' 
    AND c.paid_success = 1 
    AND c.sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 ) 
    )-(
  SELECT
    SUM( t.cost ) 
  FROM
    treats AS t,
    charge AS c 
  WHERE
    t.charge_id = c.charge_id 
    AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) >= '2019-09-01 00:00:00' 
    AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) <= '2019-09-09 23:59:59' 
  AND c.paid_success = 1 
  AND c.sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )) AS 总利润

#部分时间范围内的外卖单量(全部单量，加上所有历史，包括付款和未付款的，不包括我们自己)
SELECT
  count(*) 
FROM
  charge
where 
  DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
  AND DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59'
  AND charge_source = 'take_out_bus'
  AND sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )

#部分时间范围内的外卖单量(全部单量，加上所有历史，已付款的，不包括我们自己)
SELECT
  count(*) 
FROM
  charge
where 
  DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
  AND DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59'
  AND charge_source = 'take_out_bus'
  AND sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )
  AND paid_success = 1


#外卖营业额
SELECT
  SUM(amount)
FROM
  charge
where 
  DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
  AND DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59'
  AND paid_success = 1
  AND charge_source = 'take_out_bus'
  AND sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )


#外卖成本
SELECT
  SUM(t.cost)
FROM
  treats AS t,
  charge as c
WHERE
  t.charge_id = c.charge_id
  AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
  AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59'
  AND c.paid_success = 1
  AND c.charge_source = 'take_out_bus'
  AND c.sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )

#外卖利润
SELECT
  (
  SELECT
    SUM( amount ) 
  FROM
    charge 
  WHERE
    DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
    AND DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59' 
    AND paid_success = 1 
    AND charge_source = 'take_out_bus' 
    AND sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 ) 
    )-(
  SELECT
    SUM( t.cost ) 
  FROM
    treats AS t,
    charge AS c 
  WHERE
    t.charge_id = c.charge_id 
    AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
    AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59' 
    AND c.paid_success = 1 
  AND c.charge_source = 'take_out_bus' 
  AND c.sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )) AS 外卖利润


#部分时间范围内的自取单量(全部单量，加上所有历史，包括付款和未付款的，不包括我们自己)
SELECT
  count(*) 
FROM
  charge
where 
  DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
  AND DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59'
  AND charge_source = 'one_self'
  AND sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )

#部分时间范围内的自取单量(全部单量，加上所有历史，已付款的，不包括我们自己)
SELECT
  count(*) 
FROM
  charge
where 
  DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
  AND DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59'
  AND charge_source = 'one_self'
  AND sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )
  AND paid_success = 1


#自取营业额
SELECT
  SUM(amount)
FROM
  charge
where 
  DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
  AND DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59'
  AND paid_success = 1
  AND charge_source = 'one_self'
  AND sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )


#自取成本
SELECT
  SUM(t.cost)
FROM
  treats AS t,
  charge as c
WHERE
  t.charge_id = c.charge_id
  AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
  AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59'
  AND c.paid_success = 1
  AND c.charge_source = 'one_self'
  AND c.sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )

#自取利润
SELECT
  (
  SELECT
    SUM( amount ) 
  FROM
    charge 
  WHERE
    DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
    AND DATE( DATE_ADD( created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59' 
    AND paid_success = 1 
    AND charge_source = 'one_self' 
    AND sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 ) 
    )-(
  SELECT
    SUM( t.cost ) 
  FROM
    treats AS t,
    charge AS c 
  WHERE
    t.charge_id = c.charge_id 
    AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
    AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59' 
    AND c.paid_success = 1 
  AND c.charge_source = 'one_self' 
  AND c.sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 )) AS 自取利润


#当天初次购买的用户量

#一定范围时间内的新注册用户列表
SELECT
  user_id,
  firstname,
  gender,
  phone_number
FROM
  users
where
DATE( DATE_ADD( created_time, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
AND DATE( DATE_ADD( created_time, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59' 


#一定范围时间内的新注册用户并且有下单的用户列表，里面包含了下单的数量和金额
select 
  user_t1.*,
  count(c.charge_id) 注册并下单的数量,
  sum(c.amount) 下单钱数
from 
( SELECT
  user_id,
  firstname,
  gender,
  phone_number
FROM
  users
where
DATE( DATE_ADD( created_time, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
AND DATE( DATE_ADD( created_time, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59' ) AS user_t1,
charge as c
where 
  c.sender_user_id = user_t1.user_id
  AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) >= '2019-09-08 00:00:00' 
  AND DATE( DATE_ADD( c.created_at, INTERVAL 8 HOUR ) ) <= '2019-09-08 23:59:59'
  AND c.paid_success = 1
GROUP BY
  user_t1.user_id