


use master
if exists ( select * from sys.databases where Name='Session13')
drop database Session13

create database Session13

use Session13

--	PART 2
--create table

create table Book (
   book_code int identity(1,1) primary key,
   category nvarchar(50) not null,
   author nvarchar(50) not null,
   publisher nvarchar(50) not null,
   title nvarchar(100) not null,
   price int not null,
   inStrore int not null,
 )
 go

 alter table Book
  add constraint ValidPrice 
  check (price > 0 )

alter table Book
   add constraint ValidQuantityInStore
   check (inStore >= 0 )



create table Customer (
    customer_id int identity (1,1) primary key,
	customer_name nvarchar(50) not null,
	address nvarchar(100) not null,
	phone varchar(12) not null
)


create table BoohSold (
    bookSold_id int identity (1,1) primary key,
	customer_id int not null,
	book_code int not null,
	date datetime not null,
	price int not null,
	amount int not null,

	check (price > 0),
	check(amount > 0 ),
	foreign key (customer_id) references Customer(customer_id),
	foreign key (book_code) references Book(book_code)

)

--1: chèn it nhất 5 bản ghi cho bảng Book, Customer, 10 bản ghi vào bàng BookSold

insert into Book values 
(N'Văn học', N'Phan Văn Trường', N'NXB Văn Học',  N'Một đời quản trị', 79 , 10 )

insert into Book values 
(N'Truyện ngắn', N'Nguyễn  Nhật Ánh', N'NXB Trẻ', N'Quán gò bên đường', 119, 4 )

insert into Book values 
(N'Truyện ngắn', N'Nguyễn  Nhật Ánh', N'NXB Trẻ', N'Hai đứa trẻ', 89, 14 )


insert into Book values 
(N'Selfhelp', N'Lưu Việt Hoa', N'NXB Trẻ', N'Em phải đến Harvard học kinh tế', 229, 40 )

insert into Book values 
(N'Tâm lí', N'Đặng Hoàng Giang', N'NXB Văn Học', N'Đại dương đen', 229, 4 )

insert into Book values 
(N'Tâm lí', N'Đặng Hoàng Giang', N'NXB Văn Học', N'Điểm đển của cuộc đời', 119, 8)

select * from Book


insert into Customer values 
(N'Nguyễn Văn Hòa', N'Cầu Giấy - Hà Nội', '12345678' )

insert into Customer values 
(N'Nguyễn Văn An', N'Cầu Giấy - Hà Nội', '23456789' )

insert into Customer values 
(N'Nguyễn Thị Thu Thanh', N'Hoàng Mai - Hà Nội', '34567890')

insert into Customer values 
(N'Nguyễn Thu Thanh', N'Hà Đông - Hà Nội', '34367890')

insert into Customer values 
(N'Nguyễn Thu Yến', N'Hoàng Mai - Hà Nội', '33456790')


select * from Customer


insert into BoohSold values 
( 1, 1, '2023-09-19', 79, 3)

sp_rename 'BoohSold' , 'BookSold'

insert into BookSold values 
( 1, 4, '2023-09-19', 299, 1)

insert into BookSold values 
( 2, 4, '2023-09-20', 229, 1)

insert into BookSold values 
( 3, 3, '2023-09-29', 79, 4)


insert into BookSold values (4, 2, '2023-10-01', 80, 2), (4, 3, '2023-10-01', 229, 1)

insert into BookSold values (5, 5, '2023-10-01', 119, 1), (5, 1, '2023-10-01', 79, 1)

insert into BookSold values (1, 2, '2023-10-05', 119, 4) , (2, 2, '2023-10-05', 1199, 2)

insert into BookSold values (1, 2, '2023-02-15', 119, 4) , (2, 2, '2023-02-05', 1199, 2)
insert into BookSold values (1, 2, '2023-02-05', 119, 4) , (2, 2, '2023-02-05', 1199, 2)
insert into BookSold values (1, 2, '2023-02-25', 119, 4) , (2, 2, '2023-02-05', 1199, 2)


