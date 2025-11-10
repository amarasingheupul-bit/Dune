pageextension 50106 JobCardS365 extends "Job Card"
{
    layout
    {
        addlast(General)
        {
            field("Use as TemplateS365"; Rec."Use as TemplateS365")
            {
                ApplicationArea = All;
                ToolTip = 'Specify if the job is use as a template';
            }
            field("Quote Type S365"; Rec."Quote Type S365")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Quote Type field.';
                TableRelation = "Quote Type S365"."Code S365";
            }
            field(DateFormulav; DateFormula)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date formula to calculate As of Date fields.';
            }
        }
        // modify("Total WIP Sales Amount")
        // {
        //     Caption = 'Unrecognized Sales';
        // }
        // modify("Total WIP Cost Amount")
        // {
        //     Visible = false;
        // }
        modify("WIP and Recognition")
        {
            Visible = false;
        }
        addafter("Total WIP Sales Amount")
        {
            field("4HC Recog. Costs Amount"; Rec."4HC Recog. Costs Amount")
            {
                ApplicationArea = All;
                Caption = 'Recong. Costs Amount';
                ToolTip = 'Specifies the value of the 4HC Recog. Costs Amount field.';
                Visible = false;
            }
            field("4HC Recog. Profit Amount"; Rec.CalcRecognizedProfitAmount4HC())
            {
                ApplicationArea = Jobs;
                Caption = 'Recog. Profit Amount';
                ToolTip = 'Specifies the recognized profit amount for the project.';
                Visible = false;
            }
        }
        addafter("WIP and Recognition")
        {
            group("Project Summary")
            {
                Caption = 'Project Summary';
                Editable = false;

                group("As of Date")
                {
                    field(Advance; Rec.Advance)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Advance field.';
                    }
                    field("Revenue As of Date"; Rec."Revenue As of Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Revenue (As of Date) field.';
                    }
                    field("Cost of Sales As of Date"; Rec."Cost of Sales As of Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cost of Sales (As of Date) field.';
                    }
                    field("GP As of Date"; Rec."GP As of Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GP (As of Date) field.';
                    }
                    field("GP % As of Date"; Rec."GP % As of Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GP % (As of Date) field.';
                    }
                    field("WIP As of Date"; Rec."WIP As of Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the WIP Provision (As of Date) field.';
                    }
                    field("Provision for Costs"; Rec."Provision for Costs")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Provision for Costs field.';
                        Editable = false;
                    }
                    field("Interim As of Date"; Rec."Interim As of Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Interim (As of Date) field.';
                    }
                }

                group(Cummulative)
                {
                    field("Revenue Cumulative"; Rec."Revenue Cumulative")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Revenue Cumulative field.';
                    }

                    field("Cost of Sales Cumulative"; Rec."Cost of Sales Cumulative")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cost of Sales Cumulative field.';
                    }

                    field("GP Cumulative"; Rec."GP Cumulative")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GP Cumulative field.';
                    }

                    field("GP % Cumulative"; Rec."GP % Cumulative")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the GP % Cumulative field.';
                    }

                    field("WIP Cumulative"; Rec."WIP Cumulative")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the WIP Cumulative field.';
                    }

                    field("Interim Cumulative"; Rec."Interim Cumulative")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Interim Cumulative field.';
                    }
                }
            }
        }
        // modify("Recog. Costs Amount")
        // {
        //     Visible = false;
        // }
        // modify("Recog. Profit Amount")
        // {
        //     Visible = false;
        // }
        addafter(General)
        {
            group("New Fields S365")
            {
                ShowCaption = true;
                Caption = 'Additional Order Details';
                Editable = false;
                Visible = false;

                field("Change Reason S365"; Rec."Change Reason S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Change Reason field.';
                }
                field("Original Quote No. S365"; Rec."Original Quote No. S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Original Quote No. field.';
                }
                field(ConfirmedS365; Rec.ConfirmedS365)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value for confirmed qoutes';
                }
                field("Quote Status S365"; Rec."Quote Status S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quote Status field.';
                }
                field("End User/ Main Customer"; Rec."End User/ Main Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End User field.';
                }
                field("Supplier to Services"; Rec."Supplier to Services")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Supplier to Services field.';
                }

                field("Sales Derector/ Area Director"; Rec."Sales Director/ Area Director")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Derector/ Area Director field.';
                }
                field("Sales/ Area Director Name"; Rec."Sales/ Area Director Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales/ Area Director Name field.';
                    Editable = false;
                }
                field("Sales Secretary No."; Rec."Sales Secretary No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Secretary No. field.';
                }
                field("Sales Secretary Name"; Rec."Sales Secretary Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Secretary Name field.';
                }
                field("Yard No."; Rec."Yard No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Yard No. field.';
                }
                field("Milestones Dates and Amounts"; Rec."Milestones Dates and Amounts")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Milestones with Dates and Amounts field.';
                }
                field("Sales Area"; Rec."Sales Area")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Area field.';
                }
                field("4HC Type"; Rec."4HC Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("COST Reference"; Rec."COST Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the COST Reference field.';
                }
                field("Cost Center"; Rec."Cost Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cost Center field.';
                }
                field(Budget; Rec.Budget)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Budget field.';
                }
                field("G/L Account"; Rec."G/L Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the G/L Account field.';
                }
                field("Incoming PO"; Rec."Incoming PO")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Incoming PO field.';
                }
                field("OPCO Customer"; Rec."OPCO Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OPCO Customer field.';
                }
                field("Sales Manager"; Rec."Sales Manager")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Manager field.';
                }
            }
        }
    }
    actions
    {
        addafter("WIP &G/L Entries")
        {
            action(CalculateProjectSummary)
            {
                Caption = 'Calculate Project Summary';
                ApplicationArea = Jobs;
                ToolTip = 'Calculate Project Summary fields.';
                Image = CalculateBalanceAccount;
                trigger OnAction()
                var
                    Job: Record Job;
                    JobCalculateWIP: Report "Job Calculate WIP";
                begin
                    Rec.TestField(Rec."No.");
                    Job.Copy(Rec);
                    Job.SetRange("No.", Rec."No.");
                    JobCalculateWIP.SetTableView(Job);
                    JobCalculateWIP.Run();
                    Commit();
                    REPORT.RunModal(REPORT::"Job Post WIP to G/L", true, false, Job);
                    CalculateProjectSummaryFields(Rec."No.");
                    Message('Under Development %1', DateFormula);
                end;
            }

        }
        addlast(Category_Category5)
        {
            actionref(CalculateProjectSummary_Promotedc; CalculateProjectSummary)
            {
            }
        }
    }
    var

        DateFormula: Text;

    local procedure CalculateProjectSummaryFields(ProjectNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
        JobSetup: Record "Jobs Setup";
        CurrentYearStart: Date;
        LastYearEnd: Date;
        LastYearLastDayLbl: Label '<-CY-1D>';
        CurrentYearFirstDayLbl: Label '<-CY>';
    begin
        JobSetup.Get();
        GLEntry.Reset();
        GLEntry.SetRange("Job No.", ProjectNo);
        GLEntry.SetRange("G/L Account No.", JobSetup."Advance Acc. No.");
        GLEntry.CalcSums("Amount");
        Rec.Advance := GLEntry."Amount";

        CurrentYearStart := CalcDate(CurrentYearFirstDayLbl, Today());
        LastYearEnd := CalcDate(LastYearLastDayLbl, Today());

        //Revenue As of Date
        GLEntry.Reset();
        GLEntry.SetLoadFields(Amount);
        GLEntry.SetRange("Job No.", ProjectNo);
        GLEntry.SetRange("G/L Account No.", JobSetup."Revenue Acc. No.");
        GLEntry.SetRange("Posting Date", CurrentYearStart, Today());
        GLEntry.CalcSums("Amount");
        Rec."Revenue As of Date" := GLEntry."Amount";

        //Revenue Cummulative
        GLEntry.SetRange("Posting Date");
        GLEntry.SetFilter("Posting Date", '..%1', LastYearEnd);
        GLEntry.CalcSums("Amount");
        Rec."Revenue Cumulative" := GLEntry."Amount";

        //Cost of Sales As of Date
        GLEntry.Reset();
        GLEntry.SetLoadFields(Amount);
        GLEntry.SetRange("Job No.", ProjectNo);
        GLEntry.SetRange("G/L Account No.", JobSetup."Cost of Sales Acc. No.");
        GLEntry.SetRange("Posting Date", CurrentYearStart, Today());
        GLEntry.CalcSums("Amount");
        Rec."Cost of Sales As of Date" := GLEntry."Amount";

        //Cost of Sales Cummulative
        GLEntry.SetRange("Posting Date");
        GLEntry.SetFilter("Posting Date", '..%1', LastYearEnd);
        GLEntry.CalcSums("Amount");
        Rec."Cost of Sales Cumulative" := GLEntry."Amount";
        Rec.Modify(true);
    end;
}

