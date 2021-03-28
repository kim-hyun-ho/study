--sql 복습하기 (20210311-0324)


--DCL : Data Control Language : 권한 관리
--	Grant, Revoke
--DDL : Data Definition Language : 디비(테이블)관리 
--	Create, Alter, Drop, Rename, Truncate
--DML : Data Manipulation Language : 테이블 안에 튜플 조작
--	Select, Insert, Update, Delete


--<기본문법>
--주석은 --
--맨뒤에 ; 로 끝남
--sql문법 순서는
select * from [테이블명] where [조건] group by having order by [조건]
--sql내부 실행 순서는
from, where, group by ,having , select, order by 의 순서이다.


--유저 관리.
--system으로 접속해서
create user [user_name] identified by [password];
--비번 변경
alter user [user_name] identified by [new password];
--유저 삭제
drop user [user_name];
--권한부여
grant [conn,resource, ...] to [user_name];
--권한 회수
revoke [conn,resource,....] from [user_name];


--테이블 관리
create table table_1(
no number primary key,
title varchar2(80) not null
);
select * from table_1;

--구조보기
desc table_1;

create table table_2(
no number primary key,
no2 number,
constraint FK_t1_t2 foreign key(no2) references table_1(no)
);
desc table_2;

drop table table_2;

--관계 포린키 나중에 추가하기
alter table table_2
add constraint FK_t1_t2
foreign key(no2)
references table_1(no);

--제약 사항 보기
select * from all_constraints where table_name='TABLE_2';

--관계 혹은 제약사항 삭제
alter table table_2
drop constraint FK_t1_t2;

--값 넣기
insert into table_1(no,title) values(1,'title1');
insert into table_1(no,title) values(2,'title2');

--commit
commit;
--commit 전에는 rollback 가능

--select하기
select * from table_1;

--고치기
update table_1 set title='newTitle1' where no=1;

--테이블 고치기
alter table table_2 add memo varchar2(40);
desc table_2;
--alter table table_2 add constraint memo not null(memo);
--위는 틀림
alter table table_2 modify memo not null;
desc table_2;

--제약조건 확인
select * from user_constraints where table_name='TABLE_2';

--제약조건 삭제
alter table table_2 drop constraint SYS_C007046;
desc table_2;

--데이터 지우기
delete from table_1;
rollback;
select * from table_1;

truncate table table_1;

drop table table_1 cascade constraint;

-- 테이블 드롭은 롤백 안됨.
rollback;

--테이블 이름 변경
alter table table_1 rename to table_new1;
alter table table_new1 rename to table_1;

--테이블에 컬럼 추가
alter table table_1 add (etc varchar2(10));
desc table_1;
--컬럼 이름
alter table table_1 rename column etc to etc2;
desc table_1;
alter table table_1 rename column etc2 to etc;
desc table_1;
--제약조건 추가
select * from table_1;
delete from table_1;
alter table table_1 modify etc not null;
alter table table_1 modify etc null;
--제약조건 삭제
--테이블의 특정 컬럼 삭제
alter table table_1 drop column etc;
desc table_1;

--테이블 내용까지 복사해서 만들기
create table table_3
as
select * from table_1;

--테이블 내용은 없이 형식만 복사해서 만들기.
create table table_4
as
select * from table_1
where 1=2;
select * from table_4;
drop table table_4;

--테이블은 이미 있고 내용만 복사하기.*********
select * from table_1;
select * from table_3;
insert into table_3
select * from table_1;
select * from table_3;
drop table table_3;


--sql 파일 불러와서 실행하기
--@c:\filename.sql

--입력받기는 & => sql 문장의 해당 위체에 삽입됨
--dual은 연습용 더미테이블
select &aaa from dual;
select * from dual;

--컬럼이름 알리아싱
select * from table_1;
select no as "번호", title, etc from table_1;
select no  "번호", title, etc from table_1;
--as 생략가능
select no  번호, title, etc from table_1;
--as 공백이 없으면 따옴표도 생략가능

--문자열 연산 포메팅
-- || 연결 연산자.
select no || '번의 제목은 '|| title from table_1;

