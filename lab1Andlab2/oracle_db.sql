create type trip_participant as OBJECT
(
    reservation_id int,
    trip_id int,
    person_id int,
    firstname varchar2(50),
    lastname varchar2(50)
)
/

create type trip_info as OBJECT
(
    country varchar2(50),
    trip_date date,
    trip_name varchar2(100),
    max_no_places int,
    no_available_places int
)
/

create type TRIP_PARTICIPANT_TABLE as table of TRIP_PARTICIPANT
/

create type TRIP_INFO_TABLE as table of TRIP_INFO
/

create table PERSON
(
    PERSON_ID NUMBER generated as identity
        constraint PERSON_PK
            primary key,
    FIRSTNAME VARCHAR2(50),
    LASTNAME  VARCHAR2(50)
)
/

create table COUNTRY
(
    COUNTRY_ID   NUMBER generated as identity
        constraint COUNTRY_PK
            primary key,
    COUNTRY_NAME VARCHAR2(50)
)
/

create table TRIP
(
    TRIP_ID             NUMBER generated as identity
        constraint TRIP_PK
            primary key,
    TRIP_NAME           VARCHAR2(100),
    COUNTRY_ID          NUMBER
        constraint TRIP_FK1
            references COUNTRY,
    TRIP_DATE           DATE,
    MAX_NO_PLACES       NUMBER,
    NO_AVAILABLE_PLACES NUMBER
)
/

create trigger TR_UPDATE_PLACES
    after update
    on TRIP
    for each row
begin
    RECALC(TRIP_ID);
end;
/

create table RESERVATION
(
    RESERVATION_ID NUMBER generated as identity
        constraint RESERVATION_PK
            primary key,
    TRIP_ID        NUMBER
        constraint RESERVATION_FK2
            references TRIP,
    PERSON_ID      NUMBER
        constraint RESERVATION_FK1
            references PERSON,
    STATUS         CHAR
        constraint RESERVATION_CHK1
            check (status in ('N', 'P', 'C'))
)
/

create trigger TR_UPDATE_LOG
    after insert or update
    on RESERVATION
    for each row
begin
    insert into LOG(RESERVATION_ID, LOG_DATE, STATUS) VALUES(:new.RESERVATION_ID, current_date,:new.STATUS);
end;
/

create trigger TR_DELETE_RESERVATION
    before delete
    on RESERVATION
    for each row
begin
    raise_application_error(-20001, 'CANNOT REMOVE RESERVATION');
end;
/

create trigger TR_ADD_RESERVATION
    before insert
    on RESERVATION
    for each row
declare
    tmp char;
begin
    TRIP_EXIST(:new.TRIP_ID);
    PERSON_EXIST(:new.PERSON_ID);

    select 1 into tmp from AVAILABLETRIPS
    where TRIP_ID = :new.TRIP_ID;

    exception
        when NO_DATA_FOUND then
        raise_application_error(-20001, 'TRIP HAD TAKEN PLACE OR IS FULLY BOOKED');
end;
/

create trigger TR_UPDATE_RESERVATION
    before update
    on RESERVATION
    for each row
declare
    r_places int;
begin
    if :new.STATUS not in ('N','P','C') then
        raise_application_error(-20002,'WRONG STATUS');
    end if;
    
    select NO_AVAILABLE_PLACES into r_places from TRIP where TRIP_ID = :old.TRIP_ID;
    
    if not(:new.STATUS = 'C' or :new.STATUS = 'P' and :old.STATUS = 'N' or :new.STATUS = 'P' and :old.STATUS = 'C' and r_places > 0 or :new.STATUS = 'N' and :old.STATUS = 'C' and r_places > 0) then
        raise_application_error(-20002,'CANNOT CHANGE STATUS');
    end if;

    exception
        when NO_DATA_FOUND then
        raise_application_error(-20001, 'TRIP HAD TAKEN PLACE OR IS FULLY BOOKED');
end;
/

create trigger TR_UPDATE_PLACES_2
    after insert or update
    on RESERVATION
    for each row
begin
    RECALC(:new.TRIP_ID);
end;
/

create table LOG
(
    LOG_ID         NUMBER generated as identity
        constraint LOG_PK
            primary key,
    RESERVATION_ID NUMBER not null
        constraint LOG_FK1
            references RESERVATION,
    LOG_DATE       DATE   not null,
    STATUS         CHAR
        constraint LOG_CHK1
            check (status in ('N', 'P', 'C'))
)
/

