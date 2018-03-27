;; par rapport à IT1 : taxWindow ne joue plus, plus d'impôt et par rapport à IT2 pas de croissance eco, prix flexibles, espilon max 0.05


;; One type of agents: consumers
breed [consumers consumer]

globals [

;********************* FIXED PARAMETERS ***********************************
          
 ;; nbConsumers    ;; Number of consumers in the economy  <- Interface
 
 ;; nbperiods      ;; Number of periods of the run  <- Interface
 ;; nbSimul        ;; Number of simulation (= experiment with a new seed und new parameter set )
 ;; nbExperiment   ;; Number of runs in each simulation in a Monte Carlo experiment <- Interface 
    simul          ;; Experiment number in the NOLH design 
    actRun         ;; The number of the current run
    mySeed         ;; Seed of the NRG used in the run

    mu             ;; firm's mark-up
 ;; alpha          ;; rate of return of the production function
 ;; initWealth     ;; initial wealth of each consumer
    minCRate       ;; lower bound of consumption rate 
    maxCRate       ;; upper bound of consumption rate 
 ;; rho            ;; coefficient for the moving average computations
 ;  infTarget      ;; inflation target of the CB
 ;; coeffInfRate   ;; reaction coefficient to inflation in the Taylor rule
 ;; coeffUnemp     ;; idem to unemployment
 ;; epsilon        ;; adjustemtn rate of the labor demand
 ;; probImit       ;; probability of imitation (GA)
 ;; probMut        ;; probability of mutation (GA)
 ;; mutSpaceW      ;; mutation step for indexation strategies
 ;; mutSpaceK      ;; mutation step for substitution strategies
 ;; chi            ;; degree of credibility of the ifnlation target

;********************* Variables ***********************************
  
   meanCoeffSubst  ;; average substitution coefficients across households
   meanCoeffWageUpdate ;; average indexation coefficients 
   varCoeffSubst   ;; variance of substitution coefficients across households
   varCoeffWageUpdate ;; variance of indexation strat.
   meanConsumptionRate ;; average rate of consumption
   varConsumptionRate ;; variance of consumption rate across households
  
   infRate         ;; inflation rate 
   intRate         ;; nominal interest rate (fixed by the central bank)
   oldIntRate      ;; last period's nominal interest rate
   trendIntRate    ;; moving average of the interest rate
   trendInfRate    ;; idem for inflation rate

   bankrupt        ;; number of agents who go bankrupt each period
   bankrupttable   ;; table for global computation
   Sumbankrupt     ;; number of agents who went bankruptcy in the whole run
  
   labourDemand    ;; labor demand 
   soldOutput      ;; quantity of sold output
   goodSupply      ;; quantity of good supplied
   output          ;; equal to good supply
   hiredLabour     ;; quantity of hired labor
   labourCosts  
   sumCLabour      ;; sum of consumers' labor   
   meanrealConsumption  ;; average of consumers' real consumption
             
   sales           ;; soldOutput * priceLevel  
   GDP             ;; sold output
   profit          
   unemployment   
   unemploymentRate 
   sumNomBonds     ;; total of nominal holdings of households
   priceLevel       
   oldMeanPrice    ;; last period's price level
   meanPermIncome  ;; mean estimated permanent income of consumers
   meanNomBonds    ;; average of nominal holdings across households
   varNomBonds     ;; variance  ''
    
   sumLabSupply    ;; total labor supply (n units)
   fixedLabSupply  ;; labor supply per worker
   potentialGDP    ;; total potential good supply (n ^{1 - \alpha})
   potentialCConsumption ;; potential consumption at the symmetric equilibrium
   potentialCUtility     ;; corresponding utility
   outputGap       ;; gap to potential GDP
   wage            ;; weigthed mean nominal  wages 
   meanUtility     ;; mean of consumers' utility
   fullEmploymentLabour 

   techLevel       ;; factor of the production function (technology level), fixed to one
   ZLB             ;; counter for the zero lower bound of the nominal interest rate       
   publicNoise     ;; noise in scenario 2 (common across households)
  ;stdDevNoise     ;; size of the noise
  
   welfare         ;; sum of consumers utility
  
;; ;********************* variables computed for statistics over the whole range *********************
   meanGDP
   varGDP
   meanUnemp
   varUnemp
   varPriceLevel
   varOutputGap
   varPermIncome
   trendRealIntRate
   meanOutputGap
   meanInfRate
   varInfRate
   varIntRate
   meanIntRate
   meanInfExpect
   varInfExpect
   infTable             ;; table of past inflation observations (used to compute annual inflation (trendinf))
   infSum               ;; sum of past inflation observations (used to compute annual inflation (trendinf))
   flexiblePrice
   xtable
   intTable
   pTable
   yTable
   unempTable
   counterExperiment
   experimentData
   
;********************* Computational tricks ***********************************

   sortedConsumersL  ;; Labour market list of consumers (sorted by decreasing labour offer)
   sortedConsumersP  ;; Product market list of consumers (sorted by decreasing good demand)
   
   smoothProfit
  ; expectations     ;; configurations of expectations
  ; initialization   ;; configurations for initialization 
  
]
   
  
;; Variables of the consumers
consumers-own [ revenues             ;; consumer's nominal incomes
                cLabourRevenues      ;; consumer's nominal labor incomes
                cLabour              ;; consumer's labor sold to firms
                cLabourSupply        ;; consumer's labor supply (fixed to one unit)
                cNomBonds            ;; consumer's savings or debt
                cProfits             ;; dividend flow received by the consumer from the firm
                permIncome           ;; estimated permanent income (weigthed mean of past nominal incomes) 
                consumptionRate      ;; consumption rate (applied to permIncome)
                coeffSubst           ;; substitution strategy
                desNomConsumption    ;; desired nominal consumtion : amount of cash the consumer wants to spent
                realConsumption      ;;  real consumption of the consumer
                nomConsumption       ;;  nominal consumption of the consumer
                utility              ;; consumer's utility ( function of consumption )
                performance          ;; fitness for the GA (smoothed utility)
                desiredWage          ;; nominal desired wage
                coeffWageUpdate      ;; indexation strategy
                privateNoise         ;; noise in the perceived inflation target (scenario 3)
                infExpect            ;; inflation expectation
]



;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

;;setting-up the economy
to setup
  use-new-seed ;; set a new seed for the RNG
  
