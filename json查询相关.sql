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
  

-- Json聚合列
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