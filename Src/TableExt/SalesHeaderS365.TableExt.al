tableextension 50100 "Sales Header S365" extends "Sales Header"
{
    fields
    {
        field(50102; "Quote Type S365"; Code[10])
        {
            Caption = 'Quote Type';
            DataClassification = CustomerContent;
            TableRelation = "Quote Type S365"."Code S365";
        }
        field(50103; "Change Reason S365"; Code[10])
        {
            Caption = 'Change Reason';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code".Code;
        }
        field(50105; "Original Quote No. S365"; Code[20])
        {
            Caption = 'Original Quote No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50106; "Amend & Archived S365"; Boolean)
        {
            Caption = 'Amend & Archived';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50107; "ConfirmedS365"; Boolean)
        {
            Caption = 'Confirmed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50109; "Quote Status S365"; Enum "Qoute Status S365")
        {
            DataClassification = CustomerContent;
            Caption = 'Quote Status';
        }
        field(50108; "Job TemplateS365"; Code[20])
        {
            Caption = 'Job No. Template';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50117; "Job No. S365"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Job No';
            Editable = false;
        }
        field(50122; "Sales Director/ Area Director"; Code[20])
        {
            DataClassification = ToBeClassified;
            //TableRelation = "Dimension".Code where(Blocked = const(false));
            //TableRelation = "Dimension Value".Code where("Global Dimension No."=const(7), Blocked=const(false));
            TableRelation = "Salesperson/Purchaser".Code;
            Caption = 'Sales Director/ Area Director';
            trigger OnValidate()
            var
                Salesperson: Record "Salesperson/Purchaser";
            begin
                if Salesperson.Get("Sales Director/ Area Director") then
                    "Sales/ Area Director Name" := Salesperson.Name
                else
                    "Sales/ Area Director Name" := '';
            end;
        }
        field(50132; "Sales/ Area Director Name"; Text[100])
        {
            Caption = 'Sales/ Area Director Name';
        }
        field(50133; "Sales Secretary No."; Code[20])
        {
            Caption = 'Sales Secretary No.';
            TableRelation = "Salesperson/Purchaser".Code;
            trigger OnValidate()
            var
                Salesperson: Record "Salesperson/Purchaser";
            begin
                if Salesperson.Get("Sales Secretary No.") then
                    "Sales Secretary Name" := Salesperson.Name
                else
                    "Sales Secretary Name" := '';
            end;
        }
        field(50134; "Sales Secretary Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Sales Secretary Name';
        }
        field(50123; "Sales Contract No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Sales Contract No.';
        }
        field(50124; "Sales Contract Desc"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Sales Contract Description';
        }
        field(50125; "Yard No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Yard No.';
        }
        field(50126; "Milestones Dates and Amounts"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Milestones with Dates and Amounts';
        }
        field(50127; "End User/ Main Customer"; Text[100])
        {
            Caption = 'End User';
            DataClassification = ToBeClassified;
        }
        field(50128; "Group Customer with One Stream"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Group Customer with One Stream Code';
            TableRelation = Customer;
            ObsoleteState = Pending;
            ObsoleteTag = '4HC25710';
            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get("Group Customer with One Stream") then
                    "Group Customr Name" := Customer.Name
                else
                    "Group Customr Name" := '';
            end;
        }
        field(50131; "Group Customr Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Group Customr Name';
            ObsoleteState = Pending;
            ObsoleteTag = '4HC25710';
        }
        field(50129; "Supplier to Services"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor;
            Caption = 'Supplier to Services';
        }
        field(50130; "Sales Area"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Sales Area';
            // CaptionClass = '1,2,3';
            // Caption = 'Shortcut Dimension 1 Code';
            //    TableRelation = "Dimension".Code where(Blocked = const(false));
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(6), Blocked = const(false));
        }
        field(50135; "Cost Center"; Text[100])
        {
            Caption = 'Cost Center';
        }
        field(50136; "Budget"; Decimal)
        {
            Caption = 'Budget';
            DataClassification = ToBeClassified;
        }
        field(50137; "Service Provider No."; Code[20])
        {
            Caption = 'Service Provider No';
            DataClassification = ToBeClassified;
        }
        field(50138; "Sales Manager"; Code[20])
        {
            Caption = 'Sales Manager';
            DataClassification = ToBeClassified;
        }
        field(50140; "Bank Details"; Text[100])
        {
            Caption = 'Bank Details';
            DataClassification = ToBeClassified;
            TableRelation = "Bank Account";
        }
        field(50100; "4HC Type"; Text[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Type';
        }
        field(50101; "OPCO Customer"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'OPCO Customer';
        }
        field(50104; "COST Reference"; Text[30])
        {
            Caption = 'COST Reference';
        }
        field(50110; "G/L Account"; Text[30])
        {
            Caption = 'G/L Account';
        }
        field(50111; "Incoming PO"; Text[30])
        {
            Caption = 'Incoming PO';
        }
        field(50112; "Invoice Type Code"; Code[20])
        {
            Caption = 'Invoice Type Code';
            TableRelation = "Dimension Value".Code
                WHERE("Dimension Code" = CONST('INVOICETYPECODE'));
        }
        field(50113; "Registration identifier type"; Code[20])
        {
            Caption = 'Seller legal registration identifier type';
            TableRelation = "Dimension Value".Code
                WHERE("Dimension Code" = CONST('REGID'));
        }
        field(50114; "Country Sub-division"; Code[20])
        {
            Caption = 'Country Sub-division';
            TableRelation = "Dimension Value".Code
                WHERE("Dimension Code" = CONST('COUNTRYSUBDIV'));
        }
        field(50115; "Allowance/Charge Identity code"; Code[20])
        {
            Caption = 'Allowance or charge identification code';
            TableRelation = "Dimension Value".Code
                WHERE("Dimension Code" = CONST('ALLOWANCE/CHARGE'));
        }
        field(50116; "AE VAT category codes"; Code[20])
        {
            Caption = 'AE VAT category codes';
            TableRelation = "Dimension Value".Code
                WHERE("Dimension Code" = CONST('AE_VAT_CATCODES'));
        }
        field(50118; "Reasons for exemption from tax"; Text[50])
        {
            Caption = 'Reasons for exemption from tax';
            TableRelation = "Dimension Value".Code
                WHERE("Dimension Code" = CONST('REASONTAX'));

        }
        field(50119; "Is Free Trade Zone Supply"; Option)
        {
            Caption = 'Is Free Trade Zone Supply';
            OptionMembers = " ",Yes,No;
        }
        field(50120; "Is Deemed Supply"; Option)
        {
            Caption = 'Is Deemed Supply';
            OptionMembers = " ",Yes,No;
        }
        field(50121; "Is Profit Margin Scheme applicable"; Option)
        {
            Caption = 'Is Profit Margin Scheme applicable';
            OptionMembers = " ",Yes,No;
        }
        field(50141; "Is Summary Invoice"; Option)
        {
            Caption = 'Is Summary Invoice';
            OptionMembers = " ",Yes,No;
        }
        field(50142; "Is Continuous Supply"; Option)
        {
            Caption = 'Is Continuous Supply';
            OptionMembers = " ",Yes,No;
        }
        field(50143; "Is Agent Billing applicable"; Option)
        {
            Caption = 'Is Agent Billing applicable';
            OptionMembers = " ",Yes,No;
        }
        field(50144; "Is Supply through E-commerce"; Option)
        {
            Caption = 'Is Supply through E-commerce';
            OptionMembers = " ",Yes,No;
        }
        field(50145; "Is Exports Supply"; Option)
        {
            Caption = 'Is Exports Supply';
            OptionMembers = " ",Yes,No;
        }
        field(50146; "Credit Note Reason Code S365"; Code[10])
        {
            Caption = 'Credit Note Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code".Code;
        }
        field(50147; "Frequency of Billing S365"; Code[20])
        {
            Caption = 'Frequency of Billing';
            DataClassification = CustomerContent;
        }
        field(50148; "Invoice Note S365"; Text[250])
        {
            Caption = 'Invoice Note';
            DataClassification = CustomerContent;
        }
        field(50149; "Preceding Invoice Ref. S365"; Code[20])
        {
            Caption = 'Preceding Invoice Reference';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50150; "Preceding Invoice Date S365"; Date)
        {
            Caption = 'Preceding Invoice Issue Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50151; "Tax Accounting Currency S365"; Code[10])
        {
            Caption = 'Tax Accounting Currency';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(50152; "Invoicing Period Start S365"; Date)
        {
            Caption = 'Invoicing Period Start Date';
            DataClassification = CustomerContent;
        }
        field(50153; "Invoicing Period End S365"; Date)
        {
            Caption = 'Invoicing Period End Date';
            DataClassification = CustomerContent;
        }
        field(50154; "Sales Order Reference S365"; Code[20])
        {
            Caption = 'Sales Order Reference';
            DataClassification = CustomerContent;
        }
        field(50155; "Buyer Int. Acct. Ref. S365"; Text[50])
        {
            Caption = 'Buyer Internal Accounting Reference';
            DataClassification = CustomerContent;
        }
        field(50156; "Contract Value S365"; Decimal)
        {
            Caption = 'Contract Value';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(50157; "Receiving Advice Ref. S365"; Code[20])
        {
            Caption = 'Receiving Advice Reference';
            DataClassification = CustomerContent;
        }
        field(50158; "Despatch Advice Ref. S365"; Code[20])
        {
            Caption = 'Despatch Advice Reference';
            DataClassification = CustomerContent;
        }
        field(50159; "Tender Or Lot Reference S365"; Text[50])
        {
            Caption = 'Tender Or Lot Reference';
            DataClassification = CustomerContent;
        }
        field(50160; "Customs Reference No. S365"; Text[50])
        {
            Caption = 'Customs Reference Number';
            DataClassification = CustomerContent;
        }
        field(50161; "VAT Exemption Reason S365"; Text[250])
        {
            Caption = 'VAT Exemption Reason Text';
            DataClassification = CustomerContent;
        }
        field(50162; "Rounding Amount S365"; Decimal)
        {
            Caption = 'Rounding Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(50163; "Payment Terms Amount S365"; Decimal)
        {
            Caption = 'Payment Terms Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(50164; "Terms Payment Instr. ID S365"; Code[20])
        {
            Caption = 'Terms Payment Instructions ID';
            DataClassification = CustomerContent;
        }
        field(50165; "Terms Installment Due S365"; Date)
        {
            Caption = 'Terms Installment Due Date';
            DataClassification = CustomerContent;
        }
        field(50166; "Payment Instructions ID S365"; Code[20])
        {
            Caption = 'Payment Instructions ID';
            DataClassification = CustomerContent;
        }
        field(50167; "Delivery Incoterms S365"; Code[10])
        {
            Caption = 'Delivery Incoterms';
            DataClassification = CustomerContent;
        }
        field(50168; "VAT Tax Point Date S365"; Date)
        {
            Caption = 'VAT Tax Point Date';
            DataClassification = CustomerContent;
        }
        field(50169; "Principle ID S365"; Code[20])
        {
            Caption = 'Principle ID';
            DataClassification = CustomerContent;
        }
        field(50170; "Invoiced Object ID S365"; Code[20])
        {
            Caption = 'Invoiced Object Identifier';
            DataClassification = CustomerContent;
        }
        field(50171; "Invoiced Object ID Scheme S365"; Code[20])
        {
            Caption = 'Invoiced Object Identifier Scheme Identifier';
            DataClassification = CustomerContent;
        }
        field(50172; "Remittance Information S365"; Text[100])
        {
            Caption = 'Remittance Information';
            DataClassification = CustomerContent;
        }
        field(50173; "Remittance Info Scheme S365"; Code[20])
        {
            Caption = 'Remittance Information Scheme Identifier';
            DataClassification = CustomerContent;
        }
        field(50174; "Supporting Doc. Ref. S365"; Code[20])
        {
            Caption = 'Supporting Document Reference';
            DataClassification = CustomerContent;
        }
        field(50175; "Supporting Doc. Desc. S365"; Text[100])
        {
            Caption = 'Supporting Document Description';
            DataClassification = CustomerContent;
        }


    }
}
