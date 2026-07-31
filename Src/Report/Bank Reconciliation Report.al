report 50117 BankRecStatementSqBase
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Bank Reconciliation';
    DefaultLayout = RDLC;
    RDLCLayout = 'Src/Report/Layouts/Bank Reconcilation.rdl';
    dataset
    {
        dataitem("Bank Acc. Reconciliation"; "Bank Acc. Reconciliation")
        {
            RequestFilterFields = "Statement Type", "Bank Account No.", "Statement No.";
            column(Bank_Account_No_; "Bank Account No.")
            {
            }
            column(Bank_Account_Name; "Bank Account Name")
            {
            }
            column(Statement_No_; "Statement No.")
            {
            }
            column(Ending_Date; "Statement Date")
            {
            }
            column(Balance_Last_Statement; "Balance Last Statement")
            {
            }
            column(RunningBalance; RunningBalance)
            {
            }
            column(RunningBalance2; RunningBalance2)
            {
            }
            column(Statement_Ending_Balance; "Statement Ending Balance")
            {
            }
            column(Starting_Date; StartingDate)
            {
            }
            column(BankAccountRefNo; BankAccountRefNo)
            {
            }
            column(CompanyName; CompanyInfo.Name)
            {
            }
            column(CompanyLogo; CompanyInfo.Picture)
            {
            }
            dataitem(BankAccLedUnpresentedCheq; "Bank Account Ledger Entry")
            {
                DataItemLink = "Bank Account No." = field("Bank Account No.");
                DataItemTableView = where(Amount = filter(< 0), "Statement Status" = const(Open));
                column(UnpreCheqDocNo; BankAccLedUnpresentedCheq."Document No.")
                {
                }
                column(UnpreCheqExtDocNo; BankAccLedUnpresentedCheq."External Document No.")
                {
                }
                column(UnpreCheqDate; BankAccLedUnpresentedCheq."Posting Date")
                {
                }
                // column(UnpreCheqPayee; BankAccLedUnpresentedCheq.PayeeNameChqMgt)
                // {
                // }
                column(UnpreCheqDescription; BankAccLedUnpresentedCheq.Description)
                {
                }
                column(UnpreCheqLKRAmount; Abs(BankAccLedUnpresentedCheq."Amount (LCY)"))
                {
                }
                column(UnpreCheqAmount; Abs(BankAccLedUnpresentedCheq.Amount))
                {
                }
                trigger OnPreDataItem()
                begin
                    SetFilter("Posting Date", '<=%1', "Bank Acc. Reconciliation"."Statement Date");
                    //SetFilter("Posting Date", '%1..%2', CalcDate('<-1D>', StartingDate), "Bank Acc. Reconciliation"."Statement Date"); // VI
                end;

            }
            dataitem(BankAccLedUnRealisedDep; "Bank Account Ledger Entry")
            {
                DataItemLink = "Bank Account No." = field("Bank Account No.");
                DataItemTableView = where(Amount = filter(> 0), "Statement Status" = const(Open));
                column(UnrealizedDepDocNo; BankAccLedUnRealisedDep."Document No.")
                {
                }
                column(UnrealizedDepExtDocNo; BankAccLedUnRealisedDep."External Document No.")
                {
                }
                column(UnrealizedDepDate; BankAccLedUnRealisedDep."Posting Date")
                {
                }
                // column(UnrealizedDepPayee; BankAccLedUnRealisedDep.PayeeNameChqMgt)
                // {
                // }
                column(UnrealizedDepDescription; BankAccLedUnRealisedDep.Description)
                {
                }
                column(UnrealizedDepLKRAmount; BankAccLedUnRealisedDep."Amount (LCY)")
                {
                }
                column(UnrealizedDepAmount; BankAccLedUnRealisedDep.Amount)
                {
                }
                trigger OnPreDataItem()
                begin
                    SetFilter("Posting Date", '<=%1', "Bank Acc. Reconciliation"."Statement Date");
                    //SetFilter("Posting Date", '%1..%2', CalcDate('<-1D>', StartingDate), "Bank Acc. Reconciliation"."Statement Date"); // VI
                end;

            }
            dataitem(BankAccLedEntryReciept; "Bank Account Ledger Entry")
            {
                DataItemLink = "Bank Account No." = field("Bank Account No.");
                DataItemTableView = where(Amount = filter(> 0), Open = const(true), Reversed = const(false));
                column(Reciepts; BankAccLedEntryReciept.Amount)
                {
                }
                trigger OnPreDataItem()
                begin
                    //SetFilter("Posting Date", '<=%1', "Bank Acc. Reconciliation"."Statement Date");
                    //SetFilter("Posting Date", '%1..%2', CalcDate('<-1D>', StartingDate), "Bank Acc. Reconciliation"."Statement Date"); // VI
                    SetFilter("Posting Date", '%1..%2', StartingDate, "Bank Acc. Reconciliation"."Statement Date"); // VI
                end;
            }
            dataitem(BankAccLedEntryPayment; "Bank Account Ledger Entry")
            {
                DataItemLink = "Bank Account No." = field("Bank Account No.");
                DataItemTableView = where(Amount = filter(< 0), Open = const(true), Reversed = const(false));
                column(Payments; Abs(BankAccLedEntryPayment.Amount))
                {
                }
                trigger OnPreDataItem()
                begin
                    //SetFilter("Posting Date", '<=%1', "Bank Acc. Reconciliation"."Statement Date");
                    //SetFilter("Posting Date", '%1..%2', CalcDate('<-1D>', StartingDate), "Bank Acc. Reconciliation"."Statement Date"); // VI
                    SetFilter("Posting Date", '%1..%2', StartingDate, "Bank Acc. Reconciliation"."Statement Date"); // VI
                end;
            }

            trigger OnAfterGetRecord()
            var
                BankAccStatement: Record "Bank Account Statement";
                BankAccStatement2: Record "Bank Account Statement"; // VI 1883
                BankAccount: Record "Bank Account";

                BankAccountLedgerEntry, GetRunnBankAccountLedgerEntry : Record "Bank Account Ledger Entry";
                CalcRunningAccBalance: Codeunit "Calc. Running Acc. Balance";

            begin
                BankAccStatement.Reset();
                Clear(StartingDate);
                BankAccStatement.SetCurrentKey("Statement Date");//Damidu(+) 1531
                BankAccStatement.SetRange("Bank Account No.", "Bank Acc. Reconciliation"."Bank Account No.");
                if BankAccStatement.FindLast() then begin
                    StartingDate := CalcDate('<+1D>', BankAccStatement."Statement Date");//Damidu(+) 1531
                end else
                    StartingDate := "Bank Acc. Reconciliation"."Statement Date";
                if BankAccount.Get("Bank Account No.") then
                    BankAccountRefNo := BankAccount."Bank Account No.";


                BankAccountLedgerEntry.Reset();
                BankAccountLedgerEntry.SetCurrentKey("Entry No.");
                BankAccountLedgerEntry.SetRange("Bank Account No.", "Bank Acc. Reconciliation"."Bank Account No.");

                if BankAccountLedgerEntry.FindLast() then
                    RunningBalance := CalcRunningAccBalance.GetBankAccBalance(BankAccountLedgerEntry);

                // BankAccStatement2.Reset();
                // BankAccStatement2.SetCurrentKey("Statement Date");
                // BankAccStatement2.SetRange("Bank Account No.", "Bank Acc. Reconciliation"."Bank Account No.");
                // if BankAccStatement2.FindLast() then
                //     //RunningBalance2 := BankAccStatement2."Balance Last Statement";
                //     if BankAccount."Currency Code" <> '' then
                //         RunningBalance2 := BankAccStatement2."Statement Ending Balance" // VI 2553
                //     else
                //         RunningBalance2 := BankAccStatement2."G/L Balance at Posting Date"; // VI 1883 New 


                Clear(RunningBalance2);
                GetRunnBankAccountLedgerEntry.SetCurrentKey("Posting Date");
                GetRunnBankAccountLedgerEntry.SetRange("Posting Date", 0D, CalcDate('<-1D>', StartingDate));
                GetRunnBankAccountLedgerEntry.SetRange("Bank Account No.", "Bank Account No.");
                if GetRunnBankAccountLedgerEntry.FindLast() then
                    RunningBalance2 := CalcRunningAccBalance.GetBankAccBalance(GetRunnBankAccountLedgerEntry);
            end;
        }
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    var
        StartingDate: Date;
        BankAccountRefNo: Text[30];
        CompanyInfo: Record "Company Information";

        RunningBalance: Decimal;

        RunningBalance2: Decimal; // VI 1883
}