if initialization = "nolh" [read-experiment-data ]
if initialization = "random" [set nbExperiments nbExperiments]

if saveResults ;; touch "saveResults"-button on the interface in order to get an excel file with saved realizations of global variables / parameters
[
  if file-exists? fileName [ file-delete fileName ]    ;; erasure of the previous excel file
  file-open fileName                                   ;; we open a new excel file
  let head (word "simul;run;period;nbconsumers;probImit;probMut;initialization;expectations;stdDevNoise;mutSpaceW;mutSpaceK;chi;mu;alpha;coeffInfRate;")
  set head (word head "coeffUnemp;rho;initWealth;minCRate;maxCRate;techlevel;epsilon;inftarget;")
  set head (word head "infRate;intRate;priceLevel;wage;labourCosts;hiredLabour;fixedLabSupply;bankrupt;meanNomBonds;varNomBonds;goodSupply;meanPermIncome;unemploymentRate;outputgap;GDP;potentialGDP;ZLB;")
  set head (word head "welfare;meanCoeffSubst;meanCoeffWageUpdate;meanConsumptionRate;varCoeffSubst;varCoeffWageUpdate;varConsumptionRate;")
  set head (word head "meanGDP;varGDP;varPriceLevel;varOutputGap;meanOutputGap;meanInfRate;varInfRate;meanInfExpect;varInfexpect;varIntRate;meanIntRate;potentialCConsumption;")
  set head (word head "potentialCUtility;sumBankrupt;varUnemp;meanUnemp")   ;; this is the set of saved global variables / parameters
  file-print head 
 
]
 
  
 set counterExperiment 0
 
 while [counterExperiment < nbExperiments ]
 [
   
 if initialization = "nolh" [read-experiment counterExperiment]

  set actRun 1            ;; we start with the first simulation
  repeat nbRun         ;; we make nbSimul simulations (= with varying parameters)
  [
   clear-turtles          ;; we kill all agents from the preceding run
   clear-patches
   clear-all-plots        ;; clearing of all interface plots
   clear-output
   reset-ticks            ;; we start with tick = 0

   resetOtherGlobals         ;; initialization of global variables
 
   if initialization = "random" [ randomizeVariables ]
    
   use-new-seed
 
   setup-consumers       ;; initialization of consumer's individual variables
       
   go                        ;; Each period is run by the setup in this case.

  set actRun (actRun + 1)       ;; we continue with the next simulation (we change the current parameter set)
 ]
 
set counterExperiment (counterExperiment + 1)

if initialization = "random" [ randomizeVariables ]
   
]
 
   if (saveResults)           ;; We have opened the file and run GO during the setup
     [file-close]             ;; We must close it programmatically . Touch "file-close"-button of the interface in order to finish the excel-file.
 
end



;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx



;; Generates a new seed for the random number generator.
to use-new-seed
  set mySeed  new-seed           ;; generate a new seed
  random-seed mySeed              ;; use the new seed
end



 
;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


to setup-consumers ;;; initialization of the consumer's variables; creation of a new generation of consumers

create-consumers nbConsumers

set publicNoise  random-normal infTarget stdDevNoise 
if publicNoise < 0 [set publicNoise 0]  ;; loi normale tronquee pour que les agents ne percoivent pas une cible négative

ask consumers [
  set coeffSubst 0. + random-float 1
  set cLabourSupply fixedLabSupply    
  set cLabourRevenues 0.                     ;; initial labor revenue (before working) = 0
  set cNomBonds initWealth                              ;; initial savings
  set Cprofits 0.                         ;; initial dividend flow = 0
  set revenues  0.                          ;; initial revenues = 0 
  set consumptionRate 1.                                 ;; initial consumption rate = 1; the consumers spents all his nominal revenue 
  set realConsumption 0.                     ;; initial real consumption = 0
  set desNomConsumption 0.                   ;; initial desired nominal consumption = 0
  set utility 0.                        ;; initial utility = 0
  set permIncome 0.                             ;; initial permanent income
  set desiredWage 1
  set coeffWageUpdate 0.5 + random-float 1.5
  set privateNoise   random-normal infTarget (stdDevNoise / sqrt (nbConsumers) ) 
  if privateNoise < 0 [set privateNoise 0]
  
  if (expectations = "trend") [set infExpect trendInfRate]
  if (expectations = "misPublicTarget") [set infExpect (publicNoise)]
  if (expectations = "misPrivateTarget") [set infExpect (privateNoise) ]
  if (expectations = "combi") [set infExpect (chi * infTarget) + ((1 - chi) * trendInfRate )  ]
  if (expectations = "onTarget") [set infExpect infTarget ]
]


end

;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx


;;Running the simulation
to go
 

  while [ticks < nbPeriods] 
  [
   
    set oldMeanPrice priceLevel         ;; we save last period's mean price (in order to be able to compute inflation)
    tick                               ;; we go to the next period
    labourMarket                       ;; first step : labor market (we get to know labor demand and supply)
    computeConsumersResources          ;; second step : computation of revenues (we get to know consumers revenue, permanent revenue and consumtion rate)
    productMarket                      ;; third step : goods market (we get to know exchanges of goods betwwen firms and consumers, consumption, profits ...)
    computeWelfare                     ;; fourth step : we compute mean utility of consumers
    
    state-fix-intRate                   ;; the central bank fixes the nominal interest rate
    labour-demand-updating
  
    if (nbRun = 1 AND nbExperiments = 1) [ doPlots ]       ;; Plots only if we run through the interface 
  
    compute-aggregate-stat
  
    if ((saveResults AND (ticks mod freqSave = 0)  ) or ticks = nbperiods )  [do-saveResults]
    
     consumers-learning                  ;; sixth step : consumers' learning

   
 ;;   print (word "::: Beginning TICK: " ticks    
 ;;  " meanPrice : " meanPrice " oldmeanPrice : " oldMeanPrice " intRate : " intRate " Sumprofits : " Sumprofits " infRate : " infRate 
 ;;  " trendinf : " trendinf  )
   ]
end


;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx


to computeConsumersResources ;; computation of revenue, permanent revenue, consumption rate


;; print ( word " computeConsumersResources " )

