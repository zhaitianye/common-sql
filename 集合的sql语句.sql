-- 按照日期查询用户基础信息，id、姓名、性别
-- 时间为北京时间
-- ASC 为正序， DESC 为倒序
SELECT
  date_add( u.created_time, INTERVAL 8 HOUR ) AS '注册时间',
  u.user_id AS '用户id',
  u.firstname AS '姓名',
CASE
    u.gender 
    WHEN 1 THEN
    '男' 
    WHEN 2 THEN
    '女' ELSE '未知' 
  END AS '性别' 
FROM
  `users` AS u 
WHERE
  u.merchant_id IS NULL 
  AND date_add( u.created_time, INTERVAL 8 HOUR ) > '2019-04-01 00:00:00' 
  AND date_add( u.created_time, INTERVAL 8 HOUR ) < '2019-04-20 23:59:59' 
ORDER BY
  注册时间 DESC
  
-- 分割线

# 查一段时间的数据(天)
# 时间  注册人数   男  女 未知    交易笔数  交易金额  兑换数量
#日常运营分析
SELECT
  date( DATE_ADD( u.created_time, INTERVAL 8 HOUR ) ) AS 日期,
  count( * ) AS 注册用户数量,
  (
  SELECT
    count( * ) 
  FROM
    charge c 
  WHERE
    c.wechat_transaction_id 
    AND sender_user_id 
    AND DATE_ADD( c.paid_at, INTERVAL 8 HOUR ) >= concat( date( DATE_ADD( u.created_time, INTERVAL 8 HOUR ) ), ' 00:00:00' ) 
    AND DATE_ADD( c.paid_at, INTERVAL 8 HOUR ) <= concat( date( DATE_ADD( u.created_time, INTERVAL 8 HOUR ) ), ' 23:59:59' ) 
  ) AS 交易笔数,
  (
  SELECT
    count( * ) 
  FROM
    charge c
    JOIN users ON c.sender_user_id = users.user_id 
  WHERE
    c.wechat_transaction_id 
    AND sender_user_id 
    AND DATE_ADD( users.created_time, INTERVAL 8 HOUR ) >= concat( date( DATE_ADD( u.created_time, INTERVAL 8 HOUR ) ), ' 00:00:00' ) 
    AND DATE_ADD( users.created_time, INTERVAL 8 HOUR ) <= concat( date( DATE_ADD( u.created_time, INTERVAL 8 HOUR ) ), ' 23:59:59' ) 
    AND DATE_ADD( c.paid_at, INTERVAL 8 HOUR ) >= concat( date( DATE_ADD( u.created_time, INTERVAL 8 HOUR ) ), ' 00:00:00' ) 
    AND DATE_ADD( c.paid_at, INTERVAL 8 HOUR ) <= concat( date( DATE_ADD( u.created_time, INTERVAL 8 HOUR ) ), ' 23:59:59' ) 
  ) AS 当天注册用户交易笔数,
  (
  SELECT
    ROUND( SUM( c.amount ), 2 ) 
  FROM
    charge c 
  WHERE
    c.wechat_transaction_id 
    AND sender_user_id 
    AND DATE_ADD( c.paid_at, INTERVAL 8 HOUR ) >= concat( date( DATE_ADD( u.created_time, INTERVAL 8 HOUR ) ), ' 00:00:00' ) 
    AND DATE_ADD( c.paid_at, INTERVAL 8 HOUR ) <= concat( date( DATE_ADD( u.created_time, INTERVAL 8 HOUR ) ), ' 23:59:59' ) 
  ) AS 交易金额,
  (
  SELECT
    COUNT( * ) 
  FROM
    treats t 
  WHERE
    t.redeemed_at_shop_time 
    AND DATE_ADD( t.redeemed_at_shop_time, INTERVAL 8 HOUR ) > concat( date( DATE_ADD( u.created_time, INTERVAL 8 HOUR ) ), ' 00:00:00' ) 
    AND DATE_ADD( t.redeemed_at_shop_time, INTERVAL 8 HOUR ) <= concat( date( DATE_ADD( u.created_time, INTERVAL 8 HOUR ) ), ' 23:59:59' ) 
  ) AS 兑换数量 
FROM
  users AS u 