insert into BookSold values (1, 2, '2023-03-15', 119, 4) , (2, 2, '2023-03-05', 1199, 2)
insert into BookSold values (1, 2, '2023-03-05', 119, 4) , (2, 2, '2023-03-05', 1199, 2)
insert into BookSold values (1, 2, '2023-03-25', 119, 4) , (2, 2, '2023-03-05', 1199, 2)

select * from BookSold

--2: Tạo một khung nhìn chứa danh sách các cuốn sách (BookCode, Title, Price) kèm theo số lượng đã bán của mối cuốn
create view ListBook_View
as
select 
   b.book_code,
   b.title,
   b_s.price as price_sold,
   b_s.amount as amount_sold 
from 
   Book as b 
   inner join BookSold as b_s on b.book_code = b_s.book_code
 go  
 select * from ListBook_View
  

--3: Tạo một khung nhìn chứa danh sách các khách hàng (Customer_ID , CustomerName, Address) kèm theo số lượng cuốn sách mà 
--kh đó đã mua

select bs.customer_id , sum (bs.amount) as SumOfBookSold
from BookSold  as bs
group by bs.customer_id
go

create view CustomerAndBookSold_View 
as
select 
    bs.customer_id,
	c.customer_name,
	c.address,
	sum (bs.amount) as SumOfBookSold
from 
   BookSold as bs 
   inner join Customer as c on bs.customer_id = c.customer_id
   group by bs.customer_id, c.customer_name, c.address
go


select * from CustomerAndBookSold_View


--4: Tạo một khung nhìn chứa danh sách kh (CustomerId, CustoerName, Addess) đã mua sách vào tháng trước
-- kèm theo tên sách mà kh đã mua


select CURRENT_TIMESTAMP as my_current_timestamp
select Month(CURRENT_TIMESTAMP) as month_current , Year(CURRENT_TIMESTAMP) as year_current

-- tinh thang hien tai
declare @monthCurrent int;
set @monthCurrent = Month(CURRENT_TIMESTAMP);
select @monthCurrent as  monthRecent;

--ting nam hien tai
declare @yearCurrent int;
set @yearCurrent = Year(CURRENT_TIMESTAMP);
select @yearCurrent as yearRecent;


create view CustomerBoughtBookLastMonth_view
as
select
   c.customer_id,
   c.customer_name,
   c.address,
   b.title as BookBought,
   bs.date as DateBought
  
from Customer as c
inner join BookSold as bs on c.customer_id = bs.customer_id 
inner join Book as b on bs.book_code = b.book_code

where year(bs.date) = year(CURRENT_TIMESTAMP) and month(bs.date) = month(CURRENT_TIMESTAMP) - 1

group by c.customer_id, c.customer_name, c.address, b.title, bs.date

select * from CustomerBoughtBookLastMonth_view


--5: Tạo một khung nhìn chứa danh sách khách hàng kèm theo tổng tiền mà mỗi khách hàng đã chi cho việc mua sách


select bs.customer_id,
       sum (bs.amount * bs.price) as SumOfPice

from BookSold as bs
group by bs.customer_id
go


select * from BookSold

create view SumPriceCustomer_View
as 
select 
  bs.customer_id,
  c.customer_name,
  c.address,
  sum (bs.amount * bs.price) as SumOfPice
from 
   BookSold as bs
   inner join Customer as c on bs.customer_id = c.customer_id
   group by bs.customer_id, c.customer_name, c.address

select * from SumPriceCustomer_View


--tim ban ghi trung lap
select  
    customer_id, book_code, date, count(*) as Occurrences
from 
   BookSold
group by customer_id, book_code, date
having count(*) > 1


-- xoa ban ghi trung lap

delete from 
  BookSold
where
  bookSold_id not in (
      select min(bs.bookSold_id) MinId
	  from
	     BookSold as bs
       group by
	     bs.customer_id,
		 bs.book_code,
		 bs.date
  )

  select * from BookSold






-- PART 3
create table Class(
   class_code  varchar(10) primary key,
   head_teacher nvarchar(30) not null,
   room varchar(30) not null,
   time_slot char not null,
   close_date date not null
)


create table Student (
   roll_no varchar(10) primary key,
   class_code varchar(10) foreign key references Class(class_code),
   full_name nvarchar(30) not null,
   male bit not null,
   birth_date date not null,
   address varchar(30) ,
   provice char(2) not null,
   email varchar(30) not null unique
)

