# -*- coding: utf-8 -*-
"""
Project for course Quantitative Methods in Finance, Prof. Eric Vansteenberghe.
Université Paris 1 Panthéon-Sorbonne
Program: Master 2 Financial Economics, 2017.
Authors: João Dimas (joaohenriqueavila@gmail.com) and Umberto Collodel (umberto.collodel@gmail.com)

Replication of an agent-based model described in:
Salle, I., Yıldızoğlu, M., & Sénégas, M.-A. (2013). Inflation targeting in a learning economy: An ABM perspective. Economic Modelling, 34, 114–128.
"""
class PeriodData:
    
    @classmethod
    def getCurrentPeriodData(cls, economy):
        return [
                economy.labourMarket.getUnemploymentRate(),
                economy.goodsMarket.getCurrentInflation(),
                economy.goodsMarket.currentPrice,
                economy.centralBank.getNominalInterestRate(),
                economy.firm.getProduction(),
                economy.labourMarket.aggregateHiredLabour,
                economy.firm.getTotalCost(),
                economy.goodsMarket.aggregateSoldGoods,
                economy.labourMarket.getRealWageRate()                
                ]
        
    @classmethod
    def getHeader(cls):
        return ["unemployment_rate", "inflation_rate", "price_level", "nominal_interest_rate", "production", "selling_price", "hired_labour", "total_cost", "goods_sold", "real_wage_rate"]