WHERE
  u.merchant_id IS NULL 
  AND DATE_ADD( u.created_time, INTERVAL 8 HOUR ) >= '2019-05-31 00:00:00' 
  AND DATE_ADD( u.created_time, INTERVAL 8 HOUR ) <= '2019-05-31 23:59:59' 
GROUP BY
  日期,
  当天注册用户交易笔数,
  交易笔数,
  交易金额,
  兑换数量 
ORDER BY
  日期 DESC;
-- 测试服务器的交易笔数和交易金额，在正式服务器查询后如需对账，需要和这个测试服务器进行合并操作
-- 交易笔数
SELECT
  count( * ) AS 测试环境交易笔数 
FROM
  charge c 
WHERE
  c.wechat_transaction_id 
  AND DATE_ADD( c.paid_at, INTERVAL 8 HOUR ) >= '2019-05-30 00:00:00' 
  AND DATE_ADD( c.paid_at, INTERVAL 8 HOUR ) <= '2019-05-30 23:59:59' -- 交易金额
SELECT
  ROUND( SUM( c.amount ), 2 ) AS 测试环境交易金额 
FROM
  charge c 
WHERE
  c.wechat_transaction_id 
  AND sender_user_id 
  AND DATE_ADD( c.paid_at, INTERVAL 8 HOUR ) >= '2019-05-30 00:00:00' 
  AND DATE_ADD( c.paid_at, INTERVAL 8 HOUR ) <= '2019-05-30 23:59:59'
  
-- 分割线


-- 20190603 查询某一天的访问量
SELECT
  count(*) as visitcount
FROM
  records_app_everytime_open as r
WHERE
  date_add( r.dCreateTime, INTERVAL 8 HOUR ) > '2019-05-31 00:00:00' 
  AND date_add( r.dCreateTime, INTERVAL 8 HOUR ) < '2019-05-31 23:59:59'

-- 20190603 去重查询某一天的访问人数
SELECT
  count(DISTINCT JSON_UNQUOTE(r.xContent -> '$.userAssistanceId')) as accessNumber
FROM
  records_app_everytime_open AS r 
WHERE
  date_add( r.dCreateTime, INTERVAL 8 HOUR ) > '2019-06-03 00:00:00' 
  AND date_add( r.dCreateTime, INTERVAL 8 HOUR ) < '2019-06-03 23:59:59'
  AND JSON_UNQUOTE(r.xContent -> '$.userAssistanceId') is not null

-- 20190603 去重查询某一天无userid的userAssistanceId数组
SELECT DISTINCT
  JSON_UNQUOTE( r.xContent -> '$.userAssistanceId' ) AS userAssistanceId 
FROM
  records_app_everytime_open AS r 
WHERE
  date_add( r.dCreateTime, INTERVAL 8 HOUR ) > '2019-06-03 00:00:00' 
  AND date_add( r.dCreateTime, INTERVAL 8 HOUR ) < '2019-06-03 23:59:59' 
  AND r.userid IS NULL 
  AND JSON_UNQUOTE( r.xContent -> '$.userAssistanceId' ) IS NOT NULL 
  AND JSON_UNQUOTE( r.xContent -> '$.userAssistanceId' ) NOT IN (
  SELECT DISTINCT
    JSON_UNQUOTE( r.xContent -> '$.userAssistanceId' ) 
  FROM
    records_app_everytime_open AS r 
  WHERE
    date_add( r.dCreateTime, INTERVAL 8 HOUR ) > '2019-06-03 00:00:00' 
    AND date_add( r.dCreateTime, INTERVAL 8 HOUR ) < '2019-06-03 23:59:59' 
    AND r.userid IS NOT NULL 
    AND JSON_UNQUOTE( r.xContent -> '$.userAssistanceId' ) IS NOT NULL 
  ) 
  AND JSON_UNQUOTE( r.xContent -> '$.userAssistanceId' ) NOT IN (
  SELECT DISTINCT
    JSON_UNQUOTE( d.xContent -> '$.userAssistanceId' ) 
  FROM
    records_dic_general AS d 
  WHERE
    date_add( d.dCreateTime, INTERVAL 8 HOUR ) > '2019-06-03 00:00:00' 
    AND date_add( d.dCreateTime, INTERVAL 8 HOUR ) < '2019-06-03 23:59:59' 
    AND JSON_UNQUOTE( d.xContent -> '$.userAssistanceId' ) IS NOT NULL 
    AND d.userid NOT IN (
    SELECT DISTINCT
      u.user_id 
    FROM
      users AS u 
    WHERE
      date_add( u.created_time, INTERVAL 8 HOUR ) > '2019-06-03 00:00:00' 
      AND date_add( u.created_time, INTERVAL 8 HOUR ) < '2019-06-03 23:59:59' 
    ) 
  )
  
