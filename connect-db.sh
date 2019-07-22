#!/bin/bash
 
dropdb -U postgres anonDB --if-exists

pg_dump --no-acl --no-owner -U postgres postgres > out.dump

createdb -U postgres anonDB

psql -U postgres anonDB < out.dump

psql -U postgres -d anonDB -c "Create or replace function random_string(length integer) returns text as
$$
declare
  chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;
begin
  if length < 0 then
    raise exception 'Given length cannot be less than 0';
  end if;
  for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;
"
TUSR=$(psql -U postgres -d postgres -c "SELECT COUNT(*) FROM \"Users\"" | grep -o -E -m 1 '[0-9]+')

for i in $(seq $TUSR); do psql -U postgres -d anonDB -c "UPDATE \"Users\" SET \"email\"=(select random_string(5) || '@someemail.com'), \"hashedPassword\"=(select random_string(20)),\"accessToken\"=(select random_string(20)), \"role\"=100, \"nameFirst\"=(select random_string(6)), \"nameLast\"=(select random_string(6)),\"nickname\"=(''), \"telephone\"=(select floor(random() * 100000000)::int),\"entrepreneurRegistrationNumber\"=(select floor(random() * 10000000)::int),\"taxRegistrationNumber\"=((select floor(random()) * 1000000)::int),\"bankAccountNumber\"=(select random_string(16)),\"hourlySalary\"=(select floor(random() * 10000)::int),\"startDate\"=(select NOW()), \"birthDate\"=(select NOW()), \"contractSignDate\"=(select NOW()), \"position\"=(select random_string(5)), \"addressStreet\"=(select random_string(10)), \"addressStreetNumber\"=(select floor(random() * 100000000)::int),\"addressCity\"=(select random_string(12)),\"addressZip\"=(select random_string(5)),\"apiKeyToggl\"=(select random_string(20)) WHERE \"id\"=$i;"; done

TBLG=$(psql -U postgres -d postgres -c "SELECT COUNT(*) FROM \"Billings\"" | grep -o -E -m 1 '[0-9]+')

for j in $(seq $TBLG); do psql -U postgres -d anonDB -c "UPDATE \"Billings\" SET \"amount\"=(select floor(random() * 100000)) WHERE \"id\"=$j;"; done

TCDT=$(psql -U postgres -d postgres -c "SELECT COUNT(*) FROM \"Credits\"" | grep -o -E -m 1 '[0-9]+')

for k in $(seq $TCDT); do psql -U postgres -d anonDB -c "UPDATE \"Credits\" SET \"amount\"=(select floor(random() * 100000)) WHERE \"id\"=$k"; done

pg_dump -U postgres anonDB > anon.dump

dropdb -U postgres anonDB

rm out.dump

