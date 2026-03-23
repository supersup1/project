use project1;
#1.创建表格以及数据插入
#订单主表-------------------------------------------------------------------------------------------------------
create table order_master(
    id int primary key auto_increment,
    order_number varchar(32) not null unique comment '订单编号',
    customer_id int not null comment '客户id',
    total_money decimal(10,2) not null comment '总金额',
    status int  not null comment '订单状态 1=待提交 2=待审核 3=已审核 4=已完成 5=作废',
    create_time datetime not null default now() comment '订单创建时间',
    create_user varchar(10) not null comment '创建人',
    remark varchar(200)  comment '注释'
) comment '订单主表';
#数据插入 以及插入错误的模拟数据
INSERT INTO order_master (order_number, customer_id, total_money, status, create_user, remark) VALUES
('DD202506001', 1, 5520.00, 2, 'zhangsan', '待审核'),
('DD202506002', 2, 860.00,  3, 'lisi', '已审核'),
('DD202506003', 3, 2400.00, 2, 'wangwu', '待审核'),
('DD202506004', 1, 5200.00, 1, 'zhangsan', '待提交'),
('DD202506005', 4, 5200.00, 4, 'zhaoliu', '已完成'),
('DD202506006',2,160.00,6,'lisi','已完成'),
('DD202506007',3,160.00,7,'wangwu','作废');
;
#订单明细表格--------------------------------------------------------------------------------------------------------
create table order_item(
    id int primary key auto_increment,
    order_id            int       not null     comment '订单主表ID',
    product_id          varchar(32)   not null comment ' 商品编码',
    product_name        varchar(50)   not null  comment '商品名称',
    price               decimal(10,2)  not null comment '单价',
    num                 int    default 1      not null  comment '数量',
    money               decimal(10,2) not null  comment '小计金额'
)comment'订单明细表';
INSERT INTO order_item (order_id, product_id, product_name, price, num, money) VALUES
(1, 'SP001', '华为笔记本电脑', 5200.00, 1, 5200.00),
(1, 'SP002', '罗技鼠标',      160.00,  2, 320.00),
(2, 'SP003', '小米显示器',    860.00,  1, 860.00),
(3, 'SP004', '惠普打印机',   2400.00, 1, 2400.00),
(4, 'SP001', '华为笔记本电脑', 5200.00, 1, 5200.00),
(5, 'SP001', '华为笔记本电脑',5200.00, 1, 5200.00),
(6, 'SP002', '罗技鼠标',160.00, 1, 160.00);
#商品信息表--------------------------------------------------------------------------------------------------------
create table product(
    product_id          varchar(32) primary key   comment '商品编码（主键）',
    product_name        varchar(50)   not null  comment '商品名称',
    spec                varchar(50)   not null  comment '规格',
    unit                varchar(10)   not null  comment '单位',
    create_time         datetime   default now()  not null  comment '创建时间',
    price               decimal(20,2) not null comment '商品单价'
)comment'商品信息表';
INSERT INTO product (product_id, product_name, spec, unit,price) VALUES
('SP001', '华为笔记本电脑', '16G+512G', '台',5200.00),
('SP002', '罗技鼠标',      '无线款',    '个',160.00),
('SP003', '小米显示器',    '27寸4K',    '台',860.00),
('SP004', '惠普打印机',    'A4彩色',    '台',2400.00),
('SP005', '戴尔键盘',      '无线静音',  '个',250.00);
#库存表--------------------------------------------------------------------------------------------------------
create table stock(
     id                  int    primary key  auto_increment     comment '主键',
    product_id          varchar(32) unique  not null  comment '商品编码',
    stock_num           int            not null check ( stock_num>=0 ) comment '库存数量(不可小于0)',
    warehouse           varchar(30)    not null  comment '仓库',
    update_time         datetime      default now() comment '更新时间'
)comment'库存表';
INSERT INTO stock (product_id, stock_num, warehouse) VALUES
('SP001', 15,  '总仓'),
('SP002',      32,  '总仓'),
('SP003',    10,  '总仓'),
('SP004',    8,   '总仓'),
('SP005',     0,   '总仓');
#客户表--------------------------------------------------------------------------------------------------------
create table customer(
      id int primary key  auto_increment comment '主键',
  customer_name varchar(50)  not null comment '客户名称',
  phone varchar(20)  not null  unique comment '联系电话',
  address varchar(200) default '' comment '地址',
  create_time datetime not null default now() comment '创建时间'
)comment '客户表';
INSERT INTO customer (customer_name, phone, address) VALUES
('张三科技公司', '13800138000', '北京市朝阳区'),
('李四贸易商行', '13900139000', '上海市浦东新区'),
('王五电子商行', '13700137000', '广州市天河区'),
('赵六电脑店',   '13600136000', '深圳市南山区');
# 管理员表 ----------------------------------------------------------------------------------------------------------
create table user(
    id int primary key  auto_increment,
    username varchar(20) not null ,
    userid char(5) unique not null ,
    position varchar(20) not null
);
insert into user(username, userid, position) values
('Boss','id001','经理'),
('DaNiu','id002','开发工程师'),
('DaMa','id003','实习生');