-- 20190603 统计新访客的注册数
SELECT DISTINCT
  JSON_UNQUOTE( r.xContent -> '$.userAssistanceId' ) AS userAssistanceId 
FROM
  records_app_everytime_open AS r 
WHERE
  date_add( r.dCreateTime, INTERVAL 8 HOUR ) > '2019-06-03 00:00:00' 
  AND date_add( r.dCreateTime, INTERVAL 8 HOUR ) < '2019-06-03 23:59:59' 
  AND r.userid IS NULL 
  AND JSON_UNQUOTE( r.xContent -> '$.userAssistanceId' ) IS NOT NULL 
  AND JSON_UNQUOTE( r.xContent -> '$.userAssistanceId' ) IN (
  SELECT DISTINCT
    JSON_UNQUOTE( r.xContent -> '$.userAssistanceId' ) 
  FROM
    records_app_everytime_open AS r 
  WHERE
    date_add( r.dCreateTime, INTERVAL 8 HOUR ) > '2019-06-03 00:00:00' 
    AND date_add( r.dCreateTime, INTERVAL 8 HOUR ) < '2019-06-03 23:59:59' 
    AND r.userid IS NOT NULL 
    AND JSON_UNQUOTE( r.xContent -> '$.userAssistanceId' ) IS NOT NULL 
    AND r.userid IN (
    SELECT DISTINCT
      u.user_id
    FROM
      users AS u
    WHERE
      date_add( u.created_time, INTERVAL 8 HOUR ) > '2019-06-03 00:00:00' 
      AND date_add( u.created_time, INTERVAL 8 HOUR ) < '2019-06-03 23:59:59' 
      AND r.userid IS NOT NULL 
    ) 
  )
  
#日常运营分析 -- 周建写的语句
SELECT date(DATE_ADD(u.created_time, INTERVAL 8 HOUR)) AS 日期,
       count(*)                                        AS 注册用户数量,
       (
           SELECT count(*)
           FROM charge c
           WHERE c.wechat_transaction_id
             AND c.sender_user_id
             AND DATE(DATE_ADD(c.paid_at, INTERVAL 8 HOUR)) = DATE(DATE_ADD(u.created_time, INTERVAL 8 HOUR))
       )                                               AS 总交易笔数,
       (
           SELECT count(*)
           FROM charge c
           WHERE c.wechat_transaction_id AND c.sender_user_id NOT IN ( 368,369,370,414,623 )
             AND c.sender_user_id AND c.for_promotion != 1
             AND DATE(DATE_ADD(c.paid_at, INTERVAL 8 HOUR)) = DATE(DATE_ADD(u.created_time, INTERVAL 8 HOUR))
       )                                               AS 正常交易笔数,
       (
           SELECT count(*)
           FROM charge c
                    JOIN users ON c.sender_user_id = users.user_id
           WHERE c.wechat_transaction_id
             AND c.sender_user_id
             AND DATE(DATE_ADD(users.created_time, INTERVAL 8 HOUR)) = DATE(DATE_ADD(u.created_time, INTERVAL 8 HOUR))
             AND DATE(DATE_ADD(c.paid_at, INTERVAL 8 HOUR)) = DATE(DATE_ADD(u.created_time, INTERVAL 8 HOUR))
       )                                               AS 当天注册用户交易笔数,
       (
           SELECT ROUND(SUM(c.amount), 2)
           FROM charge c
           WHERE c.wechat_transaction_id
             AND c.sender_user_id
             AND DATE(DATE_ADD(c.paid_at, INTERVAL 8 HOUR)) = DATE(DATE_ADD(u.created_time, INTERVAL 8 HOUR))
       )                                               AS 交易金额,
       (
           SELECT COUNT(*)
           FROM treats t
           WHERE t.redeemed_at_shop_time
             AND DATE(DATE_ADD(t.redeemed_at_shop_time, INTERVAL 8 HOUR)) = DATE(DATE_ADD(u.created_time, INTERVAL 8 HOUR))
       )                                               AS 兑换数量,
       (
           SELECT COUNT(*)
           FROM treats t
           WHERE t.recipient_user_id
            AND DATE(DATE_ADD(t.grabbed_time, INTERVAL 8 HOUR)) = DATE(DATE_ADD(u.created_time, INTERVAL 8 HOUR))
       )                                               AS 礼品领取量,
       (
           SELECT COUNT(*)
           FROM treats t
           WHERE t.recipient_user_id AND t.for_promotion != 1 AND t.charge_source != 'transfer'
            AND DATE(DATE_ADD(t.grabbed_time, INTERVAL 8 HOUR)) = DATE(DATE_ADD(u.created_time, INTERVAL 8 HOUR))
       )                                               AS 正常礼品领取量,
       (
           SELECT COUNT(*)
           FROM treats t
           WHERE t.recipient_user_id AND t.for_promotion
            AND DATE(DATE_ADD(t.grabbed_time, INTERVAL 8 HOUR)) = DATE(DATE_ADD(u.created_time, INTERVAL 8 HOUR))
       )                                               AS 1分钱礼品领取量,
       (
           SELECT COUNT(*)
           FROM user_redeemed_discount d
           WHERE DATE(DATE_ADD(d.collected_time, INTERVAL 8 HOUR)) = DATE(DATE_ADD(u.created_time, INTERVAL 8 HOUR))
       )                                               AS 优惠券领取量