create table Subject (
   subject_code  varchar(10) primary key,
   subject_name varchar(40) not null,
   w_mark bit not null,
   p_mark bit not null,
   w_test_per int ,
   p_test_per int,
   check (w_test_per between 0.1 and 1.0),
   check (p_test_per between 0.1 and 1.0)
)

alter table Subject
 drop constraint [CK__Subject__p_test___4AB81AF0] 

alter table Subject 
 drop constraint [CK__Subject__w_test___49C3F6B7]
 
alter table Subject
  alter column w_test_per float not null

alter table Subject
  alter column p_test_per float not null

alter table Subject
  add constraint CheckWPerTest check (w_test_per between 0.1 and 1.0)

alter table Subject
  add constraint CheckPPerTest check (p_test_per between 0.1 and 1.0)

create table Mark (
  roll_no varchar(10) foreign key references Student(roll_no),
  subject_code varchar(10) foreign key references Subject(subject_code),
  w_mark float not null check (w_mark between 1 and 10),
  p_mark float not null check (p_mark between 1 and 10),
  mark float 

)



alter table Mark alter column roll_no varchar(10) not null
alter table Mark alter column subject_code varchar(10) not null

alter table Mark 
  add primary key (roll_no, subject_code)

select * from Mark

--1: chèn it nhất 5 bản ghi cho từng table
insert into Class values 
('C100', 'Teacher A', 'Class 1', 'G', '2023-12-01'),
('C101', 'Teacher B', 'Class 2', 'G', '2023-12-01'),
('C102', 'Teacher C', 'Class 3', 'M', '2023-12-01'),
('C103', 'Teacher D', 'Class 4', 'M', '2023-12-01'),
('C104', 'Teacher A', 'Class 5', 'I', '2023-12-01')

select * from Class

insert into Student values 
('ST100', 'C100' ,'Nguyen Van A', 1 , '2000-05-04', '334 Pham Van Dong', 'HN' , 'nguyenvana@gmail.com')

select * from Student

insert into Student values 
('ST101', 'C100', 'Nguyen Thi B', 0, '2004-12-01', '23 Xuan Dieu', 'HN', 'nguyenthib@gmail.com')


insert into Student values 
('ST102', 'C101', 'Hoang Quoc Viet', 1, '2003-10-20', '23 Xuan dieu', 'HN', 'hoang quocviet@gmail.com')

insert into Student values
('ST103', 'C101', 'Nguyen Quoc Viet', 1, '2003-09-20', '23 Xuan dieu', 'HN', 'nguyen quocviet@gmail.com')

insert into Student values
('ST104', 'C102', 'Nguyen Van Hoa', 1, '2002-10-20', '23 Xuan dieu', 'HN', 'nguyenvanhoa@gmail.com')

insert into Subject values 
('EPC' , 'Element Programming C', 1, 1, 0.4 , 0.6),
('Java1' , 'Java part 1', 1, 1, 0.4 , 0.6),
('Java2' , 'Java part 2', 1, 1, 0.4 , 0.6)


insert into Mark(roll_no, subject_code, w_mark, p_mark ) values 
('ST101', 'EPC', 8, 10)


insert into Mark(roll_no, subject_code, w_mark, p_mark ) values 
('ST102', 'EPC', 8, 8), ('ST100', 'EPC', 3, 5), ( 'ST103', 'EPC', 5, 10)

insert into Mark(roll_no, subject_code, w_mark, p_mark ) values 
('ST102', 'Java1', 8, 8), ('ST100', 'Java1', 10, 5), ( 'ST103', 'Java1', 5, 10)


insert into Mark(roll_no, subject_code, w_mark, p_mark ) values 
('ST102', 'Java2', 8, 2), ('ST100', 'Java2', 3, 5), ( 'ST103', 'Java2', 5, 5)

insert into Mark (roll_no, subject_code, w_mark, p_mark ) values 
('ST104', 'EPC', 8 ,8)

--khong insert dc
insert into Mark (roll_no, subject_code, w_mark, p_mark ) values ('ST100', 'EPC', 5, 8)

update
   Mark