#数据校验 目的是为了查出左表没匹配到右表的数据行 为接下来的外键约束做准备
select om.* from order_master om
left join  customer c on om.customer_id = c.id
where c.id is null;
#校验订单明细表和订单主表中总价格的数据一致性
select oi.* from order_item oi left join order_master om on oi.order_id =om.id
where om.total_money is null;
#校验订单明细的product_id是否存在于商品表
select oi.* from order_item oi
left join product p on oi.product_id = p.product_id
where p.product_id is null;

#校验库存的product_id是否存在于商品表
select s.* from stock s
left join product p on s.product_id = p.product_id
where p.product_id is null;

#外键约束
#1.订单主表 →  客户表 用户id
alter table order_master
    add constraint fk_id_order
        foreign key (customer_id) references customer (id)
            on UPDATE cascade on DELETE cascade;
#2. 订单明细表 → 订单主表 订单主表id
alter table order_item
    add constraint fk_oi_order
        foreign key (order_id) references order_master (id)
            on UPDATE cascade on DELETE cascade;

#3. 订单明细表 → 商品表 商品id
alter table order_item
    add constraint fk_oi_product
        foreign key (product_id) references product (product_id)
            on UPDATE cascade on DELETE cascade;

#4. 库存表 → 商品表 商品id
alter table stock
    add constraint fk_stock_product
        foreign key (product_id) references product (product_id)
            on UPDATE cascade on DELETE cascade;
#


#查询order_master表中 status值非法错误的订单信息的行数 （仅允许1-5）
select *,concat('状态值非法','——',order_master.status,'——','状态值仅允许1-5') from order_master where status not in (1,2,3,4,5);

#关于order_master表格中的错误数据的修改
update order_master set status=4 where id=6;


update order_master set status=5 where id=7;

#插入前的触发器：当order_master 表格中插入数据之前触发 条件是当status=1-5时正常插入 非1-5前置报错
delimiter //
create trigger omtrigger
    before insert on order_master for each row
begin
    if new.status not in  (1,2,3,4,5) then
        signal  sqlstate '45000'
        set message_text ='订单状态值错误（仅允许1-5）';
    end if;
end//
delimiter ;
#插入前的触发器 在order_item表中 当商品的购买数量超过stock表中的商品库存时 提示购买数量超过库存数量 当购买数量小于库存数量的时候购买完成 并且库存表数量正确减少
delimiter //
create trigger oitrigger
    before insert on order_item for each row
begin
        declare kc_num int default 0;
        # 在查询订单的时候  防止商品的超卖
        select stock.stock_num into kc_num from stock where product_id = NEW.product_id FOR UPDATE ;
     if kc_num=0 then
         signal sqlstate '45000'
         set message_text = '您购买的商品的商品库存为0 无法下单';

    elseif kc_num< NEW.num then
         signal sqlstate '45000'
         set message_text ='您购买的商品数量量大于库存量！购买失败';

    else

         update stock set stock_num=stock_num-new.num where product_id=new.product_id;

     end if;
end//
delimiter ;

#删除订单明细（用户申请退款）库存数量加回购买之前的数量
delimiter //

create trigger oitrigger_delete
    before delete on order_item for each row
begin
#   删除明细时把数量加回库存
    update stock set stock_num=stock_num+OLD.num where product_id=OLD.product_id;