;; print ( word " trendinf : " trendinf " intRate " intRate " oldIntRate : " oldIntRate)

  
ask consumers [
  
  if (expectations = "trend") [set infExpect trendInfRate]
  if (expectations = "combi") [set infExpect (chi * infTarget) + ((1 - chi) * trendInfRate )  ]
  
  set revenues (cProfits + cLabourRevenues  + (cNomBonds * ( oldIntRate + 1 )) )   ;; computation of the consumer's nominal revenue
  
  
;; Print (word "  Consumer: " who " cLabourRevenues : " cLabourRevenues " cProfits " cProfits " revenues : " revenues  " Bonds : " Bonds " cLabourSupply " claboursupply )                         
                        
  if (revenues > 1E100) [set revenues 1E100]        ;; upper bound of revenues (program shortcut)
  if (revenues < -1E100) [set revenues -1E100]      ;; lower bound of revenues (program shortcut)       
                      
  set permIncome ((1 - rho) *  (revenues) + (rho *  permIncome ) ) ; 
  set consumptionRate ( consumptionRate -  coeffSubst * ( intRate - infExpect  ) )

  if (consumptionRate >  maxCRate) [set consumptionRate maxCRate]       ;; 
  if (consumptionRate < minCRate) [set consumptionRate  minCRate ]      ;; 
  if ((cNomBonds < 0 )  and (abs(cNomBonds *  oldIntRate ) > abs(0.5 * revenues))) [set consumptionRate minCRate] ;solvability condition (threshold for debt is 50 % of the mean past revenues)

  ifelse (revenues < 0. or permIncome < 0.)  ;; if revenue is negative, the consumer cannot spend any amount of money on consumption; We do not take into account negative
                                               ;; permanent income in order to avoid desired negative consumption !!!
  [set desNomConsumption 0.       ;; no positive consumption is possible in this case
   set cNomBonds (revenues)           ;; debt is transfered to later periods
  ]  
  [ set desNomConsumption (consumptionRate * permIncome )   
    set cNomBonds ( revenues - desNomConsumption ) 
  ]    

]

set meanConsumptionRate mean [consumptionRate] of consumers
set varConsumptionRate variance [consumptionRate] of consumers

set meanPermIncome mean [permIncome] of Consumers
set meanInfExpect mean [infExpect] of consumers
set varInfExpect variance [infExpect] of consumers
 
 
;if ticks > 100 [ ask consumers [   
;                  
;  Print (word "  Consumer: " who " k : " consumptionrate )  
;  ]
;]  
  
end



;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx


;; ***** Mechanisms of the LABOUR MARKET:  ***** 
to labourMarket
;; print ( word " labourMarket " )

ask consumers [ 
  set cLabourRevenues 0.  ;; before entering the labor market, the consumer has no labor incomes
  set cLabour 0.         
  set cLabourSupply fixedLabSupply
;; print ( word " consumer : " who " cLabourSupply " cLabourSupply )
;; set coeffWageUpdate 1
 if infRate >= 0. [  set desiredWage ( desiredWage * ( 1 + (coeffWageUpdate * infExpect) ) )  ]
  ]
 

;; print (word " sumLabourSupply : " sumCLabourSupply  " sumLabourDemand : " sumFLabourDemand )

;; print (word " Labour transaction ")


;; We create a list of consumers 
set sortedConsumersL   sort-by [ [desiredWage] of ?1 <= [desiredWage] of ?2 ] consumers   ;; List of consumers, sorted by increasing nominal wage

while [ (length sortedConsumersL > 0) and labourDemand > 0 ] ;; Transactions are possible
[
  let firstSupplyL   0.
  let firstCIndex 1000
  let firstWageC 0.
  
    ;; We question first consumer (the one with the highest labor supply)  
   ask first sortedConsumersL [ 
     set firstSupplyL fixedLabSupply    ;; we look at his labor supply
     set firstCIndex who
     set firstWageC desiredWage               ;; we save his identity
   ]
      
 ;; A transaction is possible
        ;; We have 2 cases: supply >= demand -> The firm can be fully served by this consumer
                         ;; supplyL < demand -> The firm will need the next consumers to be fully served
                          
         ifelse (firstSupplyL >= labourDemand)      ;; the firm can be fully served by this consumer
         [
           let transactionQuantity labourDemand     ;; the quantity of exchanged labor is equal to the firm's labor demand
           let transactionValue (firstWageC * transactionQuantity)    ;; the amount of money exchanged is equal to the product of the consumer's wage and the exchanged labor quantity
            
           ask first sortedConsumersL [
             set cLabourRevenues (cLabourRevenues + transactionValue)  ;; we add the amount of exchanged money to the consumer's labor income
             set clabourSupply (clabourSupply - transactionQuantity)   ;; we diminish the consumer's labor supply by the qunatity of labor already given to the firm
             set cLabour (cLabour + transactionQuantity)               ;; we add the labor given to this firm to the sum of labor given by this consumer
           ]
                        
           set labourDemand  0
          
         ]
         [ ;; The firm can not be fully served by this consumer but the consumer can sell all her supply (supply < demand)
           let transactionQuantity firstSupplyL                     ;; the quantity of exchanged labor is equal to the consumer's labor supply
          let transactionValue  (firstWageC * transactionQuantity )   ;; the amount of money exchanged is equal to the product of the consumer's wage and the exchanged labor quantity 
         
           ask first sortedConsumersL [
             set cLabourRevenues (cLabourRevenues + transactionValue)  ;; we add the amount of exchanged money to the consumer's labor income
             set cLabour (cLabour + transactionQuantity)               ;; we add the labor given to this firm to the sum of labor given by this consumer
             set clabourSupply 0.                                      ;; this consumer is satisfied now
           ]
           set labourDemand (labourDemand - transactionQuantity)
           set sortedConsumersL but-first sortedConsumersL             ;; We drop this consumer, since she has been satisfied now 
         ]
 
  ]
    
  
;;  ask consumers [
;;    print ( word " consumer : " who " cLabourSupply " cLabourSupply " cLabourRevenues : " cLabourRevenues " cLabour : " cLabour )
;;    ]

set hiredLabour sum [cLabour] of consumers                                       
set labourCosts sum [cLabourRevenues] of consumers
set unemployment sum [cLabourSupply] of consumers   ;; rationed agregated labor supply of consumers
set unemploymentRate unemployment / nbConsumers
set wage (labourCosts / hiredLabour)


;; print (word " sumCLabour : " sumCLabour " RestCLabourSupply : " restCLabourSupply )


  
end



;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX



;; **** Mechanisms of the product market: ****
;; Assumes that each consumer has fixed desNomConsumption (determined by k and Pincome)
;; and that the firm has fixed its price (fprice)
to productMarket
  