set 
   Mark.mark = m.w_mark * s.w_test_per + m.p_mark * s.p_test_per
from
   Mark as m 
   inner join Subject as s on m.subject_code = s.subject_code
   

select * from Mark

--2: tạo một khung nhìn chứa danh sách các sinh viên đã có ít nhất 2 bài thi (2 môn học khác nhau)


--dem sinh vien thi mon hoc giong nhau

select roll_no, subject_code, count (*) as Occurrences
from Mark
group by roll_no, subject_code
having count(*) > 1

-- sinh vien cos it nhat 2 bai thi
select s.roll_no , count (*) as CountExam from Student as s
inner join Mark as m on s.roll_no = m.roll_no
group by s.roll_no
having count(*) > 1

-- thong tin sinh vien co it nhat 2 bai thi
select * from Student 

where Student.roll_no  in (
   select s.roll_no from Student as s
  inner join Mark as m on s.roll_no = m.roll_no
  group by s.roll_no
  having count(*) > 1

)

create view StudentHaveLeast2Exam_VIEW
as 

select *  from Student 

where Student.roll_no  in (
   select s.roll_no from Student as s
  inner join Mark as m on s.roll_no = m.roll_no
  group by s.roll_no
  having count(*) > 1

)

select * from StudentHaveLeast2Exam_VIEW



--3: tạo một khung nhìn chúa danh sách tất cả các sinh viên đã bị trượt it nhất 1 lần

alter table Mark 
  add  status bit null 
--if mark = 5.0 -> passed
begin
   declare @a float
   set @a = 5.0

   update 
     Mark
   set 
     Mark.status = 1
   from Mark
   where Mark.mark >= @a
end

--else -> not passed
begin 
   declare @a float
   set @a = 5.0
   update 
     Mark
   set 
     Mark.status = 0
   from Mark
   where Mark.mark < @a
end

create view ListStudentNotPassed_View
as 
select  s.roll_no, s.full_name , sb.subject_name as SubjectFaild
  from Student as s
  inner join Mark as m on s.roll_no = m.roll_no 
  inner join Subject as sb on m.subject_code = sb.subject_code
  where m.status = 0

select * from ListStudentNotPassed_View

	    


--4: tạo một khung nhìn chứa danh sách các sinh viên  đang học ở TimeSlot G
create view StudentLearnInSlotG_View
as
  select Student.* from Student 
  inner join Class on Student.class_code = Class.class_code
  where Class.time_slot like 'G'

select * from StudentLearnInSlotG_View



--5: tạo một khung nhìn chứa danh sách GV có it nhất 2 học sinh thi trượt ở bất kì môn nao

select Class.head_teacher as Teacher 
from
   Class 
   inner join Student as st on Class.class_code = st.class_code
   inner join Mark as m on m.roll_no = st.roll_no
   where m.status = 0


--sinh vien thi truot it nhat 2 lan

select Student.roll_no
from Student 
where Student.roll_no in (
    select Mark.roll_no 
	from Mark
	where Mark.status = 0
	group by Mark.roll_no
	having count (*) > 1
)

--gv cos sinh vien thi truot it nhat 2 lan

create view TeacherHasStudentFalaild_View
as

select Class.head_teacher as Teacher
   from  Class 
   inner join Student on Class.class_code = Student.class_code
   inner join Mark on Student.roll_no = Mark.roll_no
   where Mark.status = 0
   group by Mark.roll_no, Class.head_teacher
   having count (*) > 1

select * from TeacherHasStudentFalaild_View          

select * from Mark
--6: tạo một khung nhìn chứa  các sinh viên thi trượt môn EPC của từng lớp: có các cột: 
--tên sv, tên lớp, tên GV, điểm thi môn EPC

create view StudentFaildEPC_view
as
select Student.full_name ,
       Class.room,
	   Class.head_teacher,
	   Mark.mark 
from Class 
     inner join Student on Class.class_code = Student.class_code 
	 inner join Mark on Mark.roll_no = Student.roll_no
	 inner join Subject on Subject.subject_code = Mark.subject_code

	 where Subject.subject_code like 'EPC' and Mark.status = 0

select * from StudentFaildEPC_view