FROM users AS u
WHERE u.merchant_id IS NULL
  AND DATE(DATE_ADD(u.created_time, INTERVAL 8 HOUR))  >= '2019-06-03'
  AND DATE(DATE_ADD(u.created_time, INTERVAL 8 HOUR))  <= '2019-06-05'
GROUP BY 日期,
         当天注册用户交易笔数,
         总交易笔数,
         正常交易笔数,
         交易金额,
         兑换数量,
         礼品领取量,
         正常礼品领取量,
         1分钱礼品领取量,
         优惠券领取量
ORDER BY 日期 DESC;


-- 查询特定商家的总扫码量
-- 'JWA562EV' 代表商家名为 "小时光休闲餐吧(深职院西校区)" 的商家
SELECT
  * 
FROM
  records_dic_general AS r 
WHERE
  r.nDicDataid = 'E4F7D0AA-011B-4F06-A008-DBF3C8EFC0D4' 
  AND JSON_UNQUOTE( r.xContent -> '$."merchant_random_id"' ) = 'JWA562EV'


# 统计一个商家的线下扫码数量，卖出的总数量，库存
SELECT
    m.NAME AS 商家名称,
    (
        SELECT
            count( * )
        FROM
            merchant_scan_tracks st
        WHERE
                st.merchant_random_id = m.random_id
          AND st.user_id NOT IN (368,369,370,414,623)
          AND st.created_time > ( SELECT date_sub( ( SELECT STR_TO_DATE( '2018-05-31 00:00:00', '%Y-%m-%d %H:%i:%s' ) ), INTERVAL 8 HOUR ) )
          AND st.created_time < ( SELECT date_sub( ( SELECT STR_TO_DATE( '2020-12-30 23:59:59', '%Y-%m-%d %H:%i:%s' ) ), INTERVAL 8 HOUR ) )
    ) AS 商家码总扫码量,

    (
        SELECT
            count( c.charge_id )
        FROM
            charge c,
            treats tr
        WHERE
                tr.merchant_random_id = m.random_id
          AND c.charge_id = tr.charge_id
          AND c.created_at > ( SELECT date_sub( ( SELECT STR_TO_DATE( '2018-05-31 00:00:00', '%Y-%m-%d %H:%i:%s' ) ), INTERVAL 8 HOUR ) )
          AND c.created_at < ( SELECT date_sub( ( SELECT STR_TO_DATE( '2020-12-30 23:59:59', '%Y-%m-%d %H:%i:%s' ) ), INTERVAL 8 HOUR ) )
          AND c.paid_success = 1
          AND c.wechat_transaction_id is not NULL
          AND m.language = 'hk'
#          AND c.sender_user_id NOT IN (368,369,370,414,623)
    ) AS 总销售量,
    (
        SELECT
            count( c.charge_id )
        FROM
            charge c,
            treats tr
        WHERE
                tr.merchant_random_id = m.random_id
          AND tr.redeemed_at_shop_time IS NOT NULL
          AND c.charge_id = tr.charge_id
          AND c.created_at > ( SELECT date_sub( ( SELECT STR_TO_DATE( '2018-05-31 00:00:00', '%Y-%m-%d %H:%i:%s' ) ), INTERVAL 8 HOUR ) )
          AND c.created_at < ( SELECT date_sub( ( SELECT STR_TO_DATE( '2020-12-30 23:59:59', '%Y-%m-%d %H:%i:%s' ) ), INTERVAL 8 HOUR ) )
          AND c.paid_success = 1
          AND c.wechat_transaction_id is not NULL
          AND m.language = 'hk'
#         AND c.sender_user_id NOT IN (368,369,370,414,623)
    ) AS 总兑换量,
    ( SELECT sum( o.order_count ) FROM vouchers_order o WHERE o.merchant_id = m.merchant_id AND o.valid = 1 ) AS 总采购量