create view RESERVATIONS as
select C.COUNTRY_NAME, T.TRIP_DATE, T.TRIP_NAME, P.FIRSTNAME, P.LASTNAME, R.RESERVATION_ID, R.STATUS
    from RESERVATION R join TRIP T on R.TRIP_ID = T.TRIP_ID
        join PERSON P on R.PERSON_ID = P.PERSON_ID
        join COUNTRY C on T.COUNTRY_ID = C.COUNTRY_ID
/

create view NUMOFRESERVATIONS as
select T.TRIP_ID, NVL(AC.NUM_OF_RESERVATIONS,0) as NUM_OF_RESERVATIONS
    from (select T.TRIP_ID, count(R.STATUS) as NUM_OF_RESERVATIONS
    from TRIP T join RESERVATION R on T.TRIP_ID = R.TRIP_ID
    where R.STATUS != 'C'
    group by T.TRIP_ID) AC right join TRIP T on T.TRIP_ID = AC.TRIP_ID
/

create view TRIPS as
select T.TRIP_ID, C.COUNTRY_NAME, T.TRIP_DATE, T.TRIP_NAME, T.MAX_NO_PLACES, (T.MAX_NO_PLACES - AC.NUM_OF_RESERVATIONS) as NO_AVALIABLE_PLACES
    from NUMOFRESERVATIONS AC join TRIP T on AC.TRIP_ID = T.TRIP_ID
        join COUNTRY C on T.COUNTRY_ID = C.COUNTRY_ID
/

create view AVAILABLETRIPS as
select "TRIP_ID","COUNTRY_NAME","TRIP_DATE","TRIP_NAME","MAX_NO_PLACES","NO_AVALIABLE_PLACES"
    from TRIPS T
    where T.TRIP_DATE > CURRENT_DATE and T.NO_AVALIABLE_PLACES > 0
/

create view TRIPS_4 as
select T.TRIP_ID, C.COUNTRY_NAME, T.TRIP_DATE, T.TRIP_NAME, T.MAX_NO_PLACES, T.NO_AVAILABLE_PLACES
    from TRIP T join COUNTRY C on T.COUNTRY_ID = C.COUNTRY_ID
/

create view AVAILABLETRIPS_4 as
select T.TRIP_ID, T.COUNTRY_NAME, T.TRIP_DATE, T.TRIP_NAME, T.MAX_NO_PLACES, T.NO_AVALIABLE_PLACES
    from TRIPS T
    where T.TRIP_DATE > CURRENT_DATE and T.NO_AVALIABLE_PLACES > 0
/

create procedure TRIP_EXIST(t_id in TRIP.TRIP_ID%type)
as
    tmp char(1);
begin
    select 1 into tmp from TRIP where TRIP_ID = t_id;
exception
    when NO_DATA_FOUND then
        raise_application_error(-20001, 'TRIP NOT FOUND');
end;
/

create function F_TRIP_PARTICIPANTS(trip_id int)
    return TRIP_PARTICIPANT_TABLE
as
    result TRIP_PARTICIPANT_TABLE;
begin
    TRIP_EXIST(trip_id);
    select TRIP_PARTICIPANT(R.RESERVATION_ID, R.TRIP_ID, P.PERSON_ID, P.FIRSTNAME, P.LASTNAME) bulk collect into result
    from RESERVATION R join PERSON P on R.PERSON_ID = P.PERSON_ID
    where R.TRIP_ID = F_TRIP_PARTICIPANTS.trip_id and R.STATUS != 'C';
    return result;
end;
/

create procedure PERSON_EXIST(p_id in PERSON.PERSON_ID%type)
as
    tmp char(1);
begin
    select 1 into tmp from PERSON where PERSON_ID = p_id;
exception
    when NO_DATA_FOUND then
        raise_application_error(-20001, 'PERSON NOT FOUND');
end;
/

create function F_PERSON_RESERVATIONS(person_id int)
    return TRIP_PARTICIPANT_TABLE
as
    result TRIP_PARTICIPANT_TABLE;
begin
    PERSON_EXIST(person_id);
    select TRIP_PARTICIPANT(R.RESERVATION_ID, R.TRIP_ID, P.PERSON_ID, P.FIRSTNAME, P.LASTNAME) bulk collect into result
    from RESERVATION R join PERSON P on R.PERSON_ID = P.PERSON_ID
    where R.PERSON_ID = F_PERSON_RESERVATIONS.person_id;
    return result;
end;
/

create procedure COUNTRY_EXIST(c_name COUNTRY.COUNTRY_NAME%type)
as
    tmp char(1);
begin
    select 1 into tmp from COUNTRY where COUNTRY_NAME = c_name;
exception
    when NO_DATA_FOUND then
        raise_application_error(-20001, 'COUNTRY NOT FOUND');
end;
/

