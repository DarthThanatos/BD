DROP role Administrator
CREATE ROLE Administrator
/*
Administrator bazy ma dostęp do wszystkich jej składników 
*/

drop role Owner
CREATE ROLE Owner
/*Owner (orgnizator) - może tworzyć konferencje i warsztaty, dostęp do wszystkich widoków i procedur związanych z
utworzonymi konferencjami + wszystko to co WebApiCustomerSupport) 
*/
drop role WebApiCustomerSupport
create role WebApiCustomerSupport
-- WebApiCustomerSupport(recepcja) - trzyma rękę na pulsie, obserwując zaległości w płaceniu
drop role WebApiCustomer
CREATE ROLE WebApiCustomer
/*
WebApiCustomer(Klient zarejestrowany) - moze dokonywac rezerwacji na konferencje i warsztaty modyfikować dane rezerwacji
dodawac osoby do rezerwacji
*/
drop role WebApi
CREATE ROLE WebApi
-- WebApi(Klient niezarejestrowany) - Rejestracja konta w systemie
drop role participant
create role participant
-- participant - dostęp do procedur pokazujących na co jest zapisany

--dziedziczenie po WebApiCustomerSupport
ALTER ROLE WebApiCustomerSupport ADD member Owner;
--WebApiCustomerSupport
--dziedziczy po WebApiCustomer
ALTER ROLE WebApiCustomer ADD MEMBER WebApiCustomerSupport;
--dodatkowe widoki

--dodajemy db_datareaders i db_writers - prawa do calej bazy danych
EXEC sp_addrolemember N'db_datareader', N'Owner'  /*  odczyt tabel  i widokow */
EXEC sp_addrolemember N'db_datawriter', N'Owner'  /*  zapis do tabel  */
EXEC sp_addrolemember N'db_owner', N'Administrator'

--WebApi
GRANT EXECUTE ON dbo.Addclients	TO WebApi
GRANT select,insert  ON  dbo.clients  	TO WebApi

--WebApiCustomers 
GRANT EXECUTE ON  dbo.Addconference_participants	TO WebApiCustomer
GRANT EXECUTE ON  dbo.Addconferencereservation		TO WebApiCustomer
GRANT EXECUTE ON  dbo.AddPeople						TO WebApiCustomer
GRANT EXECUTE ON  dbo.Addworkshopparticipants		TO WebApiCustomer
GRANT EXECUTE ON  dbo.Addworkshopreservation 		TO WebApiCustomer
GRANT EXECUTE ON  dbo.UpdatePeople 										TO WebApiCustomer	
GRANT EXECUTE ON  dbo.Update_places_reserved_IN_workshopreservation		TO WebApiCustomer		
GRANT EXECUTE ON  dbo.Update_palces_reserved_IN_conferencereservation  	TO WebApiCustomer			
GRANT EXECUTE ON  dbo.Cancel_conferencereservation                      TO WebApiCustomer		
GRANT EXECUTE ON  dbo.Cancel_workshopreservation                        TO WebApiCustomer		
GRANT EXECUTE ON  dbo.Restore_conferencereservation                     TO WebApiCustomer		
GRANT EXECUTE ON  dbo.Restore_workshopreservation                       TO WebApiCustomer
grant execute on dbo.fill_conf_partic to webapicustomer
grant execute on dbo.fill_conf_res to webapicustomer
grant execute on dbo.fill_work_partic to webapicustomer
grant execute on dbo.fill_work_res to webapicustomer
grant execute on dbo.getFee to webapicustomer
grant execute on dbo.show_fees to webapicustomer
grant execute on dbo.workres_list to webapicustomer
Grant insert, update on dbo.conference_participants   to WebApiCustomer
Grant insert, update on dbo.conferencereservation     to WebApiCustomer
Grant insert, update on dbo.People                    to WebApiCustomer
Grant insert, update on dbo.workshopparticipants      to WebApiCustomer
Grant insert, update on dbo.workshopreservation       to WebApiCustomer
grant execute on dbo.conf_places_av to webapicustomer
grant execute on dbo.conf_places_res to webapicustomer
grant execute on getIndividualOrCompany to webapicustomer
grant execute on getSameWorkshopsID to webapicustomer
grant execute on minimum_date to webapicustomer

--Owner 
GRANT EXECUTE ON dbo.Addconferencies 	TO Owner	
GRANT EXECUTE ON dbo.Addconfrenceday 	TO Owner	
GRANT EXECUTE ON dbo.Addfees 			TO Owner	
GRANT EXECUTE ON dbo.AddpaidRate 		TO Owner	
GRANT EXECUTE ON dbo.Addworkshop		TO Owner
grant select on dbo.costs to owner
grant select on dbo.vips to owner
grant select on dbo.vips_reservations to owner
grant execute on dbo.daylist to owner
grant execute on dbo.reservation_list to owner
grant execute on dbo.show_payments_for_conf to owner
grant execute on dbo.workshop_list to owner
grant execute on get_res_amount to owner
GRANT EXECUTE ON  dbo.Update_places_available_IN_confrenceday TO owner	
GRANT EXECUTE ON  dbo.Update_places_available_IN_workshop TO owner	

--participant
grant execute on dbo.getSameWorkshops to participant
grant execute on dbo.my_events to participant
grant execute on dbo.show_day_person to participant
grant execute on dbo.show_workshop_person to participant
grant execute on getSameWorkshopsID to participant
grant execute on minimum_date to participant
grant execute on dbo.fill_work_partic to participant

-- webapicustomersupport
grant execute on delayed to Webapicustomersupport
grant execute on dbo.generate_business_card to webapicustomersupport
grant execute on dbo.getFee to webapicustomersupport
grant execute on dbo.really_delayed to webapicustomersupport
grant execute on show_delaying_data to webapicustomersupport
grant execute on dbo.total_cost to webapicustomersupport
grant execute on dbo.check_if_student to webapicustomersupport