end //
delimiter ;

#修改订单状态 如果修改必须在（1，2，3，4,5）之间 订单状态为5则不能修改（订单作废的情况下不能修改订单状态值） 且 要修改状态的订单号存在于订单表中
delimiter //
create procedure p_order_master(in ordernum varchar(32),in newstatus int,out result varchar(50))
    begin
        declare om_order_number int default 0;
        declare om_order_status int;
        set result='';
        #查询传入的ordernum是否存在于order_master表中
        select count(order_number) into om_order_number from order_master where order_number=ordernum;
        #检验输入订单号是否存在
        if om_order_number = 0 then
            set result=concat('未找到订单号：',ordernum);
            signal sqlstate '45000'
            set message_text = result;
        end if ;
        #查询对应订单的状态值
        select status into om_order_status from order_master where order_number=ordernum;
        # 检验订单状态值是否正确
        if newstatus not in (1,2,3,4,5) then
            set result=concat('订单号：',ordernum,'状态值不允许');
            signal sqlstate '45000'
            set message_text = result;
        end if;
        #订单状态是否作废 作废时 禁止修改
            if om_order_status =5 then
                set result=concat('订单号：',ordernum,'状态值为5（已作废不能进行修改）');
                signal sqlstate '45000' set message_text =result;
            end if ;


        #对订单进行修改
        update order_master set status=newstatus where order_number=ordernum;
        set result=concat('订单',ordernum,'订单状态修改为',newstatus);


    end//
delimiter ;
#修改之后的触发器 由于订单主表中订单状态的修改 remark注释也需要进行对应的修改
delimiter //
    create trigger up_remark
    before update on order_master for each row
    begin
        declare newremark varchar(200) ;
        if old.status <> new.status then
            set newremark = case new.status
                when 1 then '待提交'
                when 2 then '待审核'
                when 3 then '已审核'
                when 4 then '已完成'
                when 5 then '作废'
            end;
            set new.remark=newremark;
        end if ;
    end//
delimiter ;
#查询
#1.查询订单主表的所有信息
select * from order_master;
#2.查询订单状态为5（已作废）的订单
select * from order_master where status='5';
#3.查询用户 zhangsan 的 客户id 订单状态 订单创建时间 订单编号 购买的商品名称 购买数量 商品单价 以及总金额
select om.customer_id  as '客户id',
       om.status       as '订单状态',
       om.create_time  as '订单创建时间',
       om.order_number as '订单编号',
       oi.product_name as '商品名称',
       oi.num          as '购买数量',
       oi.price        as '单价',
       oi.money        as '总金额'
from order_master om
         inner join order_item oi on om.id = oi.order_id
where om.create_user = 'zhangsan' order by oi.money desc;
#4.视图 zhangsan 存储以上信息 方便随时查阅
    create or replace view zhangsanxinxi as
    select om.customer_id  as '客户id',
       om.status       as '订单状态',
       om.create_time  as '订单创建时间',
       om.order_number as '订单编号',
       oi.product_name as '商品名称',
       oi.num          as '购买数量',
       oi.price        as '单价',
       oi.money        as '总金额'
from order_master om
         inner join order_item oi on om.id = oi.order_id
where om.create_user = 'zhangsan' order by oi.money desc;

#5.查询用户 zhangsan 一共买了多少件商品
select sum(num) as '商品数量'
from order_item
where order_id in (select id from order_master where create_user = 'zhangsan');

#6.用 分组和聚合函数 查出购买商品最多的前两名用户用户
select om.create_user as '用户', sum(num) as '购买数量'
from order_item oi
         inner join order_master om on oi.order_id = om.id
group by om.create_user LIMIT 0,2;
#7.查询出购买数量最少的用户（可并列）
select om.create_user as '用户',
       sum(oi.num)    as '购买数量'
from order_item oi
         inner join order_master om on oi.order_id = om.id
group by om.create_user
having sum(oi.num) = (select min(num2) as '最小值'
                      from (select sum(num) as num2
                            from order_item oi2
                                     inner join order_master om2 on oi2.order_id = om2.id
                            group by om2.create_user) as tab);

#数据备份 & 清理备份数据 选择对应的数据库→ 导出 →Backup with mysqldump →run