FROM
    merchants m
WHERE
        m.LANGUAGE = 'hk'
  AND m.NAME IN ( '大欢喜(深大店)', '庙东排骨(深大店)', '蜜雪冰城(深大店)', '米乐的茶(深大店)', '乐摩坊(深大店)', '星期八餐饮(深大店)', '爽爽甜品(深大店)', '时令果町(深大店)','汉拿山(海岸城店)','云海肴(海岸城店)','甜心美甲(深大店)','Hiru花坊(深大店)', '厝内小眷村(深大店)', '益禾堂(深职院西校区)','学者咖啡(南科大)','麦基因坊(深职院东校区)','皇茶(深大西丽校区)','小时光休闲餐吧(深职院西校区)','雪之丘(悦方广场店)','甜咸配(悦方广场店)','益禾堂(深职院东校区)' )
ORDER BY
    商家码总扫码量 DESC


-- 一个特定商家的扫码量
SELECT
count(*) as count
FROM
records_dic_general AS r
WHERE
r.nDicDataid = 'E4F7D0AA-011B-4F06-A008-DBF3C8EFC0D4'
AND (r.userid NOT IN (623) OR r.userid is null)
AND JSON_UNQUOTE( r.xContent -> '$."merchant_random_id"' ) = 'JUXYXOWK'
AND date_add( r.dCreateTime, INTERVAL 8 HOUR ) >= '2018-07-01 00:00:00' 
AND date_add( r.dCreateTime, INTERVAL 8 HOUR ) <= '2020-10-20 23:59:59' 


-- 查询30天内的用户注册量的列表
SELECT
  t1.day as date,
  COUNT(t2.user_id) payment_num
FROM
( SELECT
  STR_TO_DATE(@cdate := DATE_ADD( @cdate, INTERVAL - 1 DAY ),'%Y-%m-%d') day
  FROM
    ( SELECT @cdate := DATE_ADD( '2019-04-01 23:59:59', INTERVAL + 1 DAY ) FROM users LIMIT 30 ) t0 
  ORDER BY
  DAY ASC 
  ) t1
LEFT JOIN 
( SELECT
  STR_TO_DATE(date_add( u.created_time, INTERVAL 8 HOUR ),'%Y-%m-%d') day,
  u.user_id
  FROM
    users as u
  WHERE date_add( u.created_time, INTERVAL 8 HOUR ) <= '2019-04-01 00:00:00'
  AND date_add( u.created_time, INTERVAL 8 HOUR ) > DATE_SUB( '2019-04-01 00:00:00', INTERVAL 30 DAY)
  ) t2
ON t2.day = t1.day
GROUP BY
  date

-- 查询用户购买量的SQL
SELECT
  STR_TO_DATE( date_add( created_time, INTERVAL 8 HOUR ), '%Y-%m-%d' ) AS DAY,
  count( * ) 
FROM
  treats 
WHERE
  merchant_id > 44 
  AND charge_id IN (
  SELECT
    charge_id 
  FROM
    charge 
  WHERE
    sender_user_id NOT IN ( 368, 369, 370, 414, 623, 3235 ) 
    AND wechat_transaction_id 
    AND amount > 0.01 
  ) 
  AND DATE( DATE_ADD( created_time, INTERVAL 8 HOUR ) ) >= '2019-05-01 00:00:00' 
  AND DATE( DATE_ADD( created_time, INTERVAL 8 HOUR ) ) <= '2019-06-24 23:59:59' 
