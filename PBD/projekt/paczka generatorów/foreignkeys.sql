alter table conferencereservation
add foreign key (representantid)
references representative(representantid)

alter table conferencereservation
add foreign key (dayid)
references conferenceday(dayid)

alter table conferencies
add foreign key (reservationid)
references conferencereservation(reservationid)

alter table conferencies
add foreign key (workshopid)
references workshop(workshopid)

alter table fees
add foreign key (conferenceid)
references conferencies(conferenceid)

alter table workshop
add foreign key (workresid)
references workshopreservation(workresid)

alter table workshopreservation
add foreign key (representantid)
references representative(representantid)

alter table clients
add foreign key (representantid)
references representative (representantid)

alter table discounts
add foreign key (representantid)
references representative(representantid)

