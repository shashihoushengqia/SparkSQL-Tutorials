-- 用户信息表
CREATE TABLE IF NOT EXISTS dataspire_catalog.db_dev.dim_users
(
    user_id          STRING COMMENT '用户唯一标识ID',
    user_name        STRING COMMENT '用户昵称',
    register_date    STRING COMMENT '用户注册日期',
    city             STRING COMMENT '用户常驻城市',
    membership_level STRING COMMENT '会员等级：普通/白银/黄金/钻石',
    is_vip           STRING COMMENT '是否VIP用户'
)
USING iceberg
TBLPROPERTIES (
    'comment' = '用户维度表'
);

-- 订单事实表
CREATE TABLE IF NOT EXISTS dataspire_catalog.db_dev.fact_orders
(
    order_id        STRING COMMENT '订单唯一标识ID',
    user_id         STRING COMMENT '用户ID，关联dim_users表',
    order_date      STRING COMMENT '订单创建日期',
    order_time      STRING COMMENT '订单创建时间戳',
    total_amount    STRING COMMENT '订单实付金额',
    discount_amount STRING COMMENT '优惠折扣金额',
    status          STRING COMMENT '订单状态：paid/refunded/cancelled',
    payment_method  STRING COMMENT '支付方式：alipay/wechat/credit/card',
    channel         STRING COMMENT '下单渠道：app/web/miniprogram'
)
USING iceberg
TBLPROPERTIES (
    'comment' = '订单事实表'
)
;

-- 订单明细表
CREATE TABLE IF NOT EXISTS dataspire_catalog.db_dev.fact_order_items
(
    order_id     STRING COMMENT '订单ID，关联fact_orders表',
    product_id   STRING COMMENT '商品唯一标识ID',
    product_name STRING COMMENT '商品名称',
    category     STRING COMMENT '商品一级类目',
    sub_category STRING COMMENT '商品二级类目',
    quantity     STRING COMMENT '购买数量',
    unit_price   STRING COMMENT '商品单价',
    item_amount  STRING COMMENT '商品小计金额'
)
USING iceberg
TBLPROPERTIES (
    'comment' = '订单明细事实表'
)
;

-- ==================== 插入用户数据 ====================
INSERT INTO dataspire_catalog.db_dev.dim_users VALUES
(10001, '张三', '2024-01-15', '北京', '黄金', true),
(10002, '李四', '2024-03-20', '上海', '钻石', true),
(10003, '王五', '2024-06-10', '北京', '普通', false),
(10004, '赵六', '2025-01-05', '广州', '白银', false),
(10005, 'Emma', '2024-08-22', '深圳', '黄金', true),
(10006, 'John', '2024-11-30', '上海', '普通', false),
(10007, 'Mike', '2024-05-18', '北京', '钻石', true),
(10008, 'Lisa', '2025-02-01', '广州', '白银', false);