# 把对订单主表/订单明细表 进行的具体操作 存储到创建的日志表中
#订单操作日志表 创建日志表
create table order_log (
    id int primary key  auto_increment comment'主键',
    order_log_time datetime default now() comment '操作时间',
    order_log_table varchar(20) not null comment '进行操作的表',
    order_log_type varchar(20) not null comment '进行的操作 新增/修改/删除',
    order_om_id int  comment '订单主表ID（关联主表，统一检索）',
    order_oi_id int comment '订单明细表ID（明细表操作时填充，主表填NULL）',
    order_log_old_data  text comment'操作之前的数据',
    order_log_new_data text comment '操作之后的数据',
    operatorid char(5) not null , constraint  idyueshu foreign key (operatorid) references user (userid)
) comment '日志表';

set @operatorid='Boss';
# 订单主表数据 新增/修改/删除 数据写入日志表的触发器
    DELIMITER //
# 主表新增触发器
create trigger om_log_insert
    after insert on order_master for each row
begin
      declare log_operatorid int;
    #在对主表进行操作时如未输入管理员id则报错

    if @operatorid is null then
        signal sqlstate '45000' set message_text = '未登录账号';
    end if ;
    #验证管理员id是否存在
     select count(*) into log_operatorid from user where userid=@operatorid;
     if log_operatorid=0 then
         signal sqlstate '45000'
         set message_text = '该用户id不存在';
     end if;

    insert into order_log(order_log_time, order_log_table, order_log_type, order_om_id, order_oi_id, order_log_old_data, order_log_new_data,operatorid)
    values (
        now(),
        'order_master',
        '新增',
        new.id,
        null,
        NULL,
        concat('订单编号：', new.order_number, ',客户ID：', new.customer_id, ',总金额：', new.total_money, ',状态：',
               new.status,'订单创建时间：',new.create_time, '创建人：', new.create_user, '注释：', new.remark),
        @operatorid
    );
end //
delimiter ;
#主表修改触发器
delimiter //
create trigger om_log_update
    after update on order_master for each row
begin
     declare log_operatorid int;
    #在对主表进行操作时如未输入管理员id则报错
    if @operatorid is null then
        signal sqlstate '45000' set message_text = '未登录账号';
    end if ;
    #验证管理员id是否存在
     select count(*) into log_operatorid from user where userid=@operatorid;
     if log_operatorid=0 then
         signal sqlstate '45000'
         set message_text = '该用户id不存在';
     end if;

    insert into order_log(order_log_time, order_log_table, order_log_type, order_om_id, order_oi_id, order_log_old_data, order_log_new_data,operatorid)
    values (
        now(),
        'order_master',
        '修改',
        old.id,
        null,
        concat('订单编号：', old.order_number, ',客户ID：', old.customer_id, ',总金额：', old.total_money, ',状态：',
               old.status,'订单创建时间：',old.create_time, '创建人：', old.create_user, '注释', old.remark),
        concat('订单编号：', new.order_number, ',客户ID：', new.customer_id, ',总金额：', new.total_money, ',状态：',
               new.status,'订单创建时间：',new.create_time, '创建人：', new.create_user, '注释：', new.remark),
            @operatorid

    );
end //
delimiter ;
# 主表删除触发器
delimiter //
create trigger om_log_delete
    after delete on order_master for each row
begin
      declare log_operatorid int;
    #在对主表进行操作时如未输入管理员id则报错
    if @operatorid is null then
        signal sqlstate '45000' set message_text = '未登录账号';
    end if ;
    #验证管理员id是否存在
     select count(*) into log_operatorid from user where userid=@operatorid;
     if log_operatorid=0 then
         signal sqlstate '45000'
         set message_text = '该用户id不存在';
     end if;

    insert into order_log(order_log_time, order_log_table, order_log_type, order_om_id, order_oi_id, order_log_old_data, order_log_new_data,operatorid)
    values (
        now(),
        'order_master',
        '删除',
        old.id,
        null,
        concat('订单编号：', old.order_number, ',客户ID：', old.customer_id, ',总金额：', old.total_money, ',状态：',
               old.status,'订单创建时间：',old.create_time, '创建人：', old.create_user, '注释：', old.remark),
        NULL,
            @operatorid
    );
