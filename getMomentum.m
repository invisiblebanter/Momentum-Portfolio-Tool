%Function for Momentum 
function [y]=getMomentum(thisPermno,thisYear,thisMonth,crsp);

%For example, if thisPermno==10001, thisYear==2008, and thisMonth==01, 
%then getMomentum(thisPermno,thisYear,thisMonth,crsp) should return 
%the cumulative gross return from the end of January 2007 to the 
%end of December 2007.

endMonth= thisMonth-1;
endYear= thisYear;

if endMonth == 0
    endMonth = 12;
    endYear = endYear -1; 
end 

endPrice = crsp.adjustedPrice(crsp.year == endYear & crsp.month == endMonth & crsp.PERMNO == thisPermno);

startMonth= thisMonth; 
startYear= thisYear-1;
startPrice = crsp.adjustedPrice(crsp.year == startYear & crsp.month == startMonth & crsp.PERMNO == thisPermno);

%When the required data is missing from crsp, your function should return
%NaN instead.

if isempty(startPrice)|isempty(endPrice)
    y=NaN;
else 
    y=(endPrice/startPrice)-1;
end 
end