-- ==================== 插入订单数据 ====================
INSERT INTO dataspire_catalog.db_dev.fact_orders VALUES
-- 用户10001的订单（连续购买用户）
(202501010001, 10001, '2025-01-01', '2025-01-01 10:30:00', 500.00, 50.00, 'paid', 'alipay', 'app'),
(202501020001, 10001, '2025-01-02', '2025-01-02 14:20:00', 300.00, 30.00, 'paid', 'wechat', 'app'),
(202501030001, 10001, '2025-01-03', '2025-01-03 09:15:00', 200.00, 20.00, 'paid', 'alipay', 'web'),
(202501100001, 10001, '2025-01-10', '2025-01-10 16:00:00', 800.00, 80.00, 'paid', 'alipay', 'app'),
(202501150001, 10001, '2025-01-15', '2025-01-15 11:30:00', 1200.00, 100.00, 'paid', 'credit', 'app'),
-- 用户10002的订单（高价值用户）
(202501050001, 10002, '2025-01-05', '2025-01-05 10:00:00', 2000.00, 200.00, 'paid', 'credit', 'app'),
(202501060001, 10002, '2025-01-06', '2025-01-06 11:00:00', 1500.00, 150.00, 'paid', 'alipay', 'app'),
(202501070001, 10002, '2025-01-07', '2025-01-07 14:30:00', 3000.00, 300.00, 'paid', 'credit', 'web'),
(202501200001, 10002, '2025-01-20', '2025-01-20 09:00:00', 5000.00, 500.00, 'paid', 'credit', 'app'),
-- 用户10003的订单（流失风险用户）
(202501020002, 10003, '2025-01-02', '2025-01-02 08:00:00', 600.00, 60.00, 'paid', 'wechat', 'web'),
(202501030002, 10003, '2025-01-03', '2025-01-03 19:30:00', 400.00, 40.00, 'refunded', 'alipay', 'app'),
-- 用户10004的订单（新活跃用户）
(202502010001, 10004, '2025-02-01', '2025-02-01 10:00:00', 350.00, 35.00, 'paid', 'alipay', 'app'),
(202502020001, 10004, '2025-02-02', '2025-02-02 15:00:00', 450.00, 45.00, 'paid', 'wechat', 'app'),
(202502030001, 10004, '2025-02-03', '2025-02-03 12:00:00', 280.00, 28.00, 'paid', 'alipay', 'web'),
(202502040001, 10004, '2025-02-04', '2025-02-04 18:00:00', 520.00, 52.00, 'paid', 'alipay', 'app'),
-- 用户10005的订单（稳定复购用户）
(202501080001, 10005, '2025-01-08', '2025-01-08 10:00:00', 1000.00, 100.00, 'paid', 'alipay', 'app'),
(202501180001, 10005, '2025-01-18', '2025-01-18 14:00:00', 1500.00, 150.00, 'paid', 'credit', 'app'),
(202501280001, 10005, '2025-01-28', '2025-01-28 16:00:00', 2000.00, 200.00, 'paid', 'alipay', 'web'),
-- 用户10006的订单（单次购买用户）
(202501100002, 10006, '2025-01-10', '2025-01-10 11:00:00', 800.00, 80.00, 'paid', 'wechat', 'app'),
-- 用户10007的订单（VIP高价值用户）
(202501040001, 10007, '2025-01-04', '2025-01-04 09:00:00', 3000.00, 300.00, 'paid', 'credit', 'app'),
(202501050002, 10007, '2025-01-05', '2025-01-05 10:30:00', 2500.00, 250.00, 'paid', 'credit', 'app'),
(202501060002, 10007, '2025-01-06', '2025-01-06 11:30:00', 4000.00, 400.00, 'paid', 'credit', 'web'),
(202501070002, 10007, '2025-01-07', '2025-01-07 15:00:00', 3500.00, 350.00, 'paid', 'credit', 'app'),
(202501150002, 10007, '2025-01-15', '2025-01-15 10:00:00', 5000.00, 500.00, 'paid', 'credit', 'app'),
-- 用户10008的订单（新用户，数据较新）
(202502050001, 10008, '2025-02-05', '2025-02-05 14:00:00', 600.00, 60.00, 'paid', 'alipay', 'app'),
(202502060001, 10008, '2025-02-06', '2025-02-06 16:00:00', 750.00, 75.00, 'paid', 'wechat', 'app');

-- ==================== 插入订单明细数据 ====================
INSERT INTO dataspire_catalog.db_dev.fact_order_items VALUES
-- 订单202501010001明细
(202501010001, 5001, '智能手机Pro', '手机数码', '智能手机', 1, 500.00, 500.00),
-- 订单202501020001明细
(202501020001, 5002, '无线耳机', '手机数码', '音频设备', 2, 150.00, 300.00),
-- 订单202501030001明细
(202501030001, 5003, '快充充电器', '手机数码', '配件', 4, 50.00, 200.00),
-- 订单202501100001明细
(202501100001, 5004, '平板电脑', '电脑办公', '平板', 1, 800.00, 800.00),
-- 订单202501150001明细
(202501150001, 5005, '机械键盘', '电脑办公', '外设', 2, 600.00, 1200.00),
-- 订单202501050001明细
(202501050001, 5006, '笔记本电脑', '电脑办公', '笔记本', 1, 2000.00, 2000.00),
-- 订单202501060001明细
(202501060001, 5007, '显示器', '电脑办公', '显示器', 1, 1500.00, 1500.00),
-- 订单202501070001明细
(202501070001, 5008, '办公桌椅', '家居生活', '家具', 1, 3000.00, 3000.00),
-- 订单202501200001明细
(202501200001, 5009, '智能电视', '家用电器', '电视', 1, 5000.00, 5000.00),
-- 订单202501020002明细
(202501020002, 5010, '运动鞋', '服饰鞋包', '运动鞋', 2, 300.00, 600.00),
-- 订单202501030002明细
(202501030002, 5011, '休闲裤', '服饰鞋包', '裤子', 2, 200.00, 400.00),
-- 订单202502010001明细
(202502010001, 5012, '智能手表', '智能穿戴', '手表', 1, 350.00, 350.00),
-- 订单202502020001明细
(202502020001, 5013, '手环', '智能穿戴', '手环', 1, 450.00, 450.00),
-- 订单202502030001明细
(202502030001, 5014, '蓝牙耳机', '手机数码', '音频设备', 1, 280.00, 280.00),
-- 订单202502040001明细
(202502040001, 5015, '充电宝', '手机数码', '配件', 2, 260.00, 520.00),
-- 订单202501080001明细
(202501080001, 5016, '咖啡机', '家用电器', '厨房电器', 1, 1000.00, 1000.00),
-- 订单202501180001明细
(202501180001, 5017, '空气净化器', '家用电器', '生活电器', 1, 1500.00, 1500.00),
-- 订单202501280001明细
(202501280001, 5018, '扫地机器人', '家用电器', '生活电器', 1, 2000.00, 2000.00),
-- 订单202501100002明细
(202501100002, 5019, '背包', '服饰鞋包', '箱包', 1, 800.00, 800.00),
-- 订单202501040001明细
(202501040001, 5020, '高端手机', '手机数码', '智能手机', 1, 3000.00, 3000.00),
-- 订单202501050002明细
(202501050002, 5021, '高端耳机', '手机数码', '音频设备', 1, 2500.00, 2500.00),
-- 订单202501060002明细
(202501060002, 5022, '高端电脑', '电脑办公', '笔记本', 1, 4000.00, 4000.00),
-- 订单202501070002明细
(202501070002, 5023, '高端相机', '手机数码', '摄影摄像', 1, 3500.00, 3500.00),
-- 订单202501150002明细
(202501150002, 5024, '高端电视', '家用电器', '电视', 1, 5000.00, 5000.00),
-- 订单202502050001明细
(202502050001, 5025, '护肤品', '美妆个护', '护肤', 2, 300.00, 600.00),
-- 订单202502060001明细
(202502060001, 5026, '化妆品', '美妆个护', '彩妆', 3, 250.00, 750.00);