;; print ( word " productMarket " )
  
;; print ( word " meanPrice : " priceLevel )
  
;; ask consumers [

;; print (word " consumer : " who " desNomConsumption : " desNomConsumption )

;; ]  
  
 set fullEmploymentLabour (fixedLabSupply * nbConsumers) 
 set potentialGDP (techLevel * (fullEmploymentLabour ^(1 - alpha)) )
 set potentialCConsumption (potentialGDP / nbConsumers)
 set potentialCUtility  utilityFunc   potentialCConsumption   ;; mean potential utility


                
 set output ( productionFunction techLevel hiredLabour ) ;; computation of the firm's production (by the production function)
 set goodSupply output
  ifelse ( output > 0 ) [ 
  set priceLevel (((labourCosts / output)  ) / (  (1 - alpha )) ) * ( 1 + mu) ;; firm applies a mark-up over the average/marginal cost (Dixit-Stiglitz)
  ]
  [
  set priceLevel oldMeanPrice
  ]
  
  ask consumers [     
   set nomConsumption 0.       ;;  before entering the goods market, the consumer cannot spend money on goods
   set realConsumption 0.      ;;  before entering the goods market, the consumer cannot consume
  ]
 

  ;;Sort consumers by decreasing demand
  let oconsumers sort consumers with [ desNomConsumption > 0.]      ;; Firts we create a list of consumers with positive nominal demand
  set sortedConsumersP sort-by [ [desNomConsumption] of ?1 >= [desNomConsumption] of ?2 ] oconsumers   ;; List of consumers, sorted by decreasing nominal demand
  
  
  ;;**********  Transactions ************
  
 ;; print (word " Product transactions " )
  
  while [(output > 0) AND (length sortedConsumersP > 0)] ;; Transactions are possible
  [
  
    let firstDemandP   0.
    let firstCIndex 1000
    
    let transactionQuantity 0.
    let transactionValue 0.

    ;; We question first consumer (the one with the highest nominal demand)  
    ask first sortedConsumersP [                
      set firstDemandP desNomConsumption   ;; We look at his desired nominal consumption (nominal demand)
      set firstCIndex who                  ;; We save his identity
      ]
 
 
 ;; A transaction is possible
        ;; We have 2 cases: Supply * price >= nominal demand -> The consumer can be fully served by this firm
                         ;; Supply * price < fnominal demand -> The consumer will not be fully served 
      ifelse ((output * priceLevel) >= firstDemandP)     ;; first case: supply * price >= nominal demand 
      [
           set transactionQuantity (firstDemandP / priceLevel ) ;; the quantity of goods exchanged is given by the ratio (nomial demand / firm's price)
           set transactionValue (firstDemandP )                  ;; the amount of exchanged money is equal to the consumer's nominal demand
           
           ask first sortedConsumersP [
               set realConsumption (realConsumption + transactionQuantity)  ;; We add the the quantity of exchanged goods to the sum of goods bought by this consumer
               set desNomConsumption 0.                                     ;; this consumers has spent all the amount of cash dedicated to consumption
           set nomConsumption ( nomConsumption + transactionValue )  
           ]
           
         
          set sortedConsumersP but-first sortedConsumersP           ;; We drop this consumer, since her has been satisfied now 
          set output (output - transactionQuantity)
          
      ]
      [ ;; The consumer can not be fully served by this firm but the firm can sell all her supply ( Supply * price < nominal demand)
         
           set transactionQuantity (output )                   ;; the quantity of goods exchanged is given by the firm's supply of goods
           set transactionValue ( priceLevel * output)  ;; the amount of exchanged money is given by the product of price and exchanged quantity of goods
           
           ask first sortedConsumersP [
               set realConsumption (realConsumption + transactionQuantity)  ;; We add the exchanged quantity to the sum of goods bought by this consumer
              set nomConsumption ( nomConsumption + transactionValue )     ;; We add the amount of exchanged money to the sum of consumer's nominal consumption
            set desNomConsumption (desNomConsumption - transactionValue)
            
             if ( desNomConsumption <= 0) [set sortedConsumersP but-first sortedConsumersP]     ;; We drop this consumer, because he has no more money dedicated to consumption
                                         ]
           set output 0
     ]
  
   ]

     
 ;;firms profits
  set sales (sum [nomConsumption] of consumers)
  set soldOutput sum [realConsumption] of consumers
  set GDP soldOutput
  set profit ( sales - labourCosts  )                 ;; computation of the firm's profit = turnover minus labor costs      
  
 
   set meanRealConsumption mean [realConsumption] of consumers                      ;; computation of mean real consumption
   
   ;;utility of the consumers and the update of their profits and Bonds
  ask consumers [
    set utility ( utilityFunc realConsumption )
    set performance (1 - rho) * utility + (rho * performance)                                    ;; computation of consumer's utility (utility function)
    set cProfits (profit / nbConsumers )                                       ;; computation of dividend flow from the production sector to each consumer 
    set cNomBonds (cNomBonds + desNomConsumption )                                                 ;; We add residual nominal demand (caused by rationing) to consumer's savings
    ]  


  set meanUtility mean [utility ] of consumers           ;; computation of mean utility


set infRate ((priceLevel - oldMeanPrice) / priceLevel)          ;; computation of the inflation rate

set meanNomBonds mean [cNomBonds] of consumers                          ;; computation of mean consumers' savings
set sumNomBonds sum [cNomBonds] of consumers
;set varNomBonds variance [cNomBonds] of consumers
;; print (word " sales : " sales " effectiveY : " effectiveY " meanPrice : " meanPrice " oldMeanPrice : " oldMeanPrice " infRate : " infRate )

   
;; ask consumers [

;; print (word " consumer : " who " realConsumption : " realConsumption " nomConsumption : " nomConsumption " desNomConsumption : " desNomConsumption " bonds : " bonds )

;; ]  
   
end


;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX



to labour-demand-updating

;; print (word "Labour demand updating ")

set smoothProfit ((1 - rho) * profit + (rho * smoothProfit) )
set labourDemand ( hiredLabour )
if (profit >= smoothProfit )  [ set labourDemand (labourDemand * ( 1 + epsilon) )]
if (profit < smoothProfit )  [ set labourDemand (labourDemand * ( 1 - epsilon) )]


end



;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

to computeWelfare

    set welfare  (sum [ utility ] of consumers)         ;; computation of the economy's mean utility
 
end


;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;; Learning of consumers through imitation of strategies and innovation
to consumers-learning

;; print ( word " Consumers Learning " )


;; ask consumers [

;; print (word " consumer : " who " cLabour : " cLabour " performance : " performance )
;;]


;; print (word " Learning process " )

;; ************ B) Learning of consumers: 
;; They must evolve their strategies (labour supply) through imitation and innovation (mutation)
;; The probability of being imitated for a consumer is proportional to its utility  share (use of the exponetial function in order to deal with negative utilities). 
;; We construct an array that represents the roulette wheel with which we will draw the imitated consumer in each imitation
let sumS 0.                        ;; Sum of the imitation criteria (exponential function of performance)
let cumulS []                   ;; list of the consumers' different labor supplies
let tmpgammak []
let tmpgammaw []
let oConsumers (sort consumers)    ;; list of consumers, sorted by their index

