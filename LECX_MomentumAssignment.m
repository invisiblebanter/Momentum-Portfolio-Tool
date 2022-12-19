clear;clc;

%Import Data
crsp = readtable("crsp20042008.csv");

%Add datenum 
crspstr = num2str(crsp.DateOfObservation);
crsp.datenum = datenum(crspstr,'yyyymmdd');

%Add year and month 
crsp.year = year(crsp.datenum);
crsp.month = month(crsp.datenum);

%Function for Momentum written in getMomentum file. 

%Calculate Momentum. 
%Construct a new variable crsp.momentum using the NaN(n,k)function and use 
%getMomentum( )to calculate momentum for each stock and month in a for-loop.

crsp.momentum = NaN(size(crsp,1),1);

tStart=tic;

tic
for i=1:size(crsp,1)
     if ~mod(i,1000)
        completion=i/size(crsp,1);
        %toc
        fprintf('Getting Signals - %2.2f %% \r', completion*100);
    end
    thisMomentum=getMomentum(crsp.PERMNO(i),crsp.year(i),crsp.month(i),crsp);
    crsp(i,:).momentum=thisMomentum;
end 
toc(tStart)  

%Calculate Momentum Returns 
%Create a new table momentum by retrieving the list of unique dates that appeared 
%in crsp.DateOfObservation. Add the variables momentum.year and momentum.month the 
%same way you did in step 2. 

date=unique(crsp.DateOfObservation);
momentum = table(date);

momentumstr = num2str(momentum.date);
momentum.datenum=datenum(momentumstr,'yyyymmdd');

momentum.year=year(momentum.datenum);
momentum.month=month(momentum.datenum);

%Construct the equal weighted momentum returns for mom1, mom10, and mom
%momentum.mom1: Equal weighted return on the stock in the bottom momentum 
%decile(loser portfolio)
%momentum.mom10: Equal weighted return on the stock in the top momentum 
%decile (winner portfolio)
%momentum.mom: Long winner short loser returns(momentum.mom10 - momentum.mom1)

momentum.mom10=NaN(size(momentum.date));
momentum.mom1=NaN(size(momentum.date));
momentum.mom=NaN(size(momentum.date));

for i=1:size(momentum,1)
    thisYear=momentum.year(i);
    thisMonth=momentum.month(i);

%The stocks in which it is possible to invest. 
    invest=crsp.year==thisYear & crsp.month==thisMonth & ~isnan(crsp.Returns);
    thisMomentum=crsp.momentum(invest);

%Quantiles based on rank variables of investable stocks. 
    momentumQuantiles=quantile(thisMomentum,9);

%Winner stocks need to be in the top momentum decile as of last month and investable.     
    isWinner = crsp.momentum>=momentumQuantiles(9); 
    isWinner = isWinner & invest;

%Winner returns for equal weighted portfolio (mom10)
    momentum.mom10(i)=mean(crsp.Returns(isWinner));

%Loser stocks need to be in the bottom momentum decile of last month and investable 
    isLoser = crsp.momentum<=momentumQuantiles(1);
    isLoser = isLoser & invest;

%Loser returns for equal weighted portfolio (mom1)
    momentum.mom1(i)=mean(crsp.Returns(isLoser));

    wMomentumVanilla=isWinner/sum(isWinner) - isLoser/sum(isLoser);
end 

%Long-short portfolio returns 
momentum.mom=momentum.mom10 - momentum.mom1;

%Remove the first 11 rows of Nan
momentum=momentum(13:end,:);
save('Momentum_Sol_Assignment');

%CALCULATE CUMULATIVE RETURNS
%Add momentum.cumulativeRet, the cumulative net return on the long-short momentum 
%portfolio. Treat missing (NaN) returns as 0.

cumulativeReturn=momentum(:,5:end);
cumulativeReturn{1,:}=0;

cumulativeReturn{:,:}=1+cumulativeReturn{:,:};
cumulativeReturn{:,:}=cumprod(cumulativeReturn{:,:});

hold on
plot(momentum.datenum(1:end),cumulativeReturn{1:end,1},'LineWidth',2);
plot(momentum.datenum(1:end),cumulativeReturn{1:end,2},'LineWidth',2);
plot(momentum.datenum(1:end),cumulativeReturn{1:end,3},'LineWidth',2);
title("Long-Short Momentum CRSP Database")
xlabel("Months")
ylabel("Returns")
datetick('x','yyyy mmm')
legend('Winners','Losers','Long Short')
grid on;