create function F_AVAILABLE_TRIPS(country varchar, date_from date, date_to date)
    return TRIP_INFO_TABLE
as
    result TRIP_INFO_TABLE;
begin
    COUNTRY_EXIST(country);

    select TRIP_INFO(AV.COUNTRY_NAME, AV.TRIP_DATE, AV.TRIP_NAME, AV.MAX_NO_PLACES, AV.NO_AVALIABLE_PLACES) bulk collect into result
    from AVAILABLETRIPS AV
    where AV.COUNTRY_NAME = F_AVAILABLE_TRIPS.country and AV.TRIP_DATE >= F_AVAILABLE_TRIPS.date_from and AV.TRIP_DATE <= F_AVAILABLE_TRIPS.date_to;
    return result;
end;
/

create procedure ADD_RESERVATION(p_trip_id int, p_person_id int)
as
    tmp char(1);
    p_reservation_id int;
begin
    TRIP_EXIST(p_trip_id);
    PERSON_EXIST(p_person_id);

    select 1 into tmp from AVAILABLETRIPS
    where TRIP_ID = p_trip_id;

    insert into RESERVATION(TRIP_ID, PERSON_ID, STATUS) VALUES (p_trip_id, p_person_id, 'N') returning RESERVATION_ID into p_reservation_id;
    insert into LOG(RESERVATION_ID, LOG_DATE, STATUS) VALUES (p_reservation_id, current_date,'N');

exception
    when NO_DATA_FOUND then
        raise_application_error(-20001, 'TRIP HAD TAKEN PLACE OR IS FULLY BOOKED');
end;
/

create procedure RESERVATION_EXIST(r_id RESERVATION.RESERVATION_ID%type)
as
    tmp char(1);
begin
    select 1 into tmp from RESERVATION where RESERVATION_ID = r_id;
exception
    when NO_DATA_FOUND then
        raise_application_error(-20001, 'RESERVATION NOT FOUND');
end;
/

create procedure MODIFY_RESERVATION_STATUS(p_reservation_id int, p_status char)
as
    r_status char(1);
    r_places int;
begin
    RESERVATION_EXIST(p_reservation_id);

    if p_status not in ('N','P','C') then
        raise_application_error(-20002,'WRONG STATUS');
    end if;

    select STATUS into r_status from RESERVATION where RESERVATION_ID = p_reservation_id;
    select T.NO_AVALIABLE_PLACES into r_places from TRIPS T join RESERVATION R on T.TRIP_ID = R.TRIP_ID where RESERVATION_ID = p_reservation_id;

    if(p_status = 'C' or p_status = 'P' and r_status = 'N' or p_status = 'P' and r_status = 'C' and r_places > 0 or p_status = 'N' and r_status = 'C' and r_places > 0) then
        update RESERVATION set STATUS = p_status where RESERVATION_ID = p_reservation_id;
        insert into LOG(RESERVATION_ID, LOG_DATE, STATUS) values (p_reservation_id,current_date,p_status);
    else
        raise_application_error(-20002,'CANNOT CHANGE STATUS');
    end if;
end;
/

create procedure MODIFY_NO_PLACES(p_trip_id int, p_no_places int)
as
    r_places int;
begin
    TRIP_EXIST(p_trip_id);

    select NUM_OF_RESERVATIONS into r_places from NUMOFRESERVATIONS where TRIP_ID = p_trip_id;

    if(r_places <= p_no_places)then
        update TRIP set MAX_NO_PLACES = p_no_places where TRIP_ID = p_trip_id;
    else
        raise_application_error(-20002,'TOO MANY RESERVATIONS');
    end if;
end;
/

create procedure ADD_RESERVATION_2(p_trip_id int, p_person_id int)
as
    tmp char(1);
begin
    TRIP_EXIST(p_trip_id);
    PERSON_EXIST(p_person_id);

    select 1 into tmp from AVAILABLETRIPS
    where TRIP_ID = p_trip_id;

    insert into RESERVATION(TRIP_ID, PERSON_ID, STATUS) VALUES (p_trip_id, p_person_id, 'N');

exception
    when NO_DATA_FOUND then
        raise_application_error(-20001, 'TRIP HAD TAKEN PLACE OR IS FULLY BOOKED');
end;
/

create procedure MODIFY_RESERVATION_STATUS_2(p_reservation_id int, p_status char)
as
    r_status char(1);
    r_places int;