-- 计算每个用户的购买行为指标（仅统计paid状态）
SELECT
    t.user_id                     AS user_id -- 用户id
  , u.user_name                   AS user_name -- 用户名
  , COUNT(0)                      AS order_cnt -- 总订单数
  , ROUND(SUM(t.total_amount), 2) AS tol_amt -- 总消费金额
  , ROUND(IF(COUNT(0) = 0, 0, SUM(t.total_amount) / COUNT(0)),
          2)                      AS avg_amt -- 平均消费金额
  , MIN(t.order_date)             AS first_order_date -- 首次购买时间
  , MAX(t.order_date)             AS last_order_date -- 最近购买时间
  , DATEDIFF(MAX(t.order_date), MIN(t.order_date)) +
    1                             AS days_diff -- 购买天数跨度
FROM
    dataspire_catalog.db_dev.fact_orders t
    LEFT JOIN dataspire_catalog.db_dev.dim_users u ON t.user_id = u.user_id
WHERE
    1 = 1 AND t.status = 'paid'
GROUP BY
    t.user_id, u.user_name
-- 按照总消费金额降序排序
ORDER BY
    tol_amt DESC, order_cnt DESC, user_id
-- 限制输出结果为10条，虽然题目无要求，但这是非常推荐的一个实验用的习惯，可以极大地节省网络带宽
LIMIT 10
;


-- 识别连续购买行为
SELECT
    tab3.user_id            AS user_id -- 用户id
  , tab3.user_name          AS user_name -- 用户名
  , MAX(tab3.con_order_cnt) AS max_con_order_cnt -- 最大连续登录天数
FROM
    (SELECT
         tab2.user_id          AS user_id -- 用户id
       , tab2.user_name        AS user_name -- 用户名
       , tab2.con_start_date   AS con_start_date -- 连续起始日期
       , COUNT(con_start_date) AS con_order_cnt -- 连续登录天数
     FROM
         (SELECT
              tab1.user_id                 AS user_id -- 用户id
            , tab1.user_name               AS user_name -- 用户名
              -- 连续登录的用户order_date - order_rank理论上是相等的
              -- 比如所2025-01-01 减 0 = 2025-01-01，2025-01-02 减 1 = 2025-01-01
              -- 但不连续的2025-01-10 减 3 = 2025-01-07
            , DATE_SUB(tab1.order_date, tab1.order_rank -
                                        1) AS con_start_date -- 连续起始日期
          FROM
              (SELECT
                   t.user_id                 AS user_id -- 用户id
                 , u.user_name               AS user_name -- 用户名
                 , t.order_date              AS order_date -- 下单日期
                   -- 对每个用户根据下单时间做一个升序排名
                 , ROW_NUMBER() OVER (PARTITION BY t.user_id, u.user_name
                      ORDER BY t.order_date) AS order_rank -- 排名
               FROM
                   dataspire_catalog.db_dev.fact_orders t
                   LEFT JOIN dataspire_catalog.db_dev.dim_users u
                             ON t.user_id = u.user_id
               WHERE
                   1 = 1) tab1
          WHERE
              1 = 1) tab2
     WHERE
         1 = 1
     GROUP BY
         tab2.user_id, tab2.user_name, tab2.con_start_date
     HAVING con_order_cnt >= 3) tab3
