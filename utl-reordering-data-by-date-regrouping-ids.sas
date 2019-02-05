Reordering data by date regrouping ids                                                                     
                                                                                                           
Sort by the first occurance of lowest date within a group then                                             
sort the dates within a group by date.   

Recent improved solution by on end
Paul Dorfman <sashole@bellsouth.net>

Very nice single HASH solution.

Two HASH tables, seems a bit more logical then
a 'replace
 method.

This is sort-within-sort of a single variable using a grouping variable.
Like a hierarchical sort?
Note date is not stricjly in ascending order. Dates within a
group may exceed thedate  values in subsequent row,

Pauls Comment
"Very nice. It raises the question whether the same can be achieved
without sorting by [date,id] first outside the DATA step.
Though the answer is yes (below), I was a bit surprised
that it's more convoluted than I originally thought."

                                                                                                           
This can probably be done very elegantly in R or IML?    

github
https://github.com/rogerjdeangelis/utl-reordering-data-by-date-regrouping-ids
                                                                                                           
https://tinyurl.com/y9drxt6d                                                                               
https://communities.sas.com/t5/SAS-Procedures/Reordering-data-by-date-but-grouping-ids/m-p/531299          
                                                                                                           
Novinosrin                                                                                                 
https://communities.sas.com/t5/user/viewprofilepage/user-id/138205                                         
                                                                                                           
                                                                                                           
INPUT                                                                                                      
=====                                                                                                      
                                                                                                           
data have;                                                                                                 
input id date;                                                                                             
cards4;                                                                                                    
1 2005                                                                                                     
2 2008                                                                                                     
3 2004                                                                                                     
3 2012                                                                                                     
4 2001                                                                                                     
5 2016                                                                                                     
5 2007                                                                                                     
5 2010                                                                                                     
;;;;                                                                                                       
run;quit;                                                                                                  
                                                                                                           
                                                                                                           
WORK.HAVE total obs=8                                                                                      
                                                                                                           
               | RULES                                                                                     
               | Sort by Date and keep same IDs together (ecending witin ID)                               
                                                                                                           
  ID    DATE   | ID    DATE                                                                                
               |                                                                                           
   1    2005   |  4    2001   One 4 (2001 is oldest and grouo size of 1)                                   
   2    2008   |  3    2004   Two 3s (keep together and 2004 is next oldest)                               
   3    2004   |  3    2012                                                                                
   3    2012   |  1    2005   One 1 ( and is next in date sequence)                                        
   4    2001   |  5    2007                                                                                
   5    2016   |  5    2010   Three 5s note next date in sequence and sorted within 5s                     
   5    2007   |  5    2016                                                                                
   5    2010   |  2    2008                                                                                
                                                                                                           
*          _       _   _                                                                                   
 ___  ___ | |_   _| |_(_) ___  _ __                                                                        
/ __|/ _ \| | | | | __| |/ _ \| '_ \                                                                       
\__ \ (_) | | |_| | |_| | (_) | | | |                                                                      
|___/\___/|_|\__,_|\__|_|\___/|_| |_|                                                                      
                                                                                                           
;                                                                                                          
proc sort data=have out=havSrt;                                                                            
by date id;                                                                                                
run;                                                                                                       
                                                                                                           
                                                                                                           
/*  Sorted on date only                                                                                    
                                                                                                           
 WORK.HAVSRT total obs=8                                                                                   
                                                                                                           
  ID    DATE                                                                                               
                                                                                                           
   4    2001                                                                                               
   3    2004                                                                                               
   1    2005                                                                                               
   5    2007                                                                                               
   2    2008                                                                                               
   5    2010                                                                                               
   3    2012                                                                                               
   5    2016                                                                                               
*/                                                                                                         
                                                                                                           
                                                                                                           
data havHsh;                                                                                               
if _n_=1 then do;                                                                                          
   declare hash H (multidata:'y',ordered:'y') ;                                                            
   h.definekey  ("id") ;                                                                                   
   h.definedata ("seq") ;                                                                                  
   h.definedone () ;                                                                                       
end;                                                                                                       
set havSrt;                                                                                                
if h.find() ne 0 then seq+1; only update seq when first occur of ID;                                       
h.replace(); * add sequence;                                                                               
run;                                                                                                       
                                                                                                           
/*                                                                                                         
WORK.HAVHSH total obs=8                                                                                    
                                                                                                           
 ID    DATE    SEQ                                                                                         
                                                                                                           
  4    2001     1   Note sequence provides the                                                             
  3    2004     2   date order within ID                                                                   
  1    2005     3                                                                                          
  5    2007     4                                                                                          
  2    2008     5                                                                                          
  5    2010     4                                                                                          
  3    2012     2                                                                                          
  5    2016     4                                                                                          
*/                                                                                                         
                                                                                                           
proc sort data=havHsh out=want;                                                                            
by seq date;                                                                                               
run;                                                                                                       
                                                                                                           
/*                                                                                                         
WORK.WANT total obs=8                                                                                      
                                                                                                           
 ID    DATE    SEQ                                                                                         
                                                                                                           
  4    2001     1                                                                                          
                                                                                                           
  3    2004     2                                                                                          
  3    2012     2                                                                                          
                                                                                                           
  1    2005     3                                                                                          
                                                                                                           
  5    2007     4                                                                                          
  5    2010     4                                                                                          
  5    2016     4                                                                                          
                                                                                                           
  2    2008     5                                                                                          
*/                                                                                                         
                                                                                                           
                                                                                                           
*____             _
|  _ \ __ _ _   _| |
| |_) / _` | | | | |
|  __/ (_| | |_| | |
|_|   \__,_|\__,_|_|

;

data have ;
  input id date ;
  cards ;
1 2005
2 2008
3 2004
3 2012
4 2001
5 2016
5 2007
5 2010
run ;

data want ;
  if 0 then set have ;
  dcl hash h (dataset:"have", multidata:"Y", ordered:"A") ;
  h.definekey  ("date", "id") ;
  h.definedone () ;
  dcl hiter ih ("h") ;
  dcl hash r (multidata:"Y") ;
  r.definekey  ("id") ;
  r.definedata  ("date") ;
  r.definedone () ;
  dcl hash x () ;
  x.definekey ("id") ;
  x.definedone () ;
  do while (ih.next() = 0) ;
    r.add() ;
  end ;
  do while (ih.next() = 0) ;
    if x.check() = 0 then continue ;
    seq + 1 ;
    do while (r.do_over() = 0) ;
      output ;
    end ;
    x.add() ;
  end ;
  stop ;
run ;

                                                                                                          
                                                                                                           
                                                                                                           