end //
DELIMITER ;
# 订单明细表数据 新增/修改/删除 数据写入日志表的触发器
# 明细表插入触发器
DELIMITER //
create trigger oi_log_insert
    after insert on order_item for each row
begin
      declare log_operatorid int;
    #在对主表进行操作时如未输入管理员id则报错

    if @operatorid is null then
        signal sqlstate '45000' set message_text = '未登录账号';
    end if ;
    #验证管理员id是否存在
     select count(*) into log_operatorid from user where userid=@operatorid;
     if log_operatorid=0 then
         signal sqlstate '45000'
         set message_text = '该用户id不存在';
     end if;

    insert into order_log(order_log_time, order_log_table, order_log_type, order_om_id, order_oi_id, order_log_old_data, order_log_new_data, operatorid)
    values (
       now(),
       'order_item',
        '新增',
            null,
            new.id,
            null,
       concat('订单主表id：', new.order_id, '商品编码：', new.product_id, '商品名称：', new.product_name, '单价：',
              new.price, '数量：', new.num, '小计金额：', new.money),
        @operatorid
    );
end //
delimiter ;
#明细表修改触发器
delimiter //
    create trigger oi_log_update
    after update on order_item for each row
begin
      declare log_operatorid int;
    #在对主表进行操作时如未输入管理员id则报错

    if @operatorid is null then
        signal sqlstate '45000' set message_text = '未登录账号';
    end if ;
    #验证管理员id是否存在
     select count(*) into log_operatorid from user where userid=@operatorid;
     if log_operatorid=0 then
         signal sqlstate '45000'
         set message_text = '该用户id不存在';
     end if;

    insert into order_log(order_log_time, order_log_table, order_log_type, order_om_id, order_oi_id, order_log_old_data, order_log_new_data, operatorid)
    values (
       now(),
       'order_item',
        '修改',
            null,
            old.id,
            concat('订单主表id：', old.order_id, '商品编码：', old.product_id, '商品名称：', old.product_name, '单价：',
              old.price, '数量：', old.num, '小计金额：', old.money),
       concat('订单主表id：', new.order_id, '商品编码：', new.product_id, '商品名称：', new.product_name, '单价：',
              new.price, '数量：', new.num, '小计金额：', new.money),
        @operatorid
    );
end //
delimiter ;
#明细表删除触发器
delimiter //
       create trigger oi_log_delete
    after delete on order_item for each row
begin
      declare log_operatorid int;
    #在对主表进行操作时如未输入管理员id则报错

    if @operatorid is null then
        signal sqlstate '45000' set message_text = '未登录账号';
    end if ;
    #验证管理员id是否存在
     select count(*) into log_operatorid from user where userid=@operatorid;
     if log_operatorid=0 then
         signal sqlstate '45000'
         set message_text = '该用户id不存在';
     end if;

    insert into order_log(order_log_time, order_log_table, order_log_type, order_om_id, order_oi_id, order_log_old_data, order_log_new_data, operatorid)
    values (
       now(),
       'order_item',
        '删除',
            null,
            old.id,
            concat('订单主表id：', old.order_id, '商品编码：', old.product_id, '商品名称：', old.product_name, '单价：',
              old.price, '数量：', old.num, '小计金额：', old.money),
       null,
        @operatorid
    );
end //
delimiter ;
#权限管理模块 用户的创建 和 权限的分配
#创建管理员Boss 并授予该用户所有对所有数据库中所有表的全部权限
create user 'Boss'@'localhost' identified  by 'pwd001';
grant all privileges on *.* to 'boss'@'localhost';
#创建管理员DaNiu 并授予该用户对 指定数据库中所有表的全部权限
create user DaNiu'@'localhost' identified by 'pwd002';
grant all privileges on `牛逼哄哄的项目1`.* to '牛牛'@'localhost';
#创建管理员DaMa 并授予该用户 对指定数据库中指定表格 的增删改查权限
create user 'DaMa'@'localhost' identified  by  'pwd003';
grant select,insert,delete,update on `牛逼哄哄的项目1`.order_master to '马马'@'localhost';
grant select,insert,delete,update on `牛逼哄哄的项目1`.order_item to '马马'@'localhost';
FLUSH PRIVILEGES;