WHERE
    1 = 1
GROUP BY
    tab3.user_id, tab3.user_name
ORDER BY
    max_con_order_cnt DESC, user_id
LIMIT 10
;

-- 计算各商品一级二级类目的销售指标
SELECT
    i.category                   AS category -- 一级类目
  , i.sub_category               AS sub_category -- 二级类目
    -- 注意，这里要用DISTINCT做一个去重处理，因为 t 表和 i 表是一对多的join关系，t表中唯一的order_id在关联后就不再唯一了
  , COUNT(DISTINCT t.order_id)   AS order_cnt -- 销售订单数
  , COUNT(DISTINCT t.user_id)    AS user_cnt -- 购买订单数
  , ROUND(SUM(i.item_amount), 2) AS order_amt -- 销售总金额
  , SUM(i.quantity)              AS order_qty -- 销售总数量
  , ROUND(IF(COUNT(DISTINCT t.order_id) = 0, 0,
             SUM(i.item_amount) / COUNT(DISTINCT t.order_id)),
          2)                     AS order_avg_amt -- 平均订单金额
FROM
    dataspire_catalog.db_dev.fact_orders t
    LEFT JOIN dataspire_catalog.db_dev.fact_order_items i
              ON t.order_id = i.order_id
    LEFT JOIN dataspire_catalog.db_dev.dim_users u
              ON t.user_id = u.user_id
WHERE
      1 = 1
  AND t.status = 'paid'
GROUP BY
    i.category, i.sub_category
ORDER BY
    order_amt DESC, order_cnt DESC, sub_category
LIMIT 10
;

-- 计算用户品类偏好
WITH tab AS
(
SELECT
     t.user_id      AS user_id -- 用户id
   , i.category     AS category -- 一级类目
   , i.sub_category AS sub_category -- 二级类目
   , i.item_amount  AS item_amount -- 商品小计金额
 FROM
     dataspire_catalog.db_dev.fact_orders t
     LEFT JOIN dataspire_catalog.db_dev.fact_order_items i
               ON t.order_id = i.order_id
 WHERE
       1 = 1
   AND t.status = 'paid'
)
SELECT
    tab.user_id                    AS user_id -- 用户id
  , tab.category                   AS category -- 一级类目
  , tab.sub_category               AS sub_category -- 二级类目
  , ROUND(SUM(tab.item_amount), 2) AS order_amt -- 用户购买金额
  , ROUND(IF(MAX(tab1.item_amount) = 0, 0,
             SUM(tab.item_amount) / MAX(tab1.item_amount)) * 100,
          2)                       AS order_amt_ratio -- 用户购买金额占比
FROM
    tab
    LEFT JOIN (SELECT
                   tab.user_id          AS user_id -- 用户id
                 , SUM(tab.item_amount) AS item_amount -- 用户总购买金额
               FROM
                   tab
               WHERE
                   1 = 1
               GROUP BY
                   tab.user_id) tab1
              ON tab.user_id = tab1.user_id
WHERE
    1 = 1
GROUP BY
    tab.user_id, tab.category, tab.sub_category
ORDER BY
    order_amt DESC, order_amt_ratio DESC, user_id
LIMIT 10
;


-- 计算品类复购率
SELECT
    i.category                AS category -- 一级类目
  , i.sub_category            AS sub_category -- 二级类目
  , t.user_id                 AS user_id -- 用户id
  , COUNT(DISTINCT t.user_id) AS repurchase_user_cnt -- 复购用户数
  , ROUND(IF(COUNT(1) = 0, 0, COUNT(DISTINCT t.user_id) / COUNT(1)) * 100,
          2)                  AS repurchase_rate -- 品类复购率
FROM
    dataspire_catalog.db_dev.fact_orders t
    LEFT JOIN dataspire_catalog.db_dev.fact_order_items i
              ON t.order_id = i.order_id
WHERE
    1 = 1 AND t.status = 'paid'
GROUP BY
    i.category, i.sub_category, t.user_id
HAVING
    COUNT(1) >= 2
ORDER BY
    repurchase_user_cnt DESC, repurchase_rate DESC, user_id
LIMIT 10
;