set meanCoeffSubst mean [coeffSubst] of consumers 
set meanCoeffWageUpdate mean [coeffWageUpdate] of consumers
set varCoeffSubst variance [coeffSubst] of consumers 
set varCoeffWageUpdate variance [coeffWageUpdate] of consumers

;; Just to use a list of consumers where we know the identity of each consumer in each slot
foreach oConsumers[ 
  ask ? [
    
    ;;Imitation via utility share
     set sumS (sumS + (1 * exp (performance)))       ;; We add the transformed performances of all consumers
    
    ;;Cumulating performances
    set cumulS lput sumS cumulS   
    set tmpgammak lput (coeffSubst) tmpgammak         ;; We put the quantities of labor "sold" by the different consumers into a list
    set tmpgammaw lput (coeffWageUpdate) tmpgammaw
  ]
]




foreach oConsumers [ 
  ask ? [
    if ( (sumS > 0.) AND (random-float 1. <= probImit) ) [             ;; Random draw :The consumer will be able to imitate a competitor
          
      ;;the firm on the area of which this arrow is sent will be imitated now 
      let indexImitator who                                                    ;; We learn the indetity of the consumer who can imitate
      
     ;;  print (word  "imitateur : " who " labour : " claboursupply )
       
      let indexImitated 0.                                                     ;; we want to know from whom he learns : we begin with the first consumer
      
      ;Now we draw the dart: a number between 0 and the last value of cumulS
      let randDraw random-float sumS ;; A number in [0,sumS[
      
      foreach cumulS [
        if ( ? < randDraw ) [set indexImitated (indexImitated + 1)]            ;; we sort-out consumers that are not imitated
      ]
      ;; Imitation of the strategies of indexImitated                    ;; We take the labor "sold" by the imitated consumer
      set coeffSubst (item indeximitated tmpgammak) 
      set coeffWageUpdate (item indeximitated tmpgammaw) 
  ;; print (word "imité : " indeximitated " labour : " claboursupply) 
    ]
   

   if (random-float 1. <= probMut) [        ;; Random draw : The consumer will be able to mutate his  labor supply strategy    
   
  ;;  print (word " consumer : " who " Labour Supply mutation ")
                     ;; mutation around the mean of sold labor of consumers (because this is an observable variable)
   set coeffSubst (mutatelevel meanCoeffSubst) 
   set coeffWageUpdate (mutatelevelW meanCoeffWageUpdate) 
    ]

  ]

 ]

;; ask consumers [

;; print (word " consumer : " who " cLabourSupply : " cLabourSupply ) 
;; ]

end



;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


to state-fix-intRate
 
 set oldIntrate intRate        ;; we save the value of the old interest Rate
 
 if infRate < -1 [set infRate -1]
 set intRate ( (1 + infTarget) * ((( 1 + infRate) / (1 + infTarget) ) ^ coeffInfRate ) * ((1 / (1 + unemploymentRate)) ^(coeffUnemp) )    ) - 1 
    
 if (intRate < 0.0) [set intRate 0.]                                                       ;; we respect the zero bound of nominal interests
 
 if intRate = 0  [set ZLB ZLB + 1]
  
 set outputGap (GDP - potentialGDP) / potentialGDP 
  
;; print ( word " prodSum : " prodSum " smoothGap : " smoothGap " effectiveY : " effectiveY " outputGap : " outputGap )

;;print ( word " infrate : " infRate " intRate : " oldIntRate " New interest rate : " intRate  " unemploymentRate :" unemploymentRate)

 set trendIntRate ((1 - rho) *  (intRate) + (rho *  trendIntRate ) )
 set trendInfRate ((1 - rho) *  (infRate) + (rho *  trendInfRate ) )

end 


;; ########################################################################################################################################"

to compute-aggregate-stat
  

;;;; evaluation of the monetary policy results (variability of inflation, production and output gap)
   
 if( ticks > 100 ) AND (ticks < nbPeriods - 1) ;;; define a time period to consider [Awindow, nbPeriods]

[ set xTable lput outputGap xtable  ;;;; save the values of output gap for the selected period
]

 if ticks = nbperiods - 1 [set varOutputGap variance xtable
                           set meanOutputGap mean xtable     ;;; at the end of the run, compute the variance of the output gap over the selected period
;print ( word "variance output gap : " Varx) 
]

   
 if( ticks > 100 ) AND (ticks < nbPeriods - 1) ;;; define a time period to consider [Awindow, nbPeriods]

[ set unempTable lput unemploymentRate unemptable  ;;;; save the values of output gap for the selected period
]

 if ticks = nbperiods - 1 [set varUnemp variance unemptable
                           set meanUnemp mean unemptable     ;;; at the end of the run, compute the variance of the output gap over the selected period
;print ( word "variance output gap : " Varx) 
]


  if( ticks > 100 ) AND (ticks < nbPeriods - 1) ;;; define a time period to consider [Awindow, nbPeriods]

[ set intTable lput intRate intTable  ;;;; save the values of output gap for the selected period
]

 if ticks = nbperiods - 1 [set varIntRate variance intTable
                           set meanIntRate mean intTable     ;;; at the end of the run, compute the variance of the output gap over the selected period
;print ( word "variance output gap : " Varx) 
]




if ( ticks > 100 ) AND (ticks < nbPeriods - 1) [ set infTable lput infRate infTable    ;;;; idem for the inflation rate  
]

if ticks = nbperiods - 1  [set varInfRate variance infTable
                           set meanInfRate mean infTable
;print ( word "variance inflation : " VarI )
] 



if ( ticks > 100) AND (ticks < nbPeriods - 1) [ set yTable lput GDP ytable  
]    ;;; idem for the effective output

if ticks = nbperiods - 1 [set varGDP variance ytable
                          set meanGDP mean ytable
;print (word " variance produit :" varY )
]


;if ( ticks > 100 ) AND (ticks < nbPeriods - 1 ) [ set pTable lput priceLevel ptable  
;]  

;if ticks = nbperiods - 1 [set varPriceLevel variance ptable

;print (word " variance price level :" varP )
;]

;;;;  evaluating convergence to REE


set bankrupttable lput bankrupt bankrupttable
if ticks = nbperiods - 1 [set SumBankrupt  sum bankrupttable]


end


;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx





;;=============  FUNCTIONS ===================================

;; Mutate a given strategy and report the mutated value
;; The new strategy is drawn from a normal law centered on the actual strategy, with a standard deviation of deviationMutate


to-report mutateLevel [strj]                                    ;; level of mutation in the firms' learning process. Comments: look to the firms' case
    let tempDeviation 0.
    set tempDeviation mutSpaceK
    let draw (random-normal strj tempDeviation)
    ;if draw < 0 [set draw 0.01] 
    report draw
end

to-report mutateLevelW [strj]                                    ;; level of mutation in the firms' learning process. Comments: look to the firms' case
    let tempDeviation 0.
    set tempDeviation mutSpaceW
    let draw (random-normal strj tempDeviation)
    if draw < 0 [set draw 0.01] 
    report draw
end

;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx



;; Mutate a given strategy and report the mutated value
;; The new strategy is drawn from a normal law centered on the actual strategy, with a standard deviation of deviationMutate
to-report mutateRate                  
    let draw random-float 1.          ;; random draw between 0 and 1.
   report draw
end


;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX



;;utility function of the consumers
;; utility can become negative if the consumer cannot buy enough goods in comparison with her labour supply
;to-report utilityFunc [consp work]                  ;; we take Gali's utility function (2008)
to-report utilityFunc [consp]
;report ((consp ^ (1 - sigma))/(1 - sigma)) -   ( work ^ (1 + phi))/(1 + phi)
ifelse (consp > 0.0001) [ report ln (consp )] [report -9]
 end

;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


 ;;production function of the firms
 to-report productionFunction [ftechl work]
   report ftechl * (work ^ (1 - alpha))
 end

;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


to do-saveResults          ;; we put observations into our excel file
  file-print (word  counterExperiment ";" actRun ";" ticks ";"nbconsumers  ";" probImit ";" probMut ";" initialization ";" expectations ";" stdDevNoise ";" mutSpaceW ";" mutSpaceK ";"
                      chi ";" mu ";" 
                    alpha ";"  coeffInfRate ";"   coeffUnemp ";" rho ";" initWealth ";" minCRate ";" maxCRate 
                    ";" techlevel ";" epsilon ";" inftarget ";" infRate ";" intRate ";" priceLevel ";" wage ";" labourCosts ";" hiredLabour ";" fixedLabSupply ";" bankrupt
                    ";" meanNomBonds ";" varNomBonds ";" goodSupply ";" meanPermIncome ";" unemploymentRate ";" outputgap ";" GDP ";" potentialGDP ";" ZLB ";" welfare ";"
                     meanCoeffSubst ";"meanCoeffWageUpdate
                    ";" meanConsumptionRate ";" varCoeffSubst ";" varCoeffWageUpdate ";" varConsumptionRate ";" meanGDP ";" varGDP ";" varPriceLevel ";" varOutputGap ";"
                     meanOutputGap ";" meanInfRate
                    ";" varInfRate ";" meanInfExpect ";" varInfexpect ";" varIntRate ";" meanIntRate ";" potentialCConsumption ";"potentialCUtility ";"sumBankrupt ";" varUnemp
                     ";" meanUnemp)
 
 end


;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


to doplots                        ;; here we command the plots of the interface

  set-current-plot "LabourMarket"
  set-current-plot-pen "LabourDemand"
  plot  labourDemand
  set-current-plot-pen "labourHired"
  plot  hiredlabour
  set-current-plot-pen "Heq"
  plot fullEmploymentLabour

  
  set-current-plot "Profits"
  set-current-plot-pen "meanProfit"
  plot profit 
  set-current-plot-pen "zero"
  plot 0.
  
  set-current-plot "consumers strategies"
  set-current-plot-pen "k"
  plot meanConsumptionRate 
  set-current-plot-pen "gammaw"
  plot meanCoeffWageUpdate
  set-current-plot-pen "gammak"
  plot meanCoeffSubst 
  set-current-plot-pen "zero"
  plot 0.
  set-current-plot-pen "one"
  plot 1.  
  
  set-current-plot "monetary policy"
  set-current-plot-pen "intRate"
  plot intRate 
  set-current-plot-pen "infTarget"
  plot infTarget
  set-current-plot-pen "infRate"    
  plot infRate
  set-current-plot-pen "trendinf"
 ; ifelse ticks > 10 [    
 ;  plot trendInfRate
 ;  ]
 ;  [
 ;  plot 0.
 ;  ]
  set-current-plot-pen "zero"
  plot 0.
  ;set-current-plot-pen "meanInfExpect"
  ;plot meanInfExpect
 
  set-current-plot "economic situation"
  set-current-plot-pen "outputGap"
  plot outputGap
  set-current-plot-pen "unEmpRate"
  plot unemploymentRate
  set-current-plot-pen "zero"
  plot 0.
  
  
  set-current-plot "nominal Bonds"
  set-current-plot-pen "meanBonds"
  plot meanNomBonds 
  set-current-plot-pen "bankrupt"
  plot bankrupt

  set-current-plot "price dynamics"
  set-current-plot-pen "meanPrice"
  plot priceLevel     
 ; set-current-plot-pen "labourCosts"
 ; plot labourCosts  
  set-current-plot-pen "meanWage"
  plot  wage  
  
  set-current-plot "good market"
  set-current-plot-pen "effectiveY"
  plot GDP
  set-current-plot-pen "supplyY"
  plot goodSupply 
  set-current-plot-pen "Yeq"
  plot potentialGDP 
  
  set-current-plot "utility"
  set-current-plot-pen "utility"
  plot meanUtility  
  set-current-plot-pen "UeqC"
  plot potentialCUtility
  
  
end


;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

to read-experiment-data 
    
set experimentData []
let xdata user-file
let dataline 0
file-open xdata
while [not file-at-end?] [
  set dataline (word "[" file-read-line "]")
  set experimentData lput read-from-string dataline experimentData
] 
file-close
set nbExperiments length experimentData
;print (word " * " nbExperiments " experiments to run")
;print length experiments
;print length item 0 experiments

end


;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

to read-experiment [indexExp]
 let data item indexExp experimentData
 
;  set alpha item 0 data
if item 0 data = 0 [ set probImit 0.05
                     set probMut 0.01]
if item 0 data = 1 [ set probImit 0.1
                     set probMut 0.05]
if item 0 data = 2 [ set probImit 0.15
                     set probMut 0.1]

 set rho  ((item 1 data) / 2.2)
 set mutSpaceK  item 2 data
 set mutSpaceW  item 3 data
 set coeffInfRate  item 4 data
 set coeffUnemp  item 5 data
 ifelse expectations = "combi" [set chi item 6 data] [set stdDevNoise (item 6 data) / 1000] 

 set alpha 0.25
 set inftarget 0.02 
 set epsilon 0.01
 set initWealth  10
 set minCRate  0.5
 set maxCRate  1.5
 set mu 0.1   ;;  Woodford Rotemberg 11 -> 10%
 set nbConsumers 500
end


;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX



to randomizeVariables    ;; in Monte Carlo experiments, we want to make vary some parameters

 set nbConsumers 500  ;; Number of consumers in the economy  <- Interface
 
 ;;set taxWindow      ;; Number of periods before the State raises tax in case of excess imdebtness  (initial time of model stabilization)
 ;; infWindow      ;; Number of periods taken into account to compute the inflation rate

; set mu 0 + random-float 0.2       ;; variable of firms' market power
; set alpha  0 + random-float 0.5        ;; variable of the production function (rate of return) 
; set initWealth 1 + random-float 9
; set minCRate 0.1 + random-float 0.8             ;; lower bound of consumption rate 
; set maxCRate 1.1 + random-float 0.9              ;; upper bound of consumption rate 
; set rho 0 + random-float 0.9   ;; coefficient ofr the moving average computations
; set infTarget 0 + random-float 0.05  
; set epsilon 0.01 + random-float 0.04 
; set probImit 0.05 + random-float 0.25
; set probMut 0.01 + random-float 0.09
; set mutSpace  0.01 + random-float 0.49
; set coeffInfRate 0 + random-float 3
; set coeffUnemp 0 + random-float 2
  
end


;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;; Resets globals between simulations;;  
to resetOtherGlobals  ;; here, we set some invariable parameters 
  

;********************* Variables ***********************************
 set labourDemand 0 + random-float (nbConsumers * 0.5)
 set priceLevel 1
 set meanCoeffSubst  0.5
 set meanCoeffWageUpdate 1
 set varConsumptionRate 0
 
  
 set  infRate      0     ;; inflation rate (based on evolution of "meanPrice")
 set  intRate      0      ;; nominal interest rate (fixed by the central bank)
 set  oldIntRate   0   ;; last period's nominal interest rate
 set  trendIntRate 0    ;; moving average of the interest rate
 set  trendInfRate 0    ;; idem for inflation rate

 set  bankrupt     0  ;; number of agents who go bankrupt each period
 set  bankrupttable  []    ;; table for global computation
 set  Sumbankrupt  0     ;; number of agents who went bankruptcy in the whole run
  
 set   soldOutput 0
 set  goodSupply  0
 set  hiredLabour 0
 set  labourCosts 0
 set  output 0
 set  sales 0             
 set  GDP 0
 set  profit 0
 set  unemployment 0  
 set  sumNomBonds 0
 set  priceLevel     1    ;; weighted mean price of goods (weigthed by sold quantities)
 set  oldMeanPrice  1    ;; last period's mean price
 set  meanPermIncome   0    ;; mean permanent income of consumers
 set  meanNomBonds    0     ;; mean savings of cunsumers (nominal variable)
 set  meanConsumptionRate 0  
   
 set  sumLabSupply   0           ;; total labor quantity at equilibrium

 set   outputGap 0

 set  techLevel  1    ;; factor of the production function (technology level)
 set  ZLB 0
 set  unemploymentRate 0
 set  welfare     0      ;; sum of consumers utility
 set  meanrealConsumption 0 ;; mean of consumers' real consumption
 set  sumCLabour  0         ;; sum of consumers' labor
 
 set varCoeffSubst 0
 set varCoeffWageUpdate 0
 set varNomBonds 0
 set meanGDP 0
 set  varGDP 0
 set  varPriceLevel 0
 set  varOutputGap 0
 set varPermIncome 0
 set meanInfExpect 0
 set varInfExpect 0
 set  trendRealIntRate 0
 set meanUnemp 0
 set varUnemp 0
 set  meanOutputGap 0
 set  meanInfRate 0
 set  varInfRate 0
 set  varIntRate 0
 set  meanIntRate 0
 set  wage  1               ;; weigthed mean wage of firms (weigthed by labor costs associated to an individual firm's wage)
 set meanUtility   0       ;; mean of consumers' utility

;********************* Computational tricks ***********************************
 
 set sortedConsumersL []  ;; Labour market list of consumers (sorted by decreasing labour offer)
 set sortedConsumersP [] ;; Product market list of consumers (sorted by decreasing good demand)

 set smoothProfit 0
 
 set infTable  []      ;; table of past inflation observations (used to compute annual inflation (trendinf))
 set infSum 0               ;; sum of past inflation observations (used to compute annual inflation (trendinf))
 set flexiblePrice true
 set xtable []
 set intTable []
 set pTable []
 set yTable []
 set unempTable []
 
 set fixedLabSupply 1

 
end





@#$#@#$#@
GRAPHICS-WINDOW
167
37
331
222
-1
-1
4.67
1
10
1
1
1
0
1
1
1
0
32
0
32
1
1
1
ticks

TEXTBOX
61
10
437
619
Note :
11
9.9
0

INPUTBOX
320
254
391
314
nbPeriods
1000
1
0
Number

BUTTON
329
165
392
198
Go!
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SWITCH
202
165
298
198
saveResults
saveResults
0
1
-1000

INPUTBOX
248
254
321
314
fileName
IT4config35.xls
1
0
String

INPUTBOX
331
313
391
373
nbRun
10
1
0
Number

BUTTON
277
125
389
158
NIL
randomizeVariables
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

INPUTBOX
267
313
333
373
nbExperiments
17
1
0
Number

PLOT
396
10
693
160
LabourMarket
NIL
NIL
0.0
50.0
0.0
500.0
true
true
PENS
"labourHired" 1.0 0 -16777216 true
"LabourDemand" 1.0 0 -13345367 true
"Heq" 1.0 0 -2674135 true

SLIDER
-1
138
194
171
probImit
probImit
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
-3
170
196
203
probMut
probMut
0
0.5
0.05
0.01
1
NIL
HORIZONTAL

PLOT
693
10
1012
160
monetary policy
NIL
NIL
0.0
1000.0
-0.15
0.15
false
true
PENS
"infRate" 1.0 0 -16777216 true
"trendinf" 1.0 0 -2674135 true
"inftarget" 1.0 0 -8630108 true
"intRate" 1.0 0 -955883 true
"zero" 1.0 0 -1184463 true
"meanInfExpect" 1.0 0 -2064490 true

PLOT
395
160
695
319
nominal Bonds
NIL
NIL
0.0
10.0
-0.1
10.0
true
true
PENS
"meanBonds" 1.0 0 -16777216 true
"debt" 1.0 0 -8630108 true
"transfert" 1.0 0 -2674135 true
"bankrupt" 1.0 0 -10899396 true

PLOT
695
159
1012
319
price dynamics
NIL
NIL
0.0
10.0
0.0
10.0
true
true
PENS
"meanPrice" 1.0 0 -16777216 true
"labourCosts" 1.0 0 -13345367 true
"meanWage" 1.0 0 -2674135 true

PLOT
393
319
695
473
good market
NIL
NIL
0.0
10.0
-1.0
1.0
true
true
PENS
"effectiveY" 1.0 0 -16777216 true
"supplyY" 1.0 0 -13345367 true
"Yeq" 1.0 0 -8630108 true

PLOT
393
474
695
624
consumers strategies
NIL
NIL
0.0
40.0
0.9
1.2
true
true
PENS
"k" 1.0 0 -16777216 true
"zero" 1.0 0 -8630108 true
"gammak" 1.0 0 -13345367 true
"gammaw" 1.0 0 -2064490 true
"one" 1.0 0 -8630108 true

PLOT
695
319
1012
473
utility
NIL
NIL
0.0
10.0
-1.0
1.0
true
true
PENS
"utility" 1.0 0 -16777216 true
"UeqC" 1.0 0 -13345367 true

PLOT
9
420
393
626
economic situation
NIL
NIL
0.0
10.0
0.0
1.0
true
true
PENS
"outputGap" 1.0 0 -16777216 true
"zero" 1.0 0 -2674135 true
"unempRate" 1.0 0 -13345367 true

PLOT
695
474
1011
624
Profits
NIL
NIL
0.0
10.0
0.0
1.0
true
true
PENS
"meanProfit" 1.0 0 -16777216 true
"zero" 1.0 0 -2064490 true

BUTTON
329
209
391
242
NIL
file-close
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

INPUTBOX
194
253
250
313
freqSave
50
1
0
Number

INPUTBOX
193
313
269
373
nbConsumers
500
1
0
Number

SLIDER
-1
236
195
269
mutSpaceW
mutSpaceW
0
1
0.07
0.01
1
NIL
HORIZONTAL

SLIDER
-1
105
194
138
alpha
alpha
0
0.99
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
-2
365
193
398
infTarget
infTarget
0
0.2
0.02
0.001
1
NIL
HORIZONTAL

SLIDER
191
10
395
43
coeffInfRate
coeffInfRate
0
4
0.4
0.1
1
NIL
HORIZONTAL

SLIDER
190
43
393
76
coeffUnemp
coeffUnemp
0
4
0.4
0.1
1
NIL
HORIZONTAL

CHOOSER
288
79
383
124
initialization
initialization
"random" "nolh" "user"
1

CHOOSER
202
199
313
244
expectations
expectations
"trend" "misPublicTarget" "misPrivateTarget" "onTarget" "combi"
2

SLIDER
-2
73
194
106
epsilon
epsilon
0
0.15
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
-2
203
195
236
rho
rho
0
1
0
0.01
1
NIL
HORIZONTAL

SLIDER
-1
41
192
74
initWealth
initWealth
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
1
10
191
43
stdDevNoise
stdDevNoise
0
0.2
0.033
0.01
1
NIL
HORIZONTAL

MONITOR
217
374
335
419
NIL
counterExperiment\n
17
1
11

MONITOR
335
374
392
419
NIL
actRun\n
17
1
11

SLIDER
0
271
194
304
mutSpaceK
mutSpaceK
0
0.5
0.14
0.01
1
NIL
HORIZONTAL

SLIDER
-1
308
192
341
chi
chi
0
1
0.4
0.1
1
NIL
HORIZONTAL

@#$#@#$#@
WHAT IS IT?
-----------
A simple NK model of learning firms and consumers


HOW IT WORKS
------------

1/ Adjust the parameters as you desire<BR>
2/ Click Setup<BR>
3/ Click Go and observe the evolution of different indicators.



HOW TO USE IT
-------------



THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment1" repetitions="1" runMetricsEveryStep="false">
    <setup>set actRun (actRun + 1)
setup</setup>
    <go>go</go>
    <final>file-close</final>
    <steppedValueSet variable="deviationMutate" first="0.1" step="0.5" last="5"/>
    <steppedValueSet variable="probImitate" first="0.03" step="0.03" last="0.3"/>
    <steppedValueSet variable="probMutate" first="0.03" step="0.03" last="0.3"/>
    <enumeratedValueSet variable="nbPeriods">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="saveProb">
      <value value="0.05"/>
    </enumeratedValueSet>
    <steppedValueSet variable="coeffY" first="0.1" step="0.1" last="1"/>
    <steppedValueSet variable="coeffInfRate" first="0.1" step="0.1" last="1"/>
    <enumeratedValueSet variable="potentialWindow">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="saveResults">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CentralBankRate">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="techLevel">
      <value value="1"/>
      <value value="0.5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wage">
      <value value="1"/>
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment2" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <enumeratedValueSet variable="nbRun">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbSimul">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fileName">
      <value value="&quot;results-mc.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbPeriods">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="saveResults">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbFirms">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbConsumers">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="saveProb">
      <value value="0.0050"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
