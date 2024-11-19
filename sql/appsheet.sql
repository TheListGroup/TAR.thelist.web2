IF([Quotation_ID]<=MAX(Quotation[Quotation_ID])
        ,[Quotation_NO.]
        ,CONCATENATE([Quotation_Type],TEXT(TODAY(), "YYMM"),"-",
            RIGHT("00" & (NUMBER(MID(SELECT(Quotation[Quotation_No.],[Quotation_ID] = INDEX(SORT(FILTER("Quotation",LEFT([Quotation_No.],6)=CONCATENATE([_THISROW].[Quotation_Type],
            TEXT(TODAY(), "YYMM"))), TRUE), 1)),8,2))+1),2)))


IF([Service] <> "SSBP"
    , IF([Discount]="Percent"
        , -([Cost]*[Percent])
        , IF([Discount]="Amount"
            , -([Price_Discount])
            , 0))
    , IF([Discount]="Percent"
        , -([Boost]*[Percent])
        , IF([Discount]="Amount"
            , -([Price_Discount])
            , 0)))



IF(AND(LEN([Quotation_NO.])=9,[Other Quotation]="YES")
    , CONCATENATE(LEFT([_THISROW].[Quotation_NO.],9),"-"
        , RIGHT("00" & (NUMBER(MID(SELECT(Quotation[Quotation_No.],[Quotation_ID] = INDEX(SORT(FILTER("Quotation",LEFT([Quotation_NO.],9)=LEFT([_THISROW].[Quotation_NO.],9)), TRUE), 1)),11,2))+1),2))
    , IF([Quotation_ID]<=MAX(Quotation[Quotation_ID])
        , [Quotation_NO.]
        , CONCATENATE([Quotation_Type],TEXT(TODAY(), "YYMM"),"-",
            RIGHT("00" & (NUMBER(MID(SELECT(Quotation[Quotation_No.],[Quotation_ID] = INDEX(ORDERBY(FILTER("Quotation",(LEFT([Quotation_No.],6)=CONCATENATE([_THISROW].[Quotation_Type],
            TEXT(TODAY(), "YYMM")))), LEFT([Quotation_No.],9),TRUE), 1)),8,2))+1),2))))


<<_ATTACHMENTFILE_URL>>
<<_ATTACHMENTFILE_WEB_LINK>> xxx <<_NOW>> yyy <<_USEREMAIL>>


    IF(COUNT(SELECT(Service_Detail[ID], [Quotation_ID] = [_THISROW].[Quotation_ID])) > 1," ",
    CONCATENATE("a","
    
    
    
    ","a")
)


SUM(SELECT(Service_Detail[Total_Amount],[Quotation_ID.]=[_THISROW].[Quotation_ID]))
SUM(SELECT(Service_Detail[Discount_Amount],[Quotation_ID.]=[_THISROW].[Quotation_ID]))
([Cost]+[Discount])*7/100
[Cost]+[VAT]+[Discount]
[Percent Paid] * [Amount]
[Percent Paid2] * [Amount]



CONCATENATE([Quotation_Type],TEXT(TODAY(), "YYMM"),"-",
            RIGHT("00" & (NUMBER(MID(SELECT(Quotation[Quotation_No.],[Quotation_ID] = INDEX(ORDERBY(FILTER("Quotation",(LEFT([Quotation_No.],6)=CONCATENATE([_THISROW].[Quotation_Type],
            TEXT(TODAY(), "YYMM")))), LEFT([Quotation_No.],9),TRUE), 1)),8,2))+1),2))



concatenate(text([Quotation_Date],"DD"),"-"
    ,SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(text([Quotation_Date],"M"),12,"Dec"),11,"Nov"),10,"Oct"),9,"Sep"),8,"Aug"),7,"Jul"),6,"Jun"),5,"May"),4,"Apr"),3,"Mar"),2,"Feb"),1,"Jan")
    ,"-",text([Quotation_Date],"YYYY"))




IF(TEXT(TODAY(), "YY") = "24"
    , CONCATENATE("RTX",NUMBER(TEXT(TODAY(), "YY"))+43,RIGHT("000" & (NUMBER(RIGHT(SELECT(Receipt[Receipt_No.],[Receipt_ID] = INDEX(ORDERBY(FILTER("Receipt",MID([Receipt_No.],4,2)=NUMBER(TEXT(TODAY(), "YY"))+43),RIGHT([Receipt_No.],3),TRUE),1)),3))+1),3))
    , CONCATENATE("RTX",TEXT(TODAY(), "YY"),RIGHT("000" & (NUMBER(RIGHT(SELECT(Receipt[Receipt_No.],[Receipt_ID] = INDEX(ORDERBY(FILTER("Receipt",MID([Receipt_No.],4,2)=NUMBER(TEXT(TODAY(), "YY"))+43),RIGHT([Receipt_No.],3),TRUE),1)),3))+1),3)))


IF(TEXT(TODAY(), "YY") = "24"
    , CONCATENATE("RIV",NUMBER(TEXT(TODAY(), "YY"))+43,RIGHT("000" & (NUMBER(RIGHT(SELECT(Invoice[Invoice_No.],[Invoice_ID] = INDEX(ORDERBY(FILTER("Invoice",MID([Invoice_No.],4,2)=NUMBER(TEXT(TODAY(), "YY"))+43),RIGHT([Invoice_No.],3),TRUE),1)),3))+1),3))
    , CONCATENATE("RIV",TEXT(TODAY(), "YY"),RIGHT("000" & (NUMBER(RIGHT(SELECT(Invoice[Invoice_No.],[Invoice_ID] = INDEX(ORDERBY(FILTER("Invoice",MID([Invoice_No.],4,2)=NUMBER(TEXT(TODAY(), "YY"))+43),RIGHT([Invoice_No.],3),TRUE),1)),3))+1),3)))


SELECT(Invoice[Invoice Date],[Invoice_ID] = INDEX(ORDERBY(FILTER("Invoice",[Quotation_ID]=[_THISROW].[Quotation_ID]),[Invoice_Date],TRUE),1))


lookup(lookup([_thisrow].[Quotation_ID],"Invoice","Quotation_ID","Invoice_ID"),"Receipt","Invoice_ID","Max Date")

SELECT(Receipt[Receipt Date],[Receipt_ID] = INDEX(ORDERBY(FILTER("Receipt",[Quotation_NO]=[_THISROW].[Quotation_NO]),[Receipt_Date],TRUE),1))