GROUP BY
DAY 
ORDER BY
DAY ASC

-- 查询订单表
SELECT
  * 
FROM
  charge 
WHERE
  charge_source = 'take_out'
AND paid_success = 1
AND wechat_transaction_id IS NOT NULL
AND receivingTime

-- JSON统计情况的查询和分组
SELECT
  JSON_UNQUOTE( r.xContent -> '$.router.params.merchant_id' ),
  JSON_UNQUOTE( r.xContent -> '$.router.params.name' ),
  COUNT( * ) 
FROM
  records_dic_general AS r 
WHERE
  nDicDataid = 'F448EECB-5143-4B31-95F4-8E345CB97490' 
  AND JSON_UNQUOTE( r.xContent -> '$.router.path' ) = '/pages/takeaway_cart/index'
GROUP BY
  JSON_UNQUOTE( r.xContent -> '$.router.params.merchant_id' )
  
-- 给商户添加商品的时候使用
SELECT
  *
FROM
  merchants_taking_treats_rules 
WHERE
  merchant_id = 69

-- [{"name": "选温度", "children": [{"name": "冷", "active": true}, {"name": "热"}]}]
-- [{"name": "选温度", "children": [{"name": "冷", "active": true}]}]
-- [{"name": "选温度", "children": [{"name": "正常冰", "active": true}, {"name": "少冰"}, {"name": "去冰"}, {"name": "常温"}, {"name": "加热"}]},{"name": "选糖度", "children": [{"name": "正常", "active": true}, {"name": "半糖"}, {"name": "无糖"}, {"name": "微糖"}]}]
-- [{"name": "选温度", "children": [{"name": "正常冰", "active": true}, {"name": "少冰"}, {"name": "去冰"}]},{"name": "选糖度", "children": [{"name": "正常", "active": true}, {"name": "半糖"}, {"name": "无糖"}, {"name": "微糖"}]}]

-- 冷热
UPDATE merchants_taking_treats_rules SET take_away_specification = '[{"name": "选温度", "children": [{"name": "正常冰", "active": true}, {"name": "少冰"}, {"name": "去冰"}, {"name": "常温"}, {"name": "加热"}]},{"name": "选糖度", "children": [{"name": "正常", "active": true}, {"name": "半糖"}, {"name": "无糖"}, {"name": "微糖"}]}]'
WHERE merchant_id = 69 
AND name in('纯豆浆(中)', '红豆抹茶豆浆(中)', '桃胶豆浆(中)') 

-- 冷
UPDATE merchants_taking_treats_rules SET take_away_specification = '[{"name": "选温度", "children": [{"name": "正常冰", "active": true}, {"name": "少冰"}, {"name": "去冰"}]},{"name": "选糖度", "children": [{"name": "正常", "active": true}, {"name": "半糖"}, {"name": "无糖"}, {"name": "微糖"}]}]'
WHERE merchant_id = 69 
AND name in('爆柠四季春(大)', '冻柠蜜(大)', '柠檬益力多(中)') 

-- 聚合查询两个点之间的距离，以距离的远近排序
-- HAVING语句通常与GROUP BY语句联合使用，用来过滤由GROUP BY语句返回的记录集。
-- HAVING语句的存在弥补了WHERE关键字不能与聚合函数联合使用的不足。
SELECT
  *,
  (ST_Distance_Sphere (point (s.centroid_lng, s.centroid_lat),point(113.95085800,22.54286900) )) AS distance
from distribution_point as s
where 
 s.nDistributionCircleUid = '8B68D8B4-340B-4BF4-9D35-E847020FFA03'
ORDER BY distance ASC

-- json查询出来进行拼接
SELECT
  user_id,
  GROUP_CONCAT( JSON_OBJECT( 'name', firstname ) ) AS aaa 
FROM
  users 
GROUP BY
  user_id 
  LIMIT 1

SELECT
  -- CONCAT('[',GROUP_CONCAT(JSON_OBJECT( 'lowestDiscount', lowestDiscount )),']') AS JSON
  JSON_OBJECT( 'uid', uid,'lowestDiscount', lowestDiscount,'highestDiscount',highestDiscount ) AS JSON
FROM
  merchant_discount_rules as mdr
where
  mdr.nStatus <> -1
  and mdr.merchant_random_id = 'JUY2UOQV'
GROUP BY
  uid

