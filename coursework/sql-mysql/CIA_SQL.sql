create database MyTest11;
use MyTest11;
create table India11(
CapNo varchar(20) primary key,
Player_Name varchar(100),
Jersy_No int not null,
Total_Runs int,
Highest_Score int,
BatAverage decimal,
wkt int,
BowlAverage decimal ,
Domestic_Team varchar(50),
Match_No int);
insert into India11
(CapNo, Player_Name, Jersy_No, Total_Runs, Highest_Score, BatAverage, wkt, BowlAverage, Domestic_Team, Match_No)
Values 
("CAP208","Rohit Sharma", 45, 4137, 212,45.64,0,0,"Maharastra",59),
("CAP306","Yashasvi Jaiswal", 64, 1028,214,68.53,0,0,"Maharastra",9),
("CAP297","Shubhman Gill", 77, 1492,128,35.52,0,0,"Maharastra",25),
("CAP269","Virat Kohli", 18, 8848,254,49.15,0,0,"Delhi",113),
("CAP284","KL Rahul", 1, 2755,199,33.59,0,0,"Karnataka",49),
("CAP291","Rishabh Pant", 17, 2271,159,43.67,0,0,"Delhi",33),
("CAP275","Ravindra Jadeja",8,3036,175,36.14,294,24.13,"Saurashtra",72),
("CAP271","Rvaichandran Ashwin", 99, 3309,124,26.26,516,23.75,"Tamilnadu",100),
("CAP290","Jasprit Bumrah", 93, 271,34,7.32,159,20.69,"Maharastra",36),
("CAP313","Akash Deep", 45, 9,9,9,3,27.66,"Maharastra",1),
("CAP298","Mohammed Siraj", 73, 104,16, 4.45,74,29.68,"Hyderabad",27);
select * from India11;
#updating the Domestic_Team for CapNo. 297 from Mumbai to Punjab
update India11
set Domestic_Team = "Punjab"
where CapNo="CAP297";

#retrieving the top 5 batsman order by highest average
select * from India11
order by BatAverage desc limit 5;

# players with highest wickets 
select Player_Name, wkt, BowlAverage, Match_No from India11
 where wkt and BowlAverage is not null
 order by wkt desc;

select * from India11;

# to know the players with Average more than or equal to 40
select Player_Name, Total_Runs, BatAverage, Match_No from India11
where BatAverage>=40;

#to know the players from the particluar state
select CapNo, Player_Name, Domestic_Team from India11 where Domestic_Team like "Maharastra";

#count the number of player form each state 
select distinct Domestic_Team, count(Player_Name) as Players  from India11
group by Domestic_Team;

#select players highest score from top to bottom with a Average more than or equal to 30
select Player_Name, Highest_Score, BatAverage from India11
where BatAverage>=30
order by Highest_Score desc;