--where 절 조건
-- like % 여러글자, _은 한글자
select * from table_1 where title like 't%';
select * from table_1 where title like 't_';
select * from table_1 where title like '%1';
select * from table_1 where title like '%2';
-- in 연산
select * from table_1 where title in ('title1','title2');

--order by
select * from table_1;
--no의 역순 정렬
select * from table_1 order by no desc;


--view 뷰는 가상테이블
create or replace view v_table_1
as
select no, etc, title from table_1;

desc v_table_1;

select * from v_table_1;
select * from table_1;

--union 합집합
select * from v_table_1
union --중복제거 , 타입과 컬럼수 일치
select no,etc,title from table_1;

--union all :중복도 모두 출력
select * from v_table_1
union all
select no,etc,title from table_1;

--교집합
select * from v_table_1
intersect
select no,etc,title from table_1;

--차집합
select * from v_table_1
minus
select no,etc,title from table_1;

--각종함수
--to_char() --문자로 형변화
--initcap() --첫글자 대문자
--lower() --소문자화
--upper() --대문자화
--length() --문자열 길이
--lengthb() --문자열 바이트 길이 한글은 3바이트
--concat() -- 이어붙이기
--잘라내기
select 'asdf', substr('asdf',3,2) from dual;
--substr('asdf',-3,2) -- 뒤에서부터 3번째 글자부터
--instr('asdf',')' --문자열에서 특정 글자 위치
--lpad(,,) 전체 자리수 중 왼쪽 빈칸을 특정 문자로 채움.
select lpad('asdf',10,'*') from dual;
--lpad(,,) 전체 자리수 중 오른쪽 빈칸을 특정 문자로 채움.
select rpad('asdf',10,'*') from dual;
--공백제거
select ltrim('       aass__ddff         ')  from dual;
select rtrim('       aass__ddff         ')  from dual;
--옵션 문자열로 시작되는 왼쪽 오른쪽 제거
select ltrim('aaa       aa          ss__ddff         ','a')  from dual;
select rtrim('aaa       aa          ss__ddffffff','f')  from dual;
select * from table_1;
select ltrim(title,'tit') from table_1;
--변경
select 'asdf', replace('asdf','a','S') from dual;
--반올림
select round(987.12345,2) from dual;
select round(987.12345,-1) from dual; --음수는 소수점 왼쪽 자리숫


--==========
--TRUNC 절삭 버림
SELECT TRUNC(987.456,2),
TRUNC(987.456,0),
TRUNC(987.456,-1)
FROM DUAL;

--MOD *** 나머지
--CEIL 정수로 올림
--FLOOR 정수로 내림
SELECT MOD(121,10) "MOD",
CEIL(123.45) "CEIL",
FLOOR(123.45) "FLOOR",
CEIL(-123.45) "CEIL2",
FLOOR(-123.45) "FLOOR2"
FROM DUAL;

SELECT ROWNUM "ROWNUM", 
CEIL(ROWNUM/3) "TEAM",
ENAME
FROM EMP;

--POWER(숫자1,숫자2) 숫자1의 승수
SELECT POWER(2,3) FROM DUAL;

--날자함수
--SYSDATE
SELECT SYSDATE FROM DUAL;
SELECT TO_CHAR(SYSDATE,'YYYY-MM--DD') "오늘의날자"
FROM DUAL;

--MONTHS_BETWEEN 두날자 사이의 개월수 계산 앞쪽이 종료 날짜.
--윤년계산 약점.
SELECT MONTHS_BETWEEN('14/09/30','14/08/30')
FROM DUAL;

SELECT MONTHS_BETWEEN(SYSDATE,HIREDATE) "MONTHS"
, ROUND(MONTHS_BETWEEN(SYSDATE,HIREDATE),2) FROM EMP;

SELECT MONTHS_BETWEEN(SYSDATE,HIREDATE) "MONTHS"
,TO_CHAR(
ROUND(MONTHS_BETWEEN(SYSDATE,HIREDATE),2),
'9999.99') "MONTHS_ROUND" FROM EMP;

--ADD_MONTHS
SELECT SYSDATE, ADD_MONTHS(SYSDATE,1) FROM DUAL;

--NEXT_DAY
SELECT NEXT_DAY(SYSDATE,'월') FROM DUAL;

--LAST_DAY 해당월의 마지막 날자
SELECT SYSDATE, LAST_DAY(SYSDATE) FROM DUAL;

--형변환
--TO_CHAR() 날자 형변환 YYYY, RRRR, YEAR
SELECT SYSDATE
, TO_CHAR(SYSDATE,'YYYY') 
, TO_CHAR(SYSDATE,'RRRR') 
, TO_CHAR(SYSDATE,'YEAR') 
FROM DUAL;

--시간
--HH24 24시간제
--HH 12시간제
--MI 분
--SS 분
SELECT SYSDATE, TO_CHAR(SYSDATE,'RRRR-MM-DD:HH24:MI:SS')
FROM DUAL;

SELECT * FROM EMP;
--TO_CHAR()
--9 9의 갯수만큼 자릿수 표시
--0 빈자리를 0으로 채움
--$ $표시를 붙임
-- . 소수점이하표시
-- , 천단위표시
SELECT TO_CHAR(1234,'999999') FROM DUAL;
SELECT TO_CHAR(1234,'099999') FROM DUAL;
SELECT TO_CHAR(1234,'$99999') FROM DUAL;
SELECT TO_CHAR(1234,'9999.99') FROM DUAL;
SELECT TO_CHAR(12341234,'999,999,999') FROM DUAL;
--========================





--========================
--decode 마치 if문 같이 작동.
select decode('a','a','A','B') from dual;
select decode('a','','A','B') from dual;
select decode('a','','A','b','B') from dual;
select decode('a','b','A','b','B','C') from dual;
select decode('a','','A','b','B','C') from dual;
--count()
select * from table_1;
select no,title,count(*) from table_1
group by no,title;
--그룹함수들을 쓸때는 select 되는 컬럼도 그룹 조건에 넣어야 한다.
--sum() 합
--min() 최소값
--max() 최대값
--avg() 평균

--stddev() 표준편자
--variance() 분산

--nvl() 널값대신 반환할 기본값 지정.
select nvl(null,0) from dual;
--nvl2(col1,col2,col3) col1이 null이 아니면 col2, col1이 null이면 col3
select empno,ename,sal,comm,
nvl2(comm,sal+comm,sal+0)
from emp;

--======
--case에 적용 case when then else end;
select name,tel,
    case(substr(tel,1,instr(tel,')')-1)) 
        when '02' then 'seoul'
        when '031' then 'gyeonggi'        
        when '051' then 'pusan'        
        when '052' then 'ulsan'        
        when '055' then 'gyeongnam'        
        else 'etc'
    end "tel2"
from student;
--=========

--row넘버 활용
update dept set loc='ccc' where rownum=3; --이거 잘안됨.
--방법은 rownum으로 rowid를 알아내서 rowid로 찾아서 수정해야함.
--=========

--HAVING : 그룹함수 사용할 때 where아닌 having에 조건 넣어야 함.
--특정 컬럼 조건으로 그룹화된 그룹함수의 조건.
select deptno, avg(nvl(sal,0))
from emp
group by deptno
having avg(nvl(sal,0))>=2000; --여기 해빙 조건


--join은 테이블 집합 연산
--inner join , outer join
--안시 스타일, 오라클 스타일.
insert into table_2 values(3,1);
insert into table_2 values(4,2);

select * from table_1;
select * from table_2;
--안시 스타일
select *
from table_1 a inner join table_2 b
on a.no = b.no2;
--오라클 스타일
select *
from table_1 a , table_2 b
where a.no = b.no2;

--left outer join
select *
from table_1 a left outer join table_2 b
on  a.no=b.no2;
--오라클 스타일
select *
from table_1 a, table_2 b
where a.no=b.no2(+);
--left outer 이므로 오른쪽 b.no2(+)

--카티션곱 : 경의 수 모두 출력
select *
from table_1, table_2;

--서브쿼리 : 쿼리 속의 쿼리
--서브쿼리의 주의점
-- 1. SUBQUERY 부분은 WHERE 절에 연산자 오른쪽에 위치하면 반드시 ()로 묶어야 한다.
-- 2. 특별한 경우를 제외하고 SUBQUERY 절에는 ORDER BY 를 사용할 수 없다.
-- 3. 단일행 SUBQUERY, 다중행 SUBQUERY의 연산자를 잘 구분하여야 한다.

--단일행 SUBQUERY
-- 단일행 연산자 : =,!=,<>,>,>=,<,<=

--다중행 쿼리 연산자
/*
IN 결과를 메인에서 모두 검색
EXISTS 값이 있으면 메인 수행
>ANY 최소
<ANY 최대
<ALL 최소
>ALL 최대
*/

--in
-- 컬럼 in (서브쿼리)
--(컬럼1,컬럼2) in (서브쿼리)

--exists (서브쿼리)


--==================================
--정규화가 필요한 이유***********************
--==================================
--잘못된 테이블은 설계는
-- 공간낭비, 데이터 불일치 등이 발생
-- 삽입, 삭제, 갱신 이상.
-- 이러한 이유로 정규화를 하면
-- 쿼리문이 복잡해지고 여러테이블을 참조하면 속도 저하
-- 좋은 DBMS와 컴퓨터 성능으로 극복한다.
--==================================

-- 1,2,3,B-C, ...


---------------
--VIEW
--데이터 관리용으로 VIEW 기능이 있다.
--주로 데이터를 조회하는 목적으로 사용된다.

--버전에 따라 시스템에서 권한 주기 필요할 수도 있다.
/*
SYSTEM>GRANT CREATE VIEW TO [USERNAME];
*/

--인라인 뷰(inline view)
--뷰의 의미는 여러번 반복해서 사용인데, 인라인뷰는 일회성입니다.
-- from (테이블 혹은 view 자리에 서브쿼리처럼 사용)


--lag와 inline을 결합.
--lag(출력할 칼럼, offset, 기본출력) == nvl과 비슷 첫행 이전행은 없으니까 컬럼이 null 이것을 기본출력으로 설정
select * from professor;
select name, deptno,lag(deptno) over (order by deptno ) from professor;
select name, deptno,lag(deptno,1,0) over (order by deptno ) from professor;

--앞 튜플과의 차를 구할때 사용할 수 있음
select name, deptno,lag(deptno,1,0) over (order by deptno ),
        deptno - (lag(deptno,1,0) over (order by deptno)) diff 
from professor;

--1. inlinew view로 사용되는 내용 출력
select * from professor;
select lag(deptno) over (order by deptno) ndeptno, deptno, profno,name
from professor;

-- 2. deptno가 같으면 출력되지 않도록, 다르면 출력 되도록
select * from professor;
select lag(deptno) over (order by deptno) ndeptno, deptno, profno,name
from professor;

select decode(deptno, ndeptno, null, deptno) deptno, profno,name
from (select lag(deptno) over (order by deptno) ndeptno, deptno, profno,name
from professor);


--sequence
--연속적인 일련번호를 자동으로 부여하는 기능
create sequence jno_seq
increment by 1
start with 100
maxvalue 110
minvalue 90
cycle
cache 2;

--시퀀스 
--currval
--nextval


--반복문
--begin for loop
--begin
--for i in 1..20 loop
--    insert into s_order values(jno_seq.nextval, 'james', 'apple', 5);
--end loop;
--commit;
--end;


--==========================
-- 프로시저
--==========================
----------
--시퀀스 초기화 프로시저 선언
CREATE OR REPLACE PROCEDURE re_seq
(
	SNAME IN VARCHAR2
)
IS
	VAL NUMBER;
BEGIN
	EXECUTE IMMEDIATE 'SELECT ' || SNAME || '.NEXTVAL FROM DUAL ' INTO  VAL;
	EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || SNAME || ' INCREMENT BY -' || VAL || ' MINVALUE 0';
	EXECUTE IMMEDIATE 'SELECT ' || SNAME || '.NEXTVAL FROM DUAL ' INTO VAL;
	EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || SNAME || ' INCREMENT BY 1 MINVALUE 0';
END;
/
--프로시저 실행
exec re_seq('BOARD_SEQ');

--시퀀스 조회
select * from user_sequences
whEre sequence_name='BOARD_SEQ';

--시퀀스 삭제
DROP SEQUENCE BOARD_SEQ;


---PROCEDURE PL/SQL
/*
PL/SQL을 이용해서 데이터베이스에 실행절차를 저장해서 반복사용

DECLARE
BEGIN
ECEPTION
END;
/

*/

SET SERVEROUTPU ON;
-- dbms_output.put_line() 메소드 출력 하려면 환경변수 on으로 설정해야 한다.
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('HELLO BIG DATA');
END;
/

--변수에 할당
CREATE OR REPLACE PROCEDURE HELLO_BIG
IS
    I_MESSAGE VARCHAR2(100):='HELLO_BIG'; --대입연산자 
BEGIN
    DBMS_OUTPUT.PUT_LINE(I_MESSAGE);
END;
/
EXEC HELLO_BIG;

--HELLO_SOLDESK PROCEDURE
--VAR_HELLO 에 여러분 과정명을 저장해서 출력
/
CREATE OR REPLACE PROCEDURE HELLO_SOLDESK
IS
    VAR_HELLO VARCHAR2(100):='최적화된 도구(R/PYTHON)를 활용한 데이터 애널리스트 양성과정';
BEGIN
    DBMS_OUTPUT.PUT_LINE(VAR_HELLO);
    --오라클 pl/sql 의 print문
END;
/

EXEC HELLO_SOLDESK;

--데이터를 입력 받아서 처리
/
CREATE OR REPLACE PROCEDURE HELLO_BIG
--    (P_MESSAGE IN VARCHAR2)
    (P_MESSAGE IN VARCHAR2:='NO MESSAGE') --기본값 할당
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(P_MESSAGE);
END;
/

--EXEC HELLO_BIG('HI CHULSU');
EXEC HELLO_BIG;
EXEC HELLO_BIG();
/

--프로시저 정보확인
SELECT * FROM USER_OBJECTS;
SELECT * FROM USER_OBJECTS
    WHERE OBJECT_NAME='HELLO_BIG';
SELECT * FROM USER_SOURCE;
SELECT NAME, TEXT
    FROM USER_SOURCE
    WHERE NAME='HELLO_BIG';
    
-----------------
-- INSERT 문을 프로시저로 작성
--DEPARTMENTS
DESC DEPARTMENTS;
SELECT * FROM DEPARTMENTS;

--INSERT문 작성
INSERT INTO DEPARTMENTS VALUES(280, 'HONG',NULL,1700);
--INSERT INTO DEPARTMENTS VALUES(310, 'HONG',NULL,1700);

--프로시저 작성
CREATE OR REPLACE PROCEDURE ADD_DEPART
    (
        P_DEPARTMENT VARCHAR2, MGR_ID NUMBER, LOC_ID NUMBER
    )
IS
BEGIN
    INSERT INTO DEPARTMENTS VALUES(DEPARTMENTS_SEQ.NEXTVAL, P_DEPARTMENT, MGR_ID, LOC_ID);
END;
/

SELECT DEPARTMENTS_SEQ.NEXTVAL FROM DUAL;
SELECT DEPARTMENTS_SEQ.CURRVAL FROM DUAL;

--시퀀스 확인
DESC USER_OBJECTS;
SELECT OBJECT_NAME, OBJECT_TYPE,CREATED FROM USER_OBJECTS
WHERE OBJECT_TYPE='SEQUENCE'; --OBJCET_TYPE 

--실행
EXEC ADD_DEPART('SEOUL',200,1700);
SELECT * FROM DEPARTMENTS;


--====================
--반복문, 커서,트리거
--====================
--반복문
create or replace procedure sumprint
is
    num1 number:=0;
    sum1 number:=0;
begin
    num1:=num1+1;
    sum1:=sum1+num1;
    dbms_output.put_line(num1 || ',' || sum1);
end;
/
exec sumprint;


create or replace procedure sumprint10
is
    num1 number:=0;
    sum1 number:=0;
begin
    for i in 1..10
--    while( num1<10) --화일문
    loop
        num1:=num1+1;
        sum1:=sum1+num1;
        dbms_output.put_line('num1 : ' || num1 || ', sum1 :' || sum1);
--    exit when num1=10; --그냥 루프 탈출조건
    end loop;    
end;
/

exec sumprint10;

--loop로 입력하기
create or replace procedure loopinput5
is
begin
    --for i in 1..5 : 포루프는 기본 루프 바로위에 탈출조건 == 반복 회수 명시.
    for i in 1..5
    loop
        insert into board2 values(board2_seq.nextval,'big data'||i,'빅데이터의 전망'||i, 'hong'||i, 2);    
    end loop;
end;
/

select * from board2;
select board2_seq.currval from dual;

exec loopinput5;

--문제2
--업데이트 하기
/
create or replace procedure board2_update
(
    iid number,
    ititle varchar2,
    icontent varchar2
)
is
begin
    update board2 set btitle=ititle, bcontent=icontent where bid=iid;
end;
/

exec board2_update(3,'python3','sd python');

--procedure 연습3
select * from employees;
select * from employees;

select extract(year from hire_date) from employees;

select employee_id, last_name,hire_date
from employees
where extract(year from hire_date)=2003;

select * from employees where extract(year from hire_date) = &iiii;

-- 프로시저에 셀렉트 사용 요령
--cursor활용 여러행일때
--datatype 다른형태
create or replace procedure yearselect
(p_year number)
is
    -- is와 begin 사이에 로컬변수들 선언한다.
    emp employees%ROWTYPE;
    cursor emp_cur is select employee_id, last_name, hire_date
        from employees
        where extract(year from hire_date)=p_year;
begin
    open emp_cur;
    --커서에서 데이터 읽기
    fetch emp_cur into emp.employee_id, emp.last_name, emp.hire_date;
    dbms_output.put_line(emp.employee_id||':'||emp.last_name||':'||emp.hire_date);    
    close emp_cur;
end;
/

--step5 반복
create or replace procedure yearselect
(p_year number)
is
    emp employees%ROWTYPE;
    cursor emp_cur is select employee_id, last_name, hire_date
        from employees
        where extract(year from hire_date)=p_year;
begin
    open emp_cur;
--    dbms_output.put_line( 'aaa'||to_char(emp_cur%NOTFOUND));
--    while(emp_cur%FOUND)
    loop
        --커서에서 데이터 읽기
        fetch emp_cur into emp.employee_id, emp.last_name, emp.hire_date;
        exit when emp_cur%notfound;
        dbms_output.put_line(emp.employee_id||':'||emp.last_name||':'||emp.hire_date);    
--        exit when emp_cur%notfound;
    end loop;
    close emp_cur;
end;
/
--한 행
exec yearselect(2001);

--여러 행 : 여러행 처리하려면 cursor 사용해서 fetch해야.
exec yearselect(2003);

--한 행일 때
--select employee_id, last_name, hire_date
--        from employees
--        where extract(year from hire_date)=2003;

SELECT * FROM STUDENT;

---연습
--DEPTNO1 입력하면
--STUDNO, NAME, DEPTNO1 출력하는 STU_SELECT 프로시저 작성
/
CREATE OR REPLACE PROCEDURE STU_SELECT
( I_DEPTNO NUMBER )
IS
    TSTU STUDENT%ROWTYPE;
    --%rowtype : student테이블 컬럼을 참조해서 변수 만듬
    CURSOR S_CUR IS SELECT STUDNO,NAME, DEPTNO1
        FROM STUDENT
        WHERE DEPTNO1=I_DEPTNO;
    --커서 만들기
BEGIN
    OPEN S_CUR;
    --커서는 사용전 open 해야 함.
    --loop문 : 파이썬의 while Ture : 루푸와 비슷. 탈출은 break 대신 exit when 조건
    LOOP
        FETCH S_CUR INTO TSTU.STUDNO, TSTU.NAME, TSTU.DEPTNO1;
        EXIT WHEN S_CUR%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('STDUNO:'||TSTU.STUDNO||', NAME:'||TSTU.NAME||', DEPTNO1:'||TSTU.DEPTNO1);
    END LOOP;
END;
/
-- / 프로시저 마칠때 해줘야 함.

EXEC STU_SELECT(101);
EXEC STU_SELECT(102);

--================
--TRIGGER
--테이블에 특정 이벤트 발생하면 실행하는 특별한 프로시저.
--================
CREATE TABLE TEST01(
NO NUMBER NOT NULL,
NAME VARCHAR2(10),
A NUMBER,
B NUMBER);

INSERT INTO TEST01 VALUES (1,'a', 10,20);

SELECT COUNT(*) FROM TEST01;

----========================
--트리거 만들기
--=========================
create or replace trigger in_test02
    after insert on test01
    --test01에 인서트 이벤트가 생기면 트리거가 작동.
    for each row
    --매 행마다 작동하라는 옵션.
declare
begin
    insert into test02
    values(:new.no, :new.name, :new.a, :new.b);
end;
/
INSERT INTO TEST01 VALUES (3,'k', 10,20);
INSERT INTO TEST01 VALUES (5,'j', 10,20);

--트리거 삭제
drop trigger in_test02;

---=============


--index
--인덱스 주는 칼럼은 where절 칼럼을 주로 쓴다.
-- index split현상 : 삽입,삭제,수정이 빈번한 곳
-- 데이터가 테이블에서 삭제되도 인덱스에서 남아있음
-- dml작업이 빈번한 곳에 취약하다.

select rowid,empno,ename
from emp
where empno=7902;

--인덱스 생성
--create index 인덱스 이름 on 테이블이름(칼럼이름);
create index emp_idx on emp(empno);

--인덱스 조회
select * 
from user_indexes
where table_name='EMP';

--인덱스 성능 테스트
 create table emp10
 as
 select * from bigemployees
 order by dbms_random.value;
 
 create table emp_idx
 as
 select * from bigemployees
 order by dbms_random.value;
 
 select * from emp10 where rownum<=5;
 select * from emp_idx where rownum<=5;
 
 --인덱스 조회
select * 
from user_indexes
where table_name='EMP10';

select * 
from user_indexes
where table_name='EMP_IDX';

--index 를 emp_idx에 만들기
create index idx_empidx_empno
on emp_idx(emp_no);

select * from emp_idx;

select INDEX_NAME,INDEX_TYPE,BLEVEL,
LEAF_BLOCKS,DISTINCT_KEYS,NUM_ROWS
from user_indexes
where table_name='EMP_IDX';

--성능 비교
SELECT * FROM EMP10 WHERE EMP_NO <10100;
SELECT * FROM EMP10 WHERE EMP_NO =30100;
--"SELECT * FROM EMP10 WHERE EMP_NO =20100"
--[Results 1 / SQL execution time: 00:00:00.020 / Total time: 00:00:01.586]
--(1 row affected)


SELECT * FROM EMP_IDX WHERE EMP_NO <10100;
SELECT * FROM EMP_IDX WHERE EMP_NO =30100;
--"SELECT * FROM EMP_IDX WHERE EMP_NO =20100"
--[Results 1 / SQL execution time: 00:00:00.051 / Total time: 00:00:00.091]
--(1 row affected)


--인덱스 리빌딩
-- INDEX REBUILD (BALANCING 확인) 
CREATE TABLE INX_TEST
(NO NUMBER);

/
BEGIN
	FOR I IN 1..10000 LOOP
		INSERT INTO INX_TEST VALUES(I);
	END LOOP;
	COMMIT;
END;
/
SELECT COUNT(*) FROM INX_TEST;

--INDEX 생성
CREATE INDEX IDX_INXTEST_NO ON INX_TEST(NO);

--밸런스 조회
--분석
ANALYZE INDEX IDX_INXTEST_NO VALIDATE STRUCTURE;
--밸런스 조회 :0에 가까우면 좋은거
SELECT(DEL_LF_ROWS_LEN/LF_ROWS_LEN)*100 BALANCE
FROM INDEX_STATS
WHERE NAME='IDX_INXTEST_NO';

--부분삭제
DELETE FROM INX_TEST
WHERE NO BETWEEN 1 AND 4000;

--다시 분석후 밸런스 조회.

--깨진 밸런스 리빌드
ALTER INDEX IDX_INXTEST_NO REBUILD;
--다시 분석 조회 하면 0으로 복귀


-------------
/*
디비 백업
system에서 디렉터토리 권한주고
create or replace directory mdBackup as 'd:\db_backup';
grant read,write on directory mdbackup to hr;

cmd에서
expdp로 백업
예 : expdp hr/123456 directory=mdBackup dumpfile=hr.dump

*/

/*
디비 복원
impdp hr/123456 directory=mdBackup dumpfile=hr.dump
*/