
/ trades.q
/ example table with random data

trades:([]
 date:`date$();
 time:`time$();
 sym:`symbol$();
 price:`real$();
 size:`int$();
 venue:`symbol$();
 strategy:`symbol$();
 sor:`symbol$())

`trades insert (2013.07.01;10:03:54.347;`IBM;20.83e;40000;"N")
`trades insert (2013.07.01;10:04:05.827;`MSFT;88.75e;2000;"B")


syms:`IBM`MSFT`UPS`BAC`AAPL
venues:`ENX`TQ`ChiX`Bats`LSE`NDQ`FTSE
strategies:`VWAP`WVOL`TVOL`TWAP`BLOCK`OPEN`CLOSE
sors:`Quote`Hit`Dark`Fixing
tpd:10000              / trades per day
day:365                / number of days
cnt:count syms       / number of syms
len:tpd*cnt*day      / total number of trades
date:2013.07.01+len?day
time:"t"$raze (cnt*day)#enlist 09:30:00+3*til tpd    /
time+:len?1000
sym:len?syms
price:len?100e
size:100*len?1000
venue:len?venues
strategy:len?strategies
sor:len?sors

trades:0#trades      / empty trades table

`trades insert (date;time;sym;price;size;venue;strategy;sor) / Insert data

trades:`date`time xasc trades  / sort on time within date
5#trades / first 5 trades


count trades

/check
-1 "Counts: ", (", " sv string each count each (date;time;sym;price;size;strategy;sor;venue)), " should all be ", string len;


select sumnominal:sum(price*size) by 5 xbar time.minute, col:((string strategy),'"/",'(string sor))   from trades




select col:((string strategy),'"/",'(string sor)) from trades

select col:((string firstname),'(string lastname),'"/",'(string age)) from tab





count trades  

select date,sym from trades where not null date, not null sym, date>2013.07.02


10#trades
select from trades where null date

select from trades where null sym

meta trades
count trades


/ better performance - because distinctDates becomes a constant
distinctDates: count distinct exec date from trades
select date, time, sym, price, size, cond, nominal: (price*size) % distinctDates from trades


/ poor perf
select date, time, sym, price, size, cond, nominal: (price*size) % count distinct date from trades


// day by day, bucket of 5m
select sumNominal: sum price*size by date, 5 xbar time.minute from trades where date within 2013.07.01 2013.07.05, sym=`MSFT


/ by symbol by 5m bucket
select sumNominal: sum price*size by sym, 5 xbar time.minute from trades where date within 2013.07.01 2014.07.05, sym=`MSFT


select sumNominal: sum price*size  by strategy, 5 xbar time.minute from trades

select nominal:sum(price*size) by 10 xbar time.minute, sym from trades


select sumNominal: sum price*size by sym, 5 xbar time.minute from trades where date within 2013.07.01 2013.07.05

/ scater
count select nominal:price*size, sor, strategy, size,time from trades where date=2013.07.08


\

count deal:                               // histogram
by strategy sum nominal time windowed     // bar
group by time window                       
plain group by time window                // bar
scatter                                   // plain

price line:
select avg(price) by 10 xbar time.minute, strategy from trades where date=2013.07.13, strategy in `TWAP`BLOCK`WVOL

time:"t"$raze (cnt*day)#enlist 09:30:00+15*til tpd

    til tpd: Generates a list of integers from 0 up to (but not including) tpd (100 in this case). The result is a list [0, 1, 2, ..., 99].
    15*: Multiplies each element in the list by 15, giving [0, 15, 30, ..., 1485]. These numbers represent seconds.
    09:30:00+: Adds these seconds to the time 09:30:00. Each element in the list now represents a time 15 seconds apart starting from 09:30:00, up to 09:55:45.

enlist:

    enlist: Converts the list of times (created in the previous step) into a single list within a list. This is often used in kdb+/Q to handle lists of lists explicitly.

(cnt*day)#:

    cnt*day: Multiplies the number of symbols (cnt, which is 5) by the number of days (day, which is 5). The result is 25.
    (cnt*day)#: Takes the list created by enlist and repeats it cnt*day times (25 times in this case), ensuring that there are enough time stamps to cover all trades for all symbols over all days.

raze:

    raze: Flattens the list of lists into a single list. After repetition by (cnt*day)#, you would have a nested list structure where each day's times are in their sublist. raze merges these into one continuous list.

"t"$:

    "t"$: Casts the list to type time. This is necessary because the time calculations initially produce a list of type timespan or datetime. The cast ensures that the final list is appropriately typed as time for your simulated trades data


/