begin
    RESERVATION_EXIST(p_reservation_id);

    if p_status not in ('N','P','C') then
        raise_application_error(-20002,'WRONG STATUS');
    end if;

    select STATUS into r_status from RESERVATION where RESERVATION_ID = p_reservation_id;
    select T.NO_AVALIABLE_PLACES into r_places from TRIPS T join RESERVATION R on T.TRIP_ID = R.TRIP_ID where RESERVATION_ID = p_reservation_id;

    if(p_status = 'C' or p_status = 'P' and r_status = 'N' or p_status = 'P' and r_status = 'C' and r_places > 0 or p_status = 'N' and r_status = 'C' and r_places > 0) then
        update RESERVATION set STATUS = p_status where RESERVATION_ID = p_reservation_id;
    else
        raise_application_error(-20002,'CANNOT CHANGE STATUS');
    end if;
end;
/

create procedure ADD_RESERVATION_3(p_trip_id int, p_person_id int)
as
begin
    insert into RESERVATION(TRIP_ID, PERSON_ID, STATUS) VALUES (p_trip_id, p_person_id, 'N');
end;
/

create procedure MODIFY_RESERVATION_STATUS_3(p_reservation_id int, p_status char)
as
begin
    RESERVATION_EXIST(p_reservation_id);

    update RESERVATION set STATUS = p_status where RESERVATION_ID = p_reservation_id;
end;
/

create function F_AVAILABLE_TRIPS_4(country varchar, date_from date, date_to date)
    return TRIP_INFO_TABLE
as
    result TRIP_INFO_TABLE;
begin
    COUNTRY_EXIST(country);

    select TRIP_INFO(C.COUNTRY_NAME, T.TRIP_DATE, T.TRIP_NAME, T.MAX_NO_PLACES, T.NO_AVAILABLE_PLACES) bulk collect into result
    from TRIP T join COUNTRY C on C.COUNTRY_ID = T.COUNTRY_ID
    where C.COUNTRY_NAME = F_AVAILABLE_TRIPS_4.country and T.TRIP_DATE >= current_date and T.TRIP_DATE >= F_AVAILABLE_TRIPS_4.date_from and T.TRIP_DATE <= F_AVAILABLE_TRIPS_4.date_to;
    return result;
end;
/

create procedure MODIFY_NO_PLACES_5(p_trip_id int, p_no_places int)
as
    r_places int;
    m_places int;
begin
    TRIP_EXIST(p_trip_id);

    select NO_AVAILABLE_PLACES into r_places from TRIP where TRIP_ID = p_trip_id;
    select MAX_NO_PLACES into m_places from TRIP where TRIP_ID = p_trip_id;

    if(m_places-r_places <= p_no_places) then
        update TRIP set MAX_NO_PLACES = p_no_places where TRIP_ID = p_trip_id;
    end if;
end;
/

create procedure RECALC(p_trip_id int)
as
    r_places int;
begin
    TRIP_EXIST(p_trip_id);

    select NUM_OF_RESERVATIONS into r_places from NUMOFRESERVATIONS where TRIP_ID = p_trip_id;

    update TRIP set NO_AVAILABLE_PLACES = MAX_NO_PLACES - r_places where TRIP_ID = p_trip_id;
end;
/

create procedure ADD_RESERVATION_4(p_trip_id int, p_person_id int)
as
begin
    insert into RESERVATION(TRIP_ID, PERSON_ID, STATUS) VALUES (p_trip_id, p_person_id, 'N');
    RECALC(p_trip_id);
end;
/

create procedure MODIFY_NO_PLACES_4(p_trip_id int, p_no_places int)
as
    r_places int;
    m_places int;
begin
    TRIP_EXIST(p_trip_id);

    select NO_AVAILABLE_PLACES into r_places from TRIP where TRIP_ID = p_trip_id;
    select MAX_NO_PLACES into m_places from TRIP where TRIP_ID = p_trip_id;

    if(m_places-r_places <= p_no_places) then
        update TRIP set MAX_NO_PLACES = p_no_places where TRIP_ID = p_trip_id;
        RECALC(p_trip_id);
    else
        raise_application_error(-20002,'TOO MANY RESERVATIONS');
    end if;
end;
/

create procedure MODIFY_RESERVATION_STATUS_4(p_reservation_id int, p_status char)
as
    tmp char;
    trip int;
begin
    RESERVATION_EXIST(p_reservation_id);

    select STATUS into tmp from RESERVATION where RESERVATION_ID = p_reservation_id;
    select TRIP_ID into trip from RESERVATION where RESERVATION_ID = p_reservation_id;

    update RESERVATION set STATUS = p_status where RESERVATION_ID = p_reservation_id;

    RECALC(trip);
end;
/

create procedure ADD_RESERVATION_5(p_trip_id int, p_person_id int)
as
begin
    insert into RESERVATION(TRIP_ID, PERSON_ID, STATUS) VALUES (p_trip_id, p_person_id, 'N');
end;
/

