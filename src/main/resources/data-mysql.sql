insert into Location(id, address) values(1, "Boston,MA");
insert into Location(id, address) values(2, "Plansboro,NJ");
insert into Location(id, address) values(3, "Framingham,MA");

insert into User(id,first_name,last_name, email, location_id) values (1, "Srihari","Jala","sjal@yahoo.com",1);
insert into User(id,first_name,last_name, email, location_id) values (2, "Tom","Jala","tom@yahoo.com",2);
insert into User(id,first_name,last_name, email, location_id) values (3, "Bob","Jala","bob@yahoo.com",3);

insert into Post(id,post_date,details,user_id ) values (1, SYSDATE() ," Post 1 here", 1);
insert into Post(id,post_date,details,user_id ) values (2, SYSDATE() ," Post 2 here", 2);
insert into Post(id,post_date,details,user_id ) values (3, SYSDATE() ," Post 3 here", 3);
