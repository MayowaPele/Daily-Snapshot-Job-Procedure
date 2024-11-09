USE [IInvestDB_LIVE_Extension]
GO
/****** Object:  StoredProcedure [dbo].[usp_CustomerDailySnapshots]    Script Date: 11/9/2024 5:25:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,Mayowa Pelemo>
-- Create/Edit date: <Create Date,06/APRIL/2022>
-- Description:	<Description,Customer Daily Snapshots>
-- =============================================
ALTER PROCEDURE [dbo].[usp_CustomerDailySnapshots] 
--exec [dbo].[usp_CustomerDailySnapshots] 
as
begin 
Insert into  [IInvestDB_LIVE_Extension].[dbo].[indvDailySnaps] ([CustomerUniqueId],[DateOfCaputre],[NGN_Cash],[USD_Cash],[TbillsPortfolio]
      ,[FixedDepositPortfolio],[CommercialPapersPortfolio],[EquitiesPortfolio],[EurobondPortFolio], [savingsPortfolio], [USD_FDPortfolio],[EthicalInvestmentsPortfolio],MutualFundsPortfolio)
select CustomerUniqueId, getdate() DateOfCaputre,
(select Sum (CashBalance) from [IInvestDB_LIVE].[dbo].Wallets where Customers.CustomerId = Wallets.CustomerId group by CustomerId having 
count (CustomerId)>=1) NGN_Cash,
(select Sum(isnull(CashBalance,0)) from [IInvestDB_LIVE].[dbo].DollarWallets where Customers.CustomerId = 
DollarWallets.CustomerId group by CustomerId having count (CustomerId)>=1) USD_Cash,
(select sum(isnull(TBillsTrades.CurrentBalance,0)) from [IInvestDB_LIVE].[dbo].TBillsTrades where Customers.CustomerId = 
TBillsTrades.CustomerId group by CustomerId, TradeTypeID having 
count (CustomerId)>=1 and TradeTypeID = 1) TbillsPortfolio,
(select sum (CurrentBalance) from [IInvestDB_LIVE].[dbo].FixedDepositTrades where Customers.CustomerId = 
FixedDepositTrades.CustomerId group by CustomerId, TradeTypeID having 
count (CustomerId)>=1 and TradeTypeID = 1) FixedDepositPortfolio 
,(select sum (CommercialPaperTrades.CurrentBalance) from [IInvestDB_LIVE].[dbo].CommercialPaperTrades where Customers.CustomerId = 
CommercialPaperTrades.CustomerId group by CustomerId having 
count (CustomerId)>=1) CommercialPapersPortfolio 
,(select sum (AggregatePurchaseValue) from [IInvestDB_LIVE].[dbo].EquityPortfolios where Customers.CustomerId = 
EquityPortfolios.CustomerId group by CustomerId having 
count (CustomerId)>=1 ) EquitiesPortfolio,
(select sum (EuroBondTrades.CurrentBalance) from [IInvestDB_LIVE].[dbo].EuroBondTrades where Customers.CustomerId = 
EuroBondTrades.CustomerId group by CustomerId,TradeTypeID having 
count (CustomerId)>=1 and TradeTypeID = 1) EurobondPortFolio,
(select sum (SavingsPlans.AccruedPrincipal) from [IInvestDB_LIVE].[dbo].SavingsPlans where Customers.CustomerId = 
SavingsPlans.CustomerId group by CustomerId,status having 
count (CustomerId)>=1 and status = 'Active') savingsPortfolio,
(select sum (CurrentBalance) from [IInvestDB_LIVE].[dbo].USDFixedDepositTrades where Customers.CustomerId = 
USDFixedDepositTrades.CustomerId group by CustomerId, TradeTypeID having 
count (CustomerId)>=1 and TradeTypeID = 1) USD_FDPortfolio,
(select sum (a.CurrentBalance) from [IInvestDB_LIVE].[dbo].EthicalInvestmentTrades a where Customers.CustomerId = 
a.CustomerId group by CustomerId,TradeTypeID having 
count (CustomerId)>=1 and TradeTypeID = 1) EthicalInvestmentsPortfolio,
(select sum (a.Currentvalue) from [IInvestDB_LIVE].[dbo].CustomerMutualFundPortfolios a where Customers.CustomerId = 
a.CustomerId group by CustomerId having 
count (CustomerId)>=1) MutualFundsPortfolio
from [IInvestDB_LIVE].[dbo].customers
--where cast(datecreated as date) <= '2022-08-26'
order by 1